import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/metro_accessibility.dart';
import '../../localization/metro_localizations.dart';
import '../../theme/metro_spacing.dart';
import '../../theme/metro_theme.dart';
import '../../theme/metro_theme_data.dart';
import 'metro_number_box_style.dart';
import 'metro_text_field.dart';

export 'metro_number_box_style.dart';

/// Formats a nullable numeric value for a [MetroNumberBox].
typedef MetroNumberBoxFormatter<T extends num> = String Function(T? value);

/// Parses committed text for a [MetroNumberBox].
typedef MetroNumberBoxParser<T extends num> = T? Function(String text);

/// Controls how committed text that cannot be parsed is handled.
enum MetroNumberBoxInvalidInputBehavior {
  /// Restores the application-owned value.
  restoreValue,

  /// Keeps the draft text and exposes an invalid field state.
  keepText,
}

/// A controlled numeric text field with inline Metro step buttons.
///
/// Typed text is committed on submission or focus loss. Arrow Up/Down use
/// [smallChange], Page Up/Page Down use [largeChange], and the mouse wheel can
/// step a focused field. The application remains authoritative through
/// [value] and [onChanged].
class MetroNumberBox<T extends num> extends StatefulWidget {
  const MetroNumberBox({
    required this.value,
    required this.onChanged,
    this.min,
    this.max,
    this.smallChange = 1,
    this.largeChange = 10,
    this.snapToStep = false,
    this.allowNull = true,
    this.decimalPlaces = 2,
    this.trimTrailingZeros = true,
    this.formatter,
    this.parser,
    this.invalidInputBehavior = MetroNumberBoxInvalidInputBehavior.restoreValue,
    this.onInvalidInput,
    this.onTextChanged,
    this.repeatDelay = const Duration(milliseconds: 400),
    this.repeatInterval = const Duration(milliseconds: 100),
    this.mouseWheelEnabled = true,
    this.selectAllOnFocus = true,
    this.placeholder,
    this.prefix,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
    this.textAlign = TextAlign.end,
    this.inputFormatters,
    this.semanticLabel,
    this.incrementSemanticLabel,
    this.decrementSemanticLabel,
    super.key,
  }) : assert(min == null || max == null || min <= max),
       assert(value == null || min == null || value >= min),
       assert(value == null || max == null || value <= max),
       assert(smallChange > 0),
       assert(largeChange > 0),
       assert(decimalPlaces >= 0);

  final T? value;
  final ValueChanged<T?>? onChanged;
  final T? min;
  final T? max;
  final num smallChange;
  final num largeChange;
  final bool snapToStep;
  final bool allowNull;
  final int decimalPlaces;
  final bool trimTrailingZeros;
  final MetroNumberBoxFormatter<T>? formatter;
  final MetroNumberBoxParser<T>? parser;
  final MetroNumberBoxInvalidInputBehavior invalidInputBehavior;
  final ValueChanged<String>? onInvalidInput;
  final ValueChanged<String>? onTextChanged;
  final Duration repeatDelay;
  final Duration? repeatInterval;
  final bool mouseWheelEnabled;
  final bool selectAllOnFocus;
  final String? placeholder;
  final Widget? prefix;
  final MetroNumberBoxStyle? style;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool enabled;
  final TextAlign textAlign;
  final List<TextInputFormatter>? inputFormatters;
  final String? semanticLabel;
  final String? incrementSemanticLabel;
  final String? decrementSemanticLabel;

  @override
  State<MetroNumberBox<T>> createState() => _MetroNumberBoxState<T>();
}

class _MetroNumberBoxState<T extends num> extends State<MetroNumberBox<T>> {
  late final TextEditingController _controller;
  FocusNode? _internalFocusNode;
  bool _invalid = false;
  bool _draftNeedsCommit = false;

  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode!;

  bool get _enabled => widget.enabled && widget.onChanged != null;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatValue(widget.value));
    if (widget.focusNode == null) {
      _internalFocusNode = FocusNode(debugLabel: 'MetroNumberBox');
    }
    _focusNode.addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(MetroNumberBox<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      final oldFocusNode = oldWidget.focusNode ?? _internalFocusNode!;
      oldFocusNode.removeListener(_handleFocusChanged);
      if (widget.focusNode == null) {
        _internalFocusNode = FocusNode(debugLabel: 'MetroNumberBox');
      } else if (oldWidget.focusNode == null) {
        _internalFocusNode?.dispose();
        _internalFocusNode = null;
      }
      _focusNode.addListener(_handleFocusChanged);
    }

    if (oldWidget.value != widget.value ||
        oldWidget.formatter != widget.formatter ||
        oldWidget.decimalPlaces != widget.decimalPlaces ||
        oldWidget.trimTrailingZeros != widget.trimTrailingZeros ||
        (!_enabled && oldWidget.enabled != widget.enabled) ||
        (!_enabled && oldWidget.onChanged != widget.onChanged)) {
      _restoreApplicationValue();
    }
  }

  bool _debugValidateConfiguration() {
    if (widget.repeatDelay.isNegative) {
      throw FlutterError('MetroNumberBox repeatDelay cannot be negative.');
    }
    final repeatInterval = widget.repeatInterval;
    if (repeatInterval != null && repeatInterval <= Duration.zero) {
      throw FlutterError('MetroNumberBox repeatInterval must be positive.');
    }
    if (T == int &&
        (widget.smallChange % 1 != 0 || widget.largeChange % 1 != 0)) {
      throw FlutterError(
        'MetroNumberBox<int> requires integer smallChange and largeChange.',
      );
    }
    return true;
  }

  void _handleFocusChanged() {
    if (!mounted) {
      return;
    }
    if (_focusNode.hasFocus && widget.selectAllOnFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _focusNode.hasFocus) {
          _controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _controller.text.length,
          );
        }
      });
    } else if (!_focusNode.hasFocus) {
      _commitText();
    }
    setState(() {});
  }

  String _formatValue(T? value) {
    final formatter = widget.formatter;
    if (formatter != null) {
      return formatter(value);
    }
    if (value == null) {
      return '';
    }
    if (T == int || value is int) {
      return value.toInt().toString();
    }
    var text = value.toDouble().toStringAsFixed(widget.decimalPlaces);
    if (widget.trimTrailingZeros && text.contains('.')) {
      text = text.replaceFirst(RegExp(r'0+$'), '');
      text = text.replaceFirst(RegExp(r'\.$'), '');
    }
    return text;
  }

  T? _convertNumber(num value, {required bool rejectFractional}) {
    if (!value.isFinite) {
      return null;
    }
    if (T == int) {
      if (rejectFractional && value != value.truncateToDouble()) {
        return null;
      }
      return value.toInt() as T;
    }
    if (T == double) {
      return value.toDouble() as T;
    }
    return value as T;
  }

  T? _parseText(String text) {
    final parser = widget.parser;
    if (parser != null) {
      return parser(text);
    }
    final value = num.tryParse(text.trim());
    return value == null ? null : _convertNumber(value, rejectFractional: true);
  }

  T? _coerceValue(T value, {required bool snap}) {
    num result = value;
    if (snap && widget.snapToStep) {
      final base = widget.min ?? _zeroValue();
      result =
          base +
          (((result - base) / widget.smallChange).round() * widget.smallChange);
    }
    final min = widget.min;
    final max = widget.max;
    if (min != null && result < min) {
      result = min;
    }
    if (max != null && result > max) {
      result = max;
    }
    return _convertNumber(result, rejectFractional: false);
  }

  T _zeroValue() {
    if (T == double) {
      return 0.0 as T;
    }
    return 0 as T;
  }

  T? _effectiveDraftValue() {
    if (_controller.text.trim().isEmpty) {
      return widget.value;
    }
    final parsed = _parseText(_controller.text);
    return parsed == null ? widget.value : _coerceValue(parsed, snap: false);
  }

  bool get _canIncrement {
    if (!_enabled) {
      return false;
    }
    final value = _effectiveDraftValue();
    return widget.max == null || value == null || value < widget.max!;
  }

  bool get _canDecrement {
    if (!_enabled) {
      return false;
    }
    final value = _effectiveDraftValue();
    return widget.min == null || value == null || value > widget.min!;
  }

  T? _steppedValue(num delta) {
    final current =
        _parseText(_controller.text) ??
        widget.value ??
        widget.min ??
        _zeroValue();
    final converted = _convertNumber(current + delta, rejectFractional: false);
    return converted == null ? null : _coerceValue(converted, snap: false);
  }

  void _step(num delta) {
    if (!_enabled) {
      return;
    }
    final value = _steppedValue(delta);
    if (value == null) {
      return;
    }
    _setDraftValue(value);
    _requestValue(value);
  }

  void _setDraftValue(T? value) {
    final text = _formatValue(value);
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    _draftNeedsCommit = false;
    if (_invalid) {
      setState(() => _invalid = false);
    }
  }

  void _requestValue(T? value) {
    if (value == widget.value) {
      return;
    }
    widget.onChanged?.call(value);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.value != value) {
        _restoreApplicationValue();
      }
    });
  }

  void _commitText() {
    if (!_draftNeedsCommit) {
      return;
    }
    if (!_enabled) {
      _restoreApplicationValue();
      return;
    }
    final text = _controller.text.trim();
    if (text.isEmpty) {
      if (widget.allowNull) {
        _setDraftValue(null);
        _requestValue(null);
      } else {
        _handleInvalidInput(_controller.text);
      }
      return;
    }
    final parsed = _parseText(text);
    final value = parsed == null
        ? null
        : _coerceValue(parsed, snap: widget.snapToStep);
    if (value == null) {
      _handleInvalidInput(_controller.text);
      return;
    }
    _setDraftValue(value);
    _requestValue(value);
  }

  void _handleInvalidInput(String text) {
    _draftNeedsCommit = false;
    widget.onInvalidInput?.call(text);
    if (widget.invalidInputBehavior ==
        MetroNumberBoxInvalidInputBehavior.restoreValue) {
      _restoreApplicationValue();
    } else if (!_invalid) {
      setState(() => _invalid = true);
    }
  }

  void _restoreApplicationValue() {
    final text = _formatValue(widget.value);
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    _draftNeedsCommit = false;
    if (_invalid && mounted) {
      setState(() => _invalid = false);
    }
  }

  void _handleTextChanged(String text) {
    _draftNeedsCommit = true;
    if (_invalid) {
      setState(() => _invalid = false);
    }
    widget.onTextChanged?.call(text);
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (!_enabled || (event is! KeyDownEvent && event is! KeyRepeatEvent)) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowUp) {
      _step(widget.smallChange);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown) {
      _step(-widget.smallChange);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.pageUp) {
      _step(widget.largeChange);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.pageDown) {
      _step(-widget.largeChange);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.home && widget.min != null) {
      _setDraftValue(widget.min);
      _requestValue(widget.min);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.end && widget.max != null) {
      _setDraftValue(widget.max);
      _requestValue(widget.max);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.escape) {
      _restoreApplicationValue();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (!widget.mouseWheelEnabled ||
        !_enabled ||
        !_focusNode.hasFocus ||
        event is! PointerScrollEvent ||
        event.scrollDelta.dy == 0) {
      return;
    }
    GestureBinding.instance.pointerSignalResolver.register(event, (resolved) {
      if (resolved is PointerScrollEvent) {
        _step(
          resolved.scrollDelta.dy < 0
              ? widget.smallChange
              : -widget.smallChange,
        );
      }
    });
  }

  MetroNumberBoxStyle _resolveStyle(BuildContext context) {
    final theme = MetroTheme.of(context);
    return _defaultStyle(theme)
        .merge(theme.numberBoxTheme.style)
        .merge(MetroNumberBoxTheme.maybeOf(context)?.style)
        .merge(widget.style);
  }

  @override
  Widget build(BuildContext context) {
    assert(_debugValidateConfiguration());
    final style = _resolveStyle(context);
    final localizations = MetroLocalizations.of(context);
    final increment = _steppedValue(widget.smallChange);
    final decrement = _steppedValue(-widget.smallChange);
    final suffix = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MetroNumberSpinButton(
          key: const ValueKey<String>('metro-number-box-increment'),
          backgroundColor: style.buttonBackgroundColor!,
          foregroundColor: style.buttonForegroundColor!,
          extent: style.buttonExtent!,
          iconSize: style.iconSize!,
          increment: true,
          onPressed: _canIncrement ? () => _step(widget.smallChange) : null,
          repeatDelay: widget.repeatDelay,
          repeatInterval: widget.repeatInterval,
          semanticLabel:
              widget.incrementSemanticLabel ??
              localizations.numberBoxIncrementLabel,
        ),
        _MetroNumberSpinButton(
          key: const ValueKey<String>('metro-number-box-decrement'),
          backgroundColor: style.buttonBackgroundColor!,
          foregroundColor: style.buttonForegroundColor!,
          extent: style.buttonExtent!,
          iconSize: style.iconSize!,
          increment: false,
          onPressed: _canDecrement ? () => _step(-widget.smallChange) : null,
          repeatDelay: widget.repeatDelay,
          repeatInterval: widget.repeatInterval,
          semanticLabel:
              widget.decrementSemanticLabel ??
              localizations.numberBoxDecrementLabel,
        ),
      ],
    );

    Widget field = Focus(
      canRequestFocus: false,
      onKeyEvent: _handleKeyEvent,
      skipTraversal: true,
      child: MetroTextField(
        controller: _controller,
        focusNode: _focusNode,
        placeholder: widget.placeholder,
        prefix: widget.prefix,
        suffix: suffix,
        style: style.fieldStyle,
        enabled: _enabled,
        autofocus: widget.autofocus,
        keyboardType: TextInputType.numberWithOptions(
          decimal: T != int,
          signed: widget.min == null || widget.min! < 0,
        ),
        textInputAction: TextInputAction.done,
        textAlign: widget.textAlign,
        inputFormatters: widget.inputFormatters,
        onChanged: _handleTextChanged,
        onSubmitted: (_) => _commitText(),
        validationState: _invalid
            ? MetroTextFieldValidationState.error
            : MetroTextFieldValidationState.none,
      ),
    );
    field = Listener(onPointerSignal: _handlePointerSignal, child: field);

    return Semantics(
      container: true,
      enabled: _enabled,
      label: widget.semanticLabel,
      value: _controller.text.isEmpty
          ? localizations.numberBoxEmptyValueLabel
          : _controller.text,
      increasedValue: _canIncrement && increment != null
          ? _formatValue(increment)
          : null,
      decreasedValue: _canDecrement && decrement != null
          ? _formatValue(decrement)
          : null,
      onIncrease: _canIncrement ? () => _step(widget.smallChange) : null,
      onDecrease: _canDecrement ? () => _step(-widget.smallChange) : null,
      child: field,
    );
  }

  static MetroNumberBoxStyle _defaultStyle(MetroThemeData theme) {
    final colors = theme.colors;
    return MetroNumberBoxStyle(
      fieldStyle: const MetroTextFieldStyle(
        padding: EdgeInsetsDirectional.only(start: MetroSpacing.sm),
      ),
      buttonBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.disabledBackground;
        }
        if (states.contains(WidgetState.pressed)) {
          return colors.accentPressed;
        }
        if (states.contains(WidgetState.hovered)) {
          return colors.accentHover;
        }
        return colors.accent;
      }),
      buttonForegroundColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.disabled)
            ? colors.disabledForeground
            : colors.onAccent;
      }),
      buttonExtent: 40,
      iconSize: 14,
    );
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChanged);
    _internalFocusNode?.dispose();
    _controller.dispose();
    super.dispose();
  }
}

class _MetroNumberSpinButton extends StatefulWidget {
  const _MetroNumberSpinButton({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.extent,
    required this.iconSize,
    required this.increment,
    required this.onPressed,
    required this.repeatDelay,
    required this.repeatInterval,
    required this.semanticLabel,
    super.key,
  });

  final WidgetStateProperty<Color?> backgroundColor;
  final WidgetStateProperty<Color?> foregroundColor;
  final double extent;
  final double iconSize;
  final bool increment;
  final VoidCallback? onPressed;
  final Duration repeatDelay;
  final Duration? repeatInterval;
  final String semanticLabel;

  @override
  State<_MetroNumberSpinButton> createState() => _MetroNumberSpinButtonState();
}

class _MetroNumberSpinButtonState extends State<_MetroNumberSpinButton> {
  Timer? _delayTimer;
  Timer? _repeatTimer;
  bool _hovered = false;
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null;

  @override
  void didUpdateWidget(_MetroNumberSpinButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_enabled) {
      _stopRepeating(notify: false);
      _hovered = false;
      _pressed = false;
    }
  }

  void _startRepeating(PointerDownEvent event) {
    if (!_enabled || event.buttons & kPrimaryButton == 0) {
      return;
    }
    setState(() => _pressed = true);
    widget.onPressed?.call();
    final interval = widget.repeatInterval;
    if (interval == null) {
      return;
    }
    _delayTimer = Timer(widget.repeatDelay, () {
      if (!mounted || !_pressed) {
        return;
      }
      widget.onPressed?.call();
      _repeatTimer = Timer.periodic(interval, (_) {
        if (mounted && _pressed) {
          widget.onPressed?.call();
        }
      });
    });
  }

  void _stopRepeating({bool notify = true}) {
    _delayTimer?.cancel();
    _delayTimer = null;
    _repeatTimer?.cancel();
    _repeatTimer = null;
    if (_pressed && mounted && notify) {
      setState(() => _pressed = false);
    } else {
      _pressed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final states = <WidgetState>{
      if (!_enabled) WidgetState.disabled,
      if (_enabled && _hovered) WidgetState.hovered,
      if (_enabled && _pressed) WidgetState.pressed,
    };
    final background = widget.backgroundColor.resolve(states);
    final foreground = widget.foregroundColor.resolve(states);
    Widget child = AnimatedContainer(
      duration: metroReduceMotion(context)
          ? Duration.zero
          : MetroTheme.of(context).motion.fast,
      curve: MetroTheme.of(context).motion.standardCurve,
      width: widget.extent,
      height: widget.extent,
      color: background,
      child: CustomPaint(
        painter: _MetroNumberGlyphPainter(
          color: foreground ?? const Color(0x00000000),
          iconSize: widget.iconSize,
          increment: widget.increment,
        ),
      ),
    );
    child = MouseRegion(
      cursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: _enabled ? (_) => setState(() => _hovered = true) : null,
      onExit: _enabled ? (_) => setState(() => _hovered = false) : null,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerCancel: (_) => _stopRepeating(),
        onPointerDown: _startRepeating,
        onPointerUp: (_) => _stopRepeating(),
        child: child,
      ),
    );
    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.semanticLabel,
      onTap: widget.onPressed,
      child: ExcludeSemantics(child: child),
    );
  }

  @override
  void dispose() {
    _stopRepeating(notify: false);
    super.dispose();
  }
}

class _MetroNumberGlyphPainter extends CustomPainter {
  const _MetroNumberGlyphPainter({
    required this.color,
    required this.iconSize,
    required this.increment,
  });

  final Color color;
  final double iconSize;
  final bool increment;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.square
      ..strokeWidth = 1.8;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = iconSize / 2;
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      paint,
    );
    if (increment) {
      canvas.drawLine(
        Offset(center.dx, center.dy - radius),
        Offset(center.dx, center.dy + radius),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_MetroNumberGlyphPainter oldDelegate) {
    return color != oldDelegate.color ||
        iconSize != oldDelegate.iconSize ||
        increment != oldDelegate.increment;
  }
}
