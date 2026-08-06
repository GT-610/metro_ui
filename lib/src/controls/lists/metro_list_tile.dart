import 'package:flutter/widgets.dart';

import '../../foundation/metro_accessibility.dart';
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
        final borderColor =
            effective.borderColor?.resolve(effectiveStates) ??
            const Color(0x00000000);
        final borderWidth =
            effective.borderWidth?.resolve(effectiveStates) ?? 0;
        final reduceMotion = metroReduceMotion(context);
        return AnimatedScale(
          key: const ValueKey<String>('metro-list-tile-scale'),
          scale: states.contains(WidgetState.pressed) ? 0.975 : 1,
          duration: reduceMotion ? Duration.zero : theme.motion.normal,
          curve: theme.motion.standardCurve,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                key: const ValueKey<String>('metro-list-tile-surface'),
                constraints: BoxConstraints(
                  minHeight: effective.minimumHeight ?? 52,
                ),
                padding:
                    effective.padding ??
                    const EdgeInsets.symmetric(
                      horizontal: MetroSpacing.sm,
                      vertical: MetroSpacing.xs,
                    ),
                decoration: BoxDecoration(
                  color: effective.backgroundColor?.resolve(effectiveStates),
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
              ),
              if (borderWidth > 0 && borderColor.a > 0)
                Positioned(
                  top: -borderWidth,
                  right: -borderWidth,
                  bottom: -borderWidth,
                  left: -borderWidth,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      key: const ValueKey<String>('metro-list-tile-outline'),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: borderColor,
                          width: borderWidth,
                        ),
                      ),
                    ),
                  ),
                ),
              if (selected)
                PositionedDirectional(
                  top: 0,
                  end: 0,
                  child: IgnorePointer(
                    child: ExcludeSemantics(
                      child: Padding(
                        key: const ValueKey<String>(
                          'metro-list-tile-selection-checkmark',
                        ),
                        padding: const EdgeInsets.all(2),
                        child: SizedBox.square(
                          dimension: 11 * 4 / 3,
                          child: CustomPaint(
                            painter: _MetroSelectionCheckmarkPainter(
                              color: theme.colors.isHighContrast
                                  ? theme.colors.onAccent
                                  : const Color(0xFFFFFFFF),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  static MetroListTileStyle _defaultStyle(MetroThemeData theme) {
    final colors = theme.colors;
    final itemBackground = colors.isHighContrast
        ? colors.background
        : colors.isDark
        ? const Color(0xFF1D1D1D)
        : const Color(0xFFFFFFFF);
    return MetroListTileStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          if (states.contains(WidgetState.hovered)) {
            return colors.isHighContrast ? colors.accent : colors.accentHover;
          }
          return colors.accent;
        }
        if (states.contains(WidgetState.hovered)) {
          if (colors.isHighContrast) return colors.accent;
          return Color.alphaBlend(
            colors.foreground.withValues(alpha: 0.3),
            itemBackground,
          );
        }
        return itemBackground;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.disabledForeground;
        }
        if (states.contains(WidgetState.selected) ||
            (colors.isHighContrast && states.contains(WidgetState.hovered))) {
          return colors.isHighContrast
              ? colors.onAccent
              : const Color(0xFFFFFFFF);
        }
        return colors.foreground;
      }),
      borderColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return const Color(0x00000000);
        }
        if (states.contains(WidgetState.focused)) return colors.focus;
        if (states.contains(WidgetState.hovered)) {
          return colors.foreground.withValues(alpha: 0.3);
        }
        return const Color(0x00000000);
      }),
      borderWidth: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return 0;
        if (states.contains(WidgetState.focused)) return 2;
        if (states.contains(WidgetState.hovered)) return 3;
        return 0;
      }),
      titleStyle: WidgetStatePropertyAll(theme.typography.bodyStrong),
      subtitleStyle: WidgetStatePropertyAll(theme.typography.caption),
      padding: const EdgeInsets.symmetric(
        horizontal: MetroSpacing.sm,
        vertical: MetroSpacing.xs,
      ),
      minimumHeight: 52,
    );
  }
}

class _MetroSelectionCheckmarkPainter extends CustomPainter {
  const _MetroSelectionCheckmarkPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.miter
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(size.width * 0.16, size.height * 0.5)
      ..lineTo(size.width * 0.4, size.height * 0.74)
      ..lineTo(size.width * 0.84, size.height * 0.24);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_MetroSelectionCheckmarkPainter oldDelegate) =>
      oldDelegate.color != color;
}
