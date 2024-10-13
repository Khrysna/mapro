import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:raw_components/src/text_field/raw_text_field_border.dart';
import 'package:raw_components/src/text_field/raw_text_field_cursor_style.dart';

class RawTextField extends StatefulWidget {
  const RawTextField({
    required this.hintText,
    required this.textStyle,
    required this.foregroundColor,
    required this.hintColor,
    required this.disabledBackgroundColor,
    required this.cursorStyle,
    required this.inputBorder,
    required this.padding,
    super.key,
    this.autofocus = false,
    this.enabled = true,
    this.hasError = false,
    this.readOnly = false,
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.controller,
    this.focusNode,
    this.initialValue,
    this.inputFormatters,
    this.keyboardType,
    this.maxLines,
    this.minLines,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.prefix,
    this.suffix,
    this.obscuringCharacter,
  });

  final TextStyle textStyle;

  final Color foregroundColor;

  final Color hintColor;

  final Color disabledBackgroundColor;

  final RawTextFieldCursorStyle cursorStyle;

  final RawTextFieldBorder inputBorder;

  final EdgeInsets? padding;

  final bool autofocus;

  final TextEditingController? controller;

  final bool enabled;

  final FocusNode? focusNode;

  final bool hasError;

  final String? hintText;

  final String? initialValue;

  final String? obscuringCharacter;

  final List<TextInputFormatter>? inputFormatters;

  final TextInputType? keyboardType;

  final int? maxLines;

  final int? minLines;

  final ValueChanged<String>? onChanged;

  final ValueChanged<String>? onSubmitted;

  final GestureTapCallback? onTap;

  final Widget? prefix;

  final bool readOnly;

  final bool obscureText;

  final Widget? suffix;

  final TextCapitalization textCapitalization;

  final TextInputAction? textInputAction;

  @override
  State<RawTextField> createState() => _RawTextFieldState();
}

class _RawTextFieldState extends State<RawTextField>
    with RestorationMixin
    implements TextSelectionGestureDetectorBuilderDelegate {
  RestorableTextEditingController? _controller;

  FocusNode? _focusNode;

  late _TextFieldSelectionGestureDetectorBuilder _selectionGestureDetectorBuilder;

  final WidgetStatesController _statesController = WidgetStatesController();

  @override
  final GlobalKey<EditableTextState> editableTextKey = GlobalKey<EditableTextState>();

  EditableTextState get _editableText => editableTextKey.currentState!;

  TextEditingController get _effectiveController => widget.controller ?? _controller!.value;

  FocusNode get _effectiveFocusNode => widget.focusNode ?? (_focusNode ??= FocusNode());

  double get height {
    final textStyle = widget.textStyle;
    final padding = widget.padding ?? EdgeInsets.zero;

    final height = textStyle.height! * textStyle.fontSize!;
    final verticalPadding = padding.vertical;

    return height.floorToDouble() + verticalPadding;
  }

  @override
  void initState() {
    super.initState();

    _selectionGestureDetectorBuilder = _TextFieldSelectionGestureDetectorBuilder(
      state: this,
    );

    if (widget.controller == null) {
      _createLocalController();
    }

    _effectiveFocusNode.addListener(_handleFocusChanged);

    _initStatesController();
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    _effectiveFocusNode.removeListener(_handleFocusChanged);
    _controller?.dispose();
    _statesController.dispose();
    _statesController.removeListener(_handleStatesControllerChange);

    super.dispose();
  }

  @override
  void didUpdateWidget(RawTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller == null && oldWidget.controller != null) {
      _createLocalController(oldWidget.controller!.value);
    } else if (widget.controller != null && oldWidget.controller == null) {
      unregisterFromRestoration(_controller!);

      _controller!.dispose();
      _controller = null;
    }

    if (widget.focusNode != oldWidget.focusNode) {
      (oldWidget.focusNode ?? _focusNode)?.removeListener(_handleFocusChanged);
      (widget.focusNode ?? _focusNode)?.addListener(_handleFocusChanged);
    }

    _initStatesController();
  }

  /// API for TextSelectionGestureDetectorBuilderDelegate.

  @override
  bool get forcePressEnabled => false;

  @override
  String? get restorationId => null;

  @override
  bool get selectionEnabled => !widget.readOnly;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    if (_controller != null) {
      _registerController();
    }
  }

  void _createLocalController([TextEditingValue? value]) {
    assert(_controller == null, 'controller is null');

    if (value == null) {
      _controller = RestorableTextEditingController(text: widget.initialValue);
    } else {
      _controller = RestorableTextEditingController.fromValue(value);
    }

    if (!restorePending) {
      _registerController();
    }
  }

  void _handleFocusChanged() {
    _statesController.update(WidgetState.focused, _effectiveFocusNode.hasFocus);

    /// Rebuild the widget on focus change to show/hide the text selection highlight.
    setState(() {});
  }

  void _handleStatesControllerChange() {
    /// Force a rebuild to resolve MaterialStateProperty properties.
    setState(() {});
  }

  void _initStatesController() {
    _statesController.update(WidgetState.disabled, !widget.enabled);
    _statesController.update(WidgetState.focused, _effectiveFocusNode.hasFocus);
    _statesController.update(WidgetState.error, widget.hasError);
    _statesController.addListener(_handleStatesControllerChange);
  }

  void _registerController() {
    assert(_controller != null, 'controller is not null');

    registerForRestoration(_controller!, 'controller');
  }

  /// End of API for TextSelectionGestureDetectorBuilderDelegate.

  void _requestKeyboard() {
    _editableText.requestKeyboard();
  }

  WidgetStateProperty<ShapeBorder> get _shapeBorder {
    final inputBorder = widget.inputBorder;

    return WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return inputBorder.border.copyWith(borderSide: inputBorder.disabledBorderSide);
      }

      if (states.contains(WidgetState.focused)) {
        if (widget.hasError) {
          return inputBorder.border.copyWith(borderSide: inputBorder.focusedErrorBorderSide);
        }

        return inputBorder.border.copyWith(borderSide: inputBorder.focusedBorderSide);
      }

      if (states.contains(WidgetState.error)) {
        return inputBorder.border.copyWith(borderSide: inputBorder.errorBorderSide);
      }

      return inputBorder.border.copyWith(borderSide: inputBorder.borderSide);
    });
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsets effectivePadding;

    if (widget.padding != null) {
      effectivePadding = EdgeInsets.only(
        left: widget.prefix != null ? 0 : widget.padding!.left,
        top: widget.padding!.top,
        right: widget.suffix != null ? 0 : widget.padding!.right,
        bottom: widget.padding!.bottom,
      );
    } else {
      effectivePadding = EdgeInsets.zero;
    }

    final child = RepaintBoundary(
      child: UnmanagedRestorationScope(
        bucket: bucket,
        child: EditableText(
          key: editableTextKey,
          controller: _effectiveController,
          focusNode: _effectiveFocusNode,
          readOnly: widget.readOnly || !widget.enabled,
          autocorrect: false,
          enableSuggestions: false,
          style: widget.textStyle,
          cursorColor: widget.cursorStyle.color,
          backgroundCursorColor: widget.cursorStyle.backgroundCursorColor,
          maxLines: widget.minLines ?? widget.maxLines ?? 1,
          minLines: widget.minLines,
          autofocus: widget.autofocus,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          onChanged: widget.onChanged,
          obscureText: widget.obscureText,
          onSubmitted: widget.onSubmitted,
          obscuringCharacter: widget.obscuringCharacter ?? '•',
          inputFormatters: [
            if (widget.keyboardType != TextInputType.multiline) ...{
              FilteringTextInputFormatter.deny(RegExp(r'\s+'), replacementString: ' '),
            },
            ...?widget.inputFormatters,
          ],
          rendererIgnoresPointer: true,
          cursorWidth: widget.cursorStyle.width,
          cursorHeight: widget.cursorStyle.height,
          cursorRadius: widget.cursorStyle.radius,
          cursorOpacityAnimates: widget.cursorStyle.cursorOpacityAnimates,
          paintCursorAboveText: true,
          restorationId: 'editable',
        ),
      ),
    );

    final inputDecoration = Container(
      decoration: ShapeDecoration(
        color: widget.enabled ? Colors.white : widget.disabledBackgroundColor,
        shape: _shapeBorder.resolve(_statesController.value),
      ),
      child: Row(
        children: [
          if (widget.prefix != null) ...{
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: height),
              child: widget.prefix,
            ),
            const SizedBox(width: 8),
          },
          Expanded(
            child: Padding(
              padding: effectivePadding,
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _effectiveController,
                builder: (_, text, __) {
                  final hasText = text.text.isNotEmpty;

                  return Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      if (!hasText) ...{
                        Positioned.fill(
                          child: Row(
                            crossAxisAlignment: (widget.minLines != null && widget.minLines! > 1)
                                ? CrossAxisAlignment.start
                                : CrossAxisAlignment.center,
                            children: [
                              const SizedBox(width: 1),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    text: widget.hintText,
                                    style: widget.textStyle.copyWith(
                                      color: widget.hintColor,
                                      textBaseline: TextBaseline.alphabetic,
                                    ),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: widget.minLines ?? 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      },
                      child,
                    ],
                  );
                },
              ),
            ),
          ),
          if (widget.suffix != null) ...{
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: height),
              child: widget.suffix,
            ),
          },
        ],
      ),
    );

    return TextFieldTapRegion(
      child: IgnorePointer(
        ignoring: !widget.enabled,
        child: _selectionGestureDetectorBuilder.buildGestureDetector(
          behavior: HitTestBehavior.translucent,
          child: Align(
            alignment: Alignment(-1, TextAlignVertical.center.y),
            widthFactor: 1,
            heightFactor: 1,
            child: inputDecoration,
          ),
        ),
      ),
    );
  }
}

class _TextFieldSelectionGestureDetectorBuilder extends TextSelectionGestureDetectorBuilder {
  _TextFieldSelectionGestureDetectorBuilder({
    required _RawTextFieldState state,
  })  : _state = state,
        super(delegate: state);

  final _RawTextFieldState _state;

  @override
  void onSingleTapUp(TapDragUpDetails details) {
    super.onSingleTapUp(details);

    _state._requestKeyboard();
    _state.widget.onTap?.call();
  }

  @override
  void onDragSelectionEnd(TapDragEndDetails details) {
    _state._requestKeyboard();

    super.onDragSelectionEnd(details);
  }
}
