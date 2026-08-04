import 'package:flutter/widgets.dart';

import '../../foundation/state_property.dart';

/// Visual and measurement overrides for [MetroFlipViewTheme].
@immutable
class MetroFlipViewStyle {
  const MetroFlipViewStyle({
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.navigationBackgroundColor,
    this.navigationForegroundColor,
    this.navigationBorderColor,
    this.navigationBorderWidth,
    this.navigationButtonExtent,
    this.navigationButtonCrossExtent,
    this.navigationInset,
    this.bannerBackgroundColor,
    this.bannerForegroundColor,
    this.bannerTextStyle,
    this.bannerPadding,
    this.indicatorColor,
    this.selectedIndicatorColor,
    this.indicatorSize,
    this.indicatorSpacing,
    this.indicatorPadding,
    this.indicatorAlignment,
  }) : assert(navigationButtonExtent == null || navigationButtonExtent > 0),
       assert(
         navigationButtonCrossExtent == null || navigationButtonCrossExtent > 0,
       ),
       assert(navigationInset == null || navigationInset >= 0),
       assert(indicatorSize == null || indicatorSize > 0),
       assert(indicatorSpacing == null || indicatorSpacing >= 0);

  final Color? backgroundColor;
  final WidgetStateProperty<Color?>? borderColor;
  final WidgetStateProperty<double?>? borderWidth;
  final WidgetStateProperty<Color?>? navigationBackgroundColor;
  final WidgetStateProperty<Color?>? navigationForegroundColor;
  final WidgetStateProperty<Color?>? navigationBorderColor;
  final WidgetStateProperty<double?>? navigationBorderWidth;
  final double? navigationButtonExtent;
  final double? navigationButtonCrossExtent;
  final double? navigationInset;
  final Color? bannerBackgroundColor;
  final Color? bannerForegroundColor;
  final TextStyle? bannerTextStyle;
  final EdgeInsetsGeometry? bannerPadding;
  final Color? indicatorColor;
  final Color? selectedIndicatorColor;
  final double? indicatorSize;
  final double? indicatorSpacing;
  final EdgeInsetsGeometry? indicatorPadding;
  final AlignmentGeometry? indicatorAlignment;

  MetroFlipViewStyle copyWith({
    Color? backgroundColor,
    WidgetStateProperty<Color?>? borderColor,
    WidgetStateProperty<double?>? borderWidth,
    WidgetStateProperty<Color?>? navigationBackgroundColor,
    WidgetStateProperty<Color?>? navigationForegroundColor,
    WidgetStateProperty<Color?>? navigationBorderColor,
    WidgetStateProperty<double?>? navigationBorderWidth,
    double? navigationButtonExtent,
    double? navigationButtonCrossExtent,
    double? navigationInset,
    Color? bannerBackgroundColor,
    Color? bannerForegroundColor,
    TextStyle? bannerTextStyle,
    EdgeInsetsGeometry? bannerPadding,
    Color? indicatorColor,
    Color? selectedIndicatorColor,
    double? indicatorSize,
    double? indicatorSpacing,
    EdgeInsetsGeometry? indicatorPadding,
    AlignmentGeometry? indicatorAlignment,
  }) {
    return MetroFlipViewStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      navigationBackgroundColor:
          navigationBackgroundColor ?? this.navigationBackgroundColor,
      navigationForegroundColor:
          navigationForegroundColor ?? this.navigationForegroundColor,
      navigationBorderColor:
          navigationBorderColor ?? this.navigationBorderColor,
      navigationBorderWidth:
          navigationBorderWidth ?? this.navigationBorderWidth,
      navigationButtonExtent:
          navigationButtonExtent ?? this.navigationButtonExtent,
      navigationButtonCrossExtent:
          navigationButtonCrossExtent ?? this.navigationButtonCrossExtent,
      navigationInset: navigationInset ?? this.navigationInset,
      bannerBackgroundColor:
          bannerBackgroundColor ?? this.bannerBackgroundColor,
      bannerForegroundColor:
          bannerForegroundColor ?? this.bannerForegroundColor,
      bannerTextStyle: bannerTextStyle ?? this.bannerTextStyle,
      bannerPadding: bannerPadding ?? this.bannerPadding,
      indicatorColor: indicatorColor ?? this.indicatorColor,
      selectedIndicatorColor:
          selectedIndicatorColor ?? this.selectedIndicatorColor,
      indicatorSize: indicatorSize ?? this.indicatorSize,
      indicatorSpacing: indicatorSpacing ?? this.indicatorSpacing,
      indicatorPadding: indicatorPadding ?? this.indicatorPadding,
      indicatorAlignment: indicatorAlignment ?? this.indicatorAlignment,
    );
  }

  MetroFlipViewStyle merge(MetroFlipViewStyle? other) {
    if (other == null) {
      return this;
    }
    return copyWith(
      backgroundColor: other.backgroundColor,
      borderColor: other.borderColor,
      borderWidth: other.borderWidth,
      navigationBackgroundColor: other.navigationBackgroundColor,
      navigationForegroundColor: other.navigationForegroundColor,
      navigationBorderColor: other.navigationBorderColor,
      navigationBorderWidth: other.navigationBorderWidth,
      navigationButtonExtent: other.navigationButtonExtent,
      navigationButtonCrossExtent: other.navigationButtonCrossExtent,
      navigationInset: other.navigationInset,
      bannerBackgroundColor: other.bannerBackgroundColor,
      bannerForegroundColor: other.bannerForegroundColor,
      bannerTextStyle: other.bannerTextStyle,
      bannerPadding: other.bannerPadding,
      indicatorColor: other.indicatorColor,
      selectedIndicatorColor: other.selectedIndicatorColor,
      indicatorSize: other.indicatorSize,
      indicatorSpacing: other.indicatorSpacing,
      indicatorPadding: other.indicatorPadding,
      indicatorAlignment: other.indicatorAlignment,
    );
  }

  static MetroFlipViewStyle lerp(
    MetroFlipViewStyle? a,
    MetroFlipViewStyle? b,
    double t,
  ) {
    final first = a ?? const MetroFlipViewStyle();
    final second = b ?? const MetroFlipViewStyle();
    return MetroFlipViewStyle(
      backgroundColor: Color.lerp(
        first.backgroundColor,
        second.backgroundColor,
        t,
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
      navigationBackgroundColor: lerpStateProperty(
        first.navigationBackgroundColor,
        second.navigationBackgroundColor,
        t,
        Color.lerp,
      ),
      navigationForegroundColor: lerpStateProperty(
        first.navigationForegroundColor,
        second.navigationForegroundColor,
        t,
        Color.lerp,
      ),
      navigationBorderColor: lerpStateProperty(
        first.navigationBorderColor,
        second.navigationBorderColor,
        t,
        Color.lerp,
      ),
      navigationBorderWidth: lerpStateProperty(
        first.navigationBorderWidth,
        second.navigationBorderWidth,
        t,
        lerpDouble,
      ),
      navigationButtonExtent: lerpDouble(
        first.navigationButtonExtent,
        second.navigationButtonExtent,
        t,
      ),
      navigationButtonCrossExtent: lerpDouble(
        first.navigationButtonCrossExtent,
        second.navigationButtonCrossExtent,
        t,
      ),
      navigationInset: lerpDouble(
        first.navigationInset,
        second.navigationInset,
        t,
      ),
      bannerBackgroundColor: Color.lerp(
        first.bannerBackgroundColor,
        second.bannerBackgroundColor,
        t,
      ),
      bannerForegroundColor: Color.lerp(
        first.bannerForegroundColor,
        second.bannerForegroundColor,
        t,
      ),
      bannerTextStyle: TextStyle.lerp(
        first.bannerTextStyle,
        second.bannerTextStyle,
        t,
      ),
      bannerPadding: EdgeInsetsGeometry.lerp(
        first.bannerPadding,
        second.bannerPadding,
        t,
      ),
      indicatorColor: Color.lerp(
        first.indicatorColor,
        second.indicatorColor,
        t,
      ),
      selectedIndicatorColor: Color.lerp(
        first.selectedIndicatorColor,
        second.selectedIndicatorColor,
        t,
      ),
      indicatorSize: lerpDouble(first.indicatorSize, second.indicatorSize, t),
      indicatorSpacing: lerpDouble(
        first.indicatorSpacing,
        second.indicatorSpacing,
        t,
      ),
      indicatorPadding: EdgeInsetsGeometry.lerp(
        first.indicatorPadding,
        second.indicatorPadding,
        t,
      ),
      indicatorAlignment: AlignmentGeometry.lerp(
        first.indicatorAlignment,
        second.indicatorAlignment,
        t,
      ),
    );
  }
}

/// Application-level theme values for Metro FlipView controls.
@immutable
class MetroFlipViewThemeData {
  const MetroFlipViewThemeData({this.style});

  final MetroFlipViewStyle? style;

  MetroFlipViewThemeData copyWith({MetroFlipViewStyle? style}) {
    return MetroFlipViewThemeData(style: style ?? this.style);
  }

  MetroFlipViewThemeData merge(MetroFlipViewThemeData? other) {
    if (other == null) {
      return this;
    }
    return MetroFlipViewThemeData(
      style: style?.merge(other.style) ?? other.style,
    );
  }

  static MetroFlipViewThemeData lerp(
    MetroFlipViewThemeData a,
    MetroFlipViewThemeData b,
    double t,
  ) {
    return MetroFlipViewThemeData(
      style: MetroFlipViewStyle.lerp(a.style, b.style, t),
    );
  }
}

/// Overrides FlipView styling for a subtree.
class MetroFlipViewTheme extends InheritedTheme {
  const MetroFlipViewTheme({
    required this.data,
    required super.child,
    super.key,
  });

  final MetroFlipViewThemeData data;

  static MetroFlipViewThemeData? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MetroFlipViewTheme>()
        ?.data;
  }

  static MetroFlipViewThemeData of(BuildContext context) {
    return maybeOf(context) ?? const MetroFlipViewThemeData();
  }

  @override
  bool updateShouldNotify(MetroFlipViewTheme oldWidget) {
    return data != oldWidget.data;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return MetroFlipViewTheme(data: data, child: child);
  }
}
