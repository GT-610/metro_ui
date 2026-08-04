import 'package:flutter/widgets.dart';

import '../../foundation/state_property.dart';

/// Visual, sizing, and route-barrier values for Metro flyouts.
@immutable
class MetroFlyoutThemeData {
  const MetroFlyoutThemeData({
    this.backgroundColor,
    this.headerColor,
    this.barrierColor,
    this.width,
    this.headerPadding,
    this.contentPadding,
    this.titleStyle,
    this.contentStyle,
  });

  final Color? backgroundColor;
  final Color? headerColor;
  final Color? barrierColor;
  final double? width;
  final EdgeInsetsGeometry? headerPadding;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? titleStyle;
  final TextStyle? contentStyle;

  MetroFlyoutThemeData copyWith({
    Color? backgroundColor,
    Color? headerColor,
    Color? barrierColor,
    double? width,
    EdgeInsetsGeometry? headerPadding,
    EdgeInsetsGeometry? contentPadding,
    TextStyle? titleStyle,
    TextStyle? contentStyle,
  }) {
    return MetroFlyoutThemeData(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      headerColor: headerColor ?? this.headerColor,
      barrierColor: barrierColor ?? this.barrierColor,
      width: width ?? this.width,
      headerPadding: headerPadding ?? this.headerPadding,
      contentPadding: contentPadding ?? this.contentPadding,
      titleStyle: titleStyle ?? this.titleStyle,
      contentStyle: contentStyle ?? this.contentStyle,
    );
  }

  MetroFlyoutThemeData merge(MetroFlyoutThemeData? other) {
    if (other == null) {
      return this;
    }
    return MetroFlyoutThemeData(
      backgroundColor: other.backgroundColor ?? backgroundColor,
      headerColor: other.headerColor ?? headerColor,
      barrierColor: other.barrierColor ?? barrierColor,
      width: other.width ?? width,
      headerPadding: other.headerPadding ?? headerPadding,
      contentPadding: other.contentPadding ?? contentPadding,
      titleStyle: titleStyle?.merge(other.titleStyle) ?? other.titleStyle,
      contentStyle:
          contentStyle?.merge(other.contentStyle) ?? other.contentStyle,
    );
  }

  static MetroFlyoutThemeData lerp(
    MetroFlyoutThemeData a,
    MetroFlyoutThemeData b,
    double t,
  ) {
    return MetroFlyoutThemeData(
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      headerColor: Color.lerp(a.headerColor, b.headerColor, t),
      barrierColor: Color.lerp(a.barrierColor, b.barrierColor, t),
      width: lerpDouble(a.width, b.width, t),
      headerPadding: EdgeInsetsGeometry.lerp(
        a.headerPadding,
        b.headerPadding,
        t,
      ),
      contentPadding: EdgeInsetsGeometry.lerp(
        a.contentPadding,
        b.contentPadding,
        t,
      ),
      titleStyle: TextStyle.lerp(a.titleStyle, b.titleStyle, t),
      contentStyle: TextStyle.lerp(a.contentStyle, b.contentStyle, t),
    );
  }
}

/// Overrides Metro flyout styling for a subtree.
class MetroFlyoutTheme extends InheritedTheme {
  const MetroFlyoutTheme({required this.data, required super.child, super.key});

  final MetroFlyoutThemeData data;

  static MetroFlyoutThemeData of(BuildContext context) {
    return maybeOf(context) ?? const MetroFlyoutThemeData();
  }

  static MetroFlyoutThemeData? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MetroFlyoutTheme>()?.data;
  }

  @override
  bool updateShouldNotify(MetroFlyoutTheme oldWidget) {
    return data != oldWidget.data;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return MetroFlyoutTheme(data: data, child: child);
  }
}
