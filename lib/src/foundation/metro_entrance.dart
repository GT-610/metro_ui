import 'package:flutter/widgets.dart';

import '../theme/metro_theme.dart';
import 'metro_accessibility.dart';

/// Direction from which a [MetroEntrance] child enters.
enum MetroEntranceDirection { forward, backward, up, down, none }

/// Applies a Windows 8 page-content entrance recipe to one child.
///
/// The default motion travels 100 logical pixels over the theme navigation
/// duration while opacity settles during the shorter navigation fade. Give
/// siblings increasing [index] values to create a restrained stagger without
/// changing their layout or composing multiple animation controllers.
class MetroEntrance extends StatefulWidget {
  const MetroEntrance({
    required this.child,
    this.direction = MetroEntranceDirection.forward,
    this.distance = 100,
    this.delay = Duration.zero,
    this.index = 0,
    this.stagger = const Duration(milliseconds: 50),
    this.duration,
    this.fadeDuration,
    this.curve,
    this.animate = true,
    super.key,
  }) : assert(distance >= 0 && distance < double.infinity),
       assert(index >= 0);

  /// Content that enters without changing its layout position or focus order.
  final Widget child;

  /// Direction from which [child] travels into place.
  final MetroEntranceDirection direction;

  /// Logical pixels traveled by [child] during the entrance.
  final double distance;

  /// Delay before the first indexed entrance begins.
  final Duration delay;

  /// Zero-based position in a staggered entrance group.
  final int index;

  /// Additional delay applied for every [index].
  final Duration stagger;

  /// Total duration of the directional movement after the delay.
  final Duration? duration;

  /// Duration in which opacity reaches its final value.
  final Duration? fadeDuration;

  /// Easing curve used for both movement and opacity.
  final Curve? curve;

  /// Whether to play the entrance when this widget is first mounted.
  final bool animate;

  @override
  State<MetroEntrance> createState() => _MetroEntranceState();
}

class _MetroEntranceState extends State<MetroEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);
  bool _started = false;

  Duration get _effectiveDelay => Duration(
    microseconds:
        _nonNegative(widget.delay).inMicroseconds +
        _nonNegative(widget.stagger).inMicroseconds * widget.index,
  );

  Duration _nonNegative(Duration duration) =>
      duration.isNegative ? Duration.zero : duration;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _configureAndStart();
  }

  @override
  void didUpdateWidget(MetroEntrance oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_sameRecipe(oldWidget, widget)) {
      _started = false;
      _configureAndStart();
    }
  }

  bool _sameRecipe(MetroEntrance a, MetroEntrance b) {
    return a.animate == b.animate &&
        a.direction == b.direction &&
        a.distance == b.distance &&
        a.delay == b.delay &&
        a.index == b.index &&
        a.stagger == b.stagger &&
        a.duration == b.duration &&
        a.fadeDuration == b.fadeDuration &&
        a.curve == b.curve;
  }

  void _configureAndStart() {
    final theme = MetroTheme.of(context);
    final motionDuration = _nonNegative(
      widget.duration ?? theme.motion.navigation,
    );
    _controller.duration = _effectiveDelay + motionDuration;
    final noMotion =
        !widget.animate ||
        widget.direction == MetroEntranceDirection.none ||
        metroReduceMotion(context) ||
        !metroTickerModeEnabled(context) ||
        motionDuration == Duration.zero;
    if (noMotion) {
      _controller.value = 1;
      _started = true;
      return;
    }
    if (!_started) {
      _started = true;
      _controller.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = MetroTheme.of(context);
    final motionDuration = _nonNegative(
      widget.duration ?? theme.motion.navigation,
    );
    final fadeDuration = _nonNegative(
      widget.fadeDuration ?? theme.motion.navigationFade,
    );
    final curve = widget.curve ?? theme.motion.navigationCurve;
    final textDirection = Directionality.of(context);

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final elapsedMicros =
            (_controller.value * (_controller.duration?.inMicroseconds ?? 0))
                .round();
        final motionMicros = motionDuration.inMicroseconds;
        final delayedMicros = elapsedMicros - _effectiveDelay.inMicroseconds;
        final rawProgress = motionMicros == 0
            ? 1.0
            : (delayedMicros / motionMicros).clamp(0.0, 1.0);
        final movementProgress = curve.transform(rawProgress);
        final fadeFraction = motionMicros == 0
            ? 1.0
            : (fadeDuration.inMicroseconds / motionMicros).clamp(0.0, 1.0);
        final opacity = fadeFraction <= 0
            ? 1.0
            : curve.transform((rawProgress / fadeFraction).clamp(0.0, 1.0));
        final logicalEnd = textDirection == TextDirection.ltr ? 1.0 : -1.0;
        final remaining = 1 - movementProgress;
        final offset = switch (widget.direction) {
          MetroEntranceDirection.forward => Offset(
            widget.distance * logicalEnd * remaining,
            0,
          ),
          MetroEntranceDirection.backward => Offset(
            -widget.distance * logicalEnd * remaining,
            0,
          ),
          MetroEntranceDirection.up => Offset(0, widget.distance * remaining),
          MetroEntranceDirection.down => Offset(
            0,
            -widget.distance * remaining,
          ),
          MetroEntranceDirection.none => Offset.zero,
        };
        return Opacity(
          opacity: opacity,
          child: Transform.translate(offset: offset, child: child),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
