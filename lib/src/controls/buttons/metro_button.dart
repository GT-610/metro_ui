import 'package:flutter/widgets.dart';

import '../../foundation/metro_interactive.dart';
import '../../theme/metro_spacing.dart';
import '../../theme/metro_theme.dart';
import '../../theme/metro_theme_data.dart';
import 'metro_button_style.dart';

export 'metro_button_style.dart';

/// Visual emphasis used by a [MetroButton].
enum MetroButtonVariant { standard, accent }

/// A rectangular, zero-radius button with Metro interaction states.
class MetroButton extends StatelessWidget {
  /// Creates a Metro button with the requested [variant].
  const MetroButton({
    required this.child,
    required this.onPressed,
    this.variant = MetroButtonVariant.standard,
    this.style,
    this.autofocus = false,
    this.focusNode,
    this.semanticLabel,
    super.key,
  });

  /// Creates an accent-colored Metro button for a primary action.
  const MetroButton.accent({
    required this.child,
    required this.onPressed,
    this.style,
    this.autofocus = false,
    this.focusNode,
    this.semanticLabel,
    super.key,
  }) : variant = MetroButtonVariant.accent;

  /// The content displayed inside the button.
  final Widget child;

  /// Called when the button is activated by pointer or keyboard.
  ///
  /// A null callback disables the button.
  final VoidCallback? onPressed;

  /// The visual emphasis applied before local style overrides.
  final MetroButtonVariant variant;

  /// Optional style values that override the active button theme.
  final MetroButtonStyle? style;

  /// Whether this button should request focus when first inserted.
  final bool autofocus;

  /// An optional focus node owned by the caller.
  final FocusNode? focusNode;

  /// An accessible label used when [child] does not describe the action.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = MetroTheme.of(context);
    final defaultStyle = _defaultStyle(theme, variant);
    final buttonTheme = theme.buttonTheme.merge(
      MetroButtonTheme.maybeOf(context),
    );
    final themedStyle = switch (variant) {
      MetroButtonVariant.standard => buttonTheme.style,
      MetroButtonVariant.accent => buttonTheme.accentStyle,
    };
    final effectiveStyle = defaultStyle.merge(themedStyle).merge(style);

    return MetroInteractive(
      autofocus: autofocus,
      focusNode: focusNode,
      mouseCursor: effectiveStyle.mouseCursor,
      onPressed: onPressed,
      semanticLabel: semanticLabel,
      builder: (context, states) {
        final background = effectiveStyle.backgroundColor?.resolve(states);
        final foreground = effectiveStyle.foregroundColor?.resolve(states);
        final borderColor = effectiveStyle.borderColor?.resolve(states);
        final borderWidth = effectiveStyle.borderWidth?.resolve(states) ?? 0;
        final textStyle = effectiveStyle.textStyle?.resolve(states);
        final reduceMotion = _reduceMotion(context);

        return AnimatedContainer(
          constraints: BoxConstraints(
            minWidth: effectiveStyle.minimumSize?.width ?? 0,
            minHeight: effectiveStyle.minimumSize?.height ?? 0,
          ),
          duration: reduceMotion ? Duration.zero : theme.motion.fast,
          curve: theme.motion.standardCurve,
          padding: effectiveStyle.padding,
          decoration: BoxDecoration(
            color: background,
            border: borderWidth == 0
                ? null
                : Border.all(
                    color: borderColor ?? const Color(0x00000000),
                    width: borderWidth,
                  ),
          ),
          child: DefaultTextStyle.merge(
            style:
                textStyle?.copyWith(color: foreground) ??
                TextStyle(color: foreground),
            child: IconTheme.merge(
              data: IconThemeData(color: foreground, size: 18),
              child: Center(widthFactor: 1, heightFactor: 1, child: child),
            ),
          ),
        );
      },
    );
  }

  static MetroButtonStyle _defaultStyle(
    MetroThemeData theme,
    MetroButtonVariant variant,
  ) {
    final colors = theme.colors;
    final isAccent = variant == MetroButtonVariant.accent;
    return MetroButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.disabledBackground;
        }
        if (isAccent) {
          if (states.contains(WidgetState.pressed)) {
            return colors.accentPressed;
          }
          if (states.contains(WidgetState.hovered)) {
            return colors.accentHover;
          }
          return colors.accent;
        }
        if (states.contains(WidgetState.pressed)) {
          return colors.surfaceVariant;
        }
        if (states.contains(WidgetState.hovered)) {
          return colors.surface;
        }
        return colors.background;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.disabledForeground;
        }
        return isAccent ? colors.onAccent : colors.foreground;
      }),
      borderColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.disabledForeground;
        }
        if (states.contains(WidgetState.focused)) {
          return colors.focus;
        }
        return isAccent ? colors.accent : colors.border;
      }),
      borderWidth: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.focused) ? 2.5 : 2,
      ),
      textStyle: WidgetStatePropertyAll(theme.typography.button),
      padding: const EdgeInsets.symmetric(
        horizontal: MetroSpacing.sm,
        vertical: MetroSpacing.xs,
      ),
      minimumSize: const Size(80, 36),
    );
  }

  static bool _reduceMotion(BuildContext context) {
    final mediaQuery = MediaQuery.maybeOf(context);
    return mediaQuery?.disableAnimations == true ||
        mediaQuery?.accessibleNavigation == true;
  }
}
