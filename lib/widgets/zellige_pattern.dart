import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Moroccan zellige-inspired geometric motif — flat teal/coral, no shadows.
class ZelligePattern extends StatelessWidget {
  const ZelligePattern({
    super.key,
    this.size = 200,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _ZelligePainter(),
    );
  }
}

class _ZelligePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final teal = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    final coral = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;
    final light = Paint()
      ..color = AppColors.primaryLight
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.42;

    // Outer octagon-like star via rotated squares
    for (var i = 0; i < 4; i++) {
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(i * 0.785398); // 45°
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: r * 1.2,
        height: r * 1.2,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        i.isEven ? teal : coral,
      );
      canvas.restore();
    }

    // Inner diamond
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(0.785398);
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: r * 0.7, height: r * 0.7),
      light,
    );
    canvas.restore();

    // Center square
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: r * 0.35, height: r * 0.35),
        const Radius.circular(4),
      ),
      teal,
    );

    // Corner tiles
    final tile = size.width * 0.12;
    final positions = [
      Offset(tile, tile),
      Offset(size.width - tile, tile),
      Offset(tile, size.height - tile),
      Offset(size.width - tile, size.height - tile),
    ];
    for (var i = 0; i < positions.length; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: positions[i], width: tile, height: tile),
          const Radius.circular(2),
        ),
        i.isEven ? coral : teal,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
