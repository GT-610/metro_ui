import 'package:flutter/widgets.dart';

import '../../foundation/state_property.dart';

/// Visual, timing, and placement values for Metro tooltips.
@immutable
class MetroTooltipThemeData {
  const MetroTooltipThemeData({
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.textStyle,
    this.padding,
    this.maxWidth,
    this.waitDuration,
    this.showDuration,
    this.verticalOffset,
    this.mouseOffset,
    this.keyboardOffset,
    this.touchOffset,
  }) : assert(
         borderWidth == null ||
             (borderWidth >= 0 && borderWidth < double.infinity),
       ),
       assert(maxWidth == null || (maxWidth > 0 && maxWidth < double.infinity));

  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final double? maxWidth;
  final Duration? waitDuration;
  final Duration? showDuration;
  final double? verticalOffset;
  final double? mouseOffset;
  final double? keyboardOffset;
  final double? touchOffset;

  MetroTooltipThemeData copyWith({
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    TextStyle? textStyle,
    EdgeInsetsGeometry? padding,
    double? maxWidth,
    Duration? waitDuration,
    Duration? showDuration,
    double? verticalOffset,
    double? mouseOffset,
    double? keyboardOffset,
    double? touchOffset,
  }) {
    return MetroTooltipThemeData(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      textStyle: textStyle ?? this.textStyle,
      padding: padding ?? this.padding,
      maxWidth: maxWidth ?? this.maxWidth,
      waitDuration: waitDuration ?? this.waitDuration,
      showDuration: showDuration ?? this.showDuration,
      verticalOffset: verticalOffset ?? this.verticalOffset,
      mouseOffset: mouseOffset ?? this.mouseOffset,
      keyboardOffset: keyboardOffset ?? this.keyboardOffset,
      touchOffset: touchOffset ?? this.touchOffset,
    );
  }

  MetroTooltipThemeData merge(MetroTooltipThemeData? other) {
    if (other == null) {
      return this;
    }
    return MetroTooltipThemeData(
      backgroundColor: other.backgroundColor ?? backgroundColor,
      borderColor: other.borderColor ?? borderColor,
      borderWidth: other.borderWidth ?? borderWidth,
      textStyle: textStyle?.merge(other.textStyle) ?? other.textStyle,
      padding: other.padding ?? padding,
      maxWidth: other.maxWidth ?? maxWidth,
      waitDuration: other.waitDuration ?? waitDuration,
      showDuration: other.showDuration ?? showDuration,
      verticalOffset: other.verticalOffset ?? verticalOffset,
      mouseOffset: other.mouseOffset ?? mouseOffset,
      keyboardOffset: other.keyboardOffset ?? keyboardOffset,
      touchOffset: other.touchOffset ?? touchOffset,
    );
  }

  static MetroTooltipThemeData lerp(
    MetroTooltipThemeData a,
    MetroTooltipThemeData b,
    double t,
  ) {
    return MetroTooltipThemeData(
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      borderColor: Color.lerp(a.borderColor, b.borderColor, t),
      borderWidth: lerpDouble(a.borderWidth, b.borderWidth, t),
      textStyle: TextStyle.lerp(a.textStyle, b.textStyle, t),
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      maxWidth: lerpDouble(a.maxWidth, b.maxWidth, t),
      waitDuration: lerpDuration(a.waitDuration, b.waitDuration, t),
      showDuration: lerpDuration(a.showDuration, b.showDuration, t),
      verticalOffset: lerpDouble(a.verticalOffset, b.verticalOffset, t),
      mouseOffset: lerpDouble(a.mouseOffset, b.mouseOffset, t),
      keyboardOffset: lerpDouble(a.keyboardOffset, b.keyboardOffset, t),
      touchOffset: lerpDouble(a.touchOffset, b.touchOffset, t),
    );
  }
}

/// Overrides Metro tooltip styling for a subtree.
class MetroTooltipTheme extends InheritedTheme {
  const MetroTooltipTheme({
    required this.data,
    required super.child,
    super.key,
  });

  final MetroTooltipThemeData data;

  static MetroTooltipThemeData of(BuildContext context) {
    return maybeOf(context) ?? const MetroTooltipThemeData();
  }

  static MetroTooltipThemeData? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MetroTooltipTheme>()
        ?.data;
  }

  @override
  bool updateShouldNotify(MetroTooltipTheme oldWidget) {
    return data != oldWidget.data;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return MetroTooltipTheme(data: data, child: child);
  }
}
