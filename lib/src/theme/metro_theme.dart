import 'package:flutter/widgets.dart';

import 'metro_theme_data.dart';

/// Applies [MetroThemeData] to descendant Metro UI widgets.
class MetroTheme extends StatelessWidget {
  /// Creates a theme scope for [child].
  const MetroTheme({
    required this.data,
    required this.child,
    this.highContrastData,
    super.key,
  });

  /// The standard theme inherited by descendant Metro widgets.
  final MetroThemeData data;

  /// The theme used when the surrounding media query requests high contrast.
  ///
  /// When omitted, [data] remains active in high-contrast environments.
  final MetroThemeData? highContrastData;

  /// The subtree that receives this theme.
  final Widget child;

  static MetroThemeData of(BuildContext context) {
    final theme = maybeOf(context);
    assert(theme != null, 'No MetroTheme found in this context.');
    return theme!;
  }

  static MetroThemeData? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedMetroTheme>()
        ?.data;
  }

  @override
  Widget build(BuildContext context) {
    final useHighContrast = MediaQuery.maybeOf(context)?.highContrast == true;
    final effectiveData = useHighContrast ? highContrastData ?? data : data;
    return _InheritedMetroTheme(
      data: effectiveData,
      child: IconTheme(
        data: IconThemeData(color: effectiveData.colors.foreground, size: 20),
        child: DefaultTextStyle(
          style: effectiveData.typography.body,
          child: child,
        ),
      ),
    );
  }
}

class _InheritedMetroTheme extends InheritedTheme {
  const _InheritedMetroTheme({required this.data, required super.child});

  final MetroThemeData data;

  @override
  bool updateShouldNotify(_InheritedMetroTheme oldWidget) {
    return data != oldWidget.data;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return _InheritedMetroTheme(data: data, child: child);
  }
}

class _MetroThemeDataTween extends Tween<MetroThemeData> {
  _MetroThemeDataTween({super.begin});

  @override
  MetroThemeData lerp(double t) => MetroThemeData.lerp(begin!, end!, t);
}

/// Animates changes between complete Metro themes.
class AnimatedMetroTheme extends ImplicitlyAnimatedWidget {
  /// Creates a theme scope that animates changes to [data].
  const AnimatedMetroTheme({
    required this.data,
    required this.child,
    this.highContrastData,
    super.duration = const Duration(milliseconds: 200),
    super.curve = Curves.linear,
    super.onEnd,
    super.key,
  });

  /// The target theme for the current implicit animation.
  final MetroThemeData data;

  /// The theme used when the surrounding media query requests high contrast.
  ///
  /// High-contrast theme changes are applied by [MetroTheme] after the
  /// standard theme animation is evaluated.
  final MetroThemeData? highContrastData;

  /// The subtree that receives the animated theme.
  final Widget child;

  @override
  AnimatedWidgetBaseState<AnimatedMetroTheme> createState() {
    return _AnimatedMetroThemeState();
  }
}

class _AnimatedMetroThemeState
    extends AnimatedWidgetBaseState<AnimatedMetroTheme> {
  _MetroThemeDataTween? _data;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _data =
        visitor(
              _data,
              widget.data,
              (value) => _MetroThemeDataTween(begin: value as MetroThemeData),
            )
            as _MetroThemeDataTween?;
  }

  @override
  Widget build(BuildContext context) {
    return MetroTheme(
      data: _data!.evaluate(animation),
      highContrastData: widget.highContrastData,
      child: widget.child,
    );
  }
}
