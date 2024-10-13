import 'package:flutter/material.dart';
import 'package:raw_components/src/button/raw_button_size.dart';

@immutable
class RawButtonStyle {
  /// Create a [ButtonStyle].
  const RawButtonStyle({
    this.backgroundColor,
    this.foregroundColor,
    this.overlayColor,
    this.shape,
    this.side,
    this.loadingColor,
    this.animationDuration = const Duration(milliseconds: 200),
    this.splashFactory = InkSparkle.splashFactory,
  });

  /// The button's background fill color.
  final WidgetStateProperty<Color?>? backgroundColor;

  /// The color for the button's [Text] and [Icon] widget descendants.
  ///
  /// This color is typically used instead of the color of the [RawButtonSize.textStyle]. All
  /// of the components that compute defaults from [ButtonStyle] values
  /// compute a default [foregroundColor] and use that instead of the
  /// [RawButtonSize.textStyle]'s color.
  final WidgetStateProperty<Color?>? foregroundColor;

  /// The highlight color that's typically used to indicate that
  /// the button is focused, hovered, or pressed.
  final WidgetStateProperty<Color?>? overlayColor;

  /// The shape of the button's underlying [Material].
  ///
  final WidgetStateProperty<BorderSide?>? side;

  /// The shape of the button's underlying [Material].
  ///
  final OutlinedBorder? shape;

  /// Creates the [InkWell] splash factory, which defines the appearance of
  /// "ink" splashes that occur in response to taps.
  ///
  /// Use [NoSplash.splashFactory] to defeat ink splash rendering. For example:
  /// ```dart
  /// ElevatedButton(
  ///   style: ElevatedButton.styleFrom(
  ///     splashFactory: NoSplash.splashFactory,
  ///   ),
  ///   onPressed: () { },
  ///   child: const Text('No Splash'),
  /// )
  /// ```
  final InteractiveInkFeatureFactory splashFactory;

  final Duration animationDuration;

  final Color? loadingColor;
}
