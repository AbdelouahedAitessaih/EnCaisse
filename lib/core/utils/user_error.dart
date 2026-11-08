import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

import '../../services/backend_service.dart';

/// Maps a thrown error to text a person can act on.
///
/// Anything that reaches here is unexpected, so it also gets logged: the user
/// sees a readable message, the developer keeps the type and payload.
String userFacingError(Object error) {
  if (error is BackendCallException) return error.message;

  if (error is TimeoutException) {
    debugPrint('userFacingError: timed out -> $error');
    return 'The server took too long to answer. Check your connection and try again.';
  }

  if (error is PlatformException) {
    debugPrint('userFacingError: platform ${error.code} -> ${error.message}');
    final message = error.message;
    if (message != null && message.trim().isNotEmpty) return message;
    return 'This action is not available on this device right now.';
  }

  if (error is SocketException || error is HttpException) {
    debugPrint('userFacingError: network -> $error');
    return 'No internet connection. Please check your network and try again.';
  }

  if (error is FirebaseException) {
    // Raw Firebase messages are English-only and can embed the account email,
    // so the codes people actually hit get a readable line first.
    switch (error.code) {
      case 'permission-denied':
        return 'You do not have access to this. Ask the owner for an invite.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network and try again.';
      case 'unavailable':
        // The device was online in this case: the backend was unreachable or
        // overloaded, so blaming the connection sends people to the wrong fix.
        return 'The service is temporarily unavailable. Please try again.';
      case 'deadline-exceeded':
        return 'The server took too long to answer. Please try again.';
      case 'not-found':
        return 'This item no longer exists.';
      case 'unauthenticated':
      case 'requires-recent-login':
        return 'Your session expired. Please sign in again.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
    }
    if (error.message?.isNotEmpty == true) return error.message!;
  }

  debugPrint('userFacingError: unhandled ${error.runtimeType}');
  final message = error.toString();
  if (message.startsWith('Exception: ')) return message.substring(11);
  return 'Something went wrong. Please try again.';
}
