import 'package:flutter/widgets.dart';

import '../../foundation/metro_accessibility.dart';
import '../../theme/metro_theme.dart';

/// Motion recipe used by [MetroPageRoute].
enum MetroPageTransition {
  slideForward,
  slideBackward,
  drillIn,
  drillOut,
  fade,
  none,
}

/// A theme-capturing route with Windows 8-inspired navigation transitions.
class MetroPageRoute<T> extends PageRouteBuilder<T> {
  factory MetroPageRoute({
    required BuildContext context,
    required WidgetBuilder builder,
    MetroPageTransition transition = MetroPageTransition.slideForward,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) {
    final navigator = Navigator.of(context);
    final themes = InheritedTheme.capture(from: context, to: navigator.context);
    final theme = MetroTheme.of(context);
    final reduceMotion = metroReduceMotion(context);
    final noMotion = reduceMotion || transition == MetroPageTransition.none;
    final duration = noMotion
        ? Duration.zero
        : transitionDuration ??
              (transition == MetroPageTransition.fade
                  ? theme.motion.navigationFade
                  : theme.motion.navigation);
    final reverseDuration = noMotion
        ? Duration.zero
        : reverseTransitionDuration ?? theme.motion.exit;
    final textDirection = Directionality.of(context);

    return MetroPageRoute<T>._(
      builder: builder,
      curve: theme.motion.navigationCurve,
      fadeDuration: theme.motion.navigationFade,
      fullscreenDialog: fullscreenDialog,
      maintainState: maintainState,
      reverseTransitionDuration: reverseDuration,
      settings: settings,
      textDirection: textDirection,
      themes: themes,
      transition: transition,
      transitionDuration: duration,
    );
  }

  MetroPageRoute._({
    required WidgetBuilder builder,
    required Curve curve,
    required Duration fadeDuration,
    required CapturedThemes themes,
    required TextDirection textDirection,
    required MetroPageTransition transition,
    required super.transitionDuration,
    required super.reverseTransitionDuration,
    required super.maintainState,
    required super.fullscreenDialog,
    super.settings,
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) {
           return Directionality(
             textDirection: textDirection,
             child: themes.wrap(Builder(builder: builder)),
           );
         },
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           return _buildTransition(
             animation: animation,
             child: child,
             curve: curve,
             fadeFraction: transitionDuration == Duration.zero
                 ? 1
                 : (fadeDuration.inMicroseconds /
                           transitionDuration.inMicroseconds)
                       .clamp(0.0, 1.0),
             textDirection: textDirection,
             transition: transition,
           );
         },
       );

  static Widget _buildTransition({
    required Animation<double> animation,
    required Widget child,
    required Curve curve,
    required double fadeFraction,
    required TextDirection textDirection,
    required MetroPageTransition transition,
  }) {
    if (transition == MetroPageTransition.none) {
      return child;
    }
    final logicalEnd = textDirection == TextDirection.ltr ? 1.0 : -1.0;
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final reversing = animation.status == AnimationStatus.reverse;
        final movementProgress = reversing
            ? 1.0
            : curve.transform(animation.value);
        final opacityProgress = reversing
            ? 1 - curve.transform(1 - animation.value)
            : fadeFraction <= 0
            ? 1.0
            : curve.transform((animation.value / fadeFraction).clamp(0.0, 1.0));
        final transformed = switch (transition) {
          MetroPageTransition.slideForward => Transform.translate(
            offset: Offset(100 * logicalEnd * (1 - movementProgress), 0),
            child: child,
          ),
          MetroPageTransition.slideBackward => Transform.translate(
            offset: Offset(-100 * logicalEnd * (1 - movementProgress), 0),
            child: child,
          ),
          MetroPageTransition.drillIn => Transform.scale(
            scale: 0.92 + 0.08 * movementProgress,
            child: child,
          ),
          MetroPageTransition.drillOut => Transform.scale(
            scale: 1.08 - 0.08 * movementProgress,
            child: child,
          ),
          MetroPageTransition.fade || MetroPageTransition.none => child!,
        };
        return Opacity(opacity: opacityProgress, child: transformed);
      },
    );
  }
}
