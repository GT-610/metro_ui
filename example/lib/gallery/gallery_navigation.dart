import 'package:flutter/material.dart';
import 'package:metro_ui/metro_ui.dart';

import 'catalog.dart';

final List<MetroSearchBoxItem<GalleryComponent>>
_gallerySearchItems = List<MetroSearchBoxItem<GalleryComponent>>.unmodifiable([
  for (final component in galleryComponents)
    MetroSearchBoxItem<GalleryComponent>(
      value: component,
      queryText: component.name,
      semanticLabel:
          '${component.name}, ${galleryDestinationOf(component.destination).title}',
      child: _SearchResult(component: component),
    ),
]);

final Map<GalleryComponent, String> _gallerySearchIndex =
    Map<GalleryComponent, String>.unmodifiable({
      for (final component in galleryComponents)
        component: component.searchText,
    });

bool _filterGalleryComponent(
  String query,
  MetroSearchBoxItem<GalleryComponent> item,
) {
  final searchText = _gallerySearchIndex[item.value] ?? item.value.searchText;
  return searchText.contains(query.trim().toLowerCase());
}

/// The tinted rail surface used by the wide gallery navigation.
///
/// The era's place lists were a flood of the accent color with a brighter bar
/// for the current place, so the rail is a darkened accent and the selection is
/// the accent itself.
(Color, Color, Color) _railPalette(MetroThemeData theme) {
  final colors = theme.colors;
  final rail = Color.lerp(
    colors.accent,
    const Color(0xFF000000),
    colors.isDark ? 0.55 : 0.42,
  )!;
  return (rail, colors.onAccent, colors.accent);
}

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
    final (rail, railForeground, selectionColor) = _railPalette(theme);
    return SizedBox(
      width: 300,
      child: ColoredBox(
        color: rail,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  MetroSpacing.lg,
                  MetroSpacing.lg,
                  MetroSpacing.lg,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Metro Gallery',
                      style: theme.typography.subheader.copyWith(
                        color: railForeground,
                      ),
                    ),
                    const SizedBox(height: MetroSpacing.xxs),
                    Text(
                      '${galleryComponents.length} controls and patterns',
                      style: theme.typography.caption.copyWith(
                        color: railForeground.withValues(alpha: 0.72),
                      ),
                    ),
                    const SizedBox(height: MetroSpacing.lg),
                    _GallerySearch(
                      key: ValueKey<GalleryDestinationId>(selected),
                      onSelected: onComponentSelected,
                    ),
                    const SizedBox(height: MetroSpacing.xl),
                    Text(
                      'Browse',
                      style: theme.typography.bodyStrong.copyWith(
                        color: railForeground.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                ),
              ),
              // The selection bar spans the full rail width while the labels
              // stay on the rail's text inset.
              Expanded(
                child: _GalleryPlaceList(
                  selected: selected,
                  foreground: railForeground,
                  selectionColor: selectionColor,
                  onSelected: onSelected,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A flat list of places: no icons, no dividers, and no scrollbar chrome.
class _GalleryPlaceList extends StatelessWidget {
  const _GalleryPlaceList({
    required this.selected,
    required this.foreground,
    required this.selectionColor,
    required this.onSelected,
  });

  final GalleryDestinationId selected;
  final Color foreground;
  final Color selectionColor;
  final ValueChanged<GalleryDestinationId> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = MetroTheme.of(context);
    final style = MetroListTileStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return selectionColor;
        if (states.contains(WidgetState.hovered)) {
          return foreground.withValues(alpha: 0.13);
        }
        return const Color(0x00000000);
      }),
      foregroundColor: WidgetStatePropertyAll(foreground),
      titleStyle: WidgetStatePropertyAll(
        theme.typography.title.copyWith(color: foreground),
      ),
      padding: const EdgeInsets.symmetric(horizontal: MetroSpacing.lg),
      minimumHeight: 52,
      showSelectionMark: false,
    );
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: galleryDestinations.length,
        itemBuilder: (context, index) {
          final destination = galleryDestinations[index];
          return MetroListTile(
            title: Text(destination.title),
            selected: destination.id == selected,
            style: style,
            semanticLabel: 'Open ${destination.title}',
            onPressed: () => onSelected(destination.id),
          );
        },
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
    final theme = MetroTheme.of(context);
    final style = MetroListTileStyle(
      titleStyle: WidgetStatePropertyAll(theme.typography.title),
      padding: const EdgeInsets.symmetric(horizontal: MetroSpacing.md),
      minimumHeight: 44,
      showSelectionMark: false,
    );
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
                  width: 210,
                  child: MetroListTile(
                    title: Text(destination.title),
                    selected: destination.id == selected,
                    style: style,
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
      items: _gallerySearchItems,
      filter: _filterGalleryComponent,
      onSelected: (item) {
        FocusManager.instance.primaryFocus?.unfocus();
        onSelected(item.value);
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
