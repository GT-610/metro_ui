import 'package:flutter/widgets.dart';

import '../../foundation/state_property.dart';

/// Visual overrides for Metro text fields.
@immutable
class MetroTextFieldStyle {
  const MetroTextFieldStyle({
    this.backgroundColor,
    this.foregroundColor,
    this.placeholderColor,
    this.borderColor,
    this.borderWidth,
    this.cursorColor,
    this.selectionColor,
    this.textStyle,
    this.placeholderStyle,
    this.labelStyle,
    this.supportingTextStyle,
    this.errorColor,
    this.successColor,
    this.padding,
  });

  final WidgetStateProperty<Color?>? backgroundColor;
  final WidgetStateProperty<Color?>? foregroundColor;
  final WidgetStateProperty<Color?>? placeholderColor;
  final WidgetStateProperty<Color?>? borderColor;
  final WidgetStateProperty<double?>? borderWidth;
  final WidgetStateProperty<Color?>? cursorColor;
  final WidgetStateProperty<Color?>? selectionColor;
  final WidgetStateProperty<TextStyle?>? textStyle;
  final WidgetStateProperty<TextStyle?>? placeholderStyle;
  final WidgetStateProperty<TextStyle?>? labelStyle;
  final WidgetStateProperty<TextStyle?>? supportingTextStyle;
  final WidgetStateProperty<Color?>? errorColor;
  final WidgetStateProperty<Color?>? successColor;
  final EdgeInsetsGeometry? padding;

  MetroTextFieldStyle copyWith({
    WidgetStateProperty<Color?>? backgroundColor,
    WidgetStateProperty<Color?>? foregroundColor,
    WidgetStateProperty<Color?>? placeholderColor,
    WidgetStateProperty<Color?>? borderColor,
    WidgetStateProperty<double?>? borderWidth,
    WidgetStateProperty<Color?>? cursorColor,
    WidgetStateProperty<Color?>? selectionColor,
    WidgetStateProperty<TextStyle?>? textStyle,
    WidgetStateProperty<TextStyle?>? placeholderStyle,
    WidgetStateProperty<TextStyle?>? labelStyle,
    WidgetStateProperty<TextStyle?>? supportingTextStyle,
    WidgetStateProperty<Color?>? errorColor,
    WidgetStateProperty<Color?>? successColor,
    EdgeInsetsGeometry? padding,
  }) {
    return MetroTextFieldStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      placeholderColor: placeholderColor ?? this.placeholderColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      cursorColor: cursorColor ?? this.cursorColor,
      selectionColor: selectionColor ?? this.selectionColor,
      textStyle: textStyle ?? this.textStyle,
      placeholderStyle: placeholderStyle ?? this.placeholderStyle,
      labelStyle: labelStyle ?? this.labelStyle,
      supportingTextStyle: supportingTextStyle ?? this.supportingTextStyle,
      errorColor: errorColor ?? this.errorColor,
      successColor: successColor ?? this.successColor,
      padding: padding ?? this.padding,
    );
  }

  MetroTextFieldStyle merge(MetroTextFieldStyle? other) {
    if (other == null) {
      return this;
    }
    return copyWith(
      backgroundColor: other.backgroundColor,
      foregroundColor: other.foregroundColor,
      placeholderColor: other.placeholderColor,
      borderColor: other.borderColor,
      borderWidth: other.borderWidth,
      cursorColor: other.cursorColor,
      selectionColor: other.selectionColor,
      textStyle: other.textStyle,
      placeholderStyle: other.placeholderStyle,
      labelStyle: other.labelStyle,
      supportingTextStyle: other.supportingTextStyle,
      errorColor: other.errorColor,
      successColor: other.successColor,
      padding: other.padding,
    );
  }

  static MetroTextFieldStyle lerp(
    MetroTextFieldStyle? a,
    MetroTextFieldStyle? b,
    double t,
  ) {
    final first = a ?? const MetroTextFieldStyle();
    final second = b ?? const MetroTextFieldStyle();
    return MetroTextFieldStyle(
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
      cursorColor: lerpStateProperty(
        first.cursorColor,
        second.cursorColor,
        t,
        Color.lerp,
      ),
      selectionColor: lerpStateProperty(
        first.selectionColor,
        second.selectionColor,
        t,
        Color.lerp,
      ),
      textStyle: lerpStateProperty(
        first.textStyle,
        second.textStyle,
        t,
        TextStyle.lerp,
      ),
      placeholderStyle: lerpStateProperty(
        first.placeholderStyle,
        second.placeholderStyle,
        t,
        TextStyle.lerp,
      ),
      labelStyle: lerpStateProperty(
        first.labelStyle,
        second.labelStyle,
        t,
        TextStyle.lerp,
      ),
      supportingTextStyle: lerpStateProperty(
        first.supportingTextStyle,
        second.supportingTextStyle,
        t,
        TextStyle.lerp,
      ),
      errorColor: lerpStateProperty(
        first.errorColor,
        second.errorColor,
        t,
        Color.lerp,
      ),
      successColor: lerpStateProperty(
        first.successColor,
        second.successColor,
        t,
        Color.lerp,
      ),
      padding: EdgeInsetsGeometry.lerp(first.padding, second.padding, t),
    );
  }
}

/// Application-level text-field theme values.
@immutable
class MetroTextFieldThemeData {
  const MetroTextFieldThemeData({this.style});

  final MetroTextFieldStyle? style;

  MetroTextFieldThemeData copyWith({MetroTextFieldStyle? style}) {
    return MetroTextFieldThemeData(style: style ?? this.style);
  }

  MetroTextFieldThemeData merge(MetroTextFieldThemeData? other) {
    if (other == null) {
      return this;
    }
    return MetroTextFieldThemeData(
      style: style?.merge(other.style) ?? other.style,
    );
  }

  static MetroTextFieldThemeData lerp(
    MetroTextFieldThemeData a,
    MetroTextFieldThemeData b,
    double t,
  ) {
    return MetroTextFieldThemeData(
      style: MetroTextFieldStyle.lerp(a.style, b.style, t),
    );
  }
}

/// Overrides text-field styling for a subtree without replacing the complete
/// application theme.
class MetroTextFieldTheme extends InheritedTheme {
  const MetroTextFieldTheme({
    required this.data,
    required super.child,
    super.key,
  });

  final MetroTextFieldThemeData data;

  static MetroTextFieldThemeData of(BuildContext context) {
    return maybeOf(context) ?? const MetroTextFieldThemeData();
  }

  static MetroTextFieldThemeData? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MetroTextFieldTheme>()
        ?.data;
  }

  @override
  bool updateShouldNotify(MetroTextFieldTheme oldWidget) {
    return data != oldWidget.data;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return MetroTextFieldTheme(data: data, child: child);
  }
}
