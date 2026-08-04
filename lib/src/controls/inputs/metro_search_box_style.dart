import 'package:flutter/widgets.dart';

import '../../foundation/state_property.dart';
import 'metro_text_field_style.dart';

/// Visual, sizing, and suggestion-popup overrides for [MetroSearchBoxTheme].
@immutable
class MetroSearchBoxStyle {
  const MetroSearchBoxStyle({
    this.fieldStyle,
    this.searchButtonBackgroundColor,
    this.searchButtonForegroundColor,
    this.clearButtonBackgroundColor,
    this.clearButtonForegroundColor,
    this.searchButtonExtent,
    this.clearButtonExtent,
    this.iconSize,
    this.popupBackgroundColor,
    this.popupBorderColor,
    this.popupBorderWidth,
    this.popupMaxHeight,
    this.popupWidth,
    this.popupGap,
    this.itemBackgroundColor,
    this.itemForegroundColor,
    this.itemTextStyle,
    this.itemPadding,
    this.itemHeight,
    this.noResultsTextStyle,
    this.noResultsPadding,
  }) : assert(searchButtonExtent == null || searchButtonExtent > 0),
       assert(clearButtonExtent == null || clearButtonExtent > 0),
       assert(iconSize == null || iconSize > 0),
       assert(popupBorderWidth == null || popupBorderWidth >= 0),
       assert(popupMaxHeight == null || popupMaxHeight > 0),
       assert(popupWidth == null || popupWidth > 0),
       assert(popupGap == null || popupGap >= 0),
       assert(itemHeight == null || itemHeight > 0);

  final MetroTextFieldStyle? fieldStyle;
  final WidgetStateProperty<Color?>? searchButtonBackgroundColor;
  final WidgetStateProperty<Color?>? searchButtonForegroundColor;
  final WidgetStateProperty<Color?>? clearButtonBackgroundColor;
  final WidgetStateProperty<Color?>? clearButtonForegroundColor;
  final double? searchButtonExtent;
  final double? clearButtonExtent;
  final double? iconSize;
  final Color? popupBackgroundColor;
  final Color? popupBorderColor;
  final double? popupBorderWidth;
  final double? popupMaxHeight;
  final double? popupWidth;
  final double? popupGap;
  final WidgetStateProperty<Color?>? itemBackgroundColor;
  final WidgetStateProperty<Color?>? itemForegroundColor;
  final WidgetStateProperty<TextStyle?>? itemTextStyle;
  final EdgeInsetsGeometry? itemPadding;
  final double? itemHeight;
  final TextStyle? noResultsTextStyle;
  final EdgeInsetsGeometry? noResultsPadding;

  MetroSearchBoxStyle copyWith({
    MetroTextFieldStyle? fieldStyle,
    WidgetStateProperty<Color?>? searchButtonBackgroundColor,
    WidgetStateProperty<Color?>? searchButtonForegroundColor,
    WidgetStateProperty<Color?>? clearButtonBackgroundColor,
    WidgetStateProperty<Color?>? clearButtonForegroundColor,
    double? searchButtonExtent,
    double? clearButtonExtent,
    double? iconSize,
    Color? popupBackgroundColor,
    Color? popupBorderColor,
    double? popupBorderWidth,
    double? popupMaxHeight,
    double? popupWidth,
    double? popupGap,
    WidgetStateProperty<Color?>? itemBackgroundColor,
    WidgetStateProperty<Color?>? itemForegroundColor,
    WidgetStateProperty<TextStyle?>? itemTextStyle,
    EdgeInsetsGeometry? itemPadding,
    double? itemHeight,
    TextStyle? noResultsTextStyle,
    EdgeInsetsGeometry? noResultsPadding,
  }) {
    return MetroSearchBoxStyle(
      fieldStyle: fieldStyle ?? this.fieldStyle,
      searchButtonBackgroundColor:
          searchButtonBackgroundColor ?? this.searchButtonBackgroundColor,
      searchButtonForegroundColor:
          searchButtonForegroundColor ?? this.searchButtonForegroundColor,
      clearButtonBackgroundColor:
          clearButtonBackgroundColor ?? this.clearButtonBackgroundColor,
      clearButtonForegroundColor:
          clearButtonForegroundColor ?? this.clearButtonForegroundColor,
      searchButtonExtent: searchButtonExtent ?? this.searchButtonExtent,
      clearButtonExtent: clearButtonExtent ?? this.clearButtonExtent,
      iconSize: iconSize ?? this.iconSize,
      popupBackgroundColor: popupBackgroundColor ?? this.popupBackgroundColor,
      popupBorderColor: popupBorderColor ?? this.popupBorderColor,
      popupBorderWidth: popupBorderWidth ?? this.popupBorderWidth,
      popupMaxHeight: popupMaxHeight ?? this.popupMaxHeight,
      popupWidth: popupWidth ?? this.popupWidth,
      popupGap: popupGap ?? this.popupGap,
      itemBackgroundColor: itemBackgroundColor ?? this.itemBackgroundColor,
      itemForegroundColor: itemForegroundColor ?? this.itemForegroundColor,
      itemTextStyle: itemTextStyle ?? this.itemTextStyle,
      itemPadding: itemPadding ?? this.itemPadding,
      itemHeight: itemHeight ?? this.itemHeight,
      noResultsTextStyle: noResultsTextStyle ?? this.noResultsTextStyle,
      noResultsPadding: noResultsPadding ?? this.noResultsPadding,
    );
  }

  MetroSearchBoxStyle merge(MetroSearchBoxStyle? other) {
    if (other == null) {
      return this;
    }
    return copyWith(
      fieldStyle: fieldStyle?.merge(other.fieldStyle) ?? other.fieldStyle,
      searchButtonBackgroundColor: other.searchButtonBackgroundColor,
      searchButtonForegroundColor: other.searchButtonForegroundColor,
      clearButtonBackgroundColor: other.clearButtonBackgroundColor,
      clearButtonForegroundColor: other.clearButtonForegroundColor,
      searchButtonExtent: other.searchButtonExtent,
      clearButtonExtent: other.clearButtonExtent,
      iconSize: other.iconSize,
      popupBackgroundColor: other.popupBackgroundColor,
      popupBorderColor: other.popupBorderColor,
      popupBorderWidth: other.popupBorderWidth,
      popupMaxHeight: other.popupMaxHeight,
      popupWidth: other.popupWidth,
      popupGap: other.popupGap,
      itemBackgroundColor: other.itemBackgroundColor,
      itemForegroundColor: other.itemForegroundColor,
      itemTextStyle: other.itemTextStyle,
      itemPadding: other.itemPadding,
      itemHeight: other.itemHeight,
      noResultsTextStyle: other.noResultsTextStyle,
      noResultsPadding: other.noResultsPadding,
    );
  }

  static MetroSearchBoxStyle lerp(
    MetroSearchBoxStyle? a,
    MetroSearchBoxStyle? b,
    double t,
  ) {
    final first = a ?? const MetroSearchBoxStyle();
    final second = b ?? const MetroSearchBoxStyle();
    return MetroSearchBoxStyle(
      fieldStyle: MetroTextFieldStyle.lerp(
        first.fieldStyle,
        second.fieldStyle,
        t,
      ),
      searchButtonBackgroundColor: lerpStateProperty(
        first.searchButtonBackgroundColor,
        second.searchButtonBackgroundColor,
        t,
        Color.lerp,
      ),
      searchButtonForegroundColor: lerpStateProperty(
        first.searchButtonForegroundColor,
        second.searchButtonForegroundColor,
        t,
        Color.lerp,
      ),
      clearButtonBackgroundColor: lerpStateProperty(
        first.clearButtonBackgroundColor,
        second.clearButtonBackgroundColor,
        t,
        Color.lerp,
      ),
      clearButtonForegroundColor: lerpStateProperty(
        first.clearButtonForegroundColor,
        second.clearButtonForegroundColor,
        t,
        Color.lerp,
      ),
      searchButtonExtent: lerpDouble(
        first.searchButtonExtent,
        second.searchButtonExtent,
        t,
      ),
      clearButtonExtent: lerpDouble(
        first.clearButtonExtent,
        second.clearButtonExtent,
        t,
      ),
      iconSize: lerpDouble(first.iconSize, second.iconSize, t),
      popupBackgroundColor: Color.lerp(
        first.popupBackgroundColor,
        second.popupBackgroundColor,
        t,
      ),
      popupBorderColor: Color.lerp(
        first.popupBorderColor,
        second.popupBorderColor,
        t,
      ),
      popupBorderWidth: lerpDouble(
        first.popupBorderWidth,
        second.popupBorderWidth,
        t,
      ),
      popupMaxHeight: lerpDouble(
        first.popupMaxHeight,
        second.popupMaxHeight,
        t,
      ),
      popupWidth: lerpDouble(first.popupWidth, second.popupWidth, t),
      popupGap: lerpDouble(first.popupGap, second.popupGap, t),
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
      noResultsTextStyle: TextStyle.lerp(
        first.noResultsTextStyle,
        second.noResultsTextStyle,
        t,
      ),
      noResultsPadding: EdgeInsetsGeometry.lerp(
        first.noResultsPadding,
        second.noResultsPadding,
        t,
      ),
    );
  }
}

/// Application-level theme values for Metro search boxes.
@immutable
class MetroSearchBoxThemeData {
  const MetroSearchBoxThemeData({this.style});

  final MetroSearchBoxStyle? style;

  MetroSearchBoxThemeData copyWith({MetroSearchBoxStyle? style}) {
    return MetroSearchBoxThemeData(style: style ?? this.style);
  }

  MetroSearchBoxThemeData merge(MetroSearchBoxThemeData? other) {
    if (other == null) {
      return this;
    }
    return MetroSearchBoxThemeData(
      style: style?.merge(other.style) ?? other.style,
    );
  }

  static MetroSearchBoxThemeData lerp(
    MetroSearchBoxThemeData a,
    MetroSearchBoxThemeData b,
    double t,
  ) {
    return MetroSearchBoxThemeData(
      style: MetroSearchBoxStyle.lerp(a.style, b.style, t),
    );
  }
}

/// Overrides search-box styling for a subtree.
class MetroSearchBoxTheme extends InheritedTheme {
  const MetroSearchBoxTheme({
    required this.data,
    required super.child,
    super.key,
  });

  final MetroSearchBoxThemeData data;

  static MetroSearchBoxThemeData? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MetroSearchBoxTheme>()
        ?.data;
  }

  static MetroSearchBoxThemeData of(BuildContext context) {
    return maybeOf(context) ?? const MetroSearchBoxThemeData();
  }

  @override
  bool updateShouldNotify(MetroSearchBoxTheme oldWidget) {
    return data != oldWidget.data;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return MetroSearchBoxTheme(data: data, child: child);
  }
}
