import 'package:flutter/widgets.dart';

import '../../foundation/state_property.dart';

/// Stateful visual properties for a [MetroCommandButton].
@immutable
class MetroCommandButtonStyle {
  const MetroCommandButtonStyle({
    this.circleColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth,
    this.labelStyle,
    this.minimumSize,
    this.mouseCursor,
  });

  final WidgetStateProperty<Color?>? circleColor;
  final WidgetStateProperty<Color?>? foregroundColor;
  final WidgetStateProperty<Color?>? borderColor;
  final WidgetStateProperty<double?>? borderWidth;
  final WidgetStateProperty<TextStyle?>? labelStyle;
  final Size? minimumSize;
  final MouseCursor? mouseCursor;

  MetroCommandButtonStyle copyWith({
    WidgetStateProperty<Color?>? circleColor,
    WidgetStateProperty<Color?>? foregroundColor,
    WidgetStateProperty<Color?>? borderColor,
    WidgetStateProperty<double?>? borderWidth,
    WidgetStateProperty<TextStyle?>? labelStyle,
    Size? minimumSize,
    MouseCursor? mouseCursor,
  }) {
    return MetroCommandButtonStyle(
      circleColor: circleColor ?? this.circleColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      labelStyle: labelStyle ?? this.labelStyle,
      minimumSize: minimumSize ?? this.minimumSize,
      mouseCursor: mouseCursor ?? this.mouseCursor,
    );
  }

  MetroCommandButtonStyle merge(MetroCommandButtonStyle? other) {
    if (other == null) {
      return this;
    }
    return copyWith(
      circleColor: other.circleColor,
      foregroundColor: other.foregroundColor,
      borderColor: other.borderColor,
      borderWidth: other.borderWidth,
      labelStyle: other.labelStyle,
      minimumSize: other.minimumSize,
      mouseCursor: other.mouseCursor,
    );
  }

  static MetroCommandButtonStyle lerp(
    MetroCommandButtonStyle? a,
    MetroCommandButtonStyle? b,
    double t,
  ) {
    final first = a ?? const MetroCommandButtonStyle();
    final second = b ?? const MetroCommandButtonStyle();
    return MetroCommandButtonStyle(
      circleColor: lerpStateProperty(
        first.circleColor,
        second.circleColor,
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
      minimumSize: Size.lerp(first.minimumSize, second.minimumSize, t),
      mouseCursor: lerpDiscrete(first.mouseCursor, second.mouseCursor, t),
    );
  }
}

/// Theme values shared by a Metro bottom command bar and its command buttons.
@immutable
class MetroCommandBarThemeData {
  const MetroCommandBarThemeData({
    this.backgroundColor,
    this.height,
    this.padding,
    this.spacing,
    this.buttonStyle,
  });

  final Color? backgroundColor;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double? spacing;
  final MetroCommandButtonStyle? buttonStyle;

  MetroCommandBarThemeData copyWith({
    Color? backgroundColor,
    double? height,
    EdgeInsetsGeometry? padding,
    double? spacing,
    MetroCommandButtonStyle? buttonStyle,
  }) {
    return MetroCommandBarThemeData(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      height: height ?? this.height,
      padding: padding ?? this.padding,
      spacing: spacing ?? this.spacing,
      buttonStyle: buttonStyle ?? this.buttonStyle,
    );
  }

  MetroCommandBarThemeData merge(MetroCommandBarThemeData? other) {
    if (other == null) {
      return this;
    }
    return MetroCommandBarThemeData(
      backgroundColor: other.backgroundColor ?? backgroundColor,
      height: other.height ?? height,
      padding: other.padding ?? padding,
      spacing: other.spacing ?? spacing,
      buttonStyle: buttonStyle?.merge(other.buttonStyle) ?? other.buttonStyle,
    );
  }

  static MetroCommandBarThemeData lerp(
    MetroCommandBarThemeData a,
    MetroCommandBarThemeData b,
    double t,
  ) {
    return MetroCommandBarThemeData(
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      height: lerpDouble(a.height, b.height, t),
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      spacing: lerpDouble(a.spacing, b.spacing, t),
      buttonStyle: MetroCommandButtonStyle.lerp(
        a.buttonStyle,
        b.buttonStyle,
        t,
      ),
    );
  }
}

/// Applies command-bar theme overrides to a subtree.
class MetroCommandBarTheme extends InheritedTheme {
  const MetroCommandBarTheme({
    required this.data,
    required super.child,
    super.key,
  });

  final MetroCommandBarThemeData data;

  static MetroCommandBarThemeData of(BuildContext context) {
    return maybeOf(context) ?? const MetroCommandBarThemeData();
  }

  static MetroCommandBarThemeData? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MetroCommandBarTheme>()
        ?.data;
  }

  @override
  bool updateShouldNotify(MetroCommandBarTheme oldWidget) {
    return data != oldWidget.data;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return MetroCommandBarTheme(data: data, child: child);
  }
}
