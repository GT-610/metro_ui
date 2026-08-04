import 'package:flutter/widgets.dart';

import '../../foundation/metro_interactive.dart';
import '../../theme/metro_spacing.dart';
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
        final size = effective.size ?? 24;
        final foreground = effective.foregroundColor?.resolve(selectedStates);
        final reduceMotion = _reduceMotion(context);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              width: size,
              height: size,
              duration: reduceMotion ? Duration.zero : theme.motion.fast,
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
            if (label != null) ...[
              const SizedBox(width: MetroSpacing.sm),
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
    return MetroSelectionControlStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.disabledBackground;
        }
        return states.contains(WidgetState.selected)
            ? colors.accent
            : colors.background;
      }),
      foregroundColor: WidgetStatePropertyAll(colors.onAccent),
      borderColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.focused)) return colors.focus;
        if (states.contains(WidgetState.selected)) return colors.accent;
        if (states.contains(WidgetState.disabled)) {
          return colors.disabledForeground;
        }
        return colors.border;
      }),
      borderWidth: const WidgetStatePropertyAll(2),
      labelStyle: WidgetStateProperty.resolveWith(
        (states) => theme.typography.body.copyWith(
          color: states.contains(WidgetState.disabled)
              ? colors.disabledForeground
              : colors.foreground,
        ),
      ),
      size: 24,
      indicatorSize: 14,
    );
  }

  static bool _reduceMotion(BuildContext context) {
    final media = MediaQuery.maybeOf(context);
    return media?.disableAnimations == true ||
        media?.accessibleNavigation == true;
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
