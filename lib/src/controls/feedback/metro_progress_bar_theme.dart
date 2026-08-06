import 'package:flutter/widgets.dart';

/// Theme values for Metro progress bars.
@immutable
class MetroProgressBarThemeData {
  const MetroProgressBarThemeData({
    this.color,
    this.backgroundColor,
    double? height,
    double? indeterminateHeight,
    int? indeterminateDotCount,
    double? indeterminateDotDiameter,
    double? indeterminateDotSpacing,
    Duration? duration,
  }) : assert(height == null || height > 0),
       assert(indeterminateHeight == null || indeterminateHeight > 0),
       assert(indeterminateDotCount == null || indeterminateDotCount > 0),
       assert(indeterminateDotDiameter == null || indeterminateDotDiameter > 0),
       assert(indeterminateDotSpacing == null || indeterminateDotSpacing >= 0),
       _height = height,
       _indeterminateHeight = indeterminateHeight,
       _indeterminateDotCount = indeterminateDotCount,
       _indeterminateDotDiameter = indeterminateDotDiameter,
       _indeterminateDotSpacing = indeterminateDotSpacing,
       _duration = duration;

  final Color? color;
  final Color? backgroundColor;
  final double? _height;
  final double? _indeterminateHeight;
  final int? _indeterminateDotCount;
  final double? _indeterminateDotDiameter;
  final double? _indeterminateDotSpacing;
  final Duration? _duration;

  double get height => _height ?? 6;
  double get indeterminateHeight => _indeterminateHeight ?? _height ?? 4;
  int get indeterminateDotCount => _indeterminateDotCount ?? 5;
  double get indeterminateDotDiameter => _indeterminateDotDiameter ?? 4;
  double get indeterminateDotSpacing => _indeterminateDotSpacing ?? 8;
  Duration get duration => _duration ?? const Duration(milliseconds: 3917);

  MetroProgressBarThemeData copyWith({
    Color? color,
    Color? backgroundColor,
    double? height,
    double? indeterminateHeight,
    int? indeterminateDotCount,
    double? indeterminateDotDiameter,
    double? indeterminateDotSpacing,
    Duration? duration,
  }) {
    return MetroProgressBarThemeData(
      color: color ?? this.color,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      height: height ?? _height,
      indeterminateHeight: indeterminateHeight ?? _indeterminateHeight,
      indeterminateDotCount: indeterminateDotCount ?? _indeterminateDotCount,
      indeterminateDotDiameter:
          indeterminateDotDiameter ?? _indeterminateDotDiameter,
      indeterminateDotSpacing:
          indeterminateDotSpacing ?? _indeterminateDotSpacing,
      duration: duration ?? _duration,
    );
  }

  MetroProgressBarThemeData merge(MetroProgressBarThemeData? other) {
    if (other == null) return this;
    return MetroProgressBarThemeData(
      color: other.color ?? color,
      backgroundColor: other.backgroundColor ?? backgroundColor,
      height: other._height ?? _height,
      indeterminateHeight: other._indeterminateHeight ?? _indeterminateHeight,
      indeterminateDotCount:
          other._indeterminateDotCount ?? _indeterminateDotCount,
      indeterminateDotDiameter:
          other._indeterminateDotDiameter ?? _indeterminateDotDiameter,
      indeterminateDotSpacing:
          other._indeterminateDotSpacing ?? _indeterminateDotSpacing,
      duration: other._duration ?? _duration,
    );
  }

  static MetroProgressBarThemeData lerp(
    MetroProgressBarThemeData a,
    MetroProgressBarThemeData b,
    double t,
  ) => MetroProgressBarThemeData(
    color: Color.lerp(a.color, b.color, t),
    backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
    height: a.height + (b.height - a.height) * t,
    indeterminateHeight:
        a.indeterminateHeight +
        (b.indeterminateHeight - a.indeterminateHeight) * t,
    indeterminateDotCount: t < 0.5
        ? a.indeterminateDotCount
        : b.indeterminateDotCount,
    indeterminateDotDiameter:
        a.indeterminateDotDiameter +
        (b.indeterminateDotDiameter - a.indeterminateDotDiameter) * t,
    indeterminateDotSpacing:
        a.indeterminateDotSpacing +
        (b.indeterminateDotSpacing - a.indeterminateDotSpacing) * t,
    duration: Duration(
      microseconds:
          (a.duration.inMicroseconds +
                  (b.duration.inMicroseconds - a.duration.inMicroseconds) * t)
              .round(),
    ),
  );
}

/// Overrides progress-bar theme values for a subtree.
class MetroProgressBarTheme extends InheritedTheme {
  const MetroProgressBarTheme({
    required this.data,
    required super.child,
    super.key,
  });

  final MetroProgressBarThemeData data;

  static MetroProgressBarThemeData? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MetroProgressBarTheme>()
        ?.data;
  }

  static MetroProgressBarThemeData of(BuildContext context) {
    return maybeOf(context) ?? const MetroProgressBarThemeData();
  }

  @override
  bool updateShouldNotify(MetroProgressBarTheme oldWidget) =>
      data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) {
    return MetroProgressBarTheme(data: data, child: child);
  }
}
