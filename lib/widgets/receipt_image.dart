import 'dart:io';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import 'authorized_image.dart';

bool isRemoteImageUrl(String url) =>
    url.startsWith('http://') ||
    url.startsWith('https://') ||
    url.startsWith('storage://');

class ReceiptImage extends StatelessWidget {
  const ReceiptImage({
    super.key,
    required this.url,
    this.height = 180,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  final String url;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppRadii.sm);
    final image = isRemoteImageUrl(url)
        ? AuthorizedImage(
            url: url,
            height: height,
            width: double.infinity,
            fit: fit,
            errorBuilder: (context, error) => _ReceiptPlaceholder(
              height: height,
              child: const Icon(Icons.broken_image_outlined),
            ),
          )
        : Image.file(
            File(url),
            height: height,
            width: double.infinity,
            fit: fit,
            errorBuilder: (_, _, _) => _ReceiptPlaceholder(
              height: height,
              child: const Icon(Icons.broken_image_outlined),
            ),
          );

    return ClipRRect(
      borderRadius: radius,
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        child: InkWell(
          onTap: () => showReceiptViewer(context, url),
          child: image,
        ),
      ),
    );
  }
}

class _ReceiptPlaceholder extends StatelessWidget {
  const _ReceiptPlaceholder({required this.child, this.height});

  final Widget child;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 180,
      width: double.infinity,
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Center(child: child),
      ),
    );
  }
}

void showReceiptViewer(BuildContext context, String url) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          body: Center(
            child: InteractiveViewer(
              child: isRemoteImageUrl(url)
                  ? AuthorizedImage(
                      url: url,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _) => const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white70,
                        size: 48,
                      ),
                    )
                  : Image.file(
                      File(url),
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white70,
                        size: 48,
                      ),
                    ),
            ),
          ),
        );
      },
    ),
  );
}
