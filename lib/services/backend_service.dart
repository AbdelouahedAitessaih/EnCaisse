import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class BackendCallException implements Exception {
  const BackendCallException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'BackendCallException($code): $message';
}

/// Calls authenticated Firebase callable functions using the callable wire
/// protocol. This avoids exposing privileged Firestore writes to clients.
class BackendService {
  BackendService({FirebaseAuth? auth, http.Client? client})
    : _auth = auth ?? FirebaseAuth.instance,
      _client = client ?? http.Client();

  final FirebaseAuth _auth;
  final http.Client _client;

  /// Whole-call budget. The ID-token refresh that precedes the POST is a
  /// platform-channel call that can stall indefinitely when Play Services is
  /// unhealthy, so it has to sit inside the same budget as the request —
  /// otherwise the caller spins forever with no error and no way out.
  static const Duration _callTimeout = Duration(seconds: 25);

  /// Callables whose writes are keyed by a client-chosen id, so replaying the
  /// request cannot produce a second record. These are safe to retry once.
  /// createGroup, deleteGroup and deleteAccount are deliberately absent: the
  /// first would mint a second group and the other two re-run destructive
  /// sweeps, so an automatic replay there could do real damage.
  static const Set<String> _retryableOnce = {
    'joinGroup',
    'createMovement',
    'updateMovement',
    'softDeleteMovement',
    'undoSoftDelete',
    'recordSettlement',
    'confirmSettlement',
    'cancelSettlement',
  };

  Future<Map<String, dynamic>> call(
    String name,
    Map<String, dynamic> data, {
    Duration? timeout,
  }) async {
    final budget = timeout ?? _callTimeout;
    final retryable = _retryableOnce.contains(name);
    // A first-generation function that has been idle needs to boot a new
    // instance, and that can overrun the interactive budget. It surfaces as
    // `unavailable`, which reads to the user as a dead connection when the
    // network is in fact fine. One retry after a short pause absorbs the cold
    // start without lengthening the wait in the common case.
    for (var attempt = 0; ; attempt++) {
      try {
        return await _call(name, data).timeout(budget);
      } on TimeoutException {
        if (attempt == 0 && retryable) {
          await Future<void>.delayed(const Duration(seconds: 3));
          continue;
        }
        throw const BackendCallException(
          'deadline-exceeded',
          'The server took too long to answer. Check your connection and try again.',
        );
      } on BackendCallException catch (e) {
        if (attempt == 0 &&
            retryable &&
            (e.code == 'unavailable' || e.code == 'deadline-exceeded')) {
          await Future<void>.delayed(const Duration(seconds: 3));
          continue;
        }
        rethrow;
      }
    }
  }

  Future<Map<String, dynamic>> _call(
    String name,
    Map<String, dynamic> data,
  ) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const BackendCallException('unauthenticated', 'Sign in required.');
    }
    final projectId = Firebase.app().options.projectId;
    if (projectId.isEmpty) {
      throw const BackendCallException(
        'failed-precondition',
        'Firebase project is not configured.',
      );
    }

    final idToken = await user.getIdToken();
    if (idToken == null || idToken.isEmpty) {
      throw const BackendCallException('unauthenticated', 'Refresh sign-in.');
    }
    final uri = Uri.https('us-central1-$projectId.cloudfunctions.net', name);
    try {
      final response = await _client.post(
        uri,
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'data': data}),
      );

      Map<String, dynamic> envelope;
      try {
        final decoded = jsonDecode(response.body);
        envelope = decoded is Map<String, dynamic>
            ? decoded
            : <String, dynamic>{};
      } catch (e) {
        debugPrint('Callable $name returned invalid JSON: $e');
        throw BackendCallException(
          'internal',
          'The server returned an invalid response (${response.statusCode}).',
        );
      }

      final error = envelope['error'];
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          error is Map) {
        final errorMap = error is Map ? error : const <String, dynamic>{};
        throw BackendCallException(
          '${errorMap['status'] ?? 'unavailable'}'.toLowerCase().replaceAll(
            '_',
            '-',
          ),
          '${errorMap['message'] ?? 'Server request failed.'}',
        );
      }

      final result = envelope['result'] ?? envelope['data'];
      if (result is Map<String, dynamic>) return result;
      return <String, dynamic>{};
    } on SocketException {
      throw BackendCallException(
        'unavailable',
        'No internet connection. Please check your network and try again.',
      );
    } on HttpException {
      throw BackendCallException(
        'unavailable',
        'Network request failed. Please try again.',
      );
    } on HandshakeException {
      throw BackendCallException(
        'unavailable',
        'Unable to connect securely to the server. Please try again.',
      );
    } on TimeoutException {
      rethrow;
    } on BackendCallException {
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error in BackendService.call ($name): $e');
      throw BackendCallException(
        'internal',
        'Something went wrong. Please try again.',
      );
    }
  }
}
