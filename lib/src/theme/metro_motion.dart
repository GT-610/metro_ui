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
    this.normal = const Duration(milliseconds: 167),
    this.fadeIn = const Duration(milliseconds: 250),
    this.popupFade = const Duration(milliseconds: 83),
    this.navigationFade = const Duration(milliseconds: 170),
    this.exit = const Duration(milliseconds: 117),
    this.content = const Duration(milliseconds: 350),
    this.semanticZoom = const Duration(milliseconds: 333),
    this.contentFade = const Duration(milliseconds: 170),
    this.contentEntrance = const Duration(milliseconds: 550),
    this.entrance = const Duration(milliseconds: 367),
    this.panel = const Duration(milliseconds: 550),
    this.navigation = const Duration(milliseconds: 1000),
    this.standardCurve = const Cubic(0.1, 0.9, 0.2, 1),
    this.contentCurve = const Cubic(0.17, 0.79, 0.215, 1.0025),
    this.contentExitCurve = const Cubic(0.3825, 0.0025, 0.8775, -0.1075),
    this.navigationCurve = const Cubic(0.1, 0.9, 0.2, 1),
  });

  final Duration fast;
  final Duration normal;
  final Duration fadeIn;
  final Duration popupFade;
  final Duration navigationFade;
  final Duration exit;
  final Duration content;
  final Duration semanticZoom;
  final Duration contentFade;
  final Duration contentEntrance;
  final Duration entrance;
  final Duration panel;
  final Duration navigation;
  final Curve standardCurve;
  final Curve contentCurve;
  final Curve contentExitCurve;
  final Curve navigationCurve;

  MetroMotion copyWith({
    Duration? fast,
    Duration? normal,
    Duration? fadeIn,
    Duration? popupFade,
    Duration? navigationFade,
    Duration? exit,
    Duration? content,
    Duration? semanticZoom,
    Duration? contentFade,
    Duration? contentEntrance,
    Duration? entrance,
    Duration? panel,
    Duration? navigation,
    Curve? standardCurve,
    Curve? contentCurve,
    Curve? contentExitCurve,
    Curve? navigationCurve,
  }) {
    return MetroMotion(
      fast: fast ?? this.fast,
      normal: normal ?? this.normal,
      fadeIn: fadeIn ?? this.fadeIn,
      popupFade: popupFade ?? this.popupFade,
      navigationFade: navigationFade ?? this.navigationFade,
      exit: exit ?? this.exit,
      content: content ?? this.content,
      semanticZoom: semanticZoom ?? this.semanticZoom,
      contentFade: contentFade ?? this.contentFade,
      contentEntrance: contentEntrance ?? this.contentEntrance,
      entrance: entrance ?? this.entrance,
      panel: panel ?? this.panel,
      navigation: navigation ?? this.navigation,
      standardCurve: standardCurve ?? this.standardCurve,
      contentCurve: contentCurve ?? this.contentCurve,
      contentExitCurve: contentExitCurve ?? this.contentExitCurve,
      navigationCurve: navigationCurve ?? this.navigationCurve,
    );
  }

  static MetroMotion lerp(MetroMotion a, MetroMotion b, double t) {
    return MetroMotion(
      fast: _lerpDuration(a.fast, b.fast, t),
      normal: _lerpDuration(a.normal, b.normal, t),
      fadeIn: _lerpDuration(a.fadeIn, b.fadeIn, t),
      popupFade: _lerpDuration(a.popupFade, b.popupFade, t),
      navigationFade: _lerpDuration(a.navigationFade, b.navigationFade, t),
      exit: _lerpDuration(a.exit, b.exit, t),
      content: _lerpDuration(a.content, b.content, t),
      semanticZoom: _lerpDuration(a.semanticZoom, b.semanticZoom, t),
      contentFade: _lerpDuration(a.contentFade, b.contentFade, t),
      contentEntrance: _lerpDuration(a.contentEntrance, b.contentEntrance, t),
      entrance: _lerpDuration(a.entrance, b.entrance, t),
      panel: _lerpDuration(a.panel, b.panel, t),
      navigation: _lerpDuration(a.navigation, b.navigation, t),
      standardCurve: t < 0.5 ? a.standardCurve : b.standardCurve,
      contentCurve: t < 0.5 ? a.contentCurve : b.contentCurve,
      contentExitCurve: t < 0.5 ? a.contentExitCurve : b.contentExitCurve,
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
            other.fadeIn == fadeIn &&
            other.popupFade == popupFade &&
            other.navigationFade == navigationFade &&
            other.exit == exit &&
            other.content == content &&
            other.semanticZoom == semanticZoom &&
            other.contentFade == contentFade &&
            other.contentEntrance == contentEntrance &&
            other.entrance == entrance &&
            other.panel == panel &&
            other.navigation == navigation &&
            other.standardCurve == standardCurve &&
            other.contentCurve == contentCurve &&
            other.contentExitCurve == contentExitCurve &&
            other.navigationCurve == navigationCurve;
  }

  @override
  int get hashCode => Object.hash(
    fast,
    normal,
    fadeIn,
    popupFade,
    navigationFade,
    exit,
    content,
    semanticZoom,
    contentFade,
    contentEntrance,
    entrance,
    panel,
    navigation,
    standardCurve,
    contentCurve,
    contentExitCurve,
    navigationCurve,
  );
}
