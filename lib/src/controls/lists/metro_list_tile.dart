import 'package:flutter/widgets.dart';

import '../../foundation/metro_interactive.dart';
import '../../theme/metro_spacing.dart';
import '../../theme/metro_theme.dart';
import '../../theme/metro_theme_data.dart';
import 'metro_list_tile_style.dart';

export 'metro_list_tile_style.dart';

/// A flat, keyboard-accessible row for primary and secondary content.
class MetroListTile extends StatelessWidget {
  const MetroListTile({
    required this.title,
    required this.onPressed,
    this.subtitle,
    this.leading,
    this.trailing,
    this.selected = false,
    this.checked,
    this.style,
    this.autofocus = false,
    this.focusNode,
    this.semanticLabel,
    super.key,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onPressed;
  final bool selected;
  final bool? checked;
  final MetroListTileStyle? style;
  final bool autofocus;
  final FocusNode? focusNode;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = MetroTheme.of(context);
    final listTileTheme = theme.listTileTheme.merge(
      MetroListTileTheme.maybeOf(context),
    );
    final effective = _defaultStyle(
      theme,
    ).merge(listTileTheme.style).merge(style);
    return MetroInteractive(
      autofocus: autofocus,
      focusNode: focusNode,
      onPressed: onPressed,
      semanticChecked: checked,
      semanticLabel: semanticLabel,
      semanticSelected: selected,
      builder: (context, states) {
        final effectiveStates = <WidgetState>{
          ...states,
          if (selected) WidgetState.selected,
        };
        final foreground = effective.foregroundColor?.resolve(effectiveStates);
        return AnimatedContainer(
          constraints: BoxConstraints(minHeight: effective.minimumHeight ?? 52),
          duration: _reduceMotion(context) ? Duration.zero : theme.motion.fast,
          padding:
              effective.padding ??
              const EdgeInsets.symmetric(
                horizontal: MetroSpacing.sm,
                vertical: MetroSpacing.xs,
              ),
          decoration: BoxDecoration(
            color: effective.backgroundColor?.resolve(effectiveStates),
            border: BorderDirectional(
              start: BorderSide(
                color:
                    effective.borderColor?.resolve(effectiveStates) ??
                    const Color(0x00000000),
                width: states.contains(WidgetState.focused) ? 3 : 0,
              ),
            ),
          ),
          child: Row(
            children: [
              if (leading != null) ...[
                IconTheme.merge(
                  data: IconThemeData(color: foreground, size: 24),
                  child: leading!,
                ),
                const SizedBox(width: MetroSpacing.sm),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DefaultTextStyle.merge(
                      style: effective.titleStyle
                          ?.resolve(effectiveStates)
                          ?.copyWith(color: foreground),
                      child: title,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: MetroSpacing.xxs),
                      DefaultTextStyle.merge(
                        style: effective.subtitleStyle
                            ?.resolve(effectiveStates)
                            ?.copyWith(color: foreground),
                        child: subtitle!,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: MetroSpacing.sm),
                IconTheme.merge(
                  data: IconThemeData(color: foreground, size: 20),
                  child: trailing!,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  static MetroListTileStyle _defaultStyle(MetroThemeData theme) {
    final colors = theme.colors;
    return MetroListTileStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.disabledBackground;
        }
        if (states.contains(WidgetState.selected)) return colors.accent;
        if (states.contains(WidgetState.pressed)) {
          return colors.surfaceVariant;
        }
        if (states.contains(WidgetState.hovered)) return colors.surface;
        return const Color(0x00000000);
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.disabledForeground;
        }
        return states.contains(WidgetState.selected)
            ? colors.onAccent
            : colors.foreground;
      }),
      borderColor: WidgetStatePropertyAll(colors.focus),
      titleStyle: WidgetStatePropertyAll(theme.typography.bodyStrong),
      subtitleStyle: WidgetStatePropertyAll(theme.typography.caption),
      padding: const EdgeInsets.symmetric(
        horizontal: MetroSpacing.sm,
        vertical: MetroSpacing.xs,
      ),
      minimumHeight: 52,
    );
  }

  static bool _reduceMotion(BuildContext context) {
    final media = MediaQuery.maybeOf(context);
    return media?.disableAnimations == true ||
        media?.accessibleNavigation == true;
  }
}
