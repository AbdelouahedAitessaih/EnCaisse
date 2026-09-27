import 'dart:convert';

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

  Future<Map<String, dynamic>> call(
    String name,
    Map<String, dynamic> data,
  ) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const BackendCallException('unauthenticated', 'Sign in required.');
    }
    final projectId = Firebase.app().options.projectId;
    if (projectId == null || projectId.isEmpty) {
      throw const BackendCallException(
        'failed-precondition',
        'Firebase project is not configured.',
      );
    }

    final idToken = await user.getIdToken();
    if (idToken == null || idToken.isEmpty) {
      throw const BackendCallException('unauthenticated', 'Refresh sign-in.');
    }
    final uri = Uri.https(
      'us-central1-$projectId.cloudfunctions.net',
      name,
    );
    final response = await _client
        .post(
          uri,
          headers: {
            'Authorization': 'Bearer $idToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'data': data}),
        )
        .timeout(const Duration(seconds: 30));

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
    if (response.statusCode < 200 || response.statusCode >= 300 ||
        error is Map) {
      final errorMap = error is Map ? error : const <String, dynamic>{};
      throw BackendCallException(
        '${errorMap['status'] ?? 'unavailable'}'
            .toLowerCase()
            .replaceAll('_', '-'),
        '${errorMap['message'] ?? 'Server request failed.'}',
      );
    }

    final result = envelope['result'] ?? envelope['data'];
    if (result is Map<String, dynamic>) return result;
    return <String, dynamic>{};
  }
}
