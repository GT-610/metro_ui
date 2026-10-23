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

/// The tinted rail surfaces used by the wide gallery navigation.
///
/// A place list is a flood of the accent color: the rail sits deep in the
/// accent's shade and the current place is a lifted tint of that same channel,
/// so the labels keep one color in both states. Switching the label color with
/// the selection would make a row change its text weight mid-list, which the
/// era never did.
({Color rail, Color railContent, Color selection}) _railPalette(
  MetroThemeData theme,
) {
  final colors = theme.colors;
  final rail = Color.lerp(
    colors.accent,
    const Color(0xFF000000),
    colors.isDark ? 0.62 : 0.55,
  )!;
  final railContent = MetroColorScheme.idealForegroundFor(rail);
  return (
    rail: rail,
    railContent: railContent,
    // The bar is the rail lifted toward the accent rather than the raw accent,
    // and it stops lifting before the label color would stop reading.
    selection: _liftToward(rail, colors.accent, railContent),
  );
}

/// Lifts [base] toward [target] as far as [content] still reads on the result.
///
/// A place list keeps one label color, so the current place needs a bar that
/// stays dark enough for that color even when the accent is a bright yellow.
Color _liftToward(Color base, Color target, Color content) {
  final ceiling = content == const Color(0xFFFFFFFF) ? 0.18 : 0.35;
  for (final amount in <double>[0.72, 0.6, 0.5, 0.4, 0.3, 0.2]) {
    final candidate = Color.lerp(base, target, amount)!;
    final luminance = candidate.computeLuminance();
    if (content == const Color(0xFFFFFFFF)
        ? luminance <= ceiling
        : luminance >= ceiling) {
      return candidate;
    }
  }
  return Color.lerp(base, target, 0.2)!;
}

/// Whether focus chrome should appear.
///
/// This era showed focus visuals for keyboard input only, so a pointer click
/// leaves a selected place with just its accent bar.
bool _focusVisualVisible() {
  final manager = FocusManager.instance;
  if (manager.highlightStrategy == FocusHighlightStrategy.alwaysTraditional) {
    return true;
  }
  if (manager.highlightStrategy == FocusHighlightStrategy.alwaysTouch) {
    return false;
  }
  return manager.highlightMode == FocusHighlightMode.traditional;
}

class GalleryNavigation extends StatelessWidget {
  const GalleryNavigation({
    required this.selected,
    required this.onSelected,
    required this.onComponentSelected,
    this.onBack,
    super.key,
  });

  final GalleryDestinationId selected;
  final ValueChanged<GalleryDestinationId> onSelected;
  final ValueChanged<GalleryComponent> onComponentSelected;

  /// Leaves a nested component page, or null when there is nothing to leave.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final theme = MetroTheme.of(context);
    final palette = _railPalette(theme);
    final railForeground = palette.railContent;
    return SizedBox(
      width: 300,
      child: ColoredBox(
        color: palette.rail,
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (onBack case final onBack?) ...[
                          MetroBackButton(
                            onPressed: onBack,
                            style: MetroBackButtonStyle(
                              size: 30,
                              iconSize: 14,
                              foregroundColor: WidgetStatePropertyAll(
                                railForeground,
                              ),
                              borderColor: WidgetStatePropertyAll(
                                railForeground,
                              ),
                            ),
                            semanticLabel: 'Back to Metro Gallery',
                          ),
                          const SizedBox(width: MetroSpacing.sm),
                        ],
                        Expanded(
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
                                '${galleryComponents.length} controls and '
                                'patterns',
                                style: theme.typography.caption.copyWith(
                                  color: railForeground.withValues(alpha: 0.72),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                  selectionColor: palette.selection,
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
      // The era drew no ring around a selected place and showed the focus
      // outline for keyboard input only, in the rail's own content color.
      borderColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.focused) && _focusVisualVisible()) {
          return foreground;
        }
        return const Color(0x00000000);
      }),
      borderWidth: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.focused) && _focusVisualVisible()) {
          return 2;
        }
        return 0;
      }),
      titleStyle: WidgetStatePropertyAll(theme.typography.title),
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
    final colors = theme.colors;
    // On a page surface the current place is a filled selection, so its label
    // follows the same content rule as a tile of that color.
    final selectionContent = MetroColorScheme.tileForegroundFor(colors.accent);
    final style = MetroListTileStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected)
            ? colors.accent
            : const Color(0x00000000);
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected)
            ? selectionContent
            : colors.foreground;
      }),
      titleStyle: WidgetStatePropertyAll(theme.typography.title),
      padding: const EdgeInsets.symmetric(horizontal: MetroSpacing.lg),
      minimumHeight: 52,
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
