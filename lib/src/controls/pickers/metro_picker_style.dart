import 'package:flutter/widgets.dart';

import '../../foundation/state_property.dart';

/// Visual and measurement overrides for segmented picker fields.
@immutable
class MetroPickerStyle {
  const MetroPickerStyle({
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth,
    this.separatorColor,
    this.textStyle,
    this.padding,
    this.minimumHeight,
  });

  final WidgetStateProperty<Color?>? backgroundColor;
  final WidgetStateProperty<Color?>? foregroundColor;
  final WidgetStateProperty<Color?>? borderColor;
  final WidgetStateProperty<double?>? borderWidth;
  final WidgetStateProperty<Color?>? separatorColor;
  final WidgetStateProperty<TextStyle?>? textStyle;
  final EdgeInsetsGeometry? padding;
  final double? minimumHeight;

  MetroPickerStyle copyWith({
    WidgetStateProperty<Color?>? backgroundColor,
    WidgetStateProperty<Color?>? foregroundColor,
    WidgetStateProperty<Color?>? borderColor,
    WidgetStateProperty<double?>? borderWidth,
    WidgetStateProperty<Color?>? separatorColor,
    WidgetStateProperty<TextStyle?>? textStyle,
    EdgeInsetsGeometry? padding,
    double? minimumHeight,
  }) {
    return MetroPickerStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      separatorColor: separatorColor ?? this.separatorColor,
      textStyle: textStyle ?? this.textStyle,
      padding: padding ?? this.padding,
      minimumHeight: minimumHeight ?? this.minimumHeight,
    );
  }

  MetroPickerStyle merge(MetroPickerStyle? other) {
    if (other == null) {
      return this;
    }
    return copyWith(
      backgroundColor: other.backgroundColor,
      foregroundColor: other.foregroundColor,
      borderColor: other.borderColor,
      borderWidth: other.borderWidth,
      separatorColor: other.separatorColor,
      textStyle: other.textStyle,
      padding: other.padding,
      minimumHeight: other.minimumHeight,
    );
  }

  static MetroPickerStyle lerp(
    MetroPickerStyle? a,
    MetroPickerStyle? b,
    double t,
  ) {
    final first = a ?? const MetroPickerStyle();
    final second = b ?? const MetroPickerStyle();
    return MetroPickerStyle(
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
      separatorColor: lerpStateProperty(
        first.separatorColor,
        second.separatorColor,
        t,
        Color.lerp,
      ),
      textStyle: lerpStateProperty(
        first.textStyle,
        second.textStyle,
        t,
        TextStyle.lerp,
      ),
      padding: EdgeInsetsGeometry.lerp(first.padding, second.padding, t),
      minimumHeight: lerpDouble(first.minimumHeight, second.minimumHeight, t),
    );
  }
}

/// Application-level values shared by date and time pickers.
@immutable
class MetroPickerThemeData {
  const MetroPickerThemeData({
    this.style,
    this.selectedBackgroundColor,
    this.selectedForegroundColor,
    this.itemTextStyle,
    this.itemExtent,
    this.visibleItemCount,
    this.popupWidth,
  });

  final MetroPickerStyle? style;
  final Color? selectedBackgroundColor;
  final Color? selectedForegroundColor;
  final TextStyle? itemTextStyle;
  final double? itemExtent;
  final int? visibleItemCount;
  final double? popupWidth;

  MetroPickerThemeData copyWith({
    MetroPickerStyle? style,
    Color? selectedBackgroundColor,
    Color? selectedForegroundColor,
    TextStyle? itemTextStyle,
    double? itemExtent,
    int? visibleItemCount,
    double? popupWidth,
  }) {
    return MetroPickerThemeData(
      style: style ?? this.style,
      selectedBackgroundColor:
          selectedBackgroundColor ?? this.selectedBackgroundColor,
      selectedForegroundColor:
          selectedForegroundColor ?? this.selectedForegroundColor,
      itemTextStyle: itemTextStyle ?? this.itemTextStyle,
      itemExtent: itemExtent ?? this.itemExtent,
      visibleItemCount: visibleItemCount ?? this.visibleItemCount,
      popupWidth: popupWidth ?? this.popupWidth,
    );
  }

  MetroPickerThemeData merge(MetroPickerThemeData? other) {
    if (other == null) {
      return this;
    }
    return MetroPickerThemeData(
      style: style?.merge(other.style) ?? other.style,
      selectedBackgroundColor:
          other.selectedBackgroundColor ?? selectedBackgroundColor,
      selectedForegroundColor:
          other.selectedForegroundColor ?? selectedForegroundColor,
      itemTextStyle: other.itemTextStyle ?? itemTextStyle,
      itemExtent: other.itemExtent ?? itemExtent,
      visibleItemCount: other.visibleItemCount ?? visibleItemCount,
      popupWidth: other.popupWidth ?? popupWidth,
    );
  }

  static MetroPickerThemeData lerp(
    MetroPickerThemeData a,
    MetroPickerThemeData b,
    double t,
  ) {
    return MetroPickerThemeData(
      style: MetroPickerStyle.lerp(a.style, b.style, t),
      selectedBackgroundColor: Color.lerp(
        a.selectedBackgroundColor,
        b.selectedBackgroundColor,
        t,
      ),
      selectedForegroundColor: Color.lerp(
        a.selectedForegroundColor,
        b.selectedForegroundColor,
        t,
      ),
      itemTextStyle: TextStyle.lerp(a.itemTextStyle, b.itemTextStyle, t),
      itemExtent: lerpDouble(a.itemExtent, b.itemExtent, t),
      visibleItemCount: t < 0.5 ? a.visibleItemCount : b.visibleItemCount,
      popupWidth: lerpDouble(a.popupWidth, b.popupWidth, t),
    );
  }
}

/// Overrides date and time picker styling for a subtree.
class MetroPickerTheme extends InheritedTheme {
  const MetroPickerTheme({required this.data, required super.child, super.key});

  final MetroPickerThemeData data;

  static MetroPickerThemeData? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MetroPickerTheme>()?.data;
  }

  static MetroPickerThemeData of(BuildContext context) {
    return maybeOf(context) ?? const MetroPickerThemeData();
  }

  @override
  bool updateShouldNotify(MetroPickerTheme oldWidget) => data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) {
    return MetroPickerTheme(data: data, child: child);
  }
}
