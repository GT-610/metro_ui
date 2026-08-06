import 'package:flutter/widgets.dart';

import '../../foundation/state_property.dart';

/// Visual and measurement overrides for Metro list tiles.
@immutable
class MetroListTileStyle {
  const MetroListTileStyle({
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth,
    this.titleStyle,
    this.subtitleStyle,
    this.padding,
    this.minimumHeight,
  });

  final WidgetStateProperty<Color?>? backgroundColor;
  final WidgetStateProperty<Color?>? foregroundColor;
  final WidgetStateProperty<Color?>? borderColor;
  final WidgetStateProperty<double?>? borderWidth;
  final WidgetStateProperty<TextStyle?>? titleStyle;
  final WidgetStateProperty<TextStyle?>? subtitleStyle;
  final EdgeInsetsGeometry? padding;
  final double? minimumHeight;

  MetroListTileStyle copyWith({
    WidgetStateProperty<Color?>? backgroundColor,
    WidgetStateProperty<Color?>? foregroundColor,
    WidgetStateProperty<Color?>? borderColor,
    WidgetStateProperty<double?>? borderWidth,
    WidgetStateProperty<TextStyle?>? titleStyle,
    WidgetStateProperty<TextStyle?>? subtitleStyle,
    EdgeInsetsGeometry? padding,
    double? minimumHeight,
  }) => MetroListTileStyle(
    backgroundColor: backgroundColor ?? this.backgroundColor,
    foregroundColor: foregroundColor ?? this.foregroundColor,
    borderColor: borderColor ?? this.borderColor,
    borderWidth: borderWidth ?? this.borderWidth,
    titleStyle: titleStyle ?? this.titleStyle,
    subtitleStyle: subtitleStyle ?? this.subtitleStyle,
    padding: padding ?? this.padding,
    minimumHeight: minimumHeight ?? this.minimumHeight,
  );

  MetroListTileStyle merge(MetroListTileStyle? other) => other == null
      ? this
      : copyWith(
          backgroundColor: other.backgroundColor,
          foregroundColor: other.foregroundColor,
          borderColor: other.borderColor,
          borderWidth: other.borderWidth,
          titleStyle: other.titleStyle,
          subtitleStyle: other.subtitleStyle,
          padding: other.padding,
          minimumHeight: other.minimumHeight,
        );

  static MetroListTileStyle lerp(
    MetroListTileStyle? a,
    MetroListTileStyle? b,
    double t,
  ) {
    final first = a ?? const MetroListTileStyle();
    final second = b ?? const MetroListTileStyle();
    return MetroListTileStyle(
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
      minimumHeight: lerpDouble(first.minimumHeight, second.minimumHeight, t),
    );
  }
}

/// Application-level list-tile theme values.
@immutable
class MetroListTileThemeData {
  const MetroListTileThemeData({this.style});
  final MetroListTileStyle? style;

  MetroListTileThemeData copyWith({MetroListTileStyle? style}) {
    return MetroListTileThemeData(style: style ?? this.style);
  }

  MetroListTileThemeData merge(MetroListTileThemeData? other) {
    if (other == null) return this;
    return MetroListTileThemeData(
      style: style?.merge(other.style) ?? other.style,
    );
  }

  static MetroListTileThemeData lerp(
    MetroListTileThemeData a,
    MetroListTileThemeData b,
    double t,
  ) => MetroListTileThemeData(
    style: MetroListTileStyle.lerp(a.style, b.style, t),
  );
}

/// Overrides list-tile styling for a subtree.
class MetroListTileTheme extends InheritedTheme {
  const MetroListTileTheme({
    required this.data,
    required super.child,
    super.key,
  });

  final MetroListTileThemeData data;

  static MetroListTileThemeData? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MetroListTileTheme>()
        ?.data;
  }

  static MetroListTileThemeData of(BuildContext context) {
    return maybeOf(context) ?? const MetroListTileThemeData();
  }

  @override
  bool updateShouldNotify(MetroListTileTheme oldWidget) =>
      data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) {
    return MetroListTileTheme(data: data, child: child);
  }
}
