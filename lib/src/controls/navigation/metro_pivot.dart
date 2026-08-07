import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/metro_accessibility.dart';
import '../../foundation/metro_interactive.dart';
import '../../theme/metro_theme.dart';

/// One header/content pair displayed by a [MetroPivot].
@immutable
class MetroPivotItem {
  const MetroPivotItem({required this.header, required this.child});

  final Widget header;
  final Widget child;
}

/// Typography and spacing values used by [MetroPivot].
@immutable
class MetroPivotThemeData {
  const MetroPivotThemeData({
    this.headerStyle,
    this.selectedHeaderStyle,
    double? headerSpacing,
    double? contentSpacing,
    this.contentPadding,
  }) : assert(headerSpacing == null || headerSpacing >= 0),
       assert(contentSpacing == null || contentSpacing >= 0),
       _headerSpacing = headerSpacing,
       _contentSpacing = contentSpacing;

  final TextStyle? headerStyle;
  final TextStyle? selectedHeaderStyle;
  final double? _headerSpacing;
  final double? _contentSpacing;
  final EdgeInsetsGeometry? contentPadding;

  double get headerSpacing => _headerSpacing ?? 18;
  double get contentSpacing => _contentSpacing ?? 28;

  MetroPivotThemeData copyWith({
    TextStyle? headerStyle,
    TextStyle? selectedHeaderStyle,
    double? headerSpacing,
    double? contentSpacing,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return MetroPivotThemeData(
      headerStyle: headerStyle ?? this.headerStyle,
      selectedHeaderStyle: selectedHeaderStyle ?? this.selectedHeaderStyle,
      headerSpacing: headerSpacing ?? _headerSpacing,
      contentSpacing: contentSpacing ?? _contentSpacing,
      contentPadding: contentPadding ?? this.contentPadding,
    );
  }

  MetroPivotThemeData merge(MetroPivotThemeData? other) {
    if (other == null) return this;
    return MetroPivotThemeData(
      headerStyle: other.headerStyle ?? headerStyle,
      selectedHeaderStyle: other.selectedHeaderStyle ?? selectedHeaderStyle,
      headerSpacing: other._headerSpacing ?? _headerSpacing,
      contentSpacing: other._contentSpacing ?? _contentSpacing,
      contentPadding: other.contentPadding ?? contentPadding,
    );
  }

  static MetroPivotThemeData lerp(
    MetroPivotThemeData a,
    MetroPivotThemeData b,
    double t,
  ) {
    return MetroPivotThemeData(
      headerStyle: TextStyle.lerp(a.headerStyle, b.headerStyle, t),
      selectedHeaderStyle: TextStyle.lerp(
        a.selectedHeaderStyle,
        b.selectedHeaderStyle,
        t,
      ),
      headerSpacing: a.headerSpacing + (b.headerSpacing - a.headerSpacing) * t,
      contentSpacing:
          a.contentSpacing + (b.contentSpacing - a.contentSpacing) * t,
      contentPadding: EdgeInsetsGeometry.lerp(
        a.contentPadding,
        b.contentPadding,
        t,
      ),
    );
  }
}

/// Overrides Pivot typography and spacing for a subtree.
class MetroPivotTheme extends InheritedTheme {
  const MetroPivotTheme({required this.data, required super.child, super.key});

  final MetroPivotThemeData data;

  static MetroPivotThemeData? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MetroPivotTheme>()?.data;
  }

  static MetroPivotThemeData of(BuildContext context) {
    return maybeOf(context) ?? const MetroPivotThemeData();
  }

  @override
  bool updateShouldNotify(MetroPivotTheme oldWidget) => data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) {
    return MetroPivotTheme(data: data, child: child);
  }
}

/// Horizontal, swipeable navigation modeled after the Windows 8 Pivot.
class MetroPivot extends StatefulWidget {
  const MetroPivot({
    required this.items,
    this.index,
    this.initialIndex = 0,
    this.onChanged,
    this.swipeEnabled = true,
    this.autofocus = false,
    super.key,
  }) : assert(items.length > 0),
       assert(initialIndex >= 0 && initialIndex < items.length),
       assert(index == null || (index >= 0 && index < items.length));

  final List<MetroPivotItem> items;
  final int? index;
  final int initialIndex;
  final ValueChanged<int>? onChanged;
  final bool swipeEnabled;
  final bool autofocus;

  @override
  State<MetroPivot> createState() => _MetroPivotState();
}

class _MetroPivotState extends State<MetroPivot>
    with SingleTickerProviderStateMixin {
  late int _index = widget.index ?? widget.initialIndex;
  late int _displayedIndex = _index;
  late final AnimationController _contentController;
  Animation<double>? _outgoingProgressAnimation;
  Animation<double>? _incomingProgressAnimation;
  Animation<double>? _outgoingOffsetAnimation;
  Animation<double>? _incomingOffsetAnimation;
  Animation<double>? _dragOffsetAnimation;
  int? _incomingIndex;
  int _transitionDirection = 1;
  double _dragOffset = 0;
  double _viewportWidth = 0;
  double _physicalForwardSign = 1;
  bool _programmaticTransition = false;
  bool _commitAnimation = false;

  int get _effectiveIndex => widget.index ?? _index;
  bool get _isAnimating => _contentController.isAnimating;

  @override
  void initState() {
    super.initState();
    _contentController = AnimationController(vsync: this)
      ..addListener(_handleAnimationTick)
      ..addStatusListener(_handleAnimationStatus);
  }

  @override
  void didUpdateWidget(MetroPivot oldWidget) {
    super.didUpdateWidget(oldWidget);
    final lastIndex = widget.items.length - 1;
    if (_index > lastIndex ||
        _displayedIndex > lastIndex ||
        (_incomingIndex != null && _incomingIndex! > lastIndex)) {
      _cancelAnimation(resetController: false);
      final target = widget.index ?? (_index > lastIndex ? lastIndex : _index);
      _index = target;
      _displayedIndex = target;
    }
    if (widget.index != null && widget.index != oldWidget.index) {
      _schedulePageChange(widget.index!);
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _select(int index) {
    if (index == _effectiveIndex || _isAnimating || _incomingIndex != null) {
      return;
    }
    if (widget.index == null) {
      setState(() => _index = index);
    }
    widget.onChanged?.call(index);
    _startProgrammaticTransition(index);
  }

  void _schedulePageChange(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && index != _displayedIndex && index != _incomingIndex) {
        _startProgrammaticTransition(index);
      }
    });
  }

  void _startProgrammaticTransition(int index) {
    if (index == _displayedIndex || _viewportWidth <= 0) {
      if (_viewportWidth <= 0) {
        _schedulePageChange(index);
      }
      return;
    }
    if (metroReduceMotion(context)) {
      _cancelAnimation();
      setState(() => _displayedIndex = index);
      return;
    }

    final motion = MetroTheme.of(context).motion;
    _contentController.stop();
    _contentController.reset();
    _transitionDirection = index > _displayedIndex ? 1 : -1;
    _programmaticTransition = true;
    _commitAnimation = true;
    _dragOffset = 0;
    _incomingIndex = index;
    _contentController.duration = motion.content * 2;
    _outgoingProgressAnimation = CurvedAnimation(
      parent: _contentController,
      curve: Interval(0, 0.5, curve: motion.contentExitCurve),
    );
    _incomingProgressAnimation = CurvedAnimation(
      parent: _contentController,
      curve: Interval(0.5, 1, curve: motion.contentExitCurve.flipped),
    );
    _outgoingOffsetAnimation = Tween<double>(
      begin: 0,
      end: -_physicalForwardSign * _transitionDirection * _viewportWidth,
    ).animate(_outgoingProgressAnimation!);
    _incomingOffsetAnimation = Tween<double>(
      begin: _physicalForwardSign * _transitionDirection * _viewportWidth,
      end: 0,
    ).animate(_incomingProgressAnimation!);
    _dragOffsetAnimation = null;
    setState(() {});
    _contentController.forward(from: 0);
  }

  void _handleAnimationTick() {
    if (!mounted) return;
    final dragAnimation = _dragOffsetAnimation;
    setState(() {
      if (dragAnimation != null) {
        _dragOffset = dragAnimation.value;
      }
    });
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || !mounted) return;
    final target = _incomingIndex;
    final commit = _commitAnimation && target != null;
    _outgoingProgressAnimation = null;
    _incomingProgressAnimation = null;
    _outgoingOffsetAnimation = null;
    _incomingOffsetAnimation = null;
    _dragOffsetAnimation = null;
    _programmaticTransition = false;
    _contentController.reset();
    setState(() {
      if (commit) {
        _displayedIndex = target;
      }
      _incomingIndex = null;
      _dragOffset = 0;
      _commitAnimation = false;
    });
    if (commit) {
      _scheduleControlledReconciliation();
    }
  }

  void _scheduleControlledReconciliation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final controlledIndex = widget.index;
      if (controlledIndex != null &&
          controlledIndex != _displayedIndex &&
          _incomingIndex == null) {
        _startProgrammaticTransition(controlledIndex);
      }
    });
  }

  void _cancelAnimation({bool resetController = true}) {
    _contentController.stop();
    _outgoingProgressAnimation = null;
    _incomingProgressAnimation = null;
    _outgoingOffsetAnimation = null;
    _incomingOffsetAnimation = null;
    _dragOffsetAnimation = null;
    _programmaticTransition = false;
    if (resetController) {
      _contentController.reset();
    }
    _incomingIndex = null;
    _dragOffset = 0;
    _commitAnimation = false;
  }

  int? _neighbor(int direction) {
    final target = _displayedIndex + direction;
    return target >= 0 && target < widget.items.length ? target : null;
  }

  void _handleDragStart(DragStartDetails details) {
    if (!widget.swipeEnabled || _isAnimating) return;
    setState(() {
      _incomingIndex = null;
      _dragOffset = 0;
      _programmaticTransition = false;
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!widget.swipeEnabled || _isAnimating || _viewportWidth <= 0) return;
    final delta = details.primaryDelta ?? 0;
    var candidate = (_dragOffset + delta).clamp(
      -_viewportWidth,
      _viewportWidth,
    );
    if (candidate == 0) {
      setState(() {
        _dragOffset = 0;
        _incomingIndex = null;
      });
      return;
    }
    final direction = candidate * _physicalForwardSign < 0 ? 1 : -1;
    final target = _neighbor(direction);
    if (target == null) {
      final limit = _viewportWidth * 0.12;
      candidate = candidate.clamp(-limit, limit) * 0.35;
    }
    setState(() {
      _dragOffset = candidate;
      _transitionDirection = direction;
      _incomingIndex = target;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!widget.swipeEnabled || _viewportWidth <= 0) return;
    final target = _incomingIndex;
    if (target == null) {
      _settleDrag(commit: false);
      return;
    }
    final velocity = (details.primaryVelocity ?? 0) * _physicalForwardSign;
    final velocityCommits = _transitionDirection > 0
        ? velocity < -500
        : velocity > 500;
    final distanceCommits = _dragOffset.abs() >= _viewportWidth * 0.2;
    final commit = velocityCommits || distanceCommits;
    if (commit) {
      if (widget.index == null) {
        setState(() => _index = target);
      }
      widget.onChanged?.call(target);
    }
    _settleDrag(commit: commit);
  }

  void _settleDrag({required bool commit}) {
    final target = _incomingIndex;
    if (_dragOffset == 0) return;
    if (metroReduceMotion(context)) {
      setState(() {
        if (commit && target != null) {
          _displayedIndex = target;
        }
        _incomingIndex = null;
        _dragOffset = 0;
      });
      if (commit) _scheduleControlledReconciliation();
      return;
    }
    final end = commit && target != null
        ? -_physicalForwardSign * _transitionDirection * _viewportWidth
        : 0.0;
    final motion = MetroTheme.of(context).motion;
    _programmaticTransition = false;
    _commitAnimation = commit;
    _contentController.duration = motion.normal;
    _outgoingProgressAnimation = null;
    _incomingProgressAnimation = null;
    _outgoingOffsetAnimation = null;
    _incomingOffsetAnimation = null;
    _dragOffsetAnimation = Tween<double>(begin: _dragOffset, end: end).animate(
      CurvedAnimation(parent: _contentController, curve: motion.standardCurve),
    );
    _contentController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = MetroTheme.of(context);
    final pivotTheme = theme.pivotTheme.merge(MetroPivotTheme.maybeOf(context));
    final defaultHeaderStyle = theme.typography.hero.copyWith(
      fontSize: 60,
      fontWeight: FontWeight.w400,
      height: 1.2,
      letterSpacing: 0,
    );
    final headerStyle =
        pivotTheme.headerStyle ??
        defaultHeaderStyle.copyWith(
          color: theme.colors.foreground.withValues(
            alpha: theme.colors.isDark ? 0.4 : 0.2,
          ),
        );
    final selectedHeaderStyle =
        pivotTheme.selectedHeaderStyle ??
        defaultHeaderStyle.copyWith(color: theme.colors.foreground);
    final contentPadding =
        pivotTheme.contentPadding ??
        const EdgeInsetsDirectional.symmetric(horizontal: 19);

    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.arrowLeft): _PreviousPivotIntent(),
        SingleActivator(LogicalKeyboardKey.arrowRight): _NextPivotIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _PreviousPivotIntent: CallbackAction<_PreviousPivotIntent>(
            onInvoke: (intent) {
              final direction = Directionality.of(context);
              final delta = direction == TextDirection.ltr ? -1 : 1;
              _select(
                (_effectiveIndex + delta).clamp(0, widget.items.length - 1),
              );
              return null;
            },
          ),
          _NextPivotIntent: CallbackAction<_NextPivotIntent>(
            onInvoke: (intent) {
              final direction = Directionality.of(context);
              final delta = direction == TextDirection.ltr ? 1 : -1;
              _select(
                (_effectiveIndex + delta).clamp(0, widget.items.length - 1),
              );
              return null;
            },
          ),
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var index = 0; index < widget.items.length; index += 1)
                    Padding(
                      padding: EdgeInsetsDirectional.only(
                        end: index == widget.items.length - 1
                            ? 0
                            : pivotTheme.headerSpacing,
                      ),
                      child: MetroInteractive(
                        autofocus: widget.autofocus && index == _effectiveIndex,
                        onPressed: () => _select(index),
                        semanticSelected: index == _effectiveIndex,
                        builder: (context, states) {
                          final selected = index == _effectiveIndex;
                          return AnimatedDefaultTextStyle(
                            duration: metroReduceMotion(context)
                                ? Duration.zero
                                : theme.motion.normal,
                            style: selected ? selectedHeaderStyle : headerStyle,
                            child: CustomPaint(
                              foregroundPainter:
                                  states.contains(WidgetState.focused)
                                  ? _PivotFocusPainter(
                                      color: theme.colors.focus,
                                    )
                                  : null,
                              child: widget.items[index].header,
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: pivotTheme.contentSpacing),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  assert(
                    constraints.hasBoundedWidth,
                    'MetroPivot must have a bounded content width.',
                  );
                  _viewportWidth = constraints.maxWidth;
                  _physicalForwardSign =
                      Directionality.of(context) == TextDirection.ltr ? 1 : -1;
                  final incomingIndex = _incomingIndex;
                  final outgoingOffset = _programmaticTransition
                      ? (_outgoingOffsetAnimation?.value ?? 0)
                      : _dragOffset;
                  final incomingOffset = _programmaticTransition
                      ? (_incomingOffsetAnimation?.value ?? 0)
                      : _physicalForwardSign *
                                _transitionDirection *
                                _viewportWidth +
                            _dragOffset;
                  final outgoingOpacity = _programmaticTransition
                      ? (1 - (_outgoingProgressAnimation?.value ?? 0))
                            .clamp(0.0, 1.0)
                            .toDouble()
                      : 1.0;
                  final incomingOpacity = _programmaticTransition
                      ? (_incomingProgressAnimation?.value ?? 0)
                            .clamp(0.0, 1.0)
                            .toDouble()
                      : 1.0;
                  final hidden = <int>[
                    for (var index = 0; index < widget.items.length; index += 1)
                      if (index != _displayedIndex && index != incomingIndex)
                        index,
                  ];
                  final paintOrder = <int>[
                    ...hidden,
                    ?incomingIndex,
                    _displayedIndex,
                  ];
                  Widget content = ClipRect(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        for (final index in paintOrder)
                          Positioned.fill(
                            key: ValueKey<String>('metro-pivot-page-$index'),
                            child: Offstage(
                              offstage:
                                  index != _displayedIndex &&
                                  index != incomingIndex,
                              child: TickerMode(
                                enabled:
                                    index == _displayedIndex ||
                                    index == incomingIndex,
                                child: IgnorePointer(
                                  ignoring:
                                      _incomingIndex != null ||
                                      index != _displayedIndex,
                                  child: Opacity(
                                    key: ValueKey<String>(
                                      'metro-pivot-page-$index-opacity',
                                    ),
                                    opacity: index == _displayedIndex
                                        ? outgoingOpacity
                                        : incomingOpacity,
                                    child: Transform.translate(
                                      key: ValueKey<String>(
                                        'metro-pivot-page-$index-transform',
                                      ),
                                      offset: Offset(
                                        index == _displayedIndex
                                            ? outgoingOffset
                                            : incomingOffset,
                                        0,
                                      ),
                                      child: Padding(
                                        padding: contentPadding,
                                        child: widget.items[index].child,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                  if (widget.swipeEnabled) {
                    content = GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragStart: _handleDragStart,
                      onHorizontalDragUpdate: _handleDragUpdate,
                      onHorizontalDragEnd: _handleDragEnd,
                      onHorizontalDragCancel: () => _settleDrag(commit: false),
                      child: content,
                    );
                  }
                  return content;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviousPivotIntent extends Intent {
  const _PreviousPivotIntent();
}

class _NextPivotIntent extends Intent {
  const _NextPivotIntent();
}

class _PivotFocusPainter extends CustomPainter {
  const _PivotFocusPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 1 || size.height <= 1) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final rect = Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1);
    _drawDottedLine(canvas, rect.topLeft, rect.topRight, paint);
    _drawDottedLine(canvas, rect.topRight, rect.bottomRight, paint);
    _drawDottedLine(canvas, rect.bottomRight, rect.bottomLeft, paint);
    _drawDottedLine(canvas, rect.bottomLeft, rect.topLeft, paint);
  }

  void _drawDottedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    final delta = end - start;
    final length = delta.distance;
    if (length == 0) return;
    final direction = delta / length;
    for (double distance = 0; distance < length; distance += 3) {
      final dot = start + direction * distance;
      canvas.drawLine(dot, dot + direction, paint);
    }
  }

  @override
  bool shouldRepaint(_PivotFocusPainter oldDelegate) =>
      oldDelegate.color != color;
}
