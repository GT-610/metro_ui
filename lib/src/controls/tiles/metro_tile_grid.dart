import 'package:flutter/widgets.dart';

import '../../theme/metro_theme.dart';
import 'metro_tile_grid_scope.dart';
import 'metro_tile_style.dart';

/// A responsive wrapping layout for square and wide Metro tiles.
class MetroTileGrid extends StatelessWidget {
  const MetroTileGrid({
    required this.children,
    this.tileExtent,
    this.spacing,
    this.runSpacing,
    this.padding = EdgeInsets.zero,
    this.alignment = WrapAlignment.start,
    super.key,
  });

  final List<Widget> children;
  final double? tileExtent;
  final double? spacing;
  final double? runSpacing;
  final EdgeInsetsGeometry padding;
  final WrapAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final tileTheme = MetroTheme.of(
      context,
    ).tileTheme.merge(MetroTileTheme.maybeOf(context));
    final effectiveExtent = tileExtent ?? tileTheme.extent;
    final effectiveSpacing = spacing ?? tileTheme.spacing;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth - padding.horizontal
            : null;
        return Padding(
          padding: padding,
          child: MetroTileGridScope(
            extent: effectiveExtent,
            maxWidth: maxWidth,
            spacing: effectiveSpacing,
            child: Wrap(
              alignment: alignment,
              spacing: effectiveSpacing,
              runSpacing: runSpacing ?? effectiveSpacing,
              children: children,
            ),
          ),
        );
      },
    );
  }
}
