@Tags(['golden'])
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_ui/metro_ui.dart';

import 'preview_support.dart';

void main() {
  setUpAll(loadPreviewFonts);

  for (final brightness in previewBrightnesses) {
    testWidgets('lists preview in ${brightness.name} theme', (tester) async {
      final theme = previewTheme(brightness);
      final boundaryKey = await pumpPreview(
        tester,
        brightness: brightness,
        child: _ListsPreview(theme: theme),
      );
      await expectPreview(
        tester,
        boundaryKey,
        'preview_lists_${brightness.name}',
      );
    });
  }
}

const List<_Album> _albums = [
  _Album('Blue', 'Joni Mitchell', 1971, '4:35'),
  _Album('Kind of Blue', 'Miles Davis', 1959, '5:37'),
  _Album('Untrue', 'Burial', 2007, '5:24'),
  _Album('Selected Ambient Works', 'Aphex Twin', 1992, '7:12'),
  _Album('Homogenic', 'Bjork', 1997, '4:33'),
  _Album('Music Has the Right', 'Boards of Canada', 1998, '6:06'),
  _Album('Vespertine', 'Bjork', 2001, '4:03'),
  _Album('Dummy', 'Portishead', 1994, '4:47'),
  _Album('Maxinquaye', 'Tricky', 1995, '5:12'),
];

class _Album {
  const _Album(this.title, this.artist, this.year, this.length);

  final String title;
  final String artist;
  final int year;
  final String length;
}

class _ListsPreview extends StatelessWidget {
  const _ListsPreview({required this.theme});

  final MetroThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Metro lists and data', style: theme.typography.header),
        const SizedBox(height: MetroSpacing.xl),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fixed side columns keep the 70 and 150 pixel tiles on one row.
              SizedBox(
                width: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _selectionSection(),
                    const SizedBox(height: MetroSpacing.xxl),
                    _singleSelectionSection(),
                  ],
                ),
              ),
              const SizedBox(width: MetroSpacing.xl),
              Expanded(child: _gridSection()),
              const SizedBox(width: MetroSpacing.xl),
              SizedBox(
                width: 310,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _liveTilesSection(),
                    const SizedBox(height: MetroSpacing.xxl),
                    _emptyGridSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _singleSelectionSection() {
    return PreviewSection(
      title: 'Single selection',
      description: 'Under a single-choice controller.',
      child: MetroSelectionGroup<int>(
        initialSelectedValues: const [1],
        child: Column(
          children: [
            MetroSelectableListTile<int>(
              value: 1,
              leading: const SizedBox.square(dimension: 24),
              title: const Text('First option'),
              subtitle: const Text('Selected'),
              onPressed: () {},
            ),
            MetroSelectableListTile<int>(
              value: 2,
              leading: const SizedBox.square(dimension: 24),
              title: const Text('Second option'),
              subtitle: const Text('Not selected'),
              onPressed: () {},
            ),
            MetroSelectableListTile<int>(
              value: 3,
              leading: const SizedBox.square(dimension: 24),
              title: const Text('Third option'),
              subtitle: const Text('Not selected'),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _selectionSection() {
    final controller = MetroSelectionController<int>(
      mode: MetroSelectionMode.multiple,
      selectedValues: const [2],
    );
    addTearDown(controller.dispose);
    return PreviewSection(
      title: 'Selectable rows',
      description: 'One controller, single or multiple selection.',
      child: MetroSelectionGroup<int>(
        controller: controller,
        mode: MetroSelectionMode.multiple,
        child: Column(
          children: [
            MetroListTile(
              selected: true,
              leading: const SizedBox.square(dimension: 24),
              title: const Text('Selected item'),
              subtitle: const Text('With a supporting line'),
              trailing: const Text('Now'),
              onPressed: () {},
            ),
            MetroSelectableListTile<int>(
              value: 1,
              title: const Text('Checked row'),
              subtitle: const Text('Multiple selection mode'),
              onPressed: () {},
            ),
            const MetroListTile(title: Text('Disabled item'), onPressed: null),
          ],
        ),
      ),
    );
  }

  Widget _liveTilesSection() {
    return PreviewSection(
      title: 'Tiles',
      description: 'Square, wide, and small.',
      child: MetroTileGrid(
        children: [
          MetroTile(
            icon: const Text('M'),
            title: 'Mail',
            badge: const Text('3'),
            onPressed: () {},
          ),
          MetroLiveTile(
            size: MetroTileSize.small,
            backgroundColor: MetroColors.magenta,
            onPressed: () {},
            frames: const [
              MetroLiveTileFrame(id: 'count', child: Text('12')),
              MetroLiveTileFrame(id: 'label', child: Text('NEW')),
            ],
          ),
          MetroTile(
            size: MetroTileSize.small,
            title: 'Store',
            backgroundColor: MetroColors.teal,
            onPressed: () {},
          ),
          MetroTile(
            size: MetroTileSize.wide,
            title: 'Weather',
            backgroundColor: MetroColors.indigo,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _emptyGridSection() {
    return PreviewSection(
      title: 'Empty state',
      description: 'No rows, plus an application message.',
      child: MetroDataGrid<_Album>(
        columns: const [
          MetroDataGridColumn<_Album>(
            key: 'title',
            label: Text('ALBUM'),
            cellBuilder: _albumTitle,
          ),
        ],
        rows: const [],
        emptyState: const Text('No albums match this filter.'),
      ),
    );
  }

  Widget _gridSection() {
    return PreviewSection(
      title: 'Data grid',
      description: 'Sortable columns and selectable rows.',
      child: MetroDataGrid<_Album>(
        height: 452,
        columns: const [
          MetroDataGridColumn<_Album>(
            key: 'title',
            label: Text('ALBUM'),
            cellBuilder: _albumTitle,
            width: 212,
            sortable: true,
          ),
          MetroDataGridColumn<_Album>(
            key: 'artist',
            label: Text('ARTIST'),
            cellBuilder: _albumArtist,
          ),
          MetroDataGridColumn<_Album>(
            key: 'year',
            label: Text('YR'),
            cellBuilder: _albumYear,
            alignment: AlignmentDirectional.centerEnd,
            headerAlignment: AlignmentDirectional.centerEnd,
            width: 66,
          ),
          MetroDataGridColumn<_Album>(
            key: 'length',
            label: Text('MIN'),
            cellBuilder: _albumLength,
            alignment: AlignmentDirectional.centerEnd,
            headerAlignment: AlignmentDirectional.centerEnd,
            width: 66,
          ),
        ],
        rows: _albums,
        sort: const MetroDataGridSort(
          columnKey: 'title',
          direction: MetroDataGridSortDirection.ascending,
        ),
        rowKeyBuilder: (album) => album.title,
      ),
    );
  }
}

Widget _albumTitle(BuildContext context, _Album album, int index) =>
    Text(album.title);

Widget _albumArtist(BuildContext context, _Album album, int index) =>
    Text(album.artist);

Widget _albumYear(BuildContext context, _Album album, int index) =>
    Text('${album.year}');

Widget _albumLength(BuildContext context, _Album album, int index) =>
    Text(album.length);
