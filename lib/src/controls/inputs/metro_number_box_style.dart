import 'package:flutter/widgets.dart';

import '../../foundation/state_property.dart';
import 'metro_text_field_style.dart';

/// Visual and sizing overrides for [MetroNumberBoxTheme].
@immutable
class MetroNumberBoxStyle {
  const MetroNumberBoxStyle({
    this.fieldStyle,
    this.buttonBackgroundColor,
    this.buttonForegroundColor,
    this.buttonExtent,
    this.iconSize,
  }) : assert(buttonExtent == null || buttonExtent > 0),
       assert(iconSize == null || iconSize > 0);

  final MetroTextFieldStyle? fieldStyle;
  final WidgetStateProperty<Color?>? buttonBackgroundColor;
  final WidgetStateProperty<Color?>? buttonForegroundColor;
  final double? buttonExtent;
  final double? iconSize;

  MetroNumberBoxStyle copyWith({
    MetroTextFieldStyle? fieldStyle,
    WidgetStateProperty<Color?>? buttonBackgroundColor,
    WidgetStateProperty<Color?>? buttonForegroundColor,
    double? buttonExtent,
    double? iconSize,
  }) {
    return MetroNumberBoxStyle(
      fieldStyle: fieldStyle ?? this.fieldStyle,
      buttonBackgroundColor:
          buttonBackgroundColor ?? this.buttonBackgroundColor,
      buttonForegroundColor:
          buttonForegroundColor ?? this.buttonForegroundColor,
      buttonExtent: buttonExtent ?? this.buttonExtent,
      iconSize: iconSize ?? this.iconSize,
    );
  }

  MetroNumberBoxStyle merge(MetroNumberBoxStyle? other) {
    if (other == null) {
      return this;
    }
    return copyWith(
      fieldStyle: fieldStyle?.merge(other.fieldStyle) ?? other.fieldStyle,
      buttonBackgroundColor: other.buttonBackgroundColor,
      buttonForegroundColor: other.buttonForegroundColor,
      buttonExtent: other.buttonExtent,
      iconSize: other.iconSize,
    );
  }

  static MetroNumberBoxStyle lerp(
    MetroNumberBoxStyle? a,
    MetroNumberBoxStyle? b,
    double t,
  ) {
    final first = a ?? const MetroNumberBoxStyle();
    final second = b ?? const MetroNumberBoxStyle();
    return MetroNumberBoxStyle(
      fieldStyle: MetroTextFieldStyle.lerp(
        first.fieldStyle,
        second.fieldStyle,
        t,
      ),
      buttonBackgroundColor: lerpStateProperty(
        first.buttonBackgroundColor,
        second.buttonBackgroundColor,
        t,
        Color.lerp,
      ),
      buttonForegroundColor: lerpStateProperty(
        first.buttonForegroundColor,
        second.buttonForegroundColor,
        t,
        Color.lerp,
      ),
      buttonExtent: lerpDouble(first.buttonExtent, second.buttonExtent, t),
      iconSize: lerpDouble(first.iconSize, second.iconSize, t),
    );
  }
}

/// Application-level theme values for Metro number boxes.
@immutable
class MetroNumberBoxThemeData {
  const MetroNumberBoxThemeData({this.style});

  final MetroNumberBoxStyle? style;

  MetroNumberBoxThemeData copyWith({MetroNumberBoxStyle? style}) {
    return MetroNumberBoxThemeData(style: style ?? this.style);
  }

  MetroNumberBoxThemeData merge(MetroNumberBoxThemeData? other) {
    if (other == null) {
      return this;
    }
    return MetroNumberBoxThemeData(
      style: style?.merge(other.style) ?? other.style,
    );
  }

  static MetroNumberBoxThemeData lerp(
    MetroNumberBoxThemeData a,
    MetroNumberBoxThemeData b,
    double t,
  ) {
    return MetroNumberBoxThemeData(
      style: MetroNumberBoxStyle.lerp(a.style, b.style, t),
    );
  }
}

/// Overrides number-box styling for a subtree.
class MetroNumberBoxTheme extends InheritedTheme {
  const MetroNumberBoxTheme({
    required this.data,
    required super.child,
    super.key,
  });

  final MetroNumberBoxThemeData data;

  static MetroNumberBoxThemeData? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MetroNumberBoxTheme>()
        ?.data;
  }

  static MetroNumberBoxThemeData of(BuildContext context) {
    return maybeOf(context) ?? const MetroNumberBoxThemeData();
  }

  @override
  bool updateShouldNotify(MetroNumberBoxTheme oldWidget) {
    return data != oldWidget.data;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return MetroNumberBoxTheme(data: data, child: child);
  }
}
