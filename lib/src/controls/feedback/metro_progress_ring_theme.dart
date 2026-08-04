import 'package:flutter/widgets.dart';

/// Theme values for Metro progress rings.
@immutable
class MetroProgressRingThemeData {
  const MetroProgressRingThemeData({
    this.color,
    this.trackColor,
    double? size,
    double? strokeWidth,
    int? smallDotCount,
    int? largeDotCount,
    double? largeSizeThreshold,
    Duration? duration,
  }) : assert(size == null || size > 0),
       assert(strokeWidth == null || strokeWidth > 0),
       assert(smallDotCount == null || smallDotCount > 0),
       assert(largeDotCount == null || largeDotCount > 0),
       assert(largeSizeThreshold == null || largeSizeThreshold > 0),
       _size = size,
       _strokeWidth = strokeWidth,
       _smallDotCount = smallDotCount,
       _largeDotCount = largeDotCount,
       _largeSizeThreshold = largeSizeThreshold,
       _duration = duration;

  final Color? color;
  final Color? trackColor;
  final double? _size;
  final double? _strokeWidth;
  final int? _smallDotCount;
  final int? _largeDotCount;
  final double? _largeSizeThreshold;
  final Duration? _duration;

  double get size => _size ?? 32;
  double get strokeWidth => _strokeWidth ?? 2.5;
  int get smallDotCount => _smallDotCount ?? 5;
  int get largeDotCount => _largeDotCount ?? 6;
  double get largeSizeThreshold => _largeSizeThreshold ?? 40;
  Duration get duration => _duration ?? const Duration(milliseconds: 3470);

  MetroProgressRingThemeData copyWith({
    Color? color,
    Color? trackColor,
    double? size,
    double? strokeWidth,
    int? smallDotCount,
    int? largeDotCount,
    double? largeSizeThreshold,
    Duration? duration,
  }) {
    return MetroProgressRingThemeData(
      color: color ?? this.color,
      trackColor: trackColor ?? this.trackColor,
      size: size ?? _size,
      strokeWidth: strokeWidth ?? _strokeWidth,
      smallDotCount: smallDotCount ?? _smallDotCount,
      largeDotCount: largeDotCount ?? _largeDotCount,
      largeSizeThreshold: largeSizeThreshold ?? _largeSizeThreshold,
      duration: duration ?? _duration,
    );
  }

  MetroProgressRingThemeData merge(MetroProgressRingThemeData? other) {
    if (other == null) return this;
    return MetroProgressRingThemeData(
      color: other.color ?? color,
      trackColor: other.trackColor ?? trackColor,
      size: other._size ?? _size,
      strokeWidth: other._strokeWidth ?? _strokeWidth,
      smallDotCount: other._smallDotCount ?? _smallDotCount,
      largeDotCount: other._largeDotCount ?? _largeDotCount,
      largeSizeThreshold: other._largeSizeThreshold ?? _largeSizeThreshold,
      duration: other._duration ?? _duration,
    );
  }

  static MetroProgressRingThemeData lerp(
    MetroProgressRingThemeData a,
    MetroProgressRingThemeData b,
    double t,
  ) {
    return MetroProgressRingThemeData(
      color: Color.lerp(a.color, b.color, t),
      trackColor: Color.lerp(a.trackColor, b.trackColor, t),
      size: a.size + (b.size - a.size) * t,
      strokeWidth: a.strokeWidth + (b.strokeWidth - a.strokeWidth) * t,
      smallDotCount: t < 0.5 ? a.smallDotCount : b.smallDotCount,
      largeDotCount: t < 0.5 ? a.largeDotCount : b.largeDotCount,
      largeSizeThreshold:
          a.largeSizeThreshold +
          (b.largeSizeThreshold - a.largeSizeThreshold) * t,
      duration: Duration(
        microseconds:
            (a.duration.inMicroseconds +
                    (b.duration.inMicroseconds - a.duration.inMicroseconds) * t)
                .round(),
      ),
    );
  }
}

/// Overrides progress-ring theme values for a subtree.
class MetroProgressRingTheme extends InheritedTheme {
  const MetroProgressRingTheme({
    required this.data,
    required super.child,
    super.key,
  });

  final MetroProgressRingThemeData data;

  static MetroProgressRingThemeData? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MetroProgressRingTheme>()
        ?.data;
  }

  static MetroProgressRingThemeData of(BuildContext context) {
    return maybeOf(context) ?? const MetroProgressRingThemeData();
  }

  @override
  bool updateShouldNotify(MetroProgressRingTheme oldWidget) =>
      data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) {
    return MetroProgressRingTheme(data: data, child: child);
  }
}
