import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/image_picker_utils.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  String? _localPhotoPath;
  String? _remotePhotoUrl;
  bool _loading = false;
  bool _hydrated = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authServiceProvider).repairCurrentProfile();
    });
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _hydrate(String displayName, String? photoUrl) {
    if (_hydrated) return;
    _name.text = displayName;
    _remotePhotoUrl = photoUrl;
    _hydrated = true;
  }

  Future<void> _pickPhoto() async {
    final file = await pickGalleryImage(
      imageQuality: 80,
      maxWidth: 1024,
    );
    if (file != null) {
      setState(() => _localPhotoPath = file.path);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    final l10n = AppLocalizations.of(context);

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Ensure Firestore user doc is complete before update (rules + empty stubs).
      await ref.read(authServiceProvider).repairCurrentProfile();

      var photoUrl = _remotePhotoUrl;
      if (_localPhotoPath != null) {
        photoUrl = await ref.read(storageServiceProvider).uploadUserAvatar(
              uid: user.uid,
              localPath: _localPhotoPath!,
            );
      }

      final displayName = _name.text.trim();
      await ref.read(authServiceProvider).updateProfile(
            uid: user.uid,
            displayName: displayName,
            photoUrl: photoUrl,
          );
      await ref.read(groupServiceProvider).syncMemberProfile(
            uid: user.uid,
            displayName: displayName,
            photoUrl: photoUrl,
          );

      if (mounted) {
        setState(() {
          _remotePhotoUrl = photoUrl;
          _localPhotoPath = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.profileUpdated)),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profile = ref.watch(currentUserProfileProvider).value;
    final user = ref.watch(authStateProvider).value;

    final resolvedName = (profile?.displayName.trim().isNotEmpty == true)
        ? profile!.displayName
        : (user?.displayName?.trim().isNotEmpty == true
            ? user!.displayName!
            : (user?.email?.split('@').first ?? ''));
    final resolvedEmail = (profile?.email.trim().isNotEmpty == true)
        ? profile!.email
        : (user?.email ?? '');
    final resolvedPhoto = profile?.photoUrl ?? user?.photoURL;

    if (!_hydrated && (resolvedName.isNotEmpty || resolvedPhoto != null)) {
      _hydrate(resolvedName, resolvedPhoto);
    }

    final preview = _localPhotoPath != null
        ? FileImage(File(_localPhotoPath!))
        : (_remotePhotoUrl != null && _remotePhotoUrl!.isNotEmpty
            ? NetworkImage(_remotePhotoUrl!)
            : (resolvedPhoto != null && resolvedPhoto.isNotEmpty
                ? NetworkImage(resolvedPhoto)
                : null));

    final initial = resolvedName.isNotEmpty
        ? resolvedName[0].toUpperCase()
        : 'U';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editProfile)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 56,
                        backgroundColor: AppColors.primaryLight,
                        backgroundImage: preview as ImageProvider?,
                        child: preview == null
                            ? Text(
                                initial,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Material(
                          color: AppColors.primary,
                          shape: const CircleBorder(),
                          child: IconButton(
                            tooltip: l10n.changePhoto,
                            onPressed: _loading ? null : _pickPhoto,
                            icon: const Icon(Icons.camera_alt_outlined,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(labelText: l10n.displayName),
                  validator: (v) {
                    if (v == null || v.trim().length < 2) {
                      return l10n.enterName;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: resolvedEmail,
                  enabled: false,
                  decoration: InputDecoration(labelText: l10n.email),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(_error!, style: const TextStyle(color: AppColors.error)),
                ],
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _loading ? null : _save,
                  child: _loading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(l10n.save),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
