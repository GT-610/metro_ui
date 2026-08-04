import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../localization/metro_localizations.dart';
import '../../theme/metro_theme.dart';
import 'metro_progress_ring_theme.dart';

export 'metro_progress_ring_theme.dart';

/// A five-dot Metro activity indicator, or a determinate circular indicator
/// when [value] is supplied.
class MetroProgressRing extends StatefulWidget {
  const MetroProgressRing({
    this.value,
    this.color,
    this.trackColor,
    this.size,
    this.strokeWidth,
    this.active = true,
    this.semanticLabel,
    this.semanticValue,
    super.key,
  }) : assert(value == null || (value >= 0 && value <= 1));

  final double? value;
  final Color? color;
  final Color? trackColor;
  final double? size;
  final double? strokeWidth;

  /// Whether an indeterminate ring is visible and animated.
  ///
  /// Determinate progress remains visible regardless of this value.
  final bool active;
  final String? semanticLabel;
  final String? semanticValue;

  @override
  State<MetroProgressRing> createState() => _MetroProgressRingState();
}

class _MetroProgressRingState extends State<MetroProgressRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(MetroProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAnimation();
  }

  void _syncAnimation() {
    final progressTheme = _progressTheme(context);
    _controller.duration = progressTheme.duration;
    final shouldAnimate =
        widget.value == null &&
        widget.active &&
        _tickerModeEnabled(context) &&
        !_reduceMotion(context);
    if (shouldAnimate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!shouldAnimate && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = MetroTheme.of(context);
    final progressTheme = _progressTheme(context);
    final size = widget.size ?? progressTheme.size;
    final color = widget.color ?? progressTheme.color ?? theme.colors.accent;
    final trackColor =
        widget.trackColor ??
        progressTheme.trackColor ??
        theme.colors.border.withValues(alpha: 0.35);
    final strokeWidth = widget.strokeWidth ?? progressTheme.strokeWidth;
    final semanticValue =
        widget.semanticValue ??
        (widget.value == null
            ? null
            : MetroLocalizations.of(context).formatPercentage(widget.value!));
    final dotCount = size >= progressTheme.largeSizeThreshold
        ? progressTheme.largeDotCount
        : progressTheme.smallDotCount;

    return Semantics(
      label: widget.semanticLabel,
      value: semanticValue,
      child: SizedBox.square(
        dimension: size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _MetroProgressRingPainter(
                animationValue: _controller.value,
                active: widget.active,
                animateIndeterminate: _controller.isAnimating,
                color: color,
                dotCount: dotCount,
                trackColor: trackColor,
                strokeWidth: strokeWidth,
                value: widget.value,
              ),
            );
          },
        ),
      ),
    );
  }

  static bool _reduceMotion(BuildContext context) {
    final mediaQuery = MediaQuery.maybeOf(context);
    return mediaQuery?.disableAnimations == true ||
        mediaQuery?.accessibleNavigation == true;
  }

  static bool _tickerModeEnabled(BuildContext context) {
    // TickerMode.valuesOf is unavailable on the minimum Flutter version.
    // ignore: deprecated_member_use
    return TickerMode.of(context);
  }

  MetroProgressRingThemeData _progressTheme(BuildContext context) {
    return MetroTheme.of(
      context,
    ).progressRingTheme.merge(MetroProgressRingTheme.maybeOf(context));
  }
}

class _MetroProgressRingPainter extends CustomPainter {
  const _MetroProgressRingPainter({
    required this.animationValue,
    required this.active,
    required this.animateIndeterminate,
    required this.color,
    required this.dotCount,
    required this.trackColor,
    required this.strokeWidth,
    required this.value,
  });

  final double animationValue;
  final bool active;
  final bool animateIndeterminate;
  final Color color;
  final int dotCount;
  final Color trackColor;
  final double strokeWidth;
  final double? value;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.max(0, size.shortestSide / 2 - strokeWidth).toDouble();
    if (value != null) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas
        ..drawArc(
          rect,
          -math.pi / 2,
          math.pi * 2,
          false,
          Paint()
            ..color = trackColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth,
        )
        ..drawArc(
          rect,
          -math.pi / 2,
          math.pi * 2 * value!,
          false,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.square
            ..strokeWidth = strokeWidth,
        );
      return;
    }
    if (!active) {
      return;
    }

    final dotRadius = math.max(1.5, strokeWidth * 0.9).toDouble();
    for (var index = 0; index < dotCount; index += 1) {
      final phase = animateIndeterminate
          ? (animationValue - index * 0.048) % 1
          : index / dotCount;
      final eased = animateIndeterminate
          ? Curves.easeInOutCubic.transform(phase)
          : phase;
      final angle = -math.pi / 2 + math.pi * 2 * eased;
      final opacity = animateIndeterminate
          ? (0.35 + math.sin(phase * math.pi) * 0.65).clamp(0.0, 1.0).toDouble()
          : 1.0;
      final position =
          center + Offset(math.cos(angle), math.sin(angle)) * radius;
      canvas.drawCircle(
        position,
        dotRadius,
        Paint()..color = color.withValues(alpha: opacity),
      );
    }
  }

  @override
  bool shouldRepaint(_MetroProgressRingPainter oldDelegate) {
    return animationValue != oldDelegate.animationValue ||
        active != oldDelegate.active ||
        animateIndeterminate != oldDelegate.animateIndeterminate ||
        color != oldDelegate.color ||
        dotCount != oldDelegate.dotCount ||
        trackColor != oldDelegate.trackColor ||
        strokeWidth != oldDelegate.strokeWidth ||
        value != oldDelegate.value;
  }
}
