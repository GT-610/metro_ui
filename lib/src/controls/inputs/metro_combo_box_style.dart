import 'package:flutter/widgets.dart';

import '../../foundation/state_property.dart';

/// Visual, sizing, and popup-layout overrides for [MetroComboBoxTheme].
@immutable
class MetroComboBoxStyle {
  const MetroComboBoxStyle({
    this.backgroundColor,
    this.foregroundColor,
    this.placeholderColor,
    this.borderColor,
    this.borderWidth,
    this.iconColor,
    this.textStyle,
    this.padding,
    this.minimumWidth,
    this.minimumHeight,
    this.iconSize,
    this.menuBackgroundColor,
    this.menuBorderColor,
    this.menuBorderWidth,
    this.menuMaxHeight,
    this.menuWidth,
    this.menuGap,
    this.itemBackgroundColor,
    this.itemForegroundColor,
    this.itemTextStyle,
    this.itemPadding,
    this.itemHeight,
  }) : assert(minimumWidth == null || minimumWidth >= 0),
       assert(minimumHeight == null || minimumHeight >= 0),
       assert(iconSize == null || iconSize > 0),
       assert(menuBorderWidth == null || menuBorderWidth >= 0),
       assert(menuMaxHeight == null || menuMaxHeight > 0),
       assert(menuWidth == null || menuWidth > 0),
       assert(menuGap == null || menuGap >= 0),
       assert(itemHeight == null || itemHeight > 0);

  final WidgetStateProperty<Color?>? backgroundColor;
  final WidgetStateProperty<Color?>? foregroundColor;
  final WidgetStateProperty<Color?>? placeholderColor;
  final WidgetStateProperty<Color?>? borderColor;
  final WidgetStateProperty<double?>? borderWidth;
  final WidgetStateProperty<Color?>? iconColor;
  final WidgetStateProperty<TextStyle?>? textStyle;
  final EdgeInsetsGeometry? padding;
  final double? minimumWidth;
  final double? minimumHeight;
  final double? iconSize;
  final Color? menuBackgroundColor;
  final Color? menuBorderColor;
  final double? menuBorderWidth;
  final double? menuMaxHeight;
  final double? menuWidth;
  final double? menuGap;
  final WidgetStateProperty<Color?>? itemBackgroundColor;
  final WidgetStateProperty<Color?>? itemForegroundColor;
  final WidgetStateProperty<TextStyle?>? itemTextStyle;
  final EdgeInsetsGeometry? itemPadding;
  final double? itemHeight;

  MetroComboBoxStyle copyWith({
    WidgetStateProperty<Color?>? backgroundColor,
    WidgetStateProperty<Color?>? foregroundColor,
    WidgetStateProperty<Color?>? placeholderColor,
    WidgetStateProperty<Color?>? borderColor,
    WidgetStateProperty<double?>? borderWidth,
    WidgetStateProperty<Color?>? iconColor,
    WidgetStateProperty<TextStyle?>? textStyle,
    EdgeInsetsGeometry? padding,
    double? minimumWidth,
    double? minimumHeight,
    double? iconSize,
    Color? menuBackgroundColor,
    Color? menuBorderColor,
    double? menuBorderWidth,
    double? menuMaxHeight,
    double? menuWidth,
    double? menuGap,
    WidgetStateProperty<Color?>? itemBackgroundColor,
    WidgetStateProperty<Color?>? itemForegroundColor,
    WidgetStateProperty<TextStyle?>? itemTextStyle,
    EdgeInsetsGeometry? itemPadding,
    double? itemHeight,
  }) {
    return MetroComboBoxStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      placeholderColor: placeholderColor ?? this.placeholderColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      iconColor: iconColor ?? this.iconColor,
      textStyle: textStyle ?? this.textStyle,
      padding: padding ?? this.padding,
      minimumWidth: minimumWidth ?? this.minimumWidth,
      minimumHeight: minimumHeight ?? this.minimumHeight,
      iconSize: iconSize ?? this.iconSize,
      menuBackgroundColor: menuBackgroundColor ?? this.menuBackgroundColor,
      menuBorderColor: menuBorderColor ?? this.menuBorderColor,
      menuBorderWidth: menuBorderWidth ?? this.menuBorderWidth,
      menuMaxHeight: menuMaxHeight ?? this.menuMaxHeight,
      menuWidth: menuWidth ?? this.menuWidth,
      menuGap: menuGap ?? this.menuGap,
      itemBackgroundColor: itemBackgroundColor ?? this.itemBackgroundColor,
      itemForegroundColor: itemForegroundColor ?? this.itemForegroundColor,
      itemTextStyle: itemTextStyle ?? this.itemTextStyle,
      itemPadding: itemPadding ?? this.itemPadding,
      itemHeight: itemHeight ?? this.itemHeight,
    );
  }

  MetroComboBoxStyle merge(MetroComboBoxStyle? other) {
    if (other == null) {
      return this;
    }
    return copyWith(
      backgroundColor: other.backgroundColor,
      foregroundColor: other.foregroundColor,
      placeholderColor: other.placeholderColor,
      borderColor: other.borderColor,
      borderWidth: other.borderWidth,
      iconColor: other.iconColor,
      textStyle: other.textStyle,
      padding: other.padding,
      minimumWidth: other.minimumWidth,
      minimumHeight: other.minimumHeight,
      iconSize: other.iconSize,
      menuBackgroundColor: other.menuBackgroundColor,
      menuBorderColor: other.menuBorderColor,
      menuBorderWidth: other.menuBorderWidth,
      menuMaxHeight: other.menuMaxHeight,
      menuWidth: other.menuWidth,
      menuGap: other.menuGap,
      itemBackgroundColor: other.itemBackgroundColor,
      itemForegroundColor: other.itemForegroundColor,
      itemTextStyle: other.itemTextStyle,
      itemPadding: other.itemPadding,
      itemHeight: other.itemHeight,
    );
  }

  static MetroComboBoxStyle lerp(
    MetroComboBoxStyle? a,
    MetroComboBoxStyle? b,
    double t,
  ) {
    final first = a ?? const MetroComboBoxStyle();
    final second = b ?? const MetroComboBoxStyle();
    return MetroComboBoxStyle(
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
      placeholderColor: lerpStateProperty(
        first.placeholderColor,
        second.placeholderColor,
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
      iconColor: lerpStateProperty(
        first.iconColor,
        second.iconColor,
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
      minimumWidth: lerpDouble(first.minimumWidth, second.minimumWidth, t),
      minimumHeight: lerpDouble(first.minimumHeight, second.minimumHeight, t),
      iconSize: lerpDouble(first.iconSize, second.iconSize, t),
      menuBackgroundColor: Color.lerp(
        first.menuBackgroundColor,
        second.menuBackgroundColor,
        t,
      ),
      menuBorderColor: Color.lerp(
        first.menuBorderColor,
        second.menuBorderColor,
        t,
      ),
      menuBorderWidth: lerpDouble(
        first.menuBorderWidth,
        second.menuBorderWidth,
        t,
      ),
      menuMaxHeight: lerpDouble(first.menuMaxHeight, second.menuMaxHeight, t),
      menuWidth: lerpDouble(first.menuWidth, second.menuWidth, t),
      menuGap: lerpDouble(first.menuGap, second.menuGap, t),
      itemBackgroundColor: lerpStateProperty(
        first.itemBackgroundColor,
        second.itemBackgroundColor,
        t,
        Color.lerp,
      ),
      itemForegroundColor: lerpStateProperty(
        first.itemForegroundColor,
        second.itemForegroundColor,
        t,
        Color.lerp,
      ),
      itemTextStyle: lerpStateProperty(
        first.itemTextStyle,
        second.itemTextStyle,
        t,
        TextStyle.lerp,
      ),
      itemPadding: EdgeInsetsGeometry.lerp(
        first.itemPadding,
        second.itemPadding,
        t,
      ),
      itemHeight: lerpDouble(first.itemHeight, second.itemHeight, t),
    );
  }
}

/// Application-level theme values for Metro combo boxes.
@immutable
class MetroComboBoxThemeData {
  const MetroComboBoxThemeData({this.style});

  final MetroComboBoxStyle? style;

  MetroComboBoxThemeData copyWith({MetroComboBoxStyle? style}) {
    return MetroComboBoxThemeData(style: style ?? this.style);
  }

  MetroComboBoxThemeData merge(MetroComboBoxThemeData? other) {
    if (other == null) {
      return this;
    }
    return MetroComboBoxThemeData(
      style: style?.merge(other.style) ?? other.style,
    );
  }

  static MetroComboBoxThemeData lerp(
    MetroComboBoxThemeData a,
    MetroComboBoxThemeData b,
    double t,
  ) {
    return MetroComboBoxThemeData(
      style: MetroComboBoxStyle.lerp(a.style, b.style, t),
    );
  }
}

/// Overrides combo-box styling for a subtree.
class MetroComboBoxTheme extends InheritedTheme {
  const MetroComboBoxTheme({
    required this.data,
    required super.child,
    super.key,
  });

  final MetroComboBoxThemeData data;

  static MetroComboBoxThemeData? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MetroComboBoxTheme>()
        ?.data;
  }

  static MetroComboBoxThemeData of(BuildContext context) {
    return maybeOf(context) ?? const MetroComboBoxThemeData();
  }

  @override
  bool updateShouldNotify(MetroComboBoxTheme oldWidget) {
    return data != oldWidget.data;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return MetroComboBoxTheme(data: data, child: child);
  }
}
