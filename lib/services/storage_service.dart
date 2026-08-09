import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  StorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  Future<String> uploadUserAvatar({
    required String uid,
    required String localPath,
  }) {
    return _upload(
      path: 'users/$uid/avatar.jpg',
      localPath: localPath,
    );
  }

  Future<String> uploadGroupImage({
    required String groupId,
    required String localPath,
  }) {
    return _upload(
      path: 'groups/$groupId/cover.jpg',
      localPath: localPath,
    );
  }

  Future<String> uploadReceipt({
    required String groupId,
    required String localPath,
  }) {
    final id = DateTime.now().millisecondsSinceEpoch;
    return _upload(
      path: 'groups/$groupId/receipts/$id.jpg',
      localPath: localPath,
    );
  }

  Future<String> _upload({
    required String path,
    required String localPath,
  }) async {
    final ref = _storage.ref(path);
    final metadata = SettableMetadata(contentType: 'image/jpeg');
    if (kIsWeb) {
      throw UnsupportedError('Image upload is not supported on web.');
    }
    await ref.putFile(File(localPath), metadata);
    return ref.getDownloadURL();
  }
}
