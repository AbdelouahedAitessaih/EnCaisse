import 'package:firebase_core/firebase_core.dart';

import '../../services/backend_service.dart';

String userFacingError(Object error) {
  if (error is BackendCallException) return error.message;
  if (error is FirebaseException && error.message?.isNotEmpty == true) {
    return error.message!;
  }
  final message = error.toString();
  if (message.startsWith('Exception: ')) return message.substring(11);
  return 'Something went wrong. Please try again.';
}
