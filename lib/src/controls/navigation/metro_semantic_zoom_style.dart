import 'package:flutter/widgets.dart';

import '../../foundation/state_property.dart';

/// Visual and measurement overrides for [MetroSemanticZoomTheme].
@immutable
class MetroSemanticZoomStyle {
  const MetroSemanticZoomStyle({
    this.buttonBackgroundColor,
    this.buttonForegroundColor,
    this.buttonBorderColor,
    this.buttonBorderWidth,
    this.buttonSize,
    this.buttonIconSize,
    this.buttonEndInset,
    this.buttonBottomInset,
    this.buttonShowDuration,
    this.buttonMouseCursor,
  }) : assert(buttonSize == null || buttonSize > 0),
       assert(buttonIconSize == null || buttonIconSize > 0),
       assert(buttonEndInset == null || buttonEndInset >= 0),
       assert(buttonBottomInset == null || buttonBottomInset >= 0);

  final WidgetStateProperty<Color?>? buttonBackgroundColor;
  final WidgetStateProperty<Color?>? buttonForegroundColor;
  final WidgetStateProperty<Color?>? buttonBorderColor;
  final WidgetStateProperty<double?>? buttonBorderWidth;
  final double? buttonSize;
  final double? buttonIconSize;
  final double? buttonEndInset;
  final double? buttonBottomInset;
  final Duration? buttonShowDuration;
  final MouseCursor? buttonMouseCursor;

  MetroSemanticZoomStyle copyWith({
    WidgetStateProperty<Color?>? buttonBackgroundColor,
    WidgetStateProperty<Color?>? buttonForegroundColor,
    WidgetStateProperty<Color?>? buttonBorderColor,
    WidgetStateProperty<double?>? buttonBorderWidth,
    double? buttonSize,
    double? buttonIconSize,
    double? buttonEndInset,
    double? buttonBottomInset,
    Duration? buttonShowDuration,
    MouseCursor? buttonMouseCursor,
  }) {
    return MetroSemanticZoomStyle(
      buttonBackgroundColor:
          buttonBackgroundColor ?? this.buttonBackgroundColor,
      buttonForegroundColor:
          buttonForegroundColor ?? this.buttonForegroundColor,
      buttonBorderColor: buttonBorderColor ?? this.buttonBorderColor,
      buttonBorderWidth: buttonBorderWidth ?? this.buttonBorderWidth,
      buttonSize: buttonSize ?? this.buttonSize,
      buttonIconSize: buttonIconSize ?? this.buttonIconSize,
      buttonEndInset: buttonEndInset ?? this.buttonEndInset,
      buttonBottomInset: buttonBottomInset ?? this.buttonBottomInset,
      buttonShowDuration: buttonShowDuration ?? this.buttonShowDuration,
      buttonMouseCursor: buttonMouseCursor ?? this.buttonMouseCursor,
    );
  }

  MetroSemanticZoomStyle merge(MetroSemanticZoomStyle? other) {
    if (other == null) return this;
    return copyWith(
      buttonBackgroundColor: other.buttonBackgroundColor,
      buttonForegroundColor: other.buttonForegroundColor,
      buttonBorderColor: other.buttonBorderColor,
      buttonBorderWidth: other.buttonBorderWidth,
      buttonSize: other.buttonSize,
      buttonIconSize: other.buttonIconSize,
      buttonEndInset: other.buttonEndInset,
      buttonBottomInset: other.buttonBottomInset,
      buttonShowDuration: other.buttonShowDuration,
      buttonMouseCursor: other.buttonMouseCursor,
    );
  }

  static MetroSemanticZoomStyle lerp(
    MetroSemanticZoomStyle? a,
    MetroSemanticZoomStyle? b,
    double t,
  ) {
    final first = a ?? const MetroSemanticZoomStyle();
    final second = b ?? const MetroSemanticZoomStyle();
    return MetroSemanticZoomStyle(
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
      buttonBorderColor: lerpStateProperty(
        first.buttonBorderColor,
        second.buttonBorderColor,
        t,
        Color.lerp,
      ),
      buttonBorderWidth: lerpStateProperty(
        first.buttonBorderWidth,
        second.buttonBorderWidth,
        t,
        lerpDouble,
      ),
      buttonSize: lerpDouble(first.buttonSize, second.buttonSize, t),
      buttonIconSize: lerpDouble(
        first.buttonIconSize,
        second.buttonIconSize,
        t,
      ),
      buttonEndInset: lerpDouble(
        first.buttonEndInset,
        second.buttonEndInset,
        t,
      ),
      buttonBottomInset: lerpDouble(
        first.buttonBottomInset,
        second.buttonBottomInset,
        t,
      ),
      buttonShowDuration: _lerpDuration(
        first.buttonShowDuration,
        second.buttonShowDuration,
        t,
      ),
      buttonMouseCursor: lerpDiscrete(
        first.buttonMouseCursor,
        second.buttonMouseCursor,
        t,
      ),
    );
  }
}

Duration? _lerpDuration(Duration? a, Duration? b, double t) {
  if (a == null && b == null) return null;
  final first = a ?? b!;
  final second = b ?? a!;
  return Duration(
    microseconds:
        (first.inMicroseconds +
                (second.inMicroseconds - first.inMicroseconds) * t)
            .round(),
  );
}

/// Application-level styling for Metro semantic zoom controls.
@immutable
class MetroSemanticZoomThemeData {
  const MetroSemanticZoomThemeData({this.style});

  final MetroSemanticZoomStyle? style;

  MetroSemanticZoomThemeData copyWith({MetroSemanticZoomStyle? style}) {
    return MetroSemanticZoomThemeData(style: style ?? this.style);
  }

  MetroSemanticZoomThemeData merge(MetroSemanticZoomThemeData? other) {
    if (other == null) return this;
    return MetroSemanticZoomThemeData(
      style: style?.merge(other.style) ?? other.style,
    );
  }

  static MetroSemanticZoomThemeData lerp(
    MetroSemanticZoomThemeData a,
    MetroSemanticZoomThemeData b,
    double t,
  ) {
    return MetroSemanticZoomThemeData(
      style: MetroSemanticZoomStyle.lerp(a.style, b.style, t),
    );
  }
}

/// Overrides semantic-zoom styling for a subtree.
class MetroSemanticZoomTheme extends InheritedTheme {
  const MetroSemanticZoomTheme({
    required this.data,
    required super.child,
    super.key,
  });

  final MetroSemanticZoomThemeData data;

  static MetroSemanticZoomThemeData? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MetroSemanticZoomTheme>()
        ?.data;
  }

  static MetroSemanticZoomThemeData of(BuildContext context) {
    return maybeOf(context) ?? const MetroSemanticZoomThemeData();
  }

  @override
  bool updateShouldNotify(MetroSemanticZoomTheme oldWidget) =>
      data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) {
    return MetroSemanticZoomTheme(data: data, child: child);
  }
}
