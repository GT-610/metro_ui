import 'package:flutter/widgets.dart';

import '../../foundation/metro_interactive.dart';
import '../../theme/metro_theme.dart';
import '../../theme/metro_theme_data.dart';
import 'metro_selection_control_style.dart';

export 'metro_selection_control_style.dart';

/// A binary or tri-state square Metro check box.
class MetroCheckBox extends StatelessWidget {
  const MetroCheckBox({
    required this.value,
    required this.onChanged,
    this.tristate = false,
    this.label,
    this.style,
    this.autofocus = false,
    this.focusNode,
    this.semanticLabel,
    super.key,
  }) : assert(tristate || value != null);

  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final bool tristate;
  final Widget? label;
  final MetroSelectionControlStyle? style;
  final bool autofocus;
  final FocusNode? focusNode;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = MetroTheme.of(context);
    final checkBoxTheme = theme.checkBoxTheme.merge(
      MetroCheckBoxTheme.maybeOf(context),
    );
    final effective = _defaultStyle(
      theme,
    ).merge(checkBoxTheme.style).merge(style);
    return MetroInteractive(
      autofocus: autofocus,
      focusNode: focusNode,
      onPressed: onChanged == null ? null : () => onChanged!(_nextValue()),
      semanticButton: false,
      semanticChecked: value == true,
      semanticMixed: value == null,
      semanticLabel: semanticLabel,
      builder: (context, states) {
        final selectedStates = <WidgetState>{
          ...states,
          if (value != false) WidgetState.selected,
        };
        final size = effective.size ?? 21;
        final foreground = effective.foregroundColor?.resolve(selectedStates);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: effective.backgroundColor?.resolve(selectedStates),
                  border: Border.all(
                    color:
                        effective.borderColor?.resolve(selectedStates) ??
                        const Color(0x00000000),
                    width: effective.borderWidth?.resolve(selectedStates) ?? 2,
                  ),
                ),
                child: value == false
                    ? null
                    : CustomPaint(
                        painter: _CheckPainter(
                          color: foreground ?? const Color(0x00000000),
                          mixed: value == null,
                        ),
                      ),
              ),
            ),
            if (label != null) ...[
              const SizedBox(width: 5),
              DefaultTextStyle.merge(
                style: effective.labelStyle?.resolve(selectedStates),
                child: label!,
              ),
            ],
          ],
        );
      },
    );
  }

  bool? _nextValue() {
    if (!tristate) return !(value ?? false);
    return switch (value) {
      false => true,
      true => null,
      null => false,
    };
  }

  static MetroSelectionControlStyle _defaultStyle(MetroThemeData theme) {
    final colors = theme.colors;
    final dark = colors.isDark;
    if (colors.isHighContrast) {
      return MetroSelectionControlStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.pressed)
              ? colors.foreground
              : colors.background,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.pressed)
              ? colors.background
              : colors.foreground,
        ),
        borderColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? colors.disabledForeground
              : colors.border,
        ),
        borderWidth: const WidgetStatePropertyAll(2),
        labelStyle: WidgetStateProperty.resolveWith(
          (states) => theme.typography.body.copyWith(
            color: states.contains(WidgetState.disabled)
                ? colors.disabledForeground
                : colors.foreground,
          ),
        ),
        size: 21,
        indicatorSize: 14,
      );
    }
    return MetroSelectionControlStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return dark ? const Color(0x66FFFFFF) : const Color(0x66CACACA);
        }
        if (states.contains(WidgetState.pressed)) {
          return dark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
        }
        if (states.contains(WidgetState.hovered)) {
          return const Color(0xDEFFFFFF);
        }
        return const Color(0xCCFFFFFF);
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return const Color(0x66000000);
        }
        if (!dark && states.contains(WidgetState.pressed)) {
          return const Color(0xFFFFFFFF);
        }
        return const Color(0xFF000000);
      }),
      borderColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.focused)) return colors.focus;
        if (states.contains(WidgetState.disabled)) {
          return dark ? const Color(0x00000000) : const Color(0x26000000);
        }
        if (states.contains(WidgetState.pressed)) {
          return const Color(0x00000000);
        }
        if (dark) {
          return const Color(0x00000000);
        }
        return states.contains(WidgetState.hovered)
            ? const Color(0x70000000)
            : const Color(0x45000000);
      }),
      borderWidth: const WidgetStatePropertyAll(2),
      labelStyle: WidgetStateProperty.resolveWith(
        (states) => theme.typography.body.copyWith(
          color: states.contains(WidgetState.disabled)
              ? colors.disabledForeground
              : colors.foreground,
        ),
      ),
      size: 21,
      indicatorSize: 14,
    );
  }
}

class _CheckPainter extends CustomPainter {
  const _CheckPainter({required this.color, required this.mixed});
  final Color color;
  final bool mixed;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.miter
      ..strokeWidth = 2.2;
    if (mixed) {
      canvas.drawLine(
        Offset(size.width * 0.25, size.height * 0.5),
        Offset(size.width * 0.75, size.height * 0.5),
        paint,
      );
      return;
    }
    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.52)
      ..lineTo(size.width * 0.43, size.height * 0.73)
      ..lineTo(size.width * 0.8, size.height * 0.28);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckPainter oldDelegate) =>
      color != oldDelegate.color || mixed != oldDelegate.mixed;
}
