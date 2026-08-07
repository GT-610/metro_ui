import 'package:flutter/material.dart';
import 'package:metro_ui/metro_ui.dart';

import 'catalog.dart';

class GalleryHome extends StatelessWidget {
  const GalleryHome({
    required this.onSelected,
    required this.accentPicker,
    super.key,
  });

  final ValueChanged<GalleryDestinationId> onSelected;
  final Widget accentPicker;

  @override
  Widget build(BuildContext context) {
    final theme = MetroTheme.of(context);
    final categories = galleryDestinations.where(
      (destination) =>
          destination.id != GalleryDestinationId.home &&
          destination.id != GalleryDestinationId.allControls,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Modern UI for Flutter', style: theme.typography.header),
        const SizedBox(height: MetroSpacing.xs),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Text(
            'Browse by family or search by control name and capability. Each '
            'category is a focused, interactive workspace; the complete '
            'integration playground remains available under All controls.',
            style: theme.typography.body,
          ),
        ),
        const SizedBox(height: MetroSpacing.xl),
        Text('BROWSE BY CATEGORY', style: theme.typography.bodyStrong),
        const SizedBox(height: MetroSpacing.sm),
        MetroFocusTraversalGroup.spatial(
          debugLabel: 'Gallery categories',
          child: MetroTileGrid(
            children: [
              for (final destination in categories)
                MetroTile(
                  size: MetroTileSize.wide,
                  icon: Icon(destination.icon),
                  title: destination.title.toUpperCase(),
                  subtitle:
                      '${galleryComponentsFor(destination.id).length} examples',
                  backgroundColor: destination.color,
                  semanticLabel: 'Browse ${destination.title}',
                  onPressed: () => onSelected(destination.id),
                ),
            ],
          ),
        ),
        const SizedBox(height: MetroSpacing.xl),
        Text('PERSONALIZE THE GALLERY', style: theme.typography.bodyStrong),
        const SizedBox(height: MetroSpacing.sm),
        accentPicker,
        const SizedBox(height: MetroSpacing.xl),
        MetroButton(
          onPressed: () => onSelected(GalleryDestinationId.allControls),
          child: const Text('OPEN THE COMPLETE PLAYGROUND'),
        ),
      ],
    );
  }
}

class GalleryPageIntroduction extends StatelessWidget {
  const GalleryPageIntroduction({
    required this.destination,
    this.selectedComponent,
    this.onRevealSelectedComponent,
    super.key,
  });

  final GalleryDestination destination;
  final GalleryComponent? selectedComponent;
  final VoidCallback? onRevealSelectedComponent;

  @override
  Widget build(BuildContext context) {
    final theme = MetroTheme.of(context);
    final components = galleryComponentsFor(destination.id);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedComponent case final component?) ...[
          DecoratedBox(
            decoration: BoxDecoration(color: theme.colors.accent),
            child: Padding(
              padding: const EdgeInsets.all(MetroSpacing.md),
              child: DefaultTextStyle.merge(
                style: theme.typography.body.copyWith(
                  color: theme.colors.onAccent,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SEARCH RESULT',
                      style: theme.typography.caption.copyWith(
                        color: theme.colors.onAccent,
                      ),
                    ),
                    const SizedBox(height: MetroSpacing.xxs),
                    Text(
                      component.name,
                      style: theme.typography.title.copyWith(
                        color: theme.colors.onAccent,
                      ),
                    ),
                    const SizedBox(height: MetroSpacing.xxs),
                    Text(component.description),
                    if (onRevealSelectedComponent != null) ...[
                      const SizedBox(height: MetroSpacing.md),
                      MetroButton(
                        onPressed: onRevealSelectedComponent,
                        child: const Text('JUMP TO DEMO'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: MetroSpacing.md),
        ],
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Text(destination.description, style: theme.typography.body),
        ),
        const SizedBox(height: MetroSpacing.md),
        Wrap(
          spacing: MetroSpacing.xs,
          runSpacing: MetroSpacing.xs,
          children: [
            for (final component in components)
              DecoratedBox(
                decoration: BoxDecoration(color: theme.colors.surfaceVariant),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: MetroSpacing.xs,
                    vertical: MetroSpacing.xxs,
                  ),
                  child: Text(component.name, style: theme.typography.caption),
                ),
              ),
          ],
        ),
        const SizedBox(height: MetroSpacing.xl),
      ],
    );
  }
}
