import 'package:flutter/widgets.dart';

import '../../foundation/state_property.dart';

/// Controls where slider tick marks are painted relative to the track.
enum MetroSliderTickPlacement { none, before, after, both }

/// Visual properties shared by [MetroSliderTheme] slider controls.
@immutable
class MetroSliderStyle {
  const MetroSliderStyle({
    this.trackColor,
    this.activeTrackColor,
    this.thumbColor,
    this.tickColor,
    this.activeTickColor,
    this.focusColor,
    this.trackThickness,
    this.activeTrackThickness,
    this.focusWidth,
    this.horizontalThumbSize,
    this.minimumInteractiveExtent,
    this.minimumLength,
    this.tickLength,
    this.tickThickness,
    this.tickGap,
  });

  final WidgetStateProperty<Color?>? trackColor;
  final WidgetStateProperty<Color?>? activeTrackColor;
  final WidgetStateProperty<Color?>? thumbColor;
  final WidgetStateProperty<Color?>? tickColor;
  final WidgetStateProperty<Color?>? activeTickColor;
  final WidgetStateProperty<Color?>? focusColor;
  final WidgetStateProperty<double?>? trackThickness;
  final WidgetStateProperty<double?>? activeTrackThickness;
  final WidgetStateProperty<double?>? focusWidth;

  /// Thumb size for a horizontal slider. A vertical slider swaps the axes.
  final Size? horizontalThumbSize;

  final double? minimumInteractiveExtent;
  final double? minimumLength;
  final double? tickLength;
  final double? tickThickness;
  final double? tickGap;

  MetroSliderStyle copyWith({
    WidgetStateProperty<Color?>? trackColor,
    WidgetStateProperty<Color?>? activeTrackColor,
    WidgetStateProperty<Color?>? thumbColor,
    WidgetStateProperty<Color?>? tickColor,
    WidgetStateProperty<Color?>? activeTickColor,
    WidgetStateProperty<Color?>? focusColor,
    WidgetStateProperty<double?>? trackThickness,
    WidgetStateProperty<double?>? activeTrackThickness,
    WidgetStateProperty<double?>? focusWidth,
    Size? horizontalThumbSize,
    double? minimumInteractiveExtent,
    double? minimumLength,
    double? tickLength,
    double? tickThickness,
    double? tickGap,
  }) {
    return MetroSliderStyle(
      trackColor: trackColor ?? this.trackColor,
      activeTrackColor: activeTrackColor ?? this.activeTrackColor,
      thumbColor: thumbColor ?? this.thumbColor,
      tickColor: tickColor ?? this.tickColor,
      activeTickColor: activeTickColor ?? this.activeTickColor,
      focusColor: focusColor ?? this.focusColor,
      trackThickness: trackThickness ?? this.trackThickness,
      activeTrackThickness: activeTrackThickness ?? this.activeTrackThickness,
      focusWidth: focusWidth ?? this.focusWidth,
      horizontalThumbSize: horizontalThumbSize ?? this.horizontalThumbSize,
      minimumInteractiveExtent:
          minimumInteractiveExtent ?? this.minimumInteractiveExtent,
      minimumLength: minimumLength ?? this.minimumLength,
      tickLength: tickLength ?? this.tickLength,
      tickThickness: tickThickness ?? this.tickThickness,
      tickGap: tickGap ?? this.tickGap,
    );
  }

  MetroSliderStyle merge(MetroSliderStyle? other) {
    if (other == null) {
      return this;
    }
    return copyWith(
      trackColor: other.trackColor,
      activeTrackColor: other.activeTrackColor,
      thumbColor: other.thumbColor,
      tickColor: other.tickColor,
      activeTickColor: other.activeTickColor,
      focusColor: other.focusColor,
      trackThickness: other.trackThickness,
      activeTrackThickness: other.activeTrackThickness,
      focusWidth: other.focusWidth,
      horizontalThumbSize: other.horizontalThumbSize,
      minimumInteractiveExtent: other.minimumInteractiveExtent,
      minimumLength: other.minimumLength,
      tickLength: other.tickLength,
      tickThickness: other.tickThickness,
      tickGap: other.tickGap,
    );
  }

  static MetroSliderStyle lerp(
    MetroSliderStyle? a,
    MetroSliderStyle? b,
    double t,
  ) {
    final first = a ?? const MetroSliderStyle();
    final second = b ?? const MetroSliderStyle();
    return MetroSliderStyle(
      trackColor: lerpStateProperty(
        first.trackColor,
        second.trackColor,
        t,
        Color.lerp,
      ),
      activeTrackColor: lerpStateProperty(
        first.activeTrackColor,
        second.activeTrackColor,
        t,
        Color.lerp,
      ),
      thumbColor: lerpStateProperty(
        first.thumbColor,
        second.thumbColor,
        t,
        Color.lerp,
      ),
      tickColor: lerpStateProperty(
        first.tickColor,
        second.tickColor,
        t,
        Color.lerp,
      ),
      activeTickColor: lerpStateProperty(
        first.activeTickColor,
        second.activeTickColor,
        t,
        Color.lerp,
      ),
      focusColor: lerpStateProperty(
        first.focusColor,
        second.focusColor,
        t,
        Color.lerp,
      ),
      trackThickness: lerpStateProperty(
        first.trackThickness,
        second.trackThickness,
        t,
        lerpDouble,
      ),
      activeTrackThickness: lerpStateProperty(
        first.activeTrackThickness,
        second.activeTrackThickness,
        t,
        lerpDouble,
      ),
      focusWidth: lerpStateProperty(
        first.focusWidth,
        second.focusWidth,
        t,
        lerpDouble,
      ),
      horizontalThumbSize: Size.lerp(
        first.horizontalThumbSize,
        second.horizontalThumbSize,
        t,
      ),
      minimumInteractiveExtent: lerpDouble(
        first.minimumInteractiveExtent,
        second.minimumInteractiveExtent,
        t,
      ),
      minimumLength: lerpDouble(first.minimumLength, second.minimumLength, t),
      tickLength: lerpDouble(first.tickLength, second.tickLength, t),
      tickThickness: lerpDouble(first.tickThickness, second.tickThickness, t),
      tickGap: lerpDouble(first.tickGap, second.tickGap, t),
    );
  }
}

/// Application-level theme values shared by Metro sliders.
@immutable
class MetroSliderThemeData {
  const MetroSliderThemeData({this.style});

  final MetroSliderStyle? style;

  MetroSliderThemeData copyWith({MetroSliderStyle? style}) {
    return MetroSliderThemeData(style: style ?? this.style);
  }

  MetroSliderThemeData merge(MetroSliderThemeData? other) {
    if (other == null) {
      return this;
    }
    return MetroSliderThemeData(
      style: style?.merge(other.style) ?? other.style,
    );
  }

  static MetroSliderThemeData lerp(
    MetroSliderThemeData a,
    MetroSliderThemeData b,
    double t,
  ) {
    return MetroSliderThemeData(
      style: MetroSliderStyle.lerp(a.style, b.style, t),
    );
  }
}

/// Overrides slider styling for a subtree.
class MetroSliderTheme extends InheritedTheme {
  const MetroSliderTheme({required this.data, required super.child, super.key});

  final MetroSliderThemeData data;

  static MetroSliderThemeData? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MetroSliderTheme>()?.data;
  }

  static MetroSliderThemeData of(BuildContext context) {
    return maybeOf(context) ?? const MetroSliderThemeData();
  }

  @override
  bool updateShouldNotify(MetroSliderTheme oldWidget) => data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) {
    return MetroSliderTheme(data: data, child: child);
  }
}
