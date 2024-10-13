import 'package:flutter/material.dart';
import 'package:raw_components/src/button/raw_button_style.dart';

class RawButtonSize {
  const RawButtonSize({
    required this.textStyle,
    required this.padding,
  });

  /// The style for a button's [Text] widget descendants.
  ///
  /// The color of the [textStyle] is typically not used directly, the
  /// [RawButtonStyle.foregroundColor] is used instead.
  final TextStyle textStyle;

  /// The padding between the button's boundary and its child.
  final EdgeInsetsGeometry padding;
}
