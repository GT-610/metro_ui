import 'package:flutter/widgets.dart';

import '../../foundation/state_property.dart';

/// Visual properties for a [MetroButton].
@immutable
class MetroButtonStyle {
  const MetroButtonStyle({
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth,
    this.textStyle,
    this.padding,
    this.minimumSize,
    this.mouseCursor,
    this.pressScale,
  }) : assert(pressScale == null || (pressScale > 0 && pressScale <= 1));

  final WidgetStateProperty<Color?>? backgroundColor;
  final WidgetStateProperty<Color?>? foregroundColor;
  final WidgetStateProperty<Color?>? borderColor;
  final WidgetStateProperty<double?>? borderWidth;
  final WidgetStateProperty<TextStyle?>? textStyle;
  final EdgeInsetsGeometry? padding;
  final Size? minimumSize;
  final MouseCursor? mouseCursor;

  /// Scale applied while the button is pressed.
  ///
  /// Set this to `1` to keep a button stationary while retaining its color
  /// inversion and other pressed-state styling.
  final double? pressScale;

  MetroButtonStyle copyWith({
    WidgetStateProperty<Color?>? backgroundColor,
    WidgetStateProperty<Color?>? foregroundColor,
    WidgetStateProperty<Color?>? borderColor,
    WidgetStateProperty<double?>? borderWidth,
    WidgetStateProperty<TextStyle?>? textStyle,
    EdgeInsetsGeometry? padding,
    Size? minimumSize,
    MouseCursor? mouseCursor,
    double? pressScale,
  }) {
    return MetroButtonStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      textStyle: textStyle ?? this.textStyle,
      padding: padding ?? this.padding,
      minimumSize: minimumSize ?? this.minimumSize,
      mouseCursor: mouseCursor ?? this.mouseCursor,
      pressScale: pressScale ?? this.pressScale,
    );
  }

  MetroButtonStyle merge(MetroButtonStyle? other) {
    if (other == null) {
      return this;
    }
    return copyWith(
      backgroundColor: other.backgroundColor,
      foregroundColor: other.foregroundColor,
      borderColor: other.borderColor,
      borderWidth: other.borderWidth,
      textStyle: other.textStyle,
      padding: other.padding,
      minimumSize: other.minimumSize,
      mouseCursor: other.mouseCursor,
      pressScale: other.pressScale,
    );
  }

  static MetroButtonStyle lerp(
    MetroButtonStyle? a,
    MetroButtonStyle? b,
    double t,
  ) {
    final first = a ?? const MetroButtonStyle();
    final second = b ?? const MetroButtonStyle();
    return MetroButtonStyle(
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
      textStyle: lerpStateProperty(
        first.textStyle,
        second.textStyle,
        t,
        TextStyle.lerp,
      ),
      padding: EdgeInsetsGeometry.lerp(first.padding, second.padding, t),
      minimumSize: Size.lerp(first.minimumSize, second.minimumSize, t),
      mouseCursor: lerpDiscrete(first.mouseCursor, second.mouseCursor, t),
      pressScale: lerpDouble(first.pressScale, second.pressScale, t),
    );
  }
}

/// Theme overrides for standard and accented Metro buttons.
@immutable
class MetroButtonThemeData {
  const MetroButtonThemeData({this.style, this.accentStyle});

  final MetroButtonStyle? style;
  final MetroButtonStyle? accentStyle;

  MetroButtonThemeData copyWith({
    MetroButtonStyle? style,
    MetroButtonStyle? accentStyle,
  }) {
    return MetroButtonThemeData(
      style: style ?? this.style,
      accentStyle: accentStyle ?? this.accentStyle,
    );
  }

  MetroButtonThemeData merge(MetroButtonThemeData? other) {
    if (other == null) return this;
    return MetroButtonThemeData(
      style: style?.merge(other.style) ?? other.style,
      accentStyle: accentStyle?.merge(other.accentStyle) ?? other.accentStyle,
    );
  }

  static MetroButtonThemeData lerp(
    MetroButtonThemeData a,
    MetroButtonThemeData b,
    double t,
  ) {
    return MetroButtonThemeData(
      style: MetroButtonStyle.lerp(a.style, b.style, t),
      accentStyle: MetroButtonStyle.lerp(a.accentStyle, b.accentStyle, t),
    );
  }
}

/// Overrides button styling for a subtree.
class MetroButtonTheme extends InheritedTheme {
  const MetroButtonTheme({required this.data, required super.child, super.key});

  final MetroButtonThemeData data;

  static MetroButtonThemeData? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MetroButtonTheme>()?.data;
  }

  static MetroButtonThemeData of(BuildContext context) {
    return maybeOf(context) ?? const MetroButtonThemeData();
  }

  @override
  bool updateShouldNotify(MetroButtonTheme oldWidget) => data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) {
    return MetroButtonTheme(data: data, child: child);
  }
}
