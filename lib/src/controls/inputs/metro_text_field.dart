import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../theme/metro_spacing.dart';
import '../../theme/metro_theme.dart';
import '../../theme/metro_theme_data.dart';
import 'metro_text_field_style.dart';

export 'metro_text_field_style.dart';

/// Validation feedback shown by a [MetroTextField].
enum MetroTextFieldValidationState { none, error, success }

/// A flat, square text input built on Flutter's native [EditableText].
class MetroTextField extends StatefulWidget {
  const MetroTextField({
    this.controller,
    this.focusNode,
    this.label,
    this.placeholder,
    this.prefix,
    this.suffix,
    this.supportingText,
    this.validationState = MetroTextFieldValidationState.none,
    this.style,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.obscureText = false,
    this.obscuringCharacter = '•',
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.autofillHints,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.maxLines = 1,
    this.minLines,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.semanticLabel,
    super.key,
  }) : assert(maxLines > 0),
       assert(minLines == null || minLines > 0),
       assert(minLines == null || minLines <= maxLines),
       assert(!obscureText || maxLines == 1),
       assert(obscuringCharacter.length == 1);

  /// Creates a single-line obscured field with secure keyboard defaults.
  ///
  /// A custom reveal action can be supplied through [suffix].
  const MetroTextField.password({
    TextEditingController? controller,
    FocusNode? focusNode,
    Widget? label,
    String? placeholder,
    Widget? prefix,
    Widget? suffix,
    Widget? supportingText,
    MetroTextFieldValidationState validationState =
        MetroTextFieldValidationState.none,
    MetroTextFieldStyle? style,
    bool enabled = true,
    bool readOnly = false,
    bool autofocus = false,
    String obscuringCharacter = '•',
    Iterable<String>? autofillHints = const <String>[AutofillHints.password],
    TextInputAction? textInputAction,
    TextAlign textAlign = TextAlign.start,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    VoidCallback? onEditingComplete,
    String? semanticLabel,
    Key? key,
  }) : this(
         controller: controller,
         focusNode: focusNode,
         label: label,
         placeholder: placeholder,
         prefix: prefix,
         suffix: suffix,
         supportingText: supportingText,
         validationState: validationState,
         style: style,
         enabled: enabled,
         readOnly: readOnly,
         autofocus: autofocus,
         obscureText: true,
         obscuringCharacter: obscuringCharacter,
         autocorrect: false,
         enableSuggestions: false,
         autofillHints: autofillHints,
         keyboardType: TextInputType.visiblePassword,
         textInputAction: textInputAction,
         textAlign: textAlign,
         inputFormatters: inputFormatters,
         onChanged: onChanged,
         onSubmitted: onSubmitted,
         onEditingComplete: onEditingComplete,
         semanticLabel: semanticLabel,
         key: key,
       );

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Widget? label;
  final String? placeholder;
  final Widget? prefix;
  final Widget? suffix;
  final Widget? supportingText;
  final MetroTextFieldValidationState validationState;
  final MetroTextFieldStyle? style;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final bool obscureText;
  final String obscuringCharacter;
  final bool autocorrect;
  final bool enableSuggestions;
  final Iterable<String>? autofillHints;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final int maxLines;
  final int? minLines;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onEditingComplete;
  final String? semanticLabel;

  @override
  State<MetroTextField> createState() => _MetroTextFieldState();
}

class _MetroTextFieldState extends State<MetroTextField> {
  TextEditingController? _internalController;
  FocusNode? _internalFocusNode;
  bool _hovered = false;

  TextEditingController get _controller =>
      widget.controller ?? _internalController!;

  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = TextEditingController();
    }
    if (widget.focusNode == null) {
      _internalFocusNode = FocusNode();
    }
    _controller.addListener(_handleControllerChanged);
    _focusNode.addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(MetroTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      final oldController = oldWidget.controller ?? _internalController!;
      oldController.removeListener(_handleControllerChanged);
      if (widget.controller == null) {
        _internalController = TextEditingController.fromValue(
          oldWidget.controller!.value,
        );
      } else if (oldWidget.controller == null) {
        _internalController?.dispose();
        _internalController = null;
      }
      _controller.addListener(_handleControllerChanged);
    }
    if (oldWidget.focusNode != widget.focusNode) {
      final oldFocusNode = oldWidget.focusNode ?? _internalFocusNode!;
      oldFocusNode.removeListener(_handleFocusChanged);
      if (widget.focusNode == null) {
        _internalFocusNode = FocusNode();
      } else if (oldWidget.focusNode == null) {
        _internalFocusNode?.dispose();
        _internalFocusNode = null;
      }
      _focusNode.addListener(_handleFocusChanged);
    }
  }

  void _handleControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleFocusChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChanged);
    _focusNode.removeListener(_handleFocusChanged);
    _internalController?.dispose();
    _internalFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = MetroTheme.of(context);
    final effectiveStyle = _defaultStyle(theme)
        .merge(theme.textFieldTheme.style)
        .merge(MetroTextFieldTheme.maybeOf(context)?.style)
        .merge(widget.style);
    final states = <WidgetState>{
      if (!widget.enabled) WidgetState.disabled,
      if (widget.enabled && _hovered) WidgetState.hovered,
      if (widget.enabled && _focusNode.hasFocus) WidgetState.focused,
    };
    final background = effectiveStyle.backgroundColor?.resolve(states);
    final foreground = effectiveStyle.foregroundColor?.resolve(states);
    final placeholderColor = effectiveStyle.placeholderColor?.resolve(states);
    final normalBorderColor = effectiveStyle.borderColor?.resolve(states);
    final errorColor =
        effectiveStyle.errorColor?.resolve(states) ?? theme.colors.error;
    final successColor =
        effectiveStyle.successColor?.resolve(states) ?? theme.colors.success;
    final validationColor = switch (widget.validationState) {
      MetroTextFieldValidationState.none => null,
      MetroTextFieldValidationState.error => errorColor,
      MetroTextFieldValidationState.success => successColor,
    };
    final borderColor = widget.enabled
        ? validationColor ?? normalBorderColor
        : normalBorderColor;
    final borderWidth = effectiveStyle.borderWidth?.resolve(states) ?? 2;
    final cursorColor =
        effectiveStyle.cursorColor?.resolve(states) ?? theme.colors.accent;
    final selectionColor =
        effectiveStyle.selectionColor?.resolve(states) ??
        theme.colors.accent.withValues(alpha: 0.35);
    final textStyle =
        (effectiveStyle.textStyle?.resolve(states) ?? theme.typography.body)
            .copyWith(color: foreground);
    final placeholderStyle =
        (effectiveStyle.placeholderStyle?.resolve(states) ??
                theme.typography.body)
            .copyWith(color: placeholderColor);
    final baseSupportingStyle =
        effectiveStyle.supportingTextStyle?.resolve(states) ??
        theme.typography.caption;
    final supportingColor = !widget.enabled
        ? theme.colors.disabledForeground
        : validationColor ??
              baseSupportingStyle.color ??
              theme.colors.mutedForeground;
    final supportingStyle = baseSupportingStyle.copyWith(
      color: supportingColor,
    );
    final reduceMotion = _reduceMotion(context);

    Widget field = MouseRegion(
      onEnter: widget.enabled ? (_) => setState(() => _hovered = true) : null,
      onExit: widget.enabled ? (_) => setState(() => _hovered = false) : null,
      cursor: widget.enabled && !widget.readOnly
          ? SystemMouseCursors.text
          : SystemMouseCursors.basic,
      child: AnimatedContainer(
        duration: reduceMotion ? Duration.zero : theme.motion.fast,
        curve: theme.motion.standardCurve,
        padding:
            effectiveStyle.padding ??
            const EdgeInsets.symmetric(
              horizontal: MetroSpacing.xs,
              vertical: MetroSpacing.xs,
            ),
        decoration: BoxDecoration(
          color: background,
          border: Border.all(
            color: borderColor ?? const Color(0x00000000),
            width: borderWidth,
          ),
        ),
        child: Row(
          crossAxisAlignment: widget.maxLines == 1
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            if (widget.prefix != null) ...[
              IconTheme.merge(
                data: IconThemeData(color: foreground, size: 18),
                child: widget.prefix!,
              ),
              const SizedBox(width: MetroSpacing.xs),
            ],
            Expanded(
              child: Stack(
                alignment: AlignmentDirectional.centerStart,
                children: [
                  if (_controller.text.isEmpty && widget.placeholder != null)
                    IgnorePointer(
                      child: Text(
                        widget.placeholder!,
                        maxLines: widget.maxLines,
                        overflow: TextOverflow.ellipsis,
                        style: placeholderStyle,
                      ),
                    ),
                  EditableText(
                    autofocus: widget.autofocus,
                    autocorrect: widget.autocorrect,
                    autofillHints: widget.autofillHints,
                    backgroundCursorColor: theme.colors.background,
                    controller: _controller,
                    cursorColor: cursorColor,
                    focusNode: _focusNode,
                    inputFormatters: widget.inputFormatters,
                    keyboardType: widget.keyboardType,
                    maxLines: widget.maxLines,
                    minLines: widget.minLines,
                    enableSuggestions: widget.enableSuggestions,
                    obscuringCharacter: widget.obscuringCharacter,
                    obscureText: widget.obscureText,
                    onChanged: widget.onChanged,
                    onEditingComplete: widget.onEditingComplete,
                    onSubmitted: widget.onSubmitted,
                    readOnly: widget.readOnly || !widget.enabled,
                    selectionColor: selectionColor,
                    style: textStyle,
                    textAlign: widget.textAlign,
                    textCapitalization: widget.textCapitalization,
                    textInputAction: widget.textInputAction,
                  ),
                ],
              ),
            ),
            if (widget.suffix != null) ...[
              const SizedBox(width: MetroSpacing.xs),
              IconTheme.merge(
                data: IconThemeData(color: foreground, size: 18),
                child: widget.suffix!,
              ),
            ],
          ],
        ),
      ),
    );
    if (!widget.enabled) {
      field = IgnorePointer(child: field);
    }
    field = Semantics(
      enabled: widget.enabled,
      label: widget.semanticLabel,
      obscured: widget.obscureText,
      textField: true,
      validationResult: switch (widget.validationState) {
        MetroTextFieldValidationState.none => SemanticsValidationResult.none,
        MetroTextFieldValidationState.error =>
          SemanticsValidationResult.invalid,
        MetroTextFieldValidationState.success =>
          SemanticsValidationResult.valid,
      },
      child: field,
    );

    if (widget.label == null && widget.supportingText == null) {
      return field;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          DefaultTextStyle.merge(
            style: effectiveStyle.labelStyle?.resolve(states),
            child: widget.label!,
          ),
          const SizedBox(height: MetroSpacing.xs),
        ],
        field,
        if (widget.supportingText != null) ...[
          const SizedBox(height: MetroSpacing.xxs),
          Semantics(
            liveRegion:
                widget.validationState != MetroTextFieldValidationState.none,
            child: DefaultTextStyle.merge(
              style: supportingStyle,
              child: widget.supportingText!,
            ),
          ),
        ],
      ],
    );
  }

  static MetroTextFieldStyle _defaultStyle(MetroThemeData theme) {
    final colors = theme.colors;
    return MetroTextFieldStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.disabled)
            ? colors.disabledBackground
            : colors.background;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.disabled)
            ? colors.disabledForeground
            : colors.foreground;
      }),
      placeholderColor: WidgetStatePropertyAll(colors.mutedForeground),
      borderColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.focused)) {
          return colors.accent;
        }
        if (states.contains(WidgetState.hovered)) {
          return colors.foreground;
        }
        return colors.border;
      }),
      borderWidth: const WidgetStatePropertyAll(2),
      cursorColor: WidgetStatePropertyAll(colors.accent),
      selectionColor: WidgetStatePropertyAll(
        colors.accent.withValues(alpha: 0.35),
      ),
      textStyle: WidgetStatePropertyAll(theme.typography.body),
      placeholderStyle: WidgetStatePropertyAll(theme.typography.body),
      labelStyle: WidgetStatePropertyAll(theme.typography.bodyStrong),
      supportingTextStyle: WidgetStatePropertyAll(theme.typography.caption),
      errorColor: WidgetStatePropertyAll(colors.error),
      successColor: WidgetStatePropertyAll(colors.success),
      padding: const EdgeInsets.symmetric(
        horizontal: MetroSpacing.xs,
        vertical: MetroSpacing.xs,
      ),
    );
  }

  static bool _reduceMotion(BuildContext context) {
    final mediaQuery = MediaQuery.maybeOf(context);
    return mediaQuery?.disableAnimations == true ||
        mediaQuery?.accessibleNavigation == true;
  }
}
