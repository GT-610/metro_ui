import 'package:flutter/widgets.dart';

import '../../foundation/state_property.dart';

/// Visual and route-barrier values for Metro dialogs.
@immutable
class MetroDialogThemeData {
  const MetroDialogThemeData({
    this.backgroundColor,
    this.borderColor,
    this.barrierColor,
    this.padding,
    this.maxWidth,
    this.titleStyle,
    this.contentStyle,
  });

  final Color? backgroundColor;
  final Color? borderColor;
  final Color? barrierColor;
  final EdgeInsetsGeometry? padding;
  final double? maxWidth;
  final TextStyle? titleStyle;
  final TextStyle? contentStyle;

  MetroDialogThemeData copyWith({
    Color? backgroundColor,
    Color? borderColor,
    Color? barrierColor,
    EdgeInsetsGeometry? padding,
    double? maxWidth,
    TextStyle? titleStyle,
    TextStyle? contentStyle,
  }) {
    return MetroDialogThemeData(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      barrierColor: barrierColor ?? this.barrierColor,
      padding: padding ?? this.padding,
      maxWidth: maxWidth ?? this.maxWidth,
      titleStyle: titleStyle ?? this.titleStyle,
      contentStyle: contentStyle ?? this.contentStyle,
    );
  }

  MetroDialogThemeData merge(MetroDialogThemeData? other) {
    if (other == null) {
      return this;
    }
    return MetroDialogThemeData(
      backgroundColor: other.backgroundColor ?? backgroundColor,
      borderColor: other.borderColor ?? borderColor,
      barrierColor: other.barrierColor ?? barrierColor,
      padding: other.padding ?? padding,
      maxWidth: other.maxWidth ?? maxWidth,
      titleStyle: titleStyle?.merge(other.titleStyle) ?? other.titleStyle,
      contentStyle:
          contentStyle?.merge(other.contentStyle) ?? other.contentStyle,
    );
  }

  static MetroDialogThemeData lerp(
    MetroDialogThemeData a,
    MetroDialogThemeData b,
    double t,
  ) {
    return MetroDialogThemeData(
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      borderColor: Color.lerp(a.borderColor, b.borderColor, t),
      barrierColor: Color.lerp(a.barrierColor, b.barrierColor, t),
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      maxWidth: lerpDouble(a.maxWidth, b.maxWidth, t),
      titleStyle: TextStyle.lerp(a.titleStyle, b.titleStyle, t),
      contentStyle: TextStyle.lerp(a.contentStyle, b.contentStyle, t),
    );
  }
}

/// Overrides Metro dialog styling for a subtree.
class MetroDialogTheme extends InheritedTheme {
  const MetroDialogTheme({required this.data, required super.child, super.key});

  final MetroDialogThemeData data;

  static MetroDialogThemeData of(BuildContext context) {
    return maybeOf(context) ?? const MetroDialogThemeData();
  }

  static MetroDialogThemeData? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MetroDialogTheme>()?.data;
  }

  @override
  bool updateShouldNotify(MetroDialogTheme oldWidget) {
    return data != oldWidget.data;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return MetroDialogTheme(data: data, child: child);
  }
}
