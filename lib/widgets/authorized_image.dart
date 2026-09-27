import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

/// Displays Firebase Storage images through authenticated SDK requests.
/// Existing Firebase download URLs are resolved back to their object path.
class AuthorizedImage extends StatefulWidget {
  const AuthorizedImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.errorBuilder,
  });

  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget Function(BuildContext, Object)? errorBuilder;

  @override
  State<AuthorizedImage> createState() => _AuthorizedImageState();
}

class _AuthorizedImageState extends State<AuthorizedImage> {
  Future<Uint8List?>? _bytes;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant AuthorizedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) _load();
  }

  void _load() {
    final path = _storagePath(widget.url);
    _bytes = path == null
        ? null
        : FirebaseStorage.instance.ref(path).getData(5 * 1024 * 1024);
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _bytes;
    if (bytes == null) {
      return Image.network(
        widget.url,
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
        errorBuilder: (context, error, _) =>
            widget.errorBuilder?.call(context, error) ?? const SizedBox.shrink(),
      );
    }
    return FutureBuilder<Uint8List?>(
      future: bytes,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return widget.errorBuilder?.call(context, snapshot.error!) ??
              const SizedBox.shrink();
        }
        final data = snapshot.data;
        if (data == null) {
          return SizedBox(
            width: widget.width,
            height: widget.height,
            child: const Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        return Image.memory(
          data,
          fit: widget.fit,
          width: widget.width,
          height: widget.height,
          errorBuilder: (context, error, _) =>
              widget.errorBuilder?.call(context, error) ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

String? _storagePath(String url) {
  if (url.startsWith('storage://')) {
    final path = url.substring('storage://'.length);
    return path.isEmpty ? null : path;
  }
  final uri = Uri.tryParse(url);
  if (uri == null ||
      uri.host != 'firebasestorage.googleapis.com' ||
      uri.pathSegments.length < 5 ||
      uri.pathSegments[0] != 'v0' ||
      uri.pathSegments[1] != 'b' ||
      uri.pathSegments[3] != 'o') {
    return null;
  }
  return uri.pathSegments.skip(4).join('/');
}
