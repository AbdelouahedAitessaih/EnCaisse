import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/models.dart';

class AuthService {
  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  final GoogleSignIn _googleSignIn;
  bool _googleInitialized = false;

  /// Web OAuth client ID from Firebase / google-services.json (client_type: 3).
  /// Required by google_sign_in 7+ on Android to obtain an ID token for Firebase.
  static const String googleServerClientId =
      '559211214178-b4qj066trj4ide94s31j014l680ad6im.apps.googleusercontent.com';

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    await _googleSignIn.initialize(serverClientId: googleServerClientId);
    _googleInitialized = true;
  }

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  Future<UserProfile> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await cred.user!.updateDisplayName(displayName.trim());
    return _ensureUserProfile(
      cred.user!,
      displayNameOverride: displayName.trim(),
    );
  }

  Future<UserProfile> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return _ensureUserProfile(cred.user!);
  }

  Future<UserProfile> signInWithGoogle() async {
    // Prefer native Google Sign-In; on Android Credential Manager failures
    // (common on some Huawei / older Play Services builds), fall back to
    // Firebase's browser OAuth flow — same path many apps use successfully.
    try {
      return await _signInWithGoogleNative();
    } catch (e, st) {
      debugPrint('Native Google Sign-In failed: $e\n$st');
      if (!_shouldFallbackToBrowserOAuth(e)) rethrow;
      if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) rethrow;
      debugPrint('Falling back to Firebase signInWithProvider (browser OAuth)');
      return _signInWithGoogleBrowser();
    }
  }

  bool _shouldFallbackToBrowserOAuth(Object e) {
    final s = e.toString();
    if (s.contains('GoogleSignInExceptionCode.canceled') &&
        !s.contains('[16]') &&
        !s.contains('reauth') &&
        !s.contains('10:')) {
      // Genuine user cancel — do not open a second browser prompt.
      return false;
    }
    return s.contains('[16]') ||
        s.contains('reauth') ||
        s.contains('google-sign-in-config') ||
        s.contains('missing-id-token') ||
        s.contains('clientConfigurationError') ||
        s.contains('ApiException: 10') ||
        s.contains('10:') ||
        s.contains('GoogleSignInExceptionCode.providerConfigurationError') ||
        s.contains('GoogleSignInExceptionCode.interrupted') ||
        s.contains('GoogleSignInExceptionCode.unknownError') ||
        s.contains('CredentialManager') ||
        s.contains('network_error') ||
        s.contains('NETWORK_ERROR');
  }

  Future<UserProfile> _signInWithGoogleNative() async {
    await _ensureGoogleInitialized();
    try {
      return await _completeGoogleSignInNative();
    } on GoogleSignInException catch (e) {
      final detail = '${e.code} ${e.description ?? ''}';
      debugPrint('GoogleSignInException: $detail');
      // Credential Manager maps many OAuth/SHA misconfigs to "canceled" + [16].
      if (detail.contains('reauth') || detail.contains('[16]')) {
        throw FirebaseAuthException(
          code: 'google-sign-in-config',
          message: 'Google Sign-In configuration error ([16]).',
        );
      }
      rethrow;
    }
  }

  Future<UserProfile> _completeGoogleSignInNative() async {
    final account = await _googleSignIn.authenticate(
      scopeHint: const ['email', 'profile'],
    );
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw FirebaseAuthException(
        code: 'missing-id-token',
        message: 'Google Sign-In missing ID token.',
      );
    }

    String? accessToken;
    try {
      final authz = await account.authorizationClient.authorizationForScopes(
        const ['email', 'profile'],
      );
      accessToken = authz?.accessToken;
      if (accessToken == null) {
        final granted = await account.authorizationClient.authorizeScopes(
          const ['email', 'profile'],
        );
        accessToken = granted.accessToken;
      }
    } catch (e) {
      debugPrint('Google accessToken optional step failed: $e');
    }

    final credential = GoogleAuthProvider.credential(
      idToken: idToken,
      accessToken: accessToken,
    );
    final cred = await _auth.signInWithCredential(credential);
    return _ensureUserProfile(cred.user!);
  }

  Future<UserProfile> _signInWithGoogleBrowser() async {
    final provider = GoogleAuthProvider()
      ..addScope('email')
      ..addScope('profile')
      ..setCustomParameters({'prompt': 'select_account'});
    final cred = await _auth.signInWithProvider(provider);
    return _ensureUserProfile(cred.user!);
  }

  Future<UserProfile> _ensureUserProfile(
    User user, {
    String? displayNameOverride,
  }) async {
    final ref = _users.doc(user.uid);
    final snap = await ref.get();
    final fallbackName = displayNameOverride?.trim().isNotEmpty == true
        ? displayNameOverride!.trim()
        : (user.displayName?.trim().isNotEmpty == true
            ? user.displayName!.trim()
            : (user.email?.split('@').first ?? 'Member'));
    final email = user.email ?? '';

    if (snap.exists) {
      final data = Map<String, dynamic>.from(snap.data()!);
      final existing = UserProfile.fromMap(user.uid, data);
      final repairs = <String, dynamic>{};

      if (existing.displayName.trim().isEmpty) {
        repairs['displayName'] = fallbackName;
      }
      if (existing.email.trim().isEmpty && email.isNotEmpty) {
        repairs['email'] = email;
      }
      if (data['createdAt'] == null) {
        repairs['createdAt'] = Timestamp.fromDate(DateTime.now());
      }
      if (existing.photoUrl == null && user.photoURL != null) {
        repairs['photoUrl'] = user.photoURL;
      }

      if (repairs.isNotEmpty) {
        await ref.set(repairs, SetOptions(merge: true));
        data.addAll(repairs);
      }
      return UserProfile.fromMap(user.uid, data);
    }

    final profile = UserProfile(
      uid: user.uid,
      displayName: fallbackName,
      email: email,
      photoUrl: user.photoURL,
      createdAt: DateTime.now(),
    );
    await ref.set(profile.toMap());
    return profile;
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    final snap = await _users.doc(uid).get();
    if (!snap.exists) return null;
    return UserProfile.fromMap(uid, snap.data()!);
  }

  Stream<UserProfile?> watchUserProfile(String uid) {
    return _users.doc(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      return UserProfile.fromMap(uid, snap.data()!);
    });
  }

  Future<void> updateUserFields(String uid, Map<String, dynamic> fields) {
    return _users.doc(uid).set(fields, SetOptions(merge: true));
  }

  Future<void> updateProfile({
    required String uid,
    required String displayName,
    String? photoUrl,
    bool clearPhotoUrl = false,
  }) async {
    final trimmed = displayName.trim();
    if (trimmed.length < 2) {
      throw ArgumentError('Display name is too short');
    }

    final user = _auth.currentUser;
    final snap = await _users.doc(uid).get();
    final existing = snap.data() ?? <String, dynamic>{};

    final fields = <String, dynamic>{
      'displayName': trimmed,
      if ((existing['email'] as String?)?.trim().isEmpty != false &&
          (user?.email?.isNotEmpty ?? false))
        'email': user!.email,
      if (existing['createdAt'] == null)
        'createdAt': Timestamp.fromDate(DateTime.now()),
      if (clearPhotoUrl)
        'photoUrl': null
      else if (photoUrl != null)
        'photoUrl': photoUrl,
    };
    await _users.doc(uid).set(fields, SetOptions(merge: true));

    if (user != null && user.uid == uid) {
      await user.updateDisplayName(trimmed);
      if (clearPhotoUrl) {
        await user.updatePhotoURL(null);
      } else if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }
    }
  }

  /// Repair profile if FCM/token write created an incomplete user doc first.
  Future<UserProfile?> repairCurrentProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _ensureUserProfile(user);
  }

  Future<void> signOut() async {
    try {
      await _ensureGoogleInitialized();
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
  }
}
