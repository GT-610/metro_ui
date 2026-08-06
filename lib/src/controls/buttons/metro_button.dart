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
        final focused = states.contains(WidgetState.focused);

        Widget button = AnimatedContainer(
          constraints: BoxConstraints(
            minWidth: effectiveStyle.minimumSize?.width ?? 0,
            minHeight: effectiveStyle.minimumSize?.height ?? 0,
          ),
          duration: Duration.zero,
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
        if (focused) {
          button = CustomPaint(
            foregroundPainter: _DottedFocusPainter(color: theme.colors.focus),
            child: button,
          );
        }
        return button;
      },
    );
  }

  static MetroButtonStyle _defaultStyle(
    MetroThemeData theme,
    MetroButtonVariant variant,
  ) {
    final colors = theme.colors;
    final isAccent = variant == MetroButtonVariant.accent;
    final pressedBackground = colors.isDark
        ? const Color(0xFFFFFFFF)
        : const Color(0xFF000000);
    final pressedForeground = colors.isDark
        ? const Color(0xFF000000)
        : const Color(0xFFFFFFFF);
    return MetroButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.isDark
              ? const Color(0x00000000)
              : const Color(0x66CACACA);
        }
        if (states.contains(WidgetState.pressed)) {
          return pressedBackground;
        }
        if (isAccent) {
          if (states.contains(WidgetState.hovered)) {
            return colors.accentHover;
          }
          return colors.accent;
        }
        if (states.contains(WidgetState.hovered)) {
          return colors.isDark
              ? const Color(0x21FFFFFF)
              : const Color(0xD1CDCDCD);
        }
        return colors.isDark
            ? const Color(0x00000000)
            : const Color(0xB3B6B6B6);
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.foreground.withValues(alpha: 0.4);
        }
        if (states.contains(WidgetState.pressed)) {
          return pressedForeground;
        }
        return isAccent ? colors.onAccent : colors.foreground;
      }),
      borderColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.foreground.withValues(
            alpha: colors.isDark ? 0.4 : 0.08,
          );
        }
        if (states.contains(WidgetState.pressed)) {
          return pressedBackground;
        }
        if (isAccent) {
          if (colors.isDark && states.contains(WidgetState.hovered)) {
            return colors.foreground;
          }
          return const Color(0x00000000);
        }
        if (colors.isDark) {
          return colors.foreground;
        }
        if (states.contains(WidgetState.hovered)) {
          return const Color(0x73A4A4A4);
        }
        return const Color(0x33000000);
      }),
      borderWidth: const WidgetStatePropertyAll(2),
      textStyle: WidgetStatePropertyAll(theme.typography.button),
      padding: const EdgeInsets.symmetric(
        horizontal: MetroSpacing.xs,
        vertical: MetroSpacing.xxs,
      ),
      minimumSize: const Size(90, 32),
    );
  }
}

class _DottedFocusPainter extends CustomPainter {
  const _DottedFocusPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 7 || size.height <= 7) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final rect = Rect.fromLTWH(3.5, 3.5, size.width - 7, size.height - 7);
    _drawDottedLine(canvas, rect.topLeft, rect.topRight, paint);
    _drawDottedLine(canvas, rect.topRight, rect.bottomRight, paint);
    _drawDottedLine(canvas, rect.bottomRight, rect.bottomLeft, paint);
    _drawDottedLine(canvas, rect.bottomLeft, rect.topLeft, paint);
  }

  void _drawDottedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    final delta = end - start;
    final length = delta.distance;
    if (length == 0) return;
    final direction = delta / length;
    for (double distance = 0; distance < length; distance += 3) {
      final dot = start + direction * distance;
      canvas.drawLine(dot, dot + direction, paint);
    }
  }

  @override
  bool shouldRepaint(_DottedFocusPainter oldDelegate) =>
      oldDelegate.color != color;
}
