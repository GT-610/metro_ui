import 'package:flutter/widgets.dart';

import '../../foundation/state_property.dart';

/// Visual, timing, and placement values for Metro tooltips.
@immutable
class MetroTooltipThemeData {
  const MetroTooltipThemeData({
    this.backgroundColor,
    this.textStyle,
    this.padding,
    this.maxWidth,
    this.waitDuration,
    this.showDuration,
    this.verticalOffset,
  });

  final Color? backgroundColor;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final double? maxWidth;
  final Duration? waitDuration;
  final Duration? showDuration;
  final double? verticalOffset;

  MetroTooltipThemeData copyWith({
    Color? backgroundColor,
    TextStyle? textStyle,
    EdgeInsetsGeometry? padding,
    double? maxWidth,
    Duration? waitDuration,
    Duration? showDuration,
    double? verticalOffset,
  }) {
    return MetroTooltipThemeData(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textStyle: textStyle ?? this.textStyle,
      padding: padding ?? this.padding,
      maxWidth: maxWidth ?? this.maxWidth,
      waitDuration: waitDuration ?? this.waitDuration,
      showDuration: showDuration ?? this.showDuration,
      verticalOffset: verticalOffset ?? this.verticalOffset,
    );
  }

  MetroTooltipThemeData merge(MetroTooltipThemeData? other) {
    if (other == null) {
      return this;
    }
    return MetroTooltipThemeData(
      backgroundColor: other.backgroundColor ?? backgroundColor,
      textStyle: textStyle?.merge(other.textStyle) ?? other.textStyle,
      padding: other.padding ?? padding,
      maxWidth: other.maxWidth ?? maxWidth,
      waitDuration: other.waitDuration ?? waitDuration,
      showDuration: other.showDuration ?? showDuration,
      verticalOffset: other.verticalOffset ?? verticalOffset,
    );
  }

  static MetroTooltipThemeData lerp(
    MetroTooltipThemeData a,
    MetroTooltipThemeData b,
    double t,
  ) {
    return MetroTooltipThemeData(
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      textStyle: TextStyle.lerp(a.textStyle, b.textStyle, t),
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      maxWidth: lerpDouble(a.maxWidth, b.maxWidth, t),
      waitDuration: _lerpDuration(a.waitDuration, b.waitDuration, t),
      showDuration: _lerpDuration(a.showDuration, b.showDuration, t),
      verticalOffset: lerpDouble(a.verticalOffset, b.verticalOffset, t),
    );
  }
}

Duration? _lerpDuration(Duration? a, Duration? b, double t) {
  if (a == null && b == null) {
    return null;
  }
  final first = a ?? b!;
  final second = b ?? a!;
  return Duration(
    microseconds:
        (first.inMicroseconds +
                (second.inMicroseconds - first.inMicroseconds) * t)
            .round(),
  );
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
