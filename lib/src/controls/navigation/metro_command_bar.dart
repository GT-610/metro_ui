import 'package:flutter/widgets.dart';

import '../../foundation/metro_interactive.dart';
import '../../theme/metro_color_scheme.dart';
import '../../theme/metro_spacing.dart';
import '../../theme/metro_theme.dart';
import '../../theme/metro_theme_data.dart';
import 'metro_command_bar_style.dart';

export 'metro_command_bar_style.dart';

/// Logical alignment of commands within a [MetroCommandBar].
enum MetroCommandBarAlignment { start, end }

/// A high-contrast bottom bar for page-level commands.
///
/// Commands are horizontally scrollable when the available width is too
/// narrow. The default end alignment mirrors Windows 8's primary AppBar
/// command placement.
class MetroCommandBar extends StatelessWidget {
  const MetroCommandBar({
    required this.commands,
    this.leading,
    this.alignment = MetroCommandBarAlignment.end,
    this.backgroundColor,
    this.height,
    this.padding,
    this.spacing,
    this.buttonStyle,
    super.key,
  }) : assert(height == null || height > 0),
       assert(spacing == null || spacing >= 0);

  final List<Widget> commands;
  final Widget? leading;
  final MetroCommandBarAlignment alignment;
  final Color? backgroundColor;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double? spacing;
  final MetroCommandButtonStyle? buttonStyle;

  @override
  Widget build(BuildContext context) {
    final theme = MetroTheme.of(context);
    final defaults = MetroCommandBarThemeData(
      backgroundColor: theme.colors.isDark
          ? theme.colors.surface
          : theme.colors.foreground,
      height: 88,
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: MetroSpacing.md,
        vertical: MetroSpacing.xs,
      ),
      spacing: MetroSpacing.xs,
    );
    final widgetOverrides = MetroCommandBarThemeData(
      backgroundColor: backgroundColor,
      height: height,
      padding: padding,
      spacing: spacing,
      buttonStyle: buttonStyle,
    );
    final effectiveTheme = defaults
        .merge(theme.commandBarTheme)
        .merge(MetroCommandBarTheme.maybeOf(context))
        .merge(widgetOverrides);
    final effectiveBackground = effectiveTheme.backgroundColor!;
    final effectiveForeground = MetroColorScheme.idealForegroundFor(
      effectiveBackground,
    );
    final effectiveSpacing = effectiveTheme.spacing!;

    return _MetroCommandBarScope(
      backgroundColor: effectiveBackground,
      buttonStyle: effectiveTheme.buttonStyle,
      child: IconTheme.merge(
        data: IconThemeData(color: effectiveForeground),
        child: DefaultTextStyle.merge(
          style: theme.typography.body.copyWith(color: effectiveForeground),
          child: ColoredBox(
            color: effectiveBackground,
            child: SizedBox(
              height: effectiveTheme.height,
              child: Padding(
                padding: effectiveTheme.padding!,
                child: Row(
                  children: [
                    if (leading != null) ...[
                      leading!,
                      if (commands.isNotEmpty)
                        SizedBox(width: effectiveSpacing),
                    ],
                    if (commands.isNotEmpty)
                      Expanded(
                        child: SingleChildScrollView(
                          reverse: alignment == MetroCommandBarAlignment.end,
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: _withSpacing(commands, effectiveSpacing),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static List<Widget> _withSpacing(List<Widget> children, double spacing) {
    return <Widget>[
      for (var index = 0; index < children.length; index++) ...[
        if (index > 0) SizedBox(width: spacing),
        children[index],
      ],
    ];
  }
}

/// A Windows 8-style AppBar command with a circular glyph and a text label.
///
/// The circular outline is intentionally limited to this historical command
/// pattern; other Metro controls remain square by default.
class MetroCommandButton extends StatelessWidget {
  const MetroCommandButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.selected,
    this.style,
    this.autofocus = false,
    this.focusNode,
    this.semanticLabel,
    super.key,
  });

  final Widget icon;
  final Widget label;
  final VoidCallback? onPressed;
  final bool? selected;
  final MetroCommandButtonStyle? style;
  final bool autofocus;
  final FocusNode? focusNode;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = MetroTheme.of(context);
    final scope = _MetroCommandBarScope.maybeOf(context);
    final localTheme = MetroCommandBarTheme.maybeOf(context);
    final background =
        scope?.backgroundColor ??
        localTheme?.backgroundColor ??
        theme.commandBarTheme.backgroundColor ??
        (theme.colors.isDark ? theme.colors.surface : theme.colors.foreground);
    final themedStyle =
        scope?.buttonStyle ??
        theme.commandBarTheme.buttonStyle?.merge(localTheme?.buttonStyle) ??
        localTheme?.buttonStyle;
    final effectiveStyle = _defaultStyle(
      theme,
      background,
    ).merge(themedStyle).merge(style);

    return MetroInteractive(
      autofocus: autofocus,
      focusNode: focusNode,
      mouseCursor: effectiveStyle.mouseCursor,
      onPressed: onPressed,
      semanticLabel: semanticLabel,
      semanticToggled: selected,
      builder: (context, states) {
        final effectiveStates = <WidgetState>{
          ...states,
          if (selected == true) WidgetState.selected,
        };
        final circleColor = effectiveStyle.circleColor?.resolve(
          effectiveStates,
        );
        final foreground = effectiveStyle.foregroundColor?.resolve(
          effectiveStates,
        );
        final borderColor = effectiveStyle.borderColor?.resolve(
          effectiveStates,
        );
        final borderWidth =
            effectiveStyle.borderWidth?.resolve(effectiveStates) ?? 2;
        final labelStyle = effectiveStyle.labelStyle?.resolve(effectiveStates);
        final minimumSize = effectiveStyle.minimumSize ?? const Size(64, 68);
        final reduceMotion = _reduceMotion(context);

        return ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: minimumSize.width,
            minHeight: minimumSize.height,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                width: 40,
                height: 40,
                duration: reduceMotion ? Duration.zero : theme.motion.fast,
                curve: theme.motion.standardCurve,
                decoration: BoxDecoration(
                  color: circleColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: borderColor ?? const Color(0x00000000),
                    width: borderWidth,
                  ),
                ),
                child: IconTheme.merge(
                  data: IconThemeData(color: foreground, size: 20),
                  child: Center(child: icon),
                ),
              ),
              const SizedBox(height: MetroSpacing.xxs),
              DefaultTextStyle(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    labelStyle?.copyWith(color: foreground) ??
                    TextStyle(color: foreground),
                textAlign: TextAlign.center,
                child: label,
              ),
            ],
          ),
        );
      },
    );
  }

  static MetroCommandButtonStyle _defaultStyle(
    MetroThemeData theme,
    Color barBackground,
  ) {
    final colors = theme.colors;
    final barForeground = MetroColorScheme.idealForegroundFor(barBackground);
    return MetroCommandButtonStyle(
      circleColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return const Color(0x00000000);
        }
        if (states.contains(WidgetState.pressed)) {
          return colors.accentPressed;
        }
        if (states.contains(WidgetState.selected)) {
          return colors.accent;
        }
        if (states.contains(WidgetState.hovered)) {
          return barForeground;
        }
        return const Color(0x00000000);
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.disabledForeground;
        }
        if (states.contains(WidgetState.pressed) ||
            states.contains(WidgetState.selected)) {
          return colors.onAccent;
        }
        if (states.contains(WidgetState.hovered)) {
          return barBackground;
        }
        return barForeground;
      }),
      borderColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.disabledForeground;
        }
        if (states.contains(WidgetState.focused) ||
            states.contains(WidgetState.pressed) ||
            states.contains(WidgetState.selected)) {
          return colors.accent;
        }
        return barForeground;
      }),
      borderWidth: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.focused) ? 3 : 2,
      ),
      labelStyle: WidgetStatePropertyAll(
        theme.typography.caption.copyWith(color: barForeground),
      ),
      minimumSize: const Size(64, 68),
    );
  }

  static bool _reduceMotion(BuildContext context) {
    final mediaQuery = MediaQuery.maybeOf(context);
    return mediaQuery?.disableAnimations == true ||
        mediaQuery?.accessibleNavigation == true;
  }
}

class _MetroCommandBarScope extends InheritedWidget {
  const _MetroCommandBarScope({
    required this.backgroundColor,
    required this.buttonStyle,
    required super.child,
  });

  final Color backgroundColor;
  final MetroCommandButtonStyle? buttonStyle;

  static _MetroCommandBarScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_MetroCommandBarScope>();
  }

  @override
  bool updateShouldNotify(_MetroCommandBarScope oldWidget) {
    return backgroundColor != oldWidget.backgroundColor ||
        buttonStyle != oldWidget.buttonStyle;
  }
}
