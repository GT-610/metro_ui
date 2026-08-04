import 'package:flutter/widgets.dart';

import '../../foundation/state_property.dart';

/// Visual and measurement overrides shared by check boxes and radio buttons.
@immutable
class MetroSelectionControlStyle {
  const MetroSelectionControlStyle({
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth,
    this.labelStyle,
    this.size,
    this.indicatorSize,
  });

  final WidgetStateProperty<Color?>? backgroundColor;
  final WidgetStateProperty<Color?>? foregroundColor;
  final WidgetStateProperty<Color?>? borderColor;
  final WidgetStateProperty<double?>? borderWidth;
  final WidgetStateProperty<TextStyle?>? labelStyle;
  final double? size;
  final double? indicatorSize;

  MetroSelectionControlStyle copyWith({
    WidgetStateProperty<Color?>? backgroundColor,
    WidgetStateProperty<Color?>? foregroundColor,
    WidgetStateProperty<Color?>? borderColor,
    WidgetStateProperty<double?>? borderWidth,
    WidgetStateProperty<TextStyle?>? labelStyle,
    double? size,
    double? indicatorSize,
  }) {
    return MetroSelectionControlStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      labelStyle: labelStyle ?? this.labelStyle,
      size: size ?? this.size,
      indicatorSize: indicatorSize ?? this.indicatorSize,
    );
  }

  MetroSelectionControlStyle merge(MetroSelectionControlStyle? other) {
    if (other == null) return this;
    return copyWith(
      backgroundColor: other.backgroundColor,
      foregroundColor: other.foregroundColor,
      borderColor: other.borderColor,
      borderWidth: other.borderWidth,
      labelStyle: other.labelStyle,
      size: other.size,
      indicatorSize: other.indicatorSize,
    );
  }

  static MetroSelectionControlStyle lerp(
    MetroSelectionControlStyle? a,
    MetroSelectionControlStyle? b,
    double t,
  ) {
    final first = a ?? const MetroSelectionControlStyle();
    final second = b ?? const MetroSelectionControlStyle();
    return MetroSelectionControlStyle(
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
      labelStyle: lerpStateProperty(
        first.labelStyle,
        second.labelStyle,
        t,
        TextStyle.lerp,
      ),
      size: lerpDouble(first.size, second.size, t),
      indicatorSize: lerpDouble(first.indicatorSize, second.indicatorSize, t),
    );
  }
}

/// Application-level check-box theme values.
@immutable
class MetroCheckBoxThemeData {
  const MetroCheckBoxThemeData({this.style});
  final MetroSelectionControlStyle? style;

  MetroCheckBoxThemeData copyWith({MetroSelectionControlStyle? style}) {
    return MetroCheckBoxThemeData(style: style ?? this.style);
  }

  MetroCheckBoxThemeData merge(MetroCheckBoxThemeData? other) {
    if (other == null) return this;
    return MetroCheckBoxThemeData(
      style: style?.merge(other.style) ?? other.style,
    );
  }

  static MetroCheckBoxThemeData lerp(
    MetroCheckBoxThemeData a,
    MetroCheckBoxThemeData b,
    double t,
  ) => MetroCheckBoxThemeData(
    style: MetroSelectionControlStyle.lerp(a.style, b.style, t),
  );
}

/// Application-level radio-button theme values.
@immutable
class MetroRadioButtonThemeData {
  const MetroRadioButtonThemeData({this.style});
  final MetroSelectionControlStyle? style;

  MetroRadioButtonThemeData copyWith({MetroSelectionControlStyle? style}) {
    return MetroRadioButtonThemeData(style: style ?? this.style);
  }

  MetroRadioButtonThemeData merge(MetroRadioButtonThemeData? other) {
    if (other == null) return this;
    return MetroRadioButtonThemeData(
      style: style?.merge(other.style) ?? other.style,
    );
  }

  static MetroRadioButtonThemeData lerp(
    MetroRadioButtonThemeData a,
    MetroRadioButtonThemeData b,
    double t,
  ) => MetroRadioButtonThemeData(
    style: MetroSelectionControlStyle.lerp(a.style, b.style, t),
  );
}

/// Overrides check-box styling for a subtree.
class MetroCheckBoxTheme extends InheritedTheme {
  const MetroCheckBoxTheme({
    required this.data,
    required super.child,
    super.key,
  });

  final MetroCheckBoxThemeData data;

  static MetroCheckBoxThemeData? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MetroCheckBoxTheme>()
        ?.data;
  }

  static MetroCheckBoxThemeData of(BuildContext context) {
    return maybeOf(context) ?? const MetroCheckBoxThemeData();
  }

  @override
  bool updateShouldNotify(MetroCheckBoxTheme oldWidget) =>
      data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) {
    return MetroCheckBoxTheme(data: data, child: child);
  }
}

/// Overrides radio-button styling for a subtree.
class MetroRadioButtonTheme extends InheritedTheme {
  const MetroRadioButtonTheme({
    required this.data,
    required super.child,
    super.key,
  });

  final MetroRadioButtonThemeData data;

  static MetroRadioButtonThemeData? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MetroRadioButtonTheme>()
        ?.data;
  }

  static MetroRadioButtonThemeData of(BuildContext context) {
    return maybeOf(context) ?? const MetroRadioButtonThemeData();
  }

  @override
  bool updateShouldNotify(MetroRadioButtonTheme oldWidget) =>
      data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) {
    return MetroRadioButtonTheme(data: data, child: child);
  }
}
