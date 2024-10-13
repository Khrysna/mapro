import 'package:flutter/material.dart';
import 'package:raw_components/src/button/raw_button_size.dart';
import 'package:raw_components/src/button/raw_button_style.dart';

class RawButton extends StatefulWidget {
  const RawButton({
    required this.onPressed,
    required this.enabled,
    required this.buttonSize,
    required this.buttonStyle,
    required this.label,
    required this.isLoading,
    this.prefix,
    super.key,
  });

  final VoidCallback? onPressed;

  final String label;

  final bool enabled;

  final bool isLoading;

  final Widget? prefix;

  final RawButtonSize buttonSize;

  final RawButtonStyle buttonStyle;

  @override
  State<RawButton> createState() => _ButtonStyleState();
}

class _ButtonStyleState extends State<RawButton> with TickerProviderStateMixin {
  AnimationController? controller;
  Color? backgroundColor;
  WidgetStatesController? internalStatesController;

  VoidCallback? get _onPressed => (widget.enabled && !widget.isLoading) ? widget.onPressed : null;

  void handleStatesControllerChange() {
    // Force a rebuild to resolve MaterialStateProperty properties
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  WidgetStatesController get statesController => internalStatesController!;

  void initStatesController() {
    internalStatesController = WidgetStatesController();
    statesController.update(WidgetState.disabled, !widget.enabled);
    statesController.addListener(handleStatesControllerChange);
  }

  @override
  void initState() {
    super.initState();
    initStatesController();
  }

  @override
  void didUpdateWidget(RawButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.enabled != oldWidget.enabled) {
      statesController.update(WidgetState.disabled, !widget.enabled);
      if (!widget.enabled) {
        // The button may have been disabled while a press gesture is currently underway.
        statesController.update(WidgetState.pressed, false);
      }
    }
  }

  @override
  void dispose() {
    statesController.removeListener(handleStatesControllerChange);
    internalStatesController?.dispose();
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    T? resolve<T>(WidgetStateProperty<T>? Function(RawButtonStyle style) getProperty) {
      return getProperty(widget.buttonStyle)?.resolve(statesController.value);
    }

    var resolvedBackgroundColor = resolve<Color?>(
      (RawButtonStyle style) => style.backgroundColor,
    );
    final resolvedForegroundColor = resolve<Color?>(
      (RawButtonStyle style) => style.foregroundColor,
    );
    final resolvedSide = resolve<BorderSide?>((RawButtonStyle style) => style.side);
    final overlayColor = WidgetStateProperty.resolveWith<Color?>(
      (Set<WidgetState> states) => widget.buttonStyle.overlayColor?.resolve(states),
    );
    final resolvedAnimationDuration = widget.buttonStyle.animationDuration;

    // If an opaque button's background is becoming translucent while its
    // elevation is changing, change the elevation first. Material implicitly
    // animates its elevation but not its color. SKIA renders non-zero
    // elevations as a shadow colored fill behind the Material's background.
    if (resolvedAnimationDuration > Duration.zero &&
        backgroundColor != null &&
        backgroundColor!.value != resolvedBackgroundColor!.value &&
        backgroundColor!.opacity == 1 &&
        resolvedBackgroundColor.opacity < 1) {
      if (controller?.duration != resolvedAnimationDuration) {
        controller?.dispose();
        controller = AnimationController(
          duration: resolvedAnimationDuration,
          vsync: this,
        )..addStatusListener((AnimationStatus status) {
            if (status == AnimationStatus.completed) {
              setState(() {}); // Rebuild with the final background color.
            }
          });
      }

      resolvedBackgroundColor = backgroundColor; // Defer changing the background color.
      controller!.value = 0;
      controller!.forward();
    }
    backgroundColor = resolvedBackgroundColor;

    Widget content;

    if (widget.isLoading) {
      content = _Loading(
        textStyle: widget.buttonSize.textStyle,
        color: widget.buttonStyle.loadingColor ?? resolvedForegroundColor,
      );
    } else {
      content = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.prefix != null) ...{
            widget.prefix!,
          },
          Text.rich(
            TextSpan(text: widget.label),
            textHeightBehavior: const TextHeightBehavior(
              applyHeightToFirstAscent: false,
            ),
          ),
        ],
      );
    }

    return Material(
      textStyle: widget.buttonSize.textStyle.copyWith(color: resolvedForegroundColor),
      shape: widget.buttonStyle.shape?.copyWith(side: resolvedSide),
      color: resolvedBackgroundColor,
      type: resolvedBackgroundColor == null ? MaterialType.transparency : MaterialType.button,
      animationDuration: resolvedAnimationDuration,
      child: InkWell(
        onTap: _onPressed,
        splashFactory: widget.buttonStyle.splashFactory,
        overlayColor: overlayColor,
        customBorder: widget.buttonStyle.shape?.copyWith(side: resolvedSide),
        statesController: statesController,
        child: Padding(
          padding: widget.buttonSize.padding,
          child: content,
        ),
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading({
    required this.textStyle,
    required this.color,
  });

  final TextStyle textStyle;

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final size = textStyle.height! * textStyle.fontSize!;

    return SizedBox(
      height: size,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: size, maxHeight: size),
          child: CircularProgressIndicator(
            color: color,
            strokeWidth: 3,
          ),
        ),
      ),
    );
  }
}
