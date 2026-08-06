import 'package:flutter/material.dart';
import 'package:metro_ui/metro_ui.dart';

import 'catalog.dart';

class GalleryNavigation extends StatelessWidget {
  const GalleryNavigation({
    required this.selected,
    required this.onSelected,
    required this.onComponentSelected,
    super.key,
  });

  final GalleryDestinationId selected;
  final ValueChanged<GalleryDestinationId> onSelected;
  final ValueChanged<GalleryComponent> onComponentSelected;

  @override
  Widget build(BuildContext context) {
    final theme = MetroTheme.of(context);
    return SizedBox(
      width: 288,
      child: ColoredBox(
        color: theme.colors.surface,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(MetroSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('METRO GALLERY', style: theme.typography.bodyStrong),
                const SizedBox(height: MetroSpacing.xxs),
                Text(
                  '${galleryComponents.length} controls and patterns',
                  style: theme.typography.caption,
                ),
                const SizedBox(height: MetroSpacing.md),
                _GallerySearch(
                  key: ValueKey<GalleryDestinationId>(selected),
                  onSelected: onComponentSelected,
                ),
                const SizedBox(height: MetroSpacing.lg),
                Text('BROWSE', style: theme.typography.caption),
                const SizedBox(height: MetroSpacing.xs),
                Expanded(
                  child: ListView.separated(
                    itemCount: galleryDestinations.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: MetroSpacing.xxs),
                    itemBuilder: (context, index) {
                      final destination = galleryDestinations[index];
                      return MetroListTile(
                        leading: Icon(destination.icon),
                        title: Text(destination.title),
                        selected: destination.id == selected,
                        semanticLabel: 'Open ${destination.title}',
                        onPressed: () => onSelected(destination.id),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CompactGalleryNavigation extends StatelessWidget {
  const CompactGalleryNavigation({
    required this.selected,
    required this.onSelected,
    required this.onComponentSelected,
    super.key,
  });

  final GalleryDestinationId selected;
  final ValueChanged<GalleryDestinationId> onSelected;
  final ValueChanged<GalleryComponent> onComponentSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: _GallerySearch(
            key: ValueKey<GalleryDestinationId>(selected),
            onSelected: onComponentSelected,
          ),
        ),
        const SizedBox(height: MetroSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final destination in galleryDestinations) ...[
                SizedBox(
                  width: 180,
                  child: MetroListTile(
                    leading: Icon(destination.icon),
                    title: Text(destination.title),
                    selected: destination.id == selected,
                    semanticLabel: 'Open ${destination.title}',
                    onPressed: () => onSelected(destination.id),
                  ),
                ),
                const SizedBox(width: MetroSpacing.xs),
              ],
            ],
          ),
        ),
        const SizedBox(height: MetroSpacing.xl),
      ],
    );
  }
}

class _GallerySearch extends StatelessWidget {
  const _GallerySearch({required this.onSelected, super.key});

  final ValueChanged<GalleryComponent> onSelected;

  @override
  Widget build(BuildContext context) {
    return MetroSearchBox<GalleryComponent>(
      placeholder: 'Find a component',
      semanticLabel: 'Find a Metro UI component',
      items: [
        for (final component in galleryComponents)
          MetroSearchBoxItem<GalleryComponent>(
            value: component,
            queryText: component.name,
            semanticLabel:
                '${component.name}, ${galleryDestinationOf(component.destination).title}',
            child: _SearchResult(component: component),
          ),
      ],
      filter: (query, item) {
        return item.value.searchText.contains(query.trim().toLowerCase());
      },
      onSelected: (item) {
        FocusManager.instance.primaryFocus?.unfocus();
        Future<void>.microtask(() => onSelected(item.value));
      },
      noResultsBuilder: (context) => const Padding(
        padding: EdgeInsets.all(MetroSpacing.sm),
        child: Text('No matching components'),
      ),
    );
  }
}

class _SearchResult extends StatelessWidget {
  const _SearchResult({required this.component});

  final GalleryComponent component;

  @override
  Widget build(BuildContext context) {
    final theme = MetroTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(component.name, style: theme.typography.bodyStrong),
        Text(
          galleryDestinationOf(component.destination).title,
          style: theme.typography.caption,
        ),
      ],
    );
  }
}
