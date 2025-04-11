import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef ImageCaptureCallback = void Function(ui.Image image);

/// Generates image from child widget right before detaching from the widget tree
/// and calls callback with the captured image
class PreviewCapturerWidget extends StatefulWidget {
  const PreviewCapturerWidget({
    Key? key,
    required this.child,
    required this.callback,
    required this.tag,
  }) : super(key: key);

  final Widget child;
  final ImageCaptureCallback callback;
  final String tag;

  @override
  State<PreviewCapturerWidget> createState() => _PreviewCapturerWidgetState();
}

class _PreviewCapturerWidgetState extends State<PreviewCapturerWidget> {
  final GlobalKey _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _key,
      child: widget.child,
    );
  }

  @override
  void deactivate() {
    _captureImage();
    super.deactivate();
  }

  Future<void> _captureImage() async {
    final ro = _key.currentContext?.findRenderObject();
    if (ro is! RenderRepaintBoundary) return;

    var retries = 3;
    while (retries > 0) {
      try {
        final image = await ro.toImage(pixelRatio: 1.5);
        widget.callback(image);
        return;
      } catch (_) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        retries--;
      }
    }
  }
}
