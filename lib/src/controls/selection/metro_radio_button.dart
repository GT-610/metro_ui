import 'package:flutter/widgets.dart';

import '../../foundation/metro_interactive.dart';
import '../../theme/metro_theme.dart';
import '../../theme/metro_theme_data.dart';
import 'metro_selection_control_style.dart';
import 'metro_selection_group.dart';

export 'metro_selection_control_style.dart';

/// A circular single-choice control with optional shared selection state.
class MetroRadioButton<T> extends StatelessWidget {
  const MetroRadioButton({
    required this.value,
    this.groupValue,
    this.onChanged,
    this.controller,
    this.label,
    this.style,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
    this.semanticLabel,
    super.key,
  });

  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final MetroSelectionController<T>? controller;
  final Widget? label;
  final MetroSelectionControlStyle? style;
  final bool enabled;
  final bool autofocus;
  final FocusNode? focusNode;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final effectiveController =
        controller ?? MetroSelectionGroup.maybeOf<T>(context);
    assert(
      effectiveController == null ||
          effectiveController.mode == MetroSelectionMode.single,
      'MetroRadioButton requires a single-selection controller.',
    );
    if (effectiveController == null) {
      return _buildButton(context, null);
    }
    return AnimatedBuilder(
      animation: effectiveController,
      builder: (context, child) {
        return _buildButton(context, effectiveController);
      },
    );
  }

  Widget _buildButton(
    BuildContext context,
    MetroSelectionController<T>? effectiveController,
  ) {
    final theme = MetroTheme.of(context);
    final radioButtonTheme = theme.radioButtonTheme.merge(
      MetroRadioButtonTheme.maybeOf(context),
    );
    final effective = _defaultStyle(
      theme,
    ).merge(radioButtonTheme.style).merge(style);
    final selected =
        effectiveController?.isSelected(value) ?? value == groupValue;
    final canChange =
        enabled && (effectiveController != null || onChanged != null);
    return MetroInteractive(
      autofocus: autofocus,
      focusNode: focusNode,
      onPressed: canChange
          ? () {
              if (effectiveController == null) {
                onChanged?.call(value);
              } else if (effectiveController.select(value)) {
                onChanged?.call(value);
              }
            }
          : null,
      semanticButton: false,
      semanticLabel: semanticLabel,
      semanticMutuallyExclusive: true,
      semanticSelected: selected,
      builder: (context, states) {
        final selectedStates = <WidgetState>{
          ...states,
          if (selected) WidgetState.selected,
        };
        final size = effective.size ?? 23;
        final indicatorSize = effective.indicatorSize ?? 12;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: effective.backgroundColor?.resolve(selectedStates),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        effective.borderColor?.resolve(selectedStates) ??
                        const Color(0x00000000),
                    width: effective.borderWidth?.resolve(selectedStates) ?? 2,
                  ),
                ),
                child: selected
                    ? Center(
                        child: SizedBox.square(
                          dimension: indicatorSize,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: effective.foregroundColor?.resolve(
                                selectedStates,
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      )
                    : null,
              ),
            ),
            if (label != null) ...[
              const SizedBox(width: 4),
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
        size: 23,
        indicatorSize: 12,
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
      size: 23,
      indicatorSize: 12,
    );
  }
}
