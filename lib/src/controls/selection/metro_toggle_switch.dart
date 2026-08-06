import 'package:flutter/widgets.dart';

import '../../foundation/metro_interactive.dart';
import '../../foundation/state_property.dart';
import '../../theme/metro_theme.dart';
import '../../theme/metro_theme_data.dart';

/// Visual properties for [MetroToggleSwitch].
@immutable
class MetroToggleSwitchStyle {
  const MetroToggleSwitchStyle({
    this.trackColor,
    this.thumbColor,
    this.borderColor,
    this.borderWidth,
    this.labelStyle,
    this.trackSize,
    this.thumbSize,
  });

  final WidgetStateProperty<Color?>? trackColor;
  final WidgetStateProperty<Color?>? thumbColor;
  final WidgetStateProperty<Color?>? borderColor;
  final WidgetStateProperty<double?>? borderWidth;
  final WidgetStateProperty<TextStyle?>? labelStyle;
  final Size? trackSize;
  final double? thumbSize;

  MetroToggleSwitchStyle copyWith({
    WidgetStateProperty<Color?>? trackColor,
    WidgetStateProperty<Color?>? thumbColor,
    WidgetStateProperty<Color?>? borderColor,
    WidgetStateProperty<double?>? borderWidth,
    WidgetStateProperty<TextStyle?>? labelStyle,
    Size? trackSize,
    double? thumbSize,
  }) {
    return MetroToggleSwitchStyle(
      trackColor: trackColor ?? this.trackColor,
      thumbColor: thumbColor ?? this.thumbColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      labelStyle: labelStyle ?? this.labelStyle,
      trackSize: trackSize ?? this.trackSize,
      thumbSize: thumbSize ?? this.thumbSize,
    );
  }

  MetroToggleSwitchStyle merge(MetroToggleSwitchStyle? other) {
    if (other == null) {
      return this;
    }
    return copyWith(
      trackColor: other.trackColor,
      thumbColor: other.thumbColor,
      borderColor: other.borderColor,
      borderWidth: other.borderWidth,
      labelStyle: other.labelStyle,
      trackSize: other.trackSize,
      thumbSize: other.thumbSize,
    );
  }

  static MetroToggleSwitchStyle lerp(
    MetroToggleSwitchStyle? a,
    MetroToggleSwitchStyle? b,
    double t,
  ) {
    final first = a ?? const MetroToggleSwitchStyle();
    final second = b ?? const MetroToggleSwitchStyle();
    return MetroToggleSwitchStyle(
      trackColor: lerpStateProperty(
        first.trackColor,
        second.trackColor,
        t,
        Color.lerp,
      ),
      thumbColor: lerpStateProperty(
        first.thumbColor,
        second.thumbColor,
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
      trackSize: Size.lerp(first.trackSize, second.trackSize, t),
      thumbSize: lerpDouble(first.thumbSize, second.thumbSize, t),
    );
  }
}

/// Application-level toggle-switch theme values.
@immutable
class MetroToggleSwitchThemeData {
  const MetroToggleSwitchThemeData({this.style});

  final MetroToggleSwitchStyle? style;

  MetroToggleSwitchThemeData copyWith({MetroToggleSwitchStyle? style}) {
    return MetroToggleSwitchThemeData(style: style ?? this.style);
  }

  MetroToggleSwitchThemeData merge(MetroToggleSwitchThemeData? other) {
    if (other == null) return this;
    return MetroToggleSwitchThemeData(
      style: style?.merge(other.style) ?? other.style,
    );
  }

  static MetroToggleSwitchThemeData lerp(
    MetroToggleSwitchThemeData a,
    MetroToggleSwitchThemeData b,
    double t,
  ) {
    return MetroToggleSwitchThemeData(
      style: MetroToggleSwitchStyle.lerp(a.style, b.style, t),
    );
  }
}

/// Overrides toggle-switch styling for a subtree.
class MetroToggleSwitchTheme extends InheritedTheme {
  const MetroToggleSwitchTheme({
    required this.data,
    required super.child,
    super.key,
  });

  final MetroToggleSwitchThemeData data;

  static MetroToggleSwitchThemeData? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MetroToggleSwitchTheme>()
        ?.data;
  }

  static MetroToggleSwitchThemeData of(BuildContext context) {
    return maybeOf(context) ?? const MetroToggleSwitchThemeData();
  }

  @override
  bool updateShouldNotify(MetroToggleSwitchTheme oldWidget) =>
      data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) {
    return MetroToggleSwitchTheme(data: data, child: child);
  }
}

/// A square-edged on/off control with keyboard and assistive semantics.
class MetroToggleSwitch extends StatelessWidget {
  const MetroToggleSwitch({
    required this.value,
    required this.onChanged,
    this.label,
    this.style,
    this.autofocus = false,
    this.focusNode,
    this.semanticLabel,
    super.key,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final Widget? label;
  final MetroToggleSwitchStyle? style;
  final bool autofocus;
  final FocusNode? focusNode;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = MetroTheme.of(context);
    final toggleSwitchTheme = theme.toggleSwitchTheme.merge(
      MetroToggleSwitchTheme.maybeOf(context),
    );
    final effectiveStyle = _defaultStyle(
      theme,
    ).merge(toggleSwitchTheme.style).merge(style);

    return MetroInteractive(
      autofocus: autofocus,
      focusNode: focusNode,
      onPressed: onChanged == null ? null : () => onChanged!(!value),
      semanticLabel: semanticLabel,
      semanticToggled: value,
      builder: (context, states) {
        final effectiveStates = <WidgetState>{
          ...states,
          if (value) WidgetState.selected,
        };
        final trackSize = effectiveStyle.trackSize ?? const Size(48, 24);
        final thumbSize = effectiveStyle.thumbSize ?? 18;
        final trackColor = effectiveStyle.trackColor?.resolve(effectiveStates);
        final thumbColor = effectiveStyle.thumbColor?.resolve(effectiveStates);
        final borderColor = effectiveStyle.borderColor?.resolve(
          effectiveStates,
        );
        final borderWidth =
            effectiveStyle.borderWidth?.resolve(effectiveStates) ?? 2;
        final reduceMotion = _reduceMotion(context);

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: trackSize.width,
              height: trackSize.height,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: AnimatedContainer(
                      duration: reduceMotion
                          ? Duration.zero
                          : theme.motion.fast,
                      curve: theme.motion.standardCurve,
                      decoration: BoxDecoration(
                        color: trackColor,
                        border: Border.all(
                          color: borderColor ?? const Color(0x00000000),
                          width: borderWidth,
                        ),
                      ),
                    ),
                  ),
                  AnimatedPositionedDirectional(
                    duration: reduceMotion ? Duration.zero : theme.motion.fast,
                    start: value ? trackSize.width - thumbSize : 0,
                    top: 0,
                    width: thumbSize,
                    height: trackSize.height,
                    child: ColoredBox(
                      color: thumbColor ?? const Color(0x00000000),
                    ),
                  ),
                ],
              ),
            ),
            if (label != null) ...[
              const SizedBox(width: 20),
              DefaultTextStyle.merge(
                style: effectiveStyle.labelStyle?.resolve(effectiveStates),
                child: label!,
              ),
            ],
          ],
        );
      },
    );
  }

  static MetroToggleSwitchStyle _defaultStyle(MetroThemeData theme) {
    final colors = theme.colors;
    return MetroToggleSwitchStyle(
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.foreground.withValues(alpha: 0.12);
        }
        if (states.contains(WidgetState.selected)) {
          if (states.contains(WidgetState.pressed)) {
            return Color.lerp(colors.accent, colors.onAccent, 0.28);
          }
          if (states.contains(WidgetState.hovered)) {
            return Color.lerp(colors.accent, colors.onAccent, 0.12);
          }
          return colors.accent;
        }
        final opacity = colors.isDark ? 0.26 : 0.35;
        if (states.contains(WidgetState.pressed)) {
          return colors.foreground.withValues(
            alpha: colors.isDark ? 0.35 : 0.26,
          );
        }
        if (states.contains(WidgetState.hovered)) {
          return colors.foreground.withValues(alpha: 0.29);
        }
        return colors.foreground.withValues(alpha: opacity);
      }),
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.isDark
              ? const Color(0xFF7E7E7E)
              : const Color(0xFF929292);
        }
        return colors.foreground;
      }),
      borderColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.focused)) {
          return colors.focus;
        }
        if (states.contains(WidgetState.disabled)) {
          return colors.foreground.withValues(alpha: 0.2);
        }
        return colors.foreground.withValues(alpha: 0.35);
      }),
      borderWidth: const WidgetStatePropertyAll(2),
      labelStyle: WidgetStateProperty.resolveWith((states) {
        return theme.typography.bodyStrong.copyWith(
          color: states.contains(WidgetState.disabled)
              ? colors.disabledForeground
              : colors.foreground,
        );
      }),
      trackSize: const Size(50, 19),
      thumbSize: 12,
    );
  }

  static bool _reduceMotion(BuildContext context) {
    final mediaQuery = MediaQuery.maybeOf(context);
    return mediaQuery?.disableAnimations == true ||
        mediaQuery?.accessibleNavigation == true;
  }
}
