import 'package:flutter/cupertino.dart';

class RawTextFieldCursorStyle {
  const RawTextFieldCursorStyle({
    required this.color,
    required this.cursorErrorColor,
    this.backgroundCursorColor = CupertinoColors.inactiveGray,
    this.cursorOpacityAnimates = false,
    this.height,
    this.radius,
    this.width = 2.0,
  });

  final Color backgroundCursorColor;

  final Color color;

  final Color cursorErrorColor;

  final bool cursorOpacityAnimates;

  final double? height;

  final Radius? radius;

  final double width;
}
