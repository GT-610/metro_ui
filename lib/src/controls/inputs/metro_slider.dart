import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../theme/metro_theme.dart';
import '../../theme/metro_theme_data.dart';
import 'metro_slider_style.dart';

export 'metro_slider_style.dart';

/// Formats a slider value for assistive technologies.
typedef MetroSliderValueFormatter = String Function(double value);

/// An immutable pair of ordered values used by [MetroRangeSlider].
@immutable
class MetroRangeValues {
  const MetroRangeValues(this.start, this.end) : assert(start <= end);

  final double start;
  final double end;

  MetroRangeValues copyWith({double? start, double? end}) {
    return MetroRangeValues(start ?? this.start, end ?? this.end);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MetroRangeValues && other.start == start && other.end == end;
  }

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'MetroRangeValues($start, $end)';
}

/// A Windows 8-style slider with a narrow rectangular thumb.
class MetroSlider extends StatefulWidget {
  const MetroSlider({
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.smallChange,
    this.largeChange,
    this.axis = Axis.horizontal,
    this.reversed = false,
    this.tickPlacement = MetroSliderTickPlacement.none,
    this.onChangeStart,
    this.onChangeEnd,
    this.semanticLabel,
    this.semanticFormatterCallback,
    this.style,
    this.autofocus = false,
    this.focusNode,
    super.key,
  }) : assert(max > min),
       assert(value >= min && value <= max),
       assert(divisions == null || divisions > 0),
       assert(smallChange == null || smallChange > 0),
       assert(largeChange == null || largeChange > 0);

  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final int? divisions;
  final double? smallChange;
  final double? largeChange;
  final Axis axis;

  /// Reverses the normal logical direction of increasing values.
  final bool reversed;

  final MetroSliderTickPlacement tickPlacement;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;
  final String? semanticLabel;
  final MetroSliderValueFormatter? semanticFormatterCallback;
  final MetroSliderStyle? style;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  State<MetroSlider> createState() => _MetroSliderState();
}

class _MetroSliderState extends State<MetroSlider> {
  late final FocusNode _internalFocusNode;
  double? _interactionValue;
  bool _dragging = false;
  bool _focused = false;
  bool _hovered = false;
  bool _pressed = false;

  bool get _enabled => widget.onChanged != null;
  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode;
  double get _value => _interactionValue ?? _clampedWidgetValue;
  double get _clampedWidgetValue =>
      _clamp(widget.value, widget.min, widget.max);

  @override
  void initState() {
    super.initState();
    _internalFocusNode = FocusNode(debugLabel: 'MetroSlider');
  }

  @override
  void dispose() {
    _internalFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = MetroTheme.of(context);
    final style = _defaultSliderStyle(theme)
        .merge(theme.sliderTheme.style)
        .merge(MetroSliderTheme.maybeOf(context)?.style)
        .merge(widget.style);
    final textDirection = Directionality.maybeOf(context) ?? TextDirection.ltr;
    final states = _states;
    final thumbSize = style.horizontalThumbSize ?? const Size(10, 16);
    final interactiveExtent = style.minimumInteractiveExtent ?? 44;
    final minimumLength = style.minimumLength ?? 160;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = _surfaceSize(
          constraints: constraints,
          axis: widget.axis,
          interactiveExtent: interactiveExtent,
          minimumLength: minimumLength,
        );
        final geometry = _SliderGeometry(
          axis: widget.axis,
          size: size,
          horizontalThumbSize: thumbSize,
          textDirection: textDirection,
          reversed: widget.reversed,
        );
        final increased = _adjustedValue(_SliderAdjustment.increase);
        final decreased = _adjustedValue(_SliderAdjustment.decrease);

        return Semantics(
          enabled: _enabled,
          increasedValue: _formatValue(increased),
          decreasedValue: _formatValue(decreased),
          label: widget.semanticLabel,
          onDecrease: _enabled
              ? () => _commitAdjustment(_SliderAdjustment.decrease)
              : null,
          onIncrease: _enabled
              ? () => _commitAdjustment(_SliderAdjustment.increase)
              : null,
          slider: true,
          value: _formatValue(_value),
          child: FocusableActionDetector(
            autofocus: widget.autofocus,
            enabled: _enabled,
            focusNode: _focusNode,
            mouseCursor: _enabled
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
            shortcuts: _sliderShortcuts,
            actions: <Type, Action<Intent>>{
              _SliderAdjustIntent: CallbackAction<_SliderAdjustIntent>(
                onInvoke: (intent) {
                  _commitAdjustment(
                    _logicalAdjustment(intent.adjustment, geometry),
                  );
                  return null;
                },
              ),
            },
            onShowFocusHighlight: (value) {
              if (_focused != value) {
                setState(() => _focused = value);
              }
            },
            onShowHoverHighlight: (value) {
              if (_hovered != value) {
                setState(() => _hovered = value);
              }
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              excludeFromSemantics: true,
              onTapCancel: _enabled ? _cancelTap : null,
              onTapDown: _enabled
                  ? (_) {
                      _focusNode.requestFocus();
                      setState(() => _pressed = true);
                    }
                  : null,
              onTapUp: _enabled
                  ? (details) => _commitTap(details.localPosition, geometry)
                  : null,
              onHorizontalDragCancel: _enabled && widget.axis == Axis.horizontal
                  ? _finishDrag
                  : null,
              onHorizontalDragEnd: _enabled && widget.axis == Axis.horizontal
                  ? (_) => _finishDrag()
                  : null,
              onHorizontalDragStart: _enabled && widget.axis == Axis.horizontal
                  ? (details) => _startDrag(details.localPosition, geometry)
                  : null,
              onHorizontalDragUpdate: _enabled && widget.axis == Axis.horizontal
                  ? (details) => _updateDrag(details.localPosition, geometry)
                  : null,
              onVerticalDragCancel: _enabled && widget.axis == Axis.vertical
                  ? _finishDrag
                  : null,
              onVerticalDragEnd: _enabled && widget.axis == Axis.vertical
                  ? (_) => _finishDrag()
                  : null,
              onVerticalDragStart: _enabled && widget.axis == Axis.vertical
                  ? (details) => _startDrag(details.localPosition, geometry)
                  : null,
              onVerticalDragUpdate: _enabled && widget.axis == Axis.vertical
                  ? (details) => _updateDrag(details.localPosition, geometry)
                  : null,
              child: CustomPaint(
                painter: _MetroSliderPainter(
                  activeEnd: _normalize(_value, widget.min, widget.max),
                  activeStart: 0,
                  activeTickColor:
                      style.activeTickColor?.resolve(states) ??
                      const Color(0x00000000),
                  activeTrackColor:
                      style.activeTrackColor?.resolve(states) ??
                      const Color(0x00000000),
                  activeTrackThickness:
                      style.activeTrackThickness?.resolve(states) ?? 5,
                  axis: widget.axis,
                  divisions: widget.divisions,
                  focusColor:
                      style.focusColor?.resolve(states) ??
                      const Color(0x00000000),
                  focusedThumb: _focused ? 0 : null,
                  focusWidth: style.focusWidth?.resolve(states) ?? 2,
                  horizontalThumbSize: thumbSize,
                  reversed: widget.reversed,
                  textDirection: textDirection,
                  thumbColor:
                      style.thumbColor?.resolve(states) ??
                      const Color(0x00000000),
                  thumbValues: [_normalize(_value, widget.min, widget.max)],
                  tickColor:
                      style.tickColor?.resolve(states) ??
                      const Color(0x00000000),
                  tickGap: style.tickGap ?? 2,
                  tickLength: style.tickLength ?? 4,
                  tickPlacement: widget.tickPlacement,
                  tickThickness: style.tickThickness ?? 1,
                  trackColor:
                      style.trackColor?.resolve(states) ??
                      const Color(0x00000000),
                  trackThickness: style.trackThickness?.resolve(states) ?? 3,
                ),
                size: size,
              ),
            ),
          ),
        );
      },
    );
  }

  Set<WidgetState> get _states => <WidgetState>{
    if (!_enabled) WidgetState.disabled,
    if (_enabled && _focused) WidgetState.focused,
    if (_enabled && _hovered) WidgetState.hovered,
    if (_enabled && _pressed) WidgetState.pressed,
  };

  void _cancelTap() {
    if (!_dragging && _pressed) {
      setState(() => _pressed = false);
    }
  }

  void _commitTap(Offset position, _SliderGeometry geometry) {
    final previous = _value;
    final next = _snap(
      geometry.valueForPosition(position, widget.min, widget.max),
      widget.min,
      widget.max,
      widget.divisions,
    );
    setState(() => _pressed = false);
    widget.onChangeStart?.call(previous);
    if (next != previous) {
      widget.onChanged?.call(next);
    }
    widget.onChangeEnd?.call(next);
  }

  void _startDrag(Offset position, _SliderGeometry geometry) {
    _focusNode.requestFocus();
    final previous = _value;
    setState(() {
      _dragging = true;
      _pressed = true;
      _interactionValue = previous;
    });
    widget.onChangeStart?.call(previous);
    _updateDrag(position, geometry);
  }

  void _updateDrag(Offset position, _SliderGeometry geometry) {
    if (!_dragging) {
      return;
    }
    final next = _snap(
      geometry.valueForPosition(position, widget.min, widget.max),
      widget.min,
      widget.max,
      widget.divisions,
    );
    if (next == _value) {
      return;
    }
    setState(() => _interactionValue = next);
    widget.onChanged?.call(next);
  }

  void _finishDrag() {
    if (!_dragging) {
      if (_pressed) {
        setState(() => _pressed = false);
      }
      return;
    }
    final finalValue = _value;
    setState(() {
      _dragging = false;
      _pressed = false;
      _interactionValue = null;
    });
    widget.onChangeEnd?.call(finalValue);
  }

  void _commitAdjustment(_SliderAdjustment adjustment) {
    if (!_enabled) {
      return;
    }
    final previous = _value;
    final next = _adjustedValue(adjustment);
    if (next == previous) {
      return;
    }
    widget.onChangeStart?.call(previous);
    widget.onChanged?.call(next);
    widget.onChangeEnd?.call(next);
  }

  double _adjustedValue(_SliderAdjustment adjustment) {
    final current = _value;
    final small =
        widget.smallChange ??
        (widget.divisions == null
            ? (widget.max - widget.min) / 20
            : (widget.max - widget.min) / widget.divisions!);
    final large = widget.largeChange ?? (widget.max - widget.min) / 10;
    final candidate = switch (adjustment) {
      _SliderAdjustment.decrease => current - small,
      _SliderAdjustment.increase => current + small,
      _SliderAdjustment.pageDown => current - math.max(small, large),
      _SliderAdjustment.pageUp => current + math.max(small, large),
      _SliderAdjustment.minimum => widget.min,
      _SliderAdjustment.maximum => widget.max,
      _SliderAdjustment.left ||
      _SliderAdjustment.right ||
      _SliderAdjustment.up ||
      _SliderAdjustment.down => current,
    };
    return _snap(candidate, widget.min, widget.max, widget.divisions);
  }

  String _formatValue(double value) {
    return widget.semanticFormatterCallback?.call(value) ??
        _defaultValueFormat(value);
  }
}

/// A two-thumb Modern UI slider. The selected segment can also be dragged.
class MetroRangeSlider extends StatefulWidget {
  const MetroRangeSlider({
    required this.values,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.minimumRange = 0,
    this.smallChange,
    this.largeChange,
    this.axis = Axis.horizontal,
    this.reversed = false,
    this.tickPlacement = MetroSliderTickPlacement.none,
    this.allowRangeDrag = true,
    this.onChangeStart,
    this.onChangeEnd,
    this.startSemanticLabel,
    this.endSemanticLabel,
    this.semanticFormatterCallback,
    this.style,
    this.autofocus = false,
    this.startFocusNode,
    this.endFocusNode,
    super.key,
  }) : assert(max > min),
       assert(minimumRange >= 0 && minimumRange <= max - min),
       assert(divisions == null || divisions > 0),
       assert(smallChange == null || smallChange > 0),
       assert(largeChange == null || largeChange > 0);

  final MetroRangeValues values;
  final ValueChanged<MetroRangeValues>? onChanged;
  final double min;
  final double max;
  final int? divisions;
  final double minimumRange;
  final double? smallChange;
  final double? largeChange;
  final Axis axis;
  final bool reversed;
  final MetroSliderTickPlacement tickPlacement;
  final bool allowRangeDrag;
  final ValueChanged<MetroRangeValues>? onChangeStart;
  final ValueChanged<MetroRangeValues>? onChangeEnd;
  final String? startSemanticLabel;
  final String? endSemanticLabel;
  final MetroSliderValueFormatter? semanticFormatterCallback;
  final MetroSliderStyle? style;
  final bool autofocus;
  final FocusNode? startFocusNode;
  final FocusNode? endFocusNode;

  @override
  State<MetroRangeSlider> createState() => _MetroRangeSliderState();
}

class _MetroRangeSliderState extends State<MetroRangeSlider> {
  late final FocusNode _internalStartFocusNode;
  late final FocusNode _internalEndFocusNode;
  MetroRangeValues? _interactionValues;
  MetroRangeValues? _dragOriginValues;
  double? _dragOriginValue;
  Offset? _pointerDownPosition;
  _RangeDragMode? _dragMode;
  _RangeThumb _activeThumb = _RangeThumb.start;
  _RangeThumb? _focusedThumb;
  bool _hovered = false;
  bool _pressed = false;

  bool get _enabled => widget.onChanged != null;
  FocusNode get _startFocusNode =>
      widget.startFocusNode ?? _internalStartFocusNode;
  FocusNode get _endFocusNode => widget.endFocusNode ?? _internalEndFocusNode;
  MetroRangeValues get _values => _interactionValues ?? _clampedWidgetValues;

  MetroRangeValues get _clampedWidgetValues {
    var start = _clamp(widget.values.start, widget.min, widget.max);
    var end = _clamp(widget.values.end, start, widget.max);
    if (end - start < widget.minimumRange) {
      end = math.min(widget.max, start + widget.minimumRange);
      start = math.max(widget.min, end - widget.minimumRange);
    }
    return MetroRangeValues(start, end);
  }

  @override
  void initState() {
    super.initState();
    _internalStartFocusNode = FocusNode(debugLabel: 'MetroRangeSlider start');
    _internalEndFocusNode = FocusNode(debugLabel: 'MetroRangeSlider end');
  }

  @override
  void dispose() {
    _internalStartFocusNode.dispose();
    _internalEndFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.values.start >= widget.min);
    assert(widget.values.end <= widget.max);
    assert(widget.values.end - widget.values.start >= widget.minimumRange);
    final theme = MetroTheme.of(context);
    final style = _defaultSliderStyle(theme)
        .merge(theme.sliderTheme.style)
        .merge(MetroSliderTheme.maybeOf(context)?.style)
        .merge(widget.style);
    final textDirection = Directionality.maybeOf(context) ?? TextDirection.ltr;
    final states = _states;
    final thumbSize = style.horizontalThumbSize ?? const Size(10, 16);
    final interactiveExtent = style.minimumInteractiveExtent ?? 44;
    final minimumLength = style.minimumLength ?? 160;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = _surfaceSize(
          constraints: constraints,
          axis: widget.axis,
          interactiveExtent: interactiveExtent,
          minimumLength: minimumLength,
        );
        final geometry = _SliderGeometry(
          axis: widget.axis,
          size: size,
          horizontalThumbSize: thumbSize,
          textDirection: textDirection,
          reversed: widget.reversed,
        );
        final startT = _normalize(_values.start, widget.min, widget.max);
        final endT = _normalize(_values.end, widget.min, widget.max);
        final startOffset = geometry.offsetForNormalizedValue(startT);
        final endOffset = geometry.offsetForNormalizedValue(endT);

        return MouseRegion(
          cursor: _enabled
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          onEnter: _enabled ? (_) => setState(() => _hovered = true) : null,
          onExit: _enabled ? (_) => setState(() => _hovered = false) : null,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            onTapCancel: _enabled ? _cancelPointer : null,
            onTapUp: _enabled
                ? (details) => _commitRangeTap(details.localPosition, geometry)
                : null,
            onHorizontalDragCancel: _enabled && widget.axis == Axis.horizontal
                ? _finishRangeDrag
                : null,
            onHorizontalDragDown: _enabled && widget.axis == Axis.horizontal
                ? (details) => _preparePointer(details.localPosition, geometry)
                : null,
            onHorizontalDragEnd: _enabled && widget.axis == Axis.horizontal
                ? (_) => _finishRangeDrag()
                : null,
            onHorizontalDragStart: _enabled && widget.axis == Axis.horizontal
                ? (details) => _startRangeDrag(details.localPosition, geometry)
                : null,
            onHorizontalDragUpdate: _enabled && widget.axis == Axis.horizontal
                ? (details) => _updateRangeDrag(details.localPosition, geometry)
                : null,
            onVerticalDragCancel: _enabled && widget.axis == Axis.vertical
                ? _finishRangeDrag
                : null,
            onVerticalDragDown: _enabled && widget.axis == Axis.vertical
                ? (details) => _preparePointer(details.localPosition, geometry)
                : null,
            onVerticalDragEnd: _enabled && widget.axis == Axis.vertical
                ? (_) => _finishRangeDrag()
                : null,
            onVerticalDragStart: _enabled && widget.axis == Axis.vertical
                ? (details) => _startRangeDrag(details.localPosition, geometry)
                : null,
            onVerticalDragUpdate: _enabled && widget.axis == Axis.vertical
                ? (details) => _updateRangeDrag(details.localPosition, geometry)
                : null,
            child: SizedBox.fromSize(
              size: size,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _MetroSliderPainter(
                        activeEnd: endT,
                        activeStart: startT,
                        activeTickColor:
                            style.activeTickColor?.resolve(states) ??
                            const Color(0x00000000),
                        activeTrackColor:
                            style.activeTrackColor?.resolve(states) ??
                            const Color(0x00000000),
                        activeTrackThickness:
                            style.activeTrackThickness?.resolve(states) ?? 5,
                        axis: widget.axis,
                        divisions: widget.divisions,
                        focusColor:
                            style.focusColor?.resolve(states) ??
                            const Color(0x00000000),
                        focusedThumb: _focusedThumb?.index,
                        focusWidth: style.focusWidth?.resolve(states) ?? 2,
                        horizontalThumbSize: thumbSize,
                        reversed: widget.reversed,
                        textDirection: textDirection,
                        thumbColor:
                            style.thumbColor?.resolve(states) ??
                            const Color(0x00000000),
                        thumbValues: [startT, endT],
                        tickColor:
                            style.tickColor?.resolve(states) ??
                            const Color(0x00000000),
                        tickGap: style.tickGap ?? 2,
                        tickLength: style.tickLength ?? 4,
                        tickPlacement: widget.tickPlacement,
                        tickThickness: style.tickThickness ?? 1,
                        trackColor:
                            style.trackColor?.resolve(states) ??
                            const Color(0x00000000),
                        trackThickness:
                            style.trackThickness?.resolve(states) ?? 3,
                      ),
                    ),
                  ),
                  _rangeHandle(
                    geometry: geometry,
                    offset: startOffset,
                    size: size,
                    thumb: _RangeThumb.start,
                  ),
                  _rangeHandle(
                    geometry: geometry,
                    offset: endOffset,
                    size: size,
                    thumb: _RangeThumb.end,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Set<WidgetState> get _states => <WidgetState>{
    if (!_enabled) WidgetState.disabled,
    if (_enabled && _focusedThumb != null) WidgetState.focused,
    if (_enabled && _hovered) WidgetState.hovered,
    if (_enabled && _pressed) WidgetState.pressed,
  };

  Widget _rangeHandle({
    required _SliderGeometry geometry,
    required Offset offset,
    required Size size,
    required _RangeThumb thumb,
  }) {
    final hitExtent = math.min(
      widget.axis == Axis.horizontal ? size.width : size.height,
      44.0,
    );
    final rect = geometry.handleRect(offset, hitExtent);
    final value = thumb == _RangeThumb.start ? _values.start : _values.end;
    final increase = _rangeAdjustedValue(thumb, _SliderAdjustment.increase);
    final decrease = _rangeAdjustedValue(thumb, _SliderAdjustment.decrease);
    final focusNode = thumb == _RangeThumb.start
        ? _startFocusNode
        : _endFocusNode;
    final label = thumb == _RangeThumb.start
        ? widget.startSemanticLabel
        : widget.endSemanticLabel;

    return Positioned.fromRect(
      rect: rect,
      child: Semantics(
        enabled: _enabled,
        increasedValue: _formatValue(increase),
        decreasedValue: _formatValue(decrease),
        label: label,
        onDecrease: _enabled
            ? () => _commitRangeAdjustment(thumb, _SliderAdjustment.decrease)
            : null,
        onIncrease: _enabled
            ? () => _commitRangeAdjustment(thumb, _SliderAdjustment.increase)
            : null,
        slider: true,
        value: _formatValue(value),
        child: FocusableActionDetector(
          autofocus: widget.autofocus && thumb == _RangeThumb.start,
          enabled: _enabled,
          focusNode: focusNode,
          mouseCursor: _enabled
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          shortcuts: _sliderShortcuts,
          actions: <Type, Action<Intent>>{
            _SliderAdjustIntent: CallbackAction<_SliderAdjustIntent>(
              onInvoke: (intent) {
                _activeThumb = thumb;
                _commitRangeAdjustment(
                  thumb,
                  _logicalAdjustment(intent.adjustment, geometry),
                );
                return null;
              },
            ),
          },
          onShowFocusHighlight: (focused) {
            final next = focused
                ? thumb
                : (_focusedThumb == thumb ? null : _focusedThumb);
            if (_focusedThumb != next) {
              setState(() {
                _focusedThumb = next;
                if (focused) {
                  _activeThumb = thumb;
                }
              });
            }
          },
          child: const SizedBox.expand(),
        ),
      ),
    );
  }

  void _preparePointer(Offset position, _SliderGeometry geometry) {
    final thumb = _nearestThumb(position, geometry);
    _activeThumb = thumb;
    _pointerDownPosition = position;
    _focusFor(thumb).requestFocus();
    setState(() => _pressed = true);
  }

  void _cancelPointer() {
    if (_dragMode == null && _pressed) {
      setState(() => _pressed = false);
    }
  }

  void _commitRangeTap(Offset position, _SliderGeometry geometry) {
    final previous = _values;
    final thumb = _nearestThumb(position, geometry);
    final raw = geometry.valueForPosition(position, widget.min, widget.max);
    final next = _valuesWithThumb(thumb, raw);
    setState(() {
      _activeThumb = thumb;
      _pointerDownPosition = null;
      _pressed = false;
    });
    _focusFor(thumb).requestFocus();
    widget.onChangeStart?.call(previous);
    if (next != previous) {
      widget.onChanged?.call(next);
    }
    widget.onChangeEnd?.call(next);
  }

  void _startRangeDrag(Offset position, _SliderGeometry geometry) {
    final previous = _values;
    final originPosition = _pointerDownPosition ?? position;
    final raw = geometry.valueForPosition(
      originPosition,
      widget.min,
      widget.max,
    );
    final thumb = _nearestThumb(originPosition, geometry);
    final mainPosition = geometry.mainCoordinate(originPosition);
    final startPosition = geometry.mainPositionForNormalizedValue(
      _normalize(previous.start, widget.min, widget.max),
    );
    final endPosition = geometry.mainPositionForNormalizedValue(
      _normalize(previous.end, widget.min, widget.max),
    );
    final thumbDistance = math.min(
      (mainPosition - startPosition).abs(),
      (mainPosition - endPosition).abs(),
    );
    final useRange =
        widget.allowRangeDrag &&
        raw > previous.start &&
        raw < previous.end &&
        thumbDistance > math.max(12, geometry.mainThumbExtent);

    _activeThumb = thumb;
    _focusFor(thumb).requestFocus();
    setState(() {
      _pressed = true;
      _dragMode = useRange
          ? _RangeDragMode.range
          : (thumb == _RangeThumb.start
                ? _RangeDragMode.start
                : _RangeDragMode.end);
      _dragOriginValue = raw;
      _dragOriginValues = previous;
      _interactionValues = previous;
    });
    widget.onChangeStart?.call(previous);
    if (!useRange) {
      _updateRangeDrag(position, geometry);
    }
  }

  void _updateRangeDrag(Offset position, _SliderGeometry geometry) {
    final mode = _dragMode;
    if (mode == null) {
      return;
    }
    final raw = geometry.valueForPosition(position, widget.min, widget.max);
    final next = switch (mode) {
      _RangeDragMode.start => _valuesWithThumb(_RangeThumb.start, raw),
      _RangeDragMode.end => _valuesWithThumb(_RangeThumb.end, raw),
      _RangeDragMode.range => _translatedRange(raw),
    };
    if (next == _values) {
      return;
    }
    setState(() => _interactionValues = next);
    widget.onChanged?.call(next);
  }

  MetroRangeValues _translatedRange(double currentValue) {
    final origin = _dragOriginValues ?? _values;
    var delta = currentValue - (_dragOriginValue ?? currentValue);
    if (widget.divisions != null) {
      final snappedStart = _snap(
        origin.start + delta,
        widget.min,
        widget.max,
        widget.divisions,
      );
      delta = snappedStart - origin.start;
    }
    delta = _clamp(delta, widget.min - origin.start, widget.max - origin.end);
    return MetroRangeValues(origin.start + delta, origin.end + delta);
  }

  void _finishRangeDrag() {
    if (_dragMode == null) {
      if (_pressed) {
        setState(() => _pressed = false);
      }
      return;
    }
    final finalValues = _values;
    setState(() {
      _dragMode = null;
      _dragOriginValue = null;
      _dragOriginValues = null;
      _interactionValues = null;
      _pointerDownPosition = null;
      _pressed = false;
    });
    widget.onChangeEnd?.call(finalValues);
  }

  _RangeThumb _nearestThumb(Offset position, _SliderGeometry geometry) {
    final main = geometry.mainCoordinate(position);
    final start = geometry.mainPositionForNormalizedValue(
      _normalize(_values.start, widget.min, widget.max),
    );
    final end = geometry.mainPositionForNormalizedValue(
      _normalize(_values.end, widget.min, widget.max),
    );
    final startDistance = (main - start).abs();
    final endDistance = (main - end).abs();
    if (startDistance == endDistance) {
      return _activeThumb;
    }
    return startDistance < endDistance ? _RangeThumb.start : _RangeThumb.end;
  }

  FocusNode _focusFor(_RangeThumb thumb) {
    return thumb == _RangeThumb.start ? _startFocusNode : _endFocusNode;
  }

  MetroRangeValues _valuesWithThumb(_RangeThumb thumb, double rawValue) {
    final value = _snap(rawValue, widget.min, widget.max, widget.divisions);
    final current = _values;
    if (thumb == _RangeThumb.start) {
      return MetroRangeValues(
        math.min(value, current.end - widget.minimumRange),
        current.end,
      );
    }
    return MetroRangeValues(
      current.start,
      math.max(value, current.start + widget.minimumRange),
    );
  }

  void _commitRangeAdjustment(_RangeThumb thumb, _SliderAdjustment adjustment) {
    if (!_enabled) {
      return;
    }
    final previous = _values;
    final value = _rangeAdjustedValue(thumb, adjustment);
    final next = _valuesWithThumb(thumb, value);
    if (next == previous) {
      return;
    }
    widget.onChangeStart?.call(previous);
    widget.onChanged?.call(next);
    widget.onChangeEnd?.call(next);
  }

  double _rangeAdjustedValue(_RangeThumb thumb, _SliderAdjustment adjustment) {
    final current = thumb == _RangeThumb.start ? _values.start : _values.end;
    final small =
        widget.smallChange ??
        (widget.divisions == null
            ? (widget.max - widget.min) / 20
            : (widget.max - widget.min) / widget.divisions!);
    final large = widget.largeChange ?? (widget.max - widget.min) / 10;
    final minimum = thumb == _RangeThumb.start
        ? widget.min
        : _values.start + widget.minimumRange;
    final maximum = thumb == _RangeThumb.start
        ? _values.end - widget.minimumRange
        : widget.max;
    final candidate = switch (adjustment) {
      _SliderAdjustment.decrease => current - small,
      _SliderAdjustment.increase => current + small,
      _SliderAdjustment.pageDown => current - math.max(small, large),
      _SliderAdjustment.pageUp => current + math.max(small, large),
      _SliderAdjustment.minimum => minimum,
      _SliderAdjustment.maximum => maximum,
      _SliderAdjustment.left ||
      _SliderAdjustment.right ||
      _SliderAdjustment.up ||
      _SliderAdjustment.down => current,
    };
    return _clamp(
      _snap(candidate, widget.min, widget.max, widget.divisions),
      minimum,
      maximum,
    );
  }

  String _formatValue(double value) {
    return widget.semanticFormatterCallback?.call(value) ??
        _defaultValueFormat(value);
  }
}

enum _SliderAdjustment {
  decrease,
  increase,
  pageDown,
  pageUp,
  minimum,
  maximum,
  left,
  right,
  up,
  down,
}

enum _RangeThumb { start, end }

enum _RangeDragMode { start, end, range }

class _SliderAdjustIntent extends Intent {
  const _SliderAdjustIntent(this.adjustment);

  final _SliderAdjustment adjustment;
}

const Map<ShortcutActivator, Intent> _sliderShortcuts =
    <ShortcutActivator, Intent>{
      SingleActivator(LogicalKeyboardKey.arrowLeft): _SliderAdjustIntent(
        _SliderAdjustment.left,
      ),
      SingleActivator(LogicalKeyboardKey.arrowRight): _SliderAdjustIntent(
        _SliderAdjustment.right,
      ),
      SingleActivator(LogicalKeyboardKey.arrowUp): _SliderAdjustIntent(
        _SliderAdjustment.up,
      ),
      SingleActivator(LogicalKeyboardKey.arrowDown): _SliderAdjustIntent(
        _SliderAdjustment.down,
      ),
      SingleActivator(LogicalKeyboardKey.pageUp): _SliderAdjustIntent(
        _SliderAdjustment.pageUp,
      ),
      SingleActivator(LogicalKeyboardKey.pageDown): _SliderAdjustIntent(
        _SliderAdjustment.pageDown,
      ),
      SingleActivator(LogicalKeyboardKey.home): _SliderAdjustIntent(
        _SliderAdjustment.minimum,
      ),
      SingleActivator(LogicalKeyboardKey.end): _SliderAdjustIntent(
        _SliderAdjustment.maximum,
      ),
    };

_SliderAdjustment _logicalAdjustment(
  _SliderAdjustment adjustment,
  _SliderGeometry geometry,
) {
  return switch (adjustment) {
    _SliderAdjustment.left =>
      geometry.valueIncreasesTowardRight
          ? _SliderAdjustment.decrease
          : _SliderAdjustment.increase,
    _SliderAdjustment.right =>
      geometry.valueIncreasesTowardRight
          ? _SliderAdjustment.increase
          : _SliderAdjustment.decrease,
    _SliderAdjustment.up =>
      geometry.valueIncreasesTowardBottom
          ? _SliderAdjustment.decrease
          : _SliderAdjustment.increase,
    _SliderAdjustment.down =>
      geometry.valueIncreasesTowardBottom
          ? _SliderAdjustment.increase
          : _SliderAdjustment.decrease,
    _ => adjustment,
  };
}

class _SliderGeometry {
  const _SliderGeometry({
    required this.axis,
    required this.size,
    required this.horizontalThumbSize,
    required this.textDirection,
    required this.reversed,
  });

  final Axis axis;
  final Size size;
  final Size horizontalThumbSize;
  final TextDirection textDirection;
  final bool reversed;

  Size get thumbSize => axis == Axis.horizontal
      ? horizontalThumbSize
      : Size(horizontalThumbSize.height, horizontalThumbSize.width);

  double get mainExtent => axis == Axis.horizontal ? size.width : size.height;
  double get mainThumbExtent =>
      axis == Axis.horizontal ? thumbSize.width : thumbSize.height;
  double get trackStart => mainThumbExtent / 2;
  double get trackEnd => mainExtent - mainThumbExtent / 2;
  double get trackExtent => math.max(0, trackEnd - trackStart);

  bool get _flipped => axis == Axis.horizontal
      ? (textDirection == TextDirection.rtl) != reversed
      : !reversed;

  bool get valueIncreasesTowardRight => axis == Axis.horizontal && !_flipped;
  bool get valueIncreasesTowardBottom => axis == Axis.vertical && !_flipped;

  double mainCoordinate(Offset position) {
    return axis == Axis.horizontal ? position.dx : position.dy;
  }

  double mainPositionForNormalizedValue(double value) {
    final physical = _flipped ? 1 - value : value;
    return trackStart + physical * trackExtent;
  }

  Offset offsetForNormalizedValue(double value) {
    final main = mainPositionForNormalizedValue(value);
    return axis == Axis.horizontal
        ? Offset(main, size.height / 2)
        : Offset(size.width / 2, main);
  }

  double valueForPosition(Offset position, double min, double max) {
    final physical = trackExtent == 0
        ? 0.0
        : ((mainCoordinate(position) - trackStart) / trackExtent).clamp(
            0.0,
            1.0,
          );
    final logical = _flipped ? 1 - physical : physical;
    return min + logical * (max - min);
  }

  Rect handleRect(Offset center, double extent) {
    if (axis == Axis.horizontal) {
      final width = math.min(extent, size.width);
      final left = (center.dx - width / 2).clamp(0.0, size.width - width);
      return Rect.fromLTWH(left, 0, width, size.height);
    }
    final height = math.min(extent, size.height);
    final top = (center.dy - height / 2).clamp(0.0, size.height - height);
    return Rect.fromLTWH(0, top, size.width, height);
  }
}

class _MetroSliderPainter extends CustomPainter {
  const _MetroSliderPainter({
    required this.axis,
    required this.textDirection,
    required this.reversed,
    required this.horizontalThumbSize,
    required this.trackColor,
    required this.activeTrackColor,
    required this.thumbColor,
    required this.tickColor,
    required this.activeTickColor,
    required this.focusColor,
    required this.trackThickness,
    required this.activeTrackThickness,
    required this.focusWidth,
    required this.tickLength,
    required this.tickThickness,
    required this.tickGap,
    required this.tickPlacement,
    required this.divisions,
    required this.activeStart,
    required this.activeEnd,
    required this.thumbValues,
    required this.focusedThumb,
  });

  final Axis axis;
  final TextDirection textDirection;
  final bool reversed;
  final Size horizontalThumbSize;
  final Color trackColor;
  final Color activeTrackColor;
  final Color thumbColor;
  final Color tickColor;
  final Color activeTickColor;
  final Color focusColor;
  final double trackThickness;
  final double activeTrackThickness;
  final double focusWidth;
  final double tickLength;
  final double tickThickness;
  final double tickGap;
  final MetroSliderTickPlacement tickPlacement;
  final int? divisions;
  final double activeStart;
  final double activeEnd;
  final List<double> thumbValues;
  final int? focusedThumb;

  @override
  void paint(Canvas canvas, Size size) {
    final geometry = _SliderGeometry(
      axis: axis,
      size: size,
      horizontalThumbSize: horizontalThumbSize,
      textDirection: textDirection,
      reversed: reversed,
    );
    final start = geometry.offsetForNormalizedValue(0);
    final end = geometry.offsetForNormalizedValue(1);
    _drawSegment(canvas, start, end, trackThickness, trackColor);
    _drawSegment(
      canvas,
      geometry.offsetForNormalizedValue(activeStart),
      geometry.offsetForNormalizedValue(activeEnd),
      activeTrackThickness,
      activeTrackColor,
    );
    _drawTicks(canvas, geometry);

    final order = <int>[
      for (var index = 0; index < thumbValues.length; index += 1)
        if (index != focusedThumb) index,
      ?focusedThumb,
    ];
    for (final index in order) {
      final center = geometry.offsetForNormalizedValue(thumbValues[index]);
      final rect = Rect.fromCenter(
        center: center,
        width: geometry.thumbSize.width,
        height: geometry.thumbSize.height,
      );
      canvas.drawRect(rect, Paint()..color = thumbColor);
      if (index == focusedThumb && focusWidth > 0) {
        canvas.drawRect(
          rect.inflate(3),
          Paint()
            ..color = focusColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = focusWidth,
        );
      }
    }
  }

  void _drawSegment(
    Canvas canvas,
    Offset first,
    Offset second,
    double thickness,
    Color color,
  ) {
    if (thickness <= 0) {
      return;
    }
    final rect = axis == Axis.horizontal
        ? Rect.fromLTRB(
            math.min(first.dx, second.dx),
            first.dy - thickness / 2,
            math.max(first.dx, second.dx),
            first.dy + thickness / 2,
          )
        : Rect.fromLTRB(
            first.dx - thickness / 2,
            math.min(first.dy, second.dy),
            first.dx + thickness / 2,
            math.max(first.dy, second.dy),
          );
    canvas.drawRect(rect, Paint()..color = color);
  }

  void _drawTicks(Canvas canvas, _SliderGeometry geometry) {
    final count = divisions;
    if (count == null ||
        tickPlacement == MetroSliderTickPlacement.none ||
        tickLength <= 0 ||
        tickThickness <= 0) {
      return;
    }
    for (var index = 0; index <= count; index += 1) {
      final value = index / count;
      final active = value >= activeStart && value <= activeEnd;
      final color = active ? activeTickColor : tickColor;
      final center = geometry.offsetForNormalizedValue(value);
      if (tickPlacement == MetroSliderTickPlacement.before ||
          tickPlacement == MetroSliderTickPlacement.both) {
        _drawTick(canvas, geometry, center, before: true, color: color);
      }
      if (tickPlacement == MetroSliderTickPlacement.after ||
          tickPlacement == MetroSliderTickPlacement.both) {
        _drawTick(canvas, geometry, center, before: false, color: color);
      }
    }
  }

  void _drawTick(
    Canvas canvas,
    _SliderGeometry geometry,
    Offset center, {
    required bool before,
    required Color color,
  }) {
    final thumb = geometry.thumbSize;
    final rect = axis == Axis.horizontal
        ? Rect.fromLTWH(
            center.dx - tickThickness / 2,
            before
                ? center.dy - thumb.height / 2 - tickGap - tickLength
                : center.dy + thumb.height / 2 + tickGap,
            tickThickness,
            tickLength,
          )
        : Rect.fromLTWH(
            before
                ? center.dx - thumb.width / 2 - tickGap - tickLength
                : center.dx + thumb.width / 2 + tickGap,
            center.dy - tickThickness / 2,
            tickLength,
            tickThickness,
          );
    canvas.drawRect(rect, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_MetroSliderPainter oldDelegate) => true;
}

MetroSliderStyle _defaultSliderStyle(MetroThemeData theme) {
  final colors = theme.colors;
  return MetroSliderStyle(
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return colors.disabledBackground;
      }
      return states.contains(WidgetState.hovered)
          ? colors.surfaceVariant
          : colors.border;
    }),
    activeTrackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return colors.disabledBackground;
      }
      return states.contains(WidgetState.pressed)
          ? colors.accentPressed
          : colors.accent;
    }),
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return colors.disabledForeground;
      }
      return states.contains(WidgetState.pressed)
          ? colors.accentPressed
          : colors.foreground;
    }),
    tickColor: WidgetStateProperty.resolveWith((states) {
      return states.contains(WidgetState.disabled)
          ? colors.disabledBackground
          : colors.border;
    }),
    activeTickColor: WidgetStateProperty.resolveWith((states) {
      return states.contains(WidgetState.disabled)
          ? colors.disabledBackground
          : colors.accent;
    }),
    focusColor: WidgetStatePropertyAll(colors.focus),
    trackThickness: const WidgetStatePropertyAll(3),
    activeTrackThickness: const WidgetStatePropertyAll(5),
    focusWidth: const WidgetStatePropertyAll(2),
    horizontalThumbSize: const Size(10, 16),
    minimumInteractiveExtent: 44,
    minimumLength: 160,
    tickLength: 4,
    tickThickness: 1,
    tickGap: 2,
  );
}

Size _surfaceSize({
  required BoxConstraints constraints,
  required Axis axis,
  required double interactiveExtent,
  required double minimumLength,
}) {
  if (axis == Axis.horizontal) {
    final width = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : minimumLength;
    return constraints.constrain(Size(width, interactiveExtent));
  }
  final height = constraints.hasBoundedHeight
      ? constraints.maxHeight
      : minimumLength;
  return constraints.constrain(Size(interactiveExtent, height));
}

double _normalize(double value, double min, double max) {
  return max == min ? 0 : ((value - min) / (max - min)).clamp(0.0, 1.0);
}

double _clamp(double value, double min, double max) {
  return value.clamp(min, max).toDouble();
}

double _snap(double value, double min, double max, int? divisions) {
  final clamped = _clamp(value, min, max);
  if (divisions == null) {
    return clamped;
  }
  final step = (max - min) / divisions;
  return _clamp(min + ((clamped - min) / step).round() * step, min, max);
}

String _defaultValueFormat(double value) {
  return value.toStringAsFixed(6).replaceFirst(RegExp(r'\.?0+$'), '');
}
