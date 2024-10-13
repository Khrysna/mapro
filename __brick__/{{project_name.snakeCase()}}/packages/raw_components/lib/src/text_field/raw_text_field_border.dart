import 'package:flutter/material.dart';

class RawTextFieldBorder {
  const RawTextFieldBorder({
    required this.border,
    this.borderSide,
    this.disabledBorderSide,
    this.errorBorderSide,
    this.focusedBorderSide,
    this.focusedErrorBorderSide,
  });

  final InputBorder border;

  final BorderSide? borderSide;

  final BorderSide? disabledBorderSide;

  final BorderSide? errorBorderSide;

  final BorderSide? focusedBorderSide;

  final BorderSide? focusedErrorBorderSide;
}
