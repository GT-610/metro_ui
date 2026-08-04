import 'package:flutter/widgets.dart';

import '../selection/metro_selection_group.dart';
import 'metro_list_tile.dart';

/// A [MetroListTile] bound to a [MetroSelectionController].
class MetroSelectableListTile<T> extends StatelessWidget {
  const MetroSelectableListTile({
    required this.value,
    required this.title,
    this.controller,
    this.subtitle,
    this.leading,
    this.trailing,
    this.enabled = true,
    this.allowDeselection = false,
    this.onSelectionChanged,
    this.onPressed,
    this.style,
    this.autofocus = false,
    this.focusNode,
    this.semanticLabel,
    super.key,
  });

  final T value;
  final Widget title;
  final MetroSelectionController<T>? controller;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final bool enabled;
  final bool allowDeselection;
  final ValueChanged<bool>? onSelectionChanged;
  final VoidCallback? onPressed;
  final MetroListTileStyle? style;
  final bool autofocus;
  final FocusNode? focusNode;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final effectiveController =
        controller ?? MetroSelectionGroup.of<T>(context);
    return AnimatedBuilder(
      animation: effectiveController,
      builder: (context, child) {
        final selected = effectiveController.isSelected(value);
        return MetroListTile(
          autofocus: autofocus,
          checked: effectiveController.mode == MetroSelectionMode.multiple
              ? selected
              : null,
          focusNode: focusNode,
          leading: leading,
          onPressed: enabled
              ? () {
                  final changed = selected
                      ? (effectiveController.mode ==
                                    MetroSelectionMode.multiple ||
                                allowDeselection
                            ? effectiveController.deselect(value)
                            : false)
                      : effectiveController.select(value);
                  if (changed) {
                    onSelectionChanged?.call(!selected);
                  }
                  onPressed?.call();
                }
              : null,
          selected: selected,
          semanticLabel: semanticLabel,
          style: style,
          subtitle: subtitle,
          title: title,
          trailing: trailing,
        );
      },
    );
  }
}
