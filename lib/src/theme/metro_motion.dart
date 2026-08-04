import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

/// Motion tokens shared by Metro UI components.
///
/// Navigation motion is intentionally directional and longer than local
/// feedback. Components must still respect the platform's reduced-motion
/// preference.
@immutable
class MetroMotion {
  const MetroMotion({
    this.fast = const Duration(milliseconds: 100),
    this.normal = const Duration(milliseconds: 200),
    this.entrance = const Duration(milliseconds: 300),
    this.navigation = const Duration(milliseconds: 600),
    this.standardCurve = Curves.easeOutCubic,
    this.navigationCurve = Curves.easeOutCubic,
  });

  final Duration fast;
  final Duration normal;
  final Duration entrance;
  final Duration navigation;
  final Curve standardCurve;
  final Curve navigationCurve;

  MetroMotion copyWith({
    Duration? fast,
    Duration? normal,
    Duration? entrance,
    Duration? navigation,
    Curve? standardCurve,
    Curve? navigationCurve,
  }) {
    return MetroMotion(
      fast: fast ?? this.fast,
      normal: normal ?? this.normal,
      entrance: entrance ?? this.entrance,
      navigation: navigation ?? this.navigation,
      standardCurve: standardCurve ?? this.standardCurve,
      navigationCurve: navigationCurve ?? this.navigationCurve,
    );
  }

  static MetroMotion lerp(MetroMotion a, MetroMotion b, double t) {
    return MetroMotion(
      fast: _lerpDuration(a.fast, b.fast, t),
      normal: _lerpDuration(a.normal, b.normal, t),
      entrance: _lerpDuration(a.entrance, b.entrance, t),
      navigation: _lerpDuration(a.navigation, b.navigation, t),
      standardCurve: t < 0.5 ? a.standardCurve : b.standardCurve,
      navigationCurve: t < 0.5 ? a.navigationCurve : b.navigationCurve,
    );
  }

  static Duration _lerpDuration(Duration a, Duration b, double t) {
    return Duration(
      microseconds:
          (a.inMicroseconds + (b.inMicroseconds - a.inMicroseconds) * t)
              .round(),
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MetroMotion &&
            other.fast == fast &&
            other.normal == normal &&
            other.entrance == entrance &&
            other.navigation == navigation &&
            other.standardCurve == standardCurve &&
            other.navigationCurve == navigationCurve;
  }

  @override
  int get hashCode => Object.hash(
    fast,
    normal,
    entrance,
    navigation,
    standardCurve,
    navigationCurve,
  );
}
