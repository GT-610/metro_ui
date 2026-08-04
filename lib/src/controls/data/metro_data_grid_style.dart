import 'package:flutter/widgets.dart';

import '../../foundation/state_property.dart';

/// Visual and measurement overrides for Metro data grids.
@immutable
class MetroDataGridStyle {
  const MetroDataGridStyle({
    this.backgroundColor,
    this.headerBackgroundColor,
    this.headerForegroundColor,
    this.headerBorderColor,
    this.rowBackgroundColor,
    this.alternateRowBackgroundColor,
    this.rowForegroundColor,
    this.dividerColor,
    this.focusColor,
    this.sortIndicatorColor,
    this.headerTextStyle,
    this.cellTextStyle,
    this.headerPadding,
    this.cellPadding,
    this.headerHeight,
    this.rowHeight,
    this.headerBorderWidth,
    this.dividerWidth,
    this.focusWidth,
    this.minimumColumnWidth,
  });

  final Color? backgroundColor;
  final WidgetStateProperty<Color?>? headerBackgroundColor;
  final WidgetStateProperty<Color?>? headerForegroundColor;
  final WidgetStateProperty<Color?>? headerBorderColor;
  final WidgetStateProperty<Color?>? rowBackgroundColor;
  final Color? alternateRowBackgroundColor;
  final WidgetStateProperty<Color?>? rowForegroundColor;
  final Color? dividerColor;
  final Color? focusColor;
  final Color? sortIndicatorColor;
  final WidgetStateProperty<TextStyle?>? headerTextStyle;
  final WidgetStateProperty<TextStyle?>? cellTextStyle;
  final EdgeInsetsGeometry? headerPadding;
  final EdgeInsetsGeometry? cellPadding;
  final double? headerHeight;
  final double? rowHeight;
  final double? headerBorderWidth;
  final double? dividerWidth;
  final double? focusWidth;
  final double? minimumColumnWidth;

  MetroDataGridStyle copyWith({
    Color? backgroundColor,
    WidgetStateProperty<Color?>? headerBackgroundColor,
    WidgetStateProperty<Color?>? headerForegroundColor,
    WidgetStateProperty<Color?>? headerBorderColor,
    WidgetStateProperty<Color?>? rowBackgroundColor,
    Color? alternateRowBackgroundColor,
    WidgetStateProperty<Color?>? rowForegroundColor,
    Color? dividerColor,
    Color? focusColor,
    Color? sortIndicatorColor,
    WidgetStateProperty<TextStyle?>? headerTextStyle,
    WidgetStateProperty<TextStyle?>? cellTextStyle,
    EdgeInsetsGeometry? headerPadding,
    EdgeInsetsGeometry? cellPadding,
    double? headerHeight,
    double? rowHeight,
    double? headerBorderWidth,
    double? dividerWidth,
    double? focusWidth,
    double? minimumColumnWidth,
  }) {
    return MetroDataGridStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      headerBackgroundColor:
          headerBackgroundColor ?? this.headerBackgroundColor,
      headerForegroundColor:
          headerForegroundColor ?? this.headerForegroundColor,
      headerBorderColor: headerBorderColor ?? this.headerBorderColor,
      rowBackgroundColor: rowBackgroundColor ?? this.rowBackgroundColor,
      alternateRowBackgroundColor:
          alternateRowBackgroundColor ?? this.alternateRowBackgroundColor,
      rowForegroundColor: rowForegroundColor ?? this.rowForegroundColor,
      dividerColor: dividerColor ?? this.dividerColor,
      focusColor: focusColor ?? this.focusColor,
      sortIndicatorColor: sortIndicatorColor ?? this.sortIndicatorColor,
      headerTextStyle: headerTextStyle ?? this.headerTextStyle,
      cellTextStyle: cellTextStyle ?? this.cellTextStyle,
      headerPadding: headerPadding ?? this.headerPadding,
      cellPadding: cellPadding ?? this.cellPadding,
      headerHeight: headerHeight ?? this.headerHeight,
      rowHeight: rowHeight ?? this.rowHeight,
      headerBorderWidth: headerBorderWidth ?? this.headerBorderWidth,
      dividerWidth: dividerWidth ?? this.dividerWidth,
      focusWidth: focusWidth ?? this.focusWidth,
      minimumColumnWidth: minimumColumnWidth ?? this.minimumColumnWidth,
    );
  }

  MetroDataGridStyle merge(MetroDataGridStyle? other) {
    if (other == null) return this;
    return copyWith(
      backgroundColor: other.backgroundColor,
      headerBackgroundColor: other.headerBackgroundColor,
      headerForegroundColor: other.headerForegroundColor,
      headerBorderColor: other.headerBorderColor,
      rowBackgroundColor: other.rowBackgroundColor,
      alternateRowBackgroundColor: other.alternateRowBackgroundColor,
      rowForegroundColor: other.rowForegroundColor,
      dividerColor: other.dividerColor,
      focusColor: other.focusColor,
      sortIndicatorColor: other.sortIndicatorColor,
      headerTextStyle: other.headerTextStyle,
      cellTextStyle: other.cellTextStyle,
      headerPadding: other.headerPadding,
      cellPadding: other.cellPadding,
      headerHeight: other.headerHeight,
      rowHeight: other.rowHeight,
      headerBorderWidth: other.headerBorderWidth,
      dividerWidth: other.dividerWidth,
      focusWidth: other.focusWidth,
      minimumColumnWidth: other.minimumColumnWidth,
    );
  }

  static MetroDataGridStyle lerp(
    MetroDataGridStyle? a,
    MetroDataGridStyle? b,
    double t,
  ) {
    final first = a ?? const MetroDataGridStyle();
    final second = b ?? const MetroDataGridStyle();
    return MetroDataGridStyle(
      backgroundColor: Color.lerp(
        first.backgroundColor,
        second.backgroundColor,
        t,
      ),
      headerBackgroundColor: lerpStateProperty(
        first.headerBackgroundColor,
        second.headerBackgroundColor,
        t,
        Color.lerp,
      ),
      headerForegroundColor: lerpStateProperty(
        first.headerForegroundColor,
        second.headerForegroundColor,
        t,
        Color.lerp,
      ),
      headerBorderColor: lerpStateProperty(
        first.headerBorderColor,
        second.headerBorderColor,
        t,
        Color.lerp,
      ),
      rowBackgroundColor: lerpStateProperty(
        first.rowBackgroundColor,
        second.rowBackgroundColor,
        t,
        Color.lerp,
      ),
      alternateRowBackgroundColor: Color.lerp(
        first.alternateRowBackgroundColor,
        second.alternateRowBackgroundColor,
        t,
      ),
      rowForegroundColor: lerpStateProperty(
        first.rowForegroundColor,
        second.rowForegroundColor,
        t,
        Color.lerp,
      ),
      dividerColor: Color.lerp(first.dividerColor, second.dividerColor, t),
      focusColor: Color.lerp(first.focusColor, second.focusColor, t),
      sortIndicatorColor: Color.lerp(
        first.sortIndicatorColor,
        second.sortIndicatorColor,
        t,
      ),
      headerTextStyle: lerpStateProperty(
        first.headerTextStyle,
        second.headerTextStyle,
        t,
        TextStyle.lerp,
      ),
      cellTextStyle: lerpStateProperty(
        first.cellTextStyle,
        second.cellTextStyle,
        t,
        TextStyle.lerp,
      ),
      headerPadding: EdgeInsetsGeometry.lerp(
        first.headerPadding,
        second.headerPadding,
        t,
      ),
      cellPadding: EdgeInsetsGeometry.lerp(
        first.cellPadding,
        second.cellPadding,
        t,
      ),
      headerHeight: lerpDouble(first.headerHeight, second.headerHeight, t),
      rowHeight: lerpDouble(first.rowHeight, second.rowHeight, t),
      headerBorderWidth: lerpDouble(
        first.headerBorderWidth,
        second.headerBorderWidth,
        t,
      ),
      dividerWidth: lerpDouble(first.dividerWidth, second.dividerWidth, t),
      focusWidth: lerpDouble(first.focusWidth, second.focusWidth, t),
      minimumColumnWidth: lerpDouble(
        first.minimumColumnWidth,
        second.minimumColumnWidth,
        t,
      ),
    );
  }
}

/// Application-level data-grid theme values.
@immutable
class MetroDataGridThemeData {
  const MetroDataGridThemeData({this.style});

  final MetroDataGridStyle? style;

  static MetroDataGridThemeData lerp(
    MetroDataGridThemeData a,
    MetroDataGridThemeData b,
    double t,
  ) {
    return MetroDataGridThemeData(
      style: MetroDataGridStyle.lerp(a.style, b.style, t),
    );
  }
}

/// Overrides data-grid styling for a subtree.
class MetroDataGridTheme extends InheritedTheme {
  const MetroDataGridTheme({
    required this.data,
    required super.child,
    super.key,
  });

  final MetroDataGridThemeData data;

  static MetroDataGridThemeData? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MetroDataGridTheme>()
        ?.data;
  }

  static MetroDataGridThemeData of(BuildContext context) {
    return maybeOf(context) ?? const MetroDataGridThemeData();
  }

  @override
  bool updateShouldNotify(MetroDataGridTheme oldWidget) =>
      data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) {
    return MetroDataGridTheme(data: data, child: child);
  }
}
