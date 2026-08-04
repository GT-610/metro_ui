import 'package:flutter/widgets.dart';

import '../../foundation/state_property.dart';

/// Visual properties for a [MetroTile].
@immutable
class MetroTileStyle {
  const MetroTileStyle({
    this.backgroundColor,
    this.foregroundColor,
    this.overlayColor,
    this.borderColor,
    this.borderWidth,
    this.titleStyle,
    this.subtitleStyle,
    this.padding,
  });

  final WidgetStateProperty<Color?>? backgroundColor;
  final WidgetStateProperty<Color?>? foregroundColor;
  final WidgetStateProperty<Color?>? overlayColor;
  final WidgetStateProperty<Color?>? borderColor;
  final WidgetStateProperty<double?>? borderWidth;
  final WidgetStateProperty<TextStyle?>? titleStyle;
  final WidgetStateProperty<TextStyle?>? subtitleStyle;
  final EdgeInsetsGeometry? padding;

  MetroTileStyle copyWith({
    WidgetStateProperty<Color?>? backgroundColor,
    WidgetStateProperty<Color?>? foregroundColor,
    WidgetStateProperty<Color?>? overlayColor,
    WidgetStateProperty<Color?>? borderColor,
    WidgetStateProperty<double?>? borderWidth,
    WidgetStateProperty<TextStyle?>? titleStyle,
    WidgetStateProperty<TextStyle?>? subtitleStyle,
    EdgeInsetsGeometry? padding,
  }) {
    return MetroTileStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      overlayColor: overlayColor ?? this.overlayColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      titleStyle: titleStyle ?? this.titleStyle,
      subtitleStyle: subtitleStyle ?? this.subtitleStyle,
      padding: padding ?? this.padding,
    );
  }

  MetroTileStyle merge(MetroTileStyle? other) {
    if (other == null) {
      return this;
    }
    return copyWith(
      backgroundColor: other.backgroundColor,
      foregroundColor: other.foregroundColor,
      overlayColor: other.overlayColor,
      borderColor: other.borderColor,
      borderWidth: other.borderWidth,
      titleStyle: other.titleStyle,
      subtitleStyle: other.subtitleStyle,
      padding: other.padding,
    );
  }

  static MetroTileStyle lerp(MetroTileStyle? a, MetroTileStyle? b, double t) {
    final first = a ?? const MetroTileStyle();
    final second = b ?? const MetroTileStyle();
    return MetroTileStyle(
      backgroundColor: lerpStateProperty(
        first.backgroundColor,
        second.backgroundColor,
        t,
        Color.lerp,
      ),
      foregroundColor: lerpStateProperty(
        first.foregroundColor,
        second.foregroundColor,
        t,
        Color.lerp,
      ),
      overlayColor: lerpStateProperty(
        first.overlayColor,
        second.overlayColor,
        t,
        Color.lerp,
      ),
      borderColor: lerpStateProperty(
        first.borderColor,
        second.borderColor,
        t,
        Color.lerp,
      ),
      borderWidth: lerpStateProperty(
        first.borderWidth,
        second.borderWidth,
        t,
        lerpDouble,
      ),
      titleStyle: lerpStateProperty(
        first.titleStyle,
        second.titleStyle,
        t,
        TextStyle.lerp,
      ),
      subtitleStyle: lerpStateProperty(
        first.subtitleStyle,
        second.subtitleStyle,
        t,
        TextStyle.lerp,
      ),
      padding: EdgeInsetsGeometry.lerp(first.padding, second.padding, t),
    );
  }
}

/// Application-level tile style, extent, and spacing values.
@immutable
class MetroTileThemeData {
  const MetroTileThemeData({this.style, double? extent, double? spacing})
    : assert(extent == null || extent > 0),
      assert(spacing == null || spacing >= 0),
      _extent = extent,
      _spacing = spacing;

  final MetroTileStyle? style;
  final double? _extent;
  final double? _spacing;

  double get extent => _extent ?? 140;
  double get spacing => _spacing ?? 8;

  MetroTileThemeData copyWith({
    MetroTileStyle? style,
    double? extent,
    double? spacing,
  }) {
    return MetroTileThemeData(
      style: style ?? this.style,
      extent: extent ?? _extent,
      spacing: spacing ?? _spacing,
    );
  }

  MetroTileThemeData merge(MetroTileThemeData? other) {
    if (other == null) return this;
    return MetroTileThemeData(
      style: style?.merge(other.style) ?? other.style,
      extent: other._extent ?? _extent,
      spacing: other._spacing ?? _spacing,
    );
  }

  static MetroTileThemeData lerp(
    MetroTileThemeData a,
    MetroTileThemeData b,
    double t,
  ) {
    return MetroTileThemeData(
      style: MetroTileStyle.lerp(a.style, b.style, t),
      extent: a.extent + (b.extent - a.extent) * t,
      spacing: a.spacing + (b.spacing - a.spacing) * t,
    );
  }
}

/// Overrides tile styling and grid metrics for a subtree.
class MetroTileTheme extends InheritedTheme {
  const MetroTileTheme({required this.data, required super.child, super.key});

  final MetroTileThemeData data;

  static MetroTileThemeData? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MetroTileTheme>()?.data;
  }

  static MetroTileThemeData of(BuildContext context) {
    return maybeOf(context) ?? const MetroTileThemeData();
  }

  @override
  bool updateShouldNotify(MetroTileTheme oldWidget) => data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) {
    return MetroTileTheme(data: data, child: child);
  }
}
