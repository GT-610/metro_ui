import 'package:flutter/widgets.dart';

import '../../foundation/metro_interactive.dart';
import '../../theme/metro_spacing.dart';
import '../../theme/metro_theme.dart';
import '../../theme/metro_theme_data.dart';
import 'metro_picker_style.dart';

class MetroPickerField extends StatelessWidget {
  const MetroPickerField({
    required this.values,
    required this.semanticLabel,
    required this.onPressed,
    this.flex,
    this.style,
    this.autofocus = false,
    this.focusNode,
    super.key,
  });

  final List<String> values;
  final List<int>? flex;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final MetroPickerStyle? style;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    assert(values.isNotEmpty);
    assert(flex == null || flex!.length == values.length);
    final theme = MetroTheme.of(context);
    final style = _defaultStyle(theme)
        .merge(theme.pickerTheme.style)
        .merge(MetroPickerTheme.maybeOf(context)?.style)
        .merge(this.style);

    return MetroInteractive(
      autofocus: autofocus,
      focusNode: focusNode,
      onPressed: onPressed,
      semanticLabel: semanticLabel,
      builder: (context, states) {
        final reduceMotion = _reduceMotion(context);
        final background = style.backgroundColor?.resolve(states);
        final foreground = style.foregroundColor?.resolve(states);
        final borderColor = style.borderColor?.resolve(states);
        final borderWidth = style.borderWidth?.resolve(states) ?? 0;
        final separatorColor = style.separatorColor?.resolve(states);
        final textStyle = style.textStyle
            ?.resolve(states)
            ?.copyWith(color: foreground);

        return AnimatedContainer(
          constraints: BoxConstraints(minHeight: style.minimumHeight ?? 44),
          duration: reduceMotion ? Duration.zero : theme.motion.fast,
          curve: theme.motion.standardCurve,
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
            style: textStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            child: Row(
              children: [
                for (var index = 0; index < values.length; index += 1) ...[
                  if (index != 0)
                    SizedBox(
                      width: 1,
                      height: style.minimumHeight ?? 44,
                      child: ColoredBox(
                        color: separatorColor ?? const Color(0x00000000),
                      ),
                    ),
                  Expanded(
                    flex: flex?[index] ?? 1,
                    child: Padding(
                      padding:
                          style.padding ??
                          const EdgeInsets.symmetric(
                            horizontal: MetroSpacing.sm,
                            vertical: MetroSpacing.xs,
                          ),
                      child: Center(child: Text(values[index])),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  static MetroPickerStyle _defaultStyle(MetroThemeData theme) {
    final colors = theme.colors;
    return MetroPickerStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.disabled)
            ? colors.disabledBackground
            : colors.surface;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.disabled)
            ? colors.disabledForeground
            : colors.foreground;
      }),
      borderColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.focused)) {
          return colors.focus;
        }
        if (states.contains(WidgetState.hovered)) {
          return colors.foreground;
        }
        return colors.border;
      }),
      borderWidth: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.focused) ||
                states.contains(WidgetState.hovered)
            ? 2
            : 1;
      }),
      separatorColor: WidgetStatePropertyAll(colors.border),
      textStyle: WidgetStatePropertyAll(theme.typography.body),
      padding: const EdgeInsets.symmetric(
        horizontal: MetroSpacing.sm,
        vertical: MetroSpacing.xs,
      ),
      minimumHeight: 44,
    );
  }

  static bool _reduceMotion(BuildContext context) {
    final media = MediaQuery.maybeOf(context);
    return media?.disableAnimations == true ||
        media?.accessibleNavigation == true;
  }
}
