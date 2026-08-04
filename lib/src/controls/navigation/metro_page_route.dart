import 'package:flutter/widgets.dart';

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
    final reduceMotion = _reduceMotion(context);
    final noMotion = reduceMotion || transition == MetroPageTransition.none;
    final duration = noMotion
        ? Duration.zero
        : transitionDuration ?? theme.motion.navigation;
    final reverseDuration = noMotion
        ? Duration.zero
        : reverseTransitionDuration ?? duration;
    final textDirection = Directionality.of(context);

    return MetroPageRoute<T>._(
      builder: builder,
      curve: theme.motion.navigationCurve,
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
             textDirection: textDirection,
             transition: transition,
           );
         },
       );

  static Widget _buildTransition({
    required Animation<double> animation,
    required Widget child,
    required Curve curve,
    required TextDirection textDirection,
    required MetroPageTransition transition,
  }) {
    if (transition == MetroPageTransition.none) {
      return child;
    }
    final curved = CurvedAnimation(parent: animation, curve: curve);
    final fade = FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(curved),
      child: child,
    );
    final logicalEnd = textDirection == TextDirection.ltr ? 1.0 : -1.0;
    return switch (transition) {
      MetroPageTransition.slideForward => SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0.18 * logicalEnd, 0),
          end: Offset.zero,
        ).animate(curved),
        child: fade,
      ),
      MetroPageTransition.slideBackward => SlideTransition(
        position: Tween<Offset>(
          begin: Offset(-0.18 * logicalEnd, 0),
          end: Offset.zero,
        ).animate(curved),
        child: fade,
      ),
      MetroPageTransition.drillIn => ScaleTransition(
        scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
        child: fade,
      ),
      MetroPageTransition.drillOut => ScaleTransition(
        scale: Tween<double>(begin: 1.08, end: 1).animate(curved),
        child: fade,
      ),
      MetroPageTransition.fade => fade,
      MetroPageTransition.none => child,
    };
  }
}

bool _reduceMotion(BuildContext context) {
  final mediaQuery = MediaQuery.maybeOf(context);
  return mediaQuery?.disableAnimations == true ||
      mediaQuery?.accessibleNavigation == true;
}
