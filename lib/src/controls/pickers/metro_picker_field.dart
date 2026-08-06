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
        final background = style.backgroundColor?.resolve(states);
        final foreground = style.foregroundColor?.resolve(states);
        final borderColor = style.borderColor?.resolve(states);
        final borderWidth = style.borderWidth?.resolve(states) ?? 0;
        final separatorColor = style.separatorColor?.resolve(states);
        final textStyle = style.textStyle
            ?.resolve(states)
            ?.copyWith(color: foreground);
        final minimumHeight = style.minimumHeight ?? 32;
        final minimumSegmentWidth = style.minimumSegmentWidth ?? 80;
        final segmentSpacing = style.segmentSpacing ?? 20;

        Widget buildSegment(int index) {
          return Container(
            key: ValueKey<String>('metro-picker-segment-$index'),
            constraints: BoxConstraints(
              minWidth: minimumSegmentWidth,
              minHeight: minimumHeight,
            ),
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
                  Expanded(
                    child: Padding(
                      padding:
                          style.padding ??
                          const EdgeInsets.symmetric(
                            horizontal: MetroSpacing.sm,
                            vertical: MetroSpacing.xxs,
                          ),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(values[index]),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 28,
                    height: minimumHeight,
                    child: CustomPaint(
                      painter: _MetroPickerChevronPainter(
                        color: foreground ?? const Color(0x00000000),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        Widget buildGap() {
          return SizedBox(
            width: segmentSpacing,
            height: minimumHeight,
            child: Center(
              child: SizedBox(
                width: 1,
                height: minimumHeight,
                child: ColoredBox(
                  color: separatorColor ?? const Color(0x00000000),
                ),
              ),
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final bounded = constraints.hasBoundedWidth;
            final requestedFlex = <int>[
              for (var index = 0; index < values.length; index += 1)
                flex?[index] ?? 1,
            ];
            final availableForSegments = bounded
                ? constraints.maxWidth - segmentSpacing * (values.length - 1)
                : double.infinity;
            final useRequestedFlex =
                !bounded ||
                availableForSegments >=
                    minimumSegmentWidth *
                        requestedFlex.fold<int>(0, (sum, value) => sum + value);
            return SizedBox(
              height: minimumHeight,
              child: Row(
                mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  for (var index = 0; index < values.length; index += 1) ...[
                    if (index != 0) buildGap(),
                    if (bounded)
                      Expanded(
                        flex: useRequestedFlex ? requestedFlex[index] : 1,
                        child: buildSegment(index),
                      )
                    else
                      SizedBox(
                        width:
                            minimumSegmentWidth *
                            (flex?[index] ?? 1).toDouble(),
                        child: buildSegment(index),
                      ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  static MetroPickerStyle _defaultStyle(MetroThemeData theme) {
    final colors = theme.colors;
    return MetroPickerStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (colors.isHighContrast) {
          return colors.background;
        }
        if (states.contains(WidgetState.disabled)) {
          return colors.isDark
              ? const Color(0x00000000)
              : const Color(0x66CACACA);
        }
        return states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.focused)
            ? const Color(0xDEFFFFFF)
            : const Color(0xCCFFFFFF);
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (colors.isHighContrast) {
          return states.contains(WidgetState.disabled)
              ? colors.disabledForeground
              : colors.foreground;
        }
        if (states.contains(WidgetState.disabled)) {
          return colors.isDark
              ? const Color(0x66FFFFFF)
              : const Color(0x66000000);
        }
        return const Color(0xFF000000);
      }),
      borderColor: WidgetStateProperty.resolveWith((states) {
        if (colors.isHighContrast) {
          return states.contains(WidgetState.focused)
              ? colors.accent
              : states.contains(WidgetState.disabled)
              ? colors.disabledForeground
              : colors.foreground;
        }
        if (colors.isDark) {
          return states.contains(WidgetState.disabled)
              ? const Color(0x66FFFFFF)
              : const Color(0x00000000);
        }
        if (states.contains(WidgetState.disabled)) {
          return const Color(0x26000000);
        }
        if (states.contains(WidgetState.focused)) {
          return const Color(0x99000000);
        }
        if (states.contains(WidgetState.hovered)) {
          return const Color(0x70000000);
        }
        return const Color(0x45000000);
      }),
      borderWidth: const WidgetStatePropertyAll(2),
      separatorColor: const WidgetStatePropertyAll(Color(0x00000000)),
      textStyle: WidgetStatePropertyAll(theme.typography.body),
      padding: const EdgeInsets.symmetric(
        horizontal: MetroSpacing.sm,
        vertical: MetroSpacing.xxs,
      ),
      minimumHeight: 32,
      minimumSegmentWidth: 80,
      segmentSpacing: 20,
    );
  }
}

class _MetroPickerChevronPainter extends CustomPainter {
  const _MetroPickerChevronPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.miter
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(center.dx - 4, center.dy - 2)
      ..lineTo(center.dx, center.dy + 2)
      ..lineTo(center.dx + 4, center.dy - 2);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_MetroPickerChevronPainter oldDelegate) {
    return color != oldDelegate.color;
  }
}
