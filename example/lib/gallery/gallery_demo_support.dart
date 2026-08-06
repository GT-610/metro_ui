import 'package:flutter/material.dart';
import 'package:metro_ui/metro_ui.dart';

class GallerySectionHeading extends StatelessWidget {
  const GallerySectionHeading({
    required this.title,
    this.description,
    super.key,
  });

  final String title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final typography = MetroTheme.of(context).typography;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: typography.title),
        if (description case final description?) ...[
          const SizedBox(height: MetroSpacing.xs),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Text(description),
          ),
        ],
      ],
    );
  }
}

class GalleryAccentPicker extends StatelessWidget {
  const GalleryAccentPicker({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final Color selected;
  final ValueChanged<Color> onSelected;

  static const _colors = <Color>[
    MetroColors.cobalt,
    MetroColors.teal,
    MetroColors.magenta,
    MetroColors.orange,
    MetroColors.yellow,
  ];

  @override
  Widget build(BuildContext context) {
    final focusColor = MetroTheme.of(context).colors.focus;
    return Wrap(
      spacing: MetroSpacing.xs,
      runSpacing: MetroSpacing.xs,
      children: [
        for (final color in _colors)
          Semantics(
            button: true,
            selected: color == selected,
            label: 'Select accent ${color.toARGB32().toRadixString(16)}',
            child: GestureDetector(
              onTap: () => onSelected(color),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(
                    color: color == selected
                        ? focusColor
                        : const Color(0x00000000),
                    width: 3,
                  ),
                ),
                child: const SizedBox.square(dimension: 36),
              ),
            ),
          ),
      ],
    );
  }
}

class GalleryFlipViewStory extends StatelessWidget {
  const GalleryFlipViewStory({
    required this.color,
    required this.eyebrow,
    required this.title,
    required this.icon,
    super.key,
  });

  final Color color;
  final String eyebrow;
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(64, MetroSpacing.lg, 64, 72),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eyebrow,
                    style: const TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: MetroSpacing.sm),
                  Flexible(
                    child: FittedBox(
                      alignment: AlignmentDirectional.centerStart,
                      fit: BoxFit.scaleDown,
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 44,
                          fontWeight: FontWeight.w300,
                          height: 0.95,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: MetroSpacing.lg),
            Icon(icon, color: const Color(0xFFFFFFFF), size: 72),
          ],
        ),
      ),
    );
  }
}

class GallerySemanticZoomOverview extends StatelessWidget {
  const GallerySemanticZoomOverview({
    required this.groups,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final List<GallerySemanticZoomGroup> groups;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(MetroSpacing.md),
      child: GridView.builder(
        itemCount: groups.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: MetroSpacing.sm,
          mainAxisSpacing: MetroSpacing.sm,
          childAspectRatio: 1.45,
        ),
        itemBuilder: (context, index) {
          final group = groups[index];
          return MetroButton(
            semanticLabel:
                '${group.label}, ${group.items.length} component examples',
            style: MetroButtonStyle(
              backgroundColor: WidgetStatePropertyAll(group.color),
              foregroundColor: const WidgetStatePropertyAll(Color(0xFFFFFFFF)),
              borderColor: WidgetStatePropertyAll(
                index == selectedIndex
                    ? const Color(0xFFFFFFFF)
                    : const Color(0x00000000),
              ),
              borderWidth: WidgetStatePropertyAll(
                index == selectedIndex ? 3 : 0,
              ),
              padding: const EdgeInsets.all(MetroSpacing.sm),
            ),
            onPressed: () => onSelected(index),
            child: Align(
              alignment: AlignmentDirectional.bottomStart,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text('${group.items.length} COMPONENTS'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class GallerySemanticZoomGroupPage extends StatelessWidget {
  const GallerySemanticZoomGroupPage({
    required this.group,
    required this.onItemPressed,
    super.key,
  });

  final GallerySemanticZoomGroup group;
  final ValueChanged<String> onItemPressed;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: group.color,
      child: Padding(
        padding: const EdgeInsets.all(MetroSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group.label,
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 36,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: MetroSpacing.xs),
            Text(
              group.description,
              style: const TextStyle(color: Color(0xFFFFFFFF)),
            ),
            const Spacer(),
            Wrap(
              spacing: MetroSpacing.sm,
              runSpacing: MetroSpacing.sm,
              children: [
                for (final item in group.items)
                  MetroButton(
                    style: const MetroButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        Color(0x26FFFFFF),
                      ),
                      foregroundColor: WidgetStatePropertyAll(
                        Color(0xFFFFFFFF),
                      ),
                      borderColor: WidgetStatePropertyAll(Color(0x99FFFFFF)),
                    ),
                    onPressed: () => onItemPressed(item),
                    child: Text(item.toUpperCase()),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

@immutable
class GallerySemanticZoomGroup {
  const GallerySemanticZoomGroup({
    required this.label,
    required this.description,
    required this.color,
    required this.items,
  });

  final String label;
  final String description;
  final Color color;
  final List<String> items;
}

@immutable
class GalleryAlbum {
  const GalleryAlbum(this.title, this.artist, this.year);

  final String title;
  final String artist;
  final int year;

  @override
  bool operator ==(Object other) {
    return other is GalleryAlbum &&
        other.title == title &&
        other.artist == artist &&
        other.year == year;
  }

  @override
  int get hashCode => Object.hash(title, artist, year);
}
