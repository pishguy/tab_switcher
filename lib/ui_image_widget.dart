import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Renders [ui.Image] data faster than encoding and displaying in [Image.memory].
class UiImageWidget extends StatelessWidget {
  const UiImageWidget({
    super.key,
    required this.image,
    this.fit = BoxFit.fill,
  });

  final ui.Image image;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _UiImageWidgetPainter(image, fit),
    );
  }
}

class _UiImageWidgetPainter extends CustomPainter {
  const _UiImageWidgetPainter(this.image, this.fit);

  final ui.Image image;
  final BoxFit fit;

  @override
  void paint(Canvas canvas, Size size) {
    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final sizes = applyBoxFit(fit, imageSize, size);
    final inputSubrect = Alignment.center.inscribe(sizes.source, Offset.zero & imageSize);
    final outputSubrect = Alignment.center.inscribe(sizes.destination, Offset.zero & size);

    canvas.drawImageRect(
      image,
      inputSubrect,
      outputSubrect,
      Paint(),
    );
  }

  @override
  bool shouldRepaint(_UiImageWidgetPainter oldDelegate) => image != oldDelegate.image;

  @override
  bool shouldRebuildSemantics(_UiImageWidgetPainter oldDelegate) => false;
}
