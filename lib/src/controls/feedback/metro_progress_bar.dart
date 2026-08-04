import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../localization/metro_localizations.dart';
import '../../theme/metro_theme.dart';
import 'metro_progress_bar_theme.dart';

export 'metro_progress_bar_theme.dart';

/// A determinate bar or Windows 8-style five-dot progress indicator.
class MetroProgressBar extends StatefulWidget {
  const MetroProgressBar({
    this.value,
    this.color,
    this.backgroundColor,
    this.height,
    this.active = true,
    this.semanticLabel,
    this.semanticValue,
    super.key,
  }) : assert(value == null || (value >= 0 && value <= 1));

  final double? value;
  final Color? color;
  final Color? backgroundColor;
  final double? height;

  /// Whether an indeterminate indicator is visible and animated.
  ///
  /// Determinate progress remains visible regardless of this value.
  final bool active;
  final String? semanticLabel;
  final String? semanticValue;

  @override
  State<MetroProgressBar> createState() => _MetroProgressBarState();
}

class _MetroProgressBarState extends State<MetroProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(MetroProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    _controller.duration = _progressTheme(context).duration;
    final animate =
        widget.value == null &&
        widget.active &&
        _tickerModeEnabled(context) &&
        !_reduceMotion(context);
    if (animate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!animate && _controller.isAnimating) {
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
    final barTheme = _progressTheme(context);
    final color = widget.color ?? barTheme.color ?? theme.colors.accent;
    final background =
        widget.backgroundColor ??
        barTheme.backgroundColor ??
        theme.colors.surfaceVariant;
    final height = widget.height ?? barTheme.height;
    final textDirection = Directionality.of(context);
    return Semantics(
      label: widget.semanticLabel,
      value:
          widget.semanticValue ??
          (widget.value == null
              ? null
              : MetroLocalizations.of(context).formatPercentage(widget.value!)),
      child: SizedBox(
        height: height,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => CustomPaint(
            painter: _ProgressBarPainter(
              animationValue: _controller.value,
              active: widget.active,
              animateIndeterminate: _controller.isAnimating,
              background: background,
              color: color,
              dotCount: barTheme.indeterminateDotCount,
              dotDiameter: barTheme.indeterminateDotDiameter,
              dotSpacing: barTheme.indeterminateDotSpacing,
              textDirection: textDirection,
              value: widget.value,
            ),
          ),
        ),
      ),
    );
  }

  static bool _reduceMotion(BuildContext context) {
    final media = MediaQuery.maybeOf(context);
    return media?.disableAnimations == true ||
        media?.accessibleNavigation == true;
  }

  static bool _tickerModeEnabled(BuildContext context) {
    // TickerMode.valuesOf is unavailable on the minimum Flutter version.
    // ignore: deprecated_member_use
    return TickerMode.of(context);
  }

  MetroProgressBarThemeData _progressTheme(BuildContext context) {
    return MetroTheme.of(
      context,
    ).progressBarTheme.merge(MetroProgressBarTheme.maybeOf(context));
  }
}

class _ProgressBarPainter extends CustomPainter {
  const _ProgressBarPainter({
    required this.animationValue,
    required this.active,
    required this.animateIndeterminate,
    required this.background,
    required this.color,
    required this.dotCount,
    required this.dotDiameter,
    required this.dotSpacing,
    required this.textDirection,
    required this.value,
  });

  final double animationValue;
  final bool active;
  final bool animateIndeterminate;
  final Color background;
  final Color color;
  final int dotCount;
  final double dotDiameter;
  final double dotSpacing;
  final TextDirection textDirection;
  final double? value;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = background);
    if (value != null) {
      final width = size.width * value!;
      final left = textDirection == TextDirection.ltr
          ? 0.0
          : size.width - width;
      canvas.drawRect(
        Rect.fromLTWH(left, 0, width, size.height),
        Paint()..color = color,
      );
      return;
    }
    if (!active || size.isEmpty) {
      return;
    }

    canvas
      ..save()
      ..clipRect(Offset.zero & size);
    if (animateIndeterminate) {
      _paintMovingDots(canvas, size);
    } else {
      _paintStaticDots(canvas, size);
    }
    canvas.restore();
  }

  void _paintMovingDots(Canvas canvas, Size size) {
    final diameter = math.min(dotDiameter, size.height);
    final radius = diameter / 2;
    const visibleFraction = 0.82;
    final paint = Paint()..color = color;
    for (var index = 0; index < dotCount; index += 1) {
      final delay = index * 0.043;
      final phase = (animationValue + 0.06 - delay + 1) % 1;
      if (phase > visibleFraction) {
        continue;
      }
      final progress = phase / visibleFraction;
      final eased = Curves.easeInOutCubic.transform(progress);
      var x = -radius + (size.width + diameter) * eased;
      if (textDirection == TextDirection.rtl) {
        x = size.width - x;
      }
      canvas.drawCircle(Offset(x, size.height / 2), radius, paint);
    }
  }

  void _paintStaticDots(Canvas canvas, Size size) {
    final diameter = math.min(dotDiameter, size.height);
    final radius = diameter / 2;
    final centerSpacing = math.max(diameter, dotSpacing);
    final totalWidth = diameter + centerSpacing * (dotCount - 1);
    final firstCenter = (size.width - totalWidth) / 2 + radius;
    final paint = Paint()..color = color;
    for (var index = 0; index < dotCount; index += 1) {
      canvas.drawCircle(
        Offset(firstCenter + centerSpacing * index, size.height / 2),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ProgressBarPainter oldDelegate) =>
      animationValue != oldDelegate.animationValue ||
      active != oldDelegate.active ||
      animateIndeterminate != oldDelegate.animateIndeterminate ||
      background != oldDelegate.background ||
      color != oldDelegate.color ||
      dotCount != oldDelegate.dotCount ||
      dotDiameter != oldDelegate.dotDiameter ||
      dotSpacing != oldDelegate.dotSpacing ||
      textDirection != oldDelegate.textDirection ||
      value != oldDelegate.value;
}
