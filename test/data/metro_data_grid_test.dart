import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_ui/metro_ui.dart';

import '../test_utils.dart';

void main() {
  test('sort state uses value semantics', () {
    expect(
      const MetroDataGridSort(
        columnKey: 'title',
        direction: MetroDataGridSortDirection.ascending,
      ),
      const MetroDataGridSort(
        columnKey: 'title',
        direction: MetroDataGridSortDirection.ascending,
      ),
    );
  });

  testWidgets('grid renders headers, cells, and an empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      metroTestApp(
        child: Center(
          child: SizedBox(
            width: 420,
            child: MetroDataGrid<_Album>(
              columns: _columns(),
              rows: const [
                _Album('Discovery', 'Daft Punk', 2001),
                _Album('Homework', 'Daft Punk', 1997),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('TITLE'), findsOneWidget);
    expect(find.text('ARTIST'), findsOneWidget);
    expect(find.text('Discovery'), findsOneWidget);
    expect(find.text('1997'), findsOneWidget);
    expect(tester.getSize(find.byType(MetroDataGrid<_Album>)).height, 132);

    await tester.pumpWidget(
      metroTestApp(
        child: Center(
          child: SizedBox(
            width: 420,
            child: MetroDataGrid<_Album>(
              columns: _columns(),
              rows: const [],
              emptyState: const Text('NO ALBUMS'),
            ),
          ),
        ),
      ),
    );
    expect(find.text('NO ALBUMS'), findsOneWidget);
  });

  testWidgets('sortable header requests controlled sort direction', (
    tester,
  ) async {
    MetroDataGridSort? sort;
    await tester.pumpWidget(
      metroTestApp(
        child: StatefulBuilder(
          builder: (context, setState) {
            return Center(
              child: SizedBox(
                width: 420,
                child: MetroDataGrid<_Album>(
                  columns: _columns(),
                  rows: const [_Album('Discovery', 'Daft Punk', 2001)],
                  sort: sort,
                  onSortChanged: (next) => setState(() => sort = next),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.bySemanticsLabel('Sort by title'));
    await tester.pump();
    expect(
      sort,
      const MetroDataGridSort(
        columnKey: 'title',
        direction: MetroDataGridSortDirection.ascending,
      ),
    );
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('Sort by title'))
          .getSemanticsData()
          .value,
      'Ascending',
    );

    await tester.tap(find.bySemanticsLabel('Sort by title'));
    await tester.pump();
    expect(sort?.direction, MetroDataGridSortDirection.descending);
  });

  testWidgets('row press updates a shared selection controller', (
    tester,
  ) async {
    final controller = MetroSelectionController<_Album>();
    const discovery = _Album('Discovery', 'Daft Punk', 2001);
    await tester.pumpWidget(
      metroTestApp(
        child: Center(
          child: SizedBox(
            width: 420,
            child: MetroDataGrid<_Album>(
              columns: _columns(),
              rows: const [discovery],
              selectionController: controller,
              rowSemanticLabelBuilder: (row, index) => row.title,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.bySemanticsLabel('Discovery'));
    await tester.pump();

    expect(controller.selectedValue, discovery);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Discovery')),
      matchesSemantics(
        label: 'Discovery',
        hasEnabledState: true,
        isEnabled: true,
        hasSelectedState: true,
        isSelected: true,
        hasTapAction: true,
        isFocusable: true,
        isFocused: true,
        hasFocusAction: true,
      ),
    );
    controller.dispose();
  });

  testWidgets(
    'keyboard navigation skips disabled rows and selects with Space',
    (tester) async {
      final controller = MetroSelectionController<_Album>(
        mode: MetroSelectionMode.multiple,
      );
      const first = _Album('First', 'Artist', 2000);
      const disabled = _Album('Disabled', 'Artist', 2001);
      const third = _Album('Third', 'Artist', 2002);
      await tester.pumpWidget(
        metroTestApp(
          child: Center(
            child: SizedBox(
              width: 420,
              child: MetroDataGrid<_Album>(
                autofocus: true,
                columns: _columns(),
                rows: const [first, disabled, third],
                rowEnabledBuilder: (row) => row != disabled,
                selectionController: controller,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();

      expect(controller.selectedValues, <_Album>{third});
      controller.dispose();
    },
  );

  testWidgets('autofocus scans enabled rows once per table build', (
    tester,
  ) async {
    final rows = List<_Album>.generate(
      10,
      (index) => _Album('Album $index', 'Artist', 2000 + index),
    );
    final controller = MetroSelectionController<_Album>();
    var enabledChecks = 0;
    await tester.pumpWidget(
      metroTestApp(
        child: Center(
          child: SizedBox(
            width: 420,
            child: MetroDataGrid<_Album>(
              autofocus: true,
              columns: _columns(),
              rowEnabledBuilder: (row) {
                enabledChecks += 1;
                return identical(row, rows.last);
              },
              rows: rows,
              selectionController: controller,
            ),
          ),
        ),
      ),
    );

    expect(enabledChecks, rows.length * 2);
    controller.dispose();
  });

  testWidgets('End navigates through a lazy viewport to the final row', (
    tester,
  ) async {
    final rows = List<_Album>.generate(
      20,
      (index) => _Album('Album $index', 'Artist', 2000 + index),
    );
    final controller = MetroSelectionController<_Album>();
    await tester.pumpWidget(
      metroTestApp(
        child: Center(
          child: SizedBox(
            width: 420,
            child: MetroDataGrid<_Album>(
              autofocus: true,
              columns: _columns(),
              height: 176,
              rows: rows,
              selectionController: controller,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pump();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();

    expect(controller.selectedValue, rows.last);
    expect(find.text('Album 19'), findsOneWidget);
    controller.dispose();
  });

  testWidgets('wide fixed columns scroll horizontally', (tester) async {
    final scrollController = ScrollController();
    await tester.pumpWidget(
      metroTestApp(
        child: Center(
          child: SizedBox(
            width: 260,
            child: MetroDataGrid<_Album>(
              columns: _columns(fixedWidth: 180),
              horizontalScrollController: scrollController,
              rows: const [_Album('Discovery', 'Daft Punk', 2001)],
            ),
          ),
        ),
      ),
    );

    expect(scrollController.position.maxScrollExtent, greaterThan(0));
    scrollController.jumpTo(scrollController.position.maxScrollExtent);
    await tester.pump();
    expect(scrollController.offset, greaterThan(0));

    await tester.pumpWidget(const SizedBox());
    scrollController.dispose();
  });

  testWidgets('widget style overrides local grid row height', (tester) async {
    await tester.pumpWidget(
      metroTestApp(
        child: Center(
          child: MetroDataGridTheme(
            data: const MetroDataGridThemeData(
              style: MetroDataGridStyle(rowHeight: 60),
            ),
            child: SizedBox(
              width: 420,
              child: MetroDataGrid<_Album>(
                columns: _columns(),
                rows: const [_Album('Discovery', 'Daft Punk', 2001)],
                showHeader: false,
                style: const MetroDataGridStyle(rowHeight: 52),
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(MetroDataGrid<_Album>)).height, 52);
  });

  testWidgets('selected rows use the filled Metro selection treatment', (
    tester,
  ) async {
    const discovery = _Album('Discovery', 'Daft Punk', 2001);
    final theme = MetroThemeData.light();
    final controller = MetroSelectionController<_Album>(
      selectedValues: const <_Album>[discovery],
    );
    await tester.pumpWidget(
      metroTestApp(
        theme: theme,
        child: Center(
          child: SizedBox(
            width: 420,
            child: MetroDataGrid<_Album>(
              columns: _columns(),
              rows: const <_Album>[discovery],
              selectionController: controller,
              showHeader: false,
            ),
          ),
        ),
      ),
    );

    final surface = find.byKey(
      const ValueKey<String>('metro-data-grid-row-0-surface'),
    );
    final container = tester.widget<Container>(surface);
    expect((container.decoration! as BoxDecoration).color, theme.colors.accent);
    expect(
      DefaultTextStyle.of(tester.element(find.text('Discovery'))).style.color,
      const Color(0xFFFFFFFF),
    );
    controller.dispose();
  });

  testWidgets('selected row hover uses the lighter accent state', (
    tester,
  ) async {
    final previousStrategy = FocusManager.instance.highlightStrategy;
    addTearDown(() {
      FocusManager.instance.highlightStrategy = previousStrategy;
    });
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    const discovery = _Album('Discovery', 'Daft Punk', 2001);
    final theme = MetroThemeData.light();
    final controller = MetroSelectionController<_Album>(
      selectedValues: const <_Album>[discovery],
    );
    await tester.pumpWidget(
      metroTestApp(
        theme: theme,
        child: Center(
          child: SizedBox(
            width: 420,
            child: MetroDataGrid<_Album>(
              columns: _columns(),
              rows: const <_Album>[discovery],
              selectionController: controller,
              showHeader: false,
            ),
          ),
        ),
      ),
    );

    final surface = find.byKey(
      const ValueKey<String>('metro-data-grid-row-0-surface'),
    );
    final position = tester.getCenter(surface);
    await tester.sendEventToBinding(
      const PointerAddedEvent(kind: PointerDeviceKind.mouse),
    );
    await tester.sendEventToBinding(
      PointerHoverEvent(kind: PointerDeviceKind.mouse, position: position),
    );
    await tester.pump();

    expect(
      (tester.widget<Container>(surface).decoration! as BoxDecoration).color,
      theme.colors.accentHover,
    );
    await tester.sendEventToBinding(
      PointerRemovedEvent(kind: PointerDeviceKind.mouse, position: position),
    );
    controller.dispose();
  });

  testWidgets('row pointer press uses the 0.975 scale without a pressed fill', (
    tester,
  ) async {
    await tester.pumpWidget(
      metroTestApp(
        child: Center(
          child: SizedBox(
            width: 420,
            child: MetroDataGrid<_Album>(
              columns: _columns(),
              rows: const <_Album>[_Album('Discovery', 'Daft Punk', 2001)],
              onRowPressed: (_) {},
              showHeader: false,
            ),
          ),
        ),
      ),
    );

    final surface = find.byKey(
      const ValueKey<String>('metro-data-grid-row-0-surface'),
    );
    final scale = find.byKey(
      const ValueKey<String>('metro-data-grid-row-0-scale'),
    );
    final gesture = await tester.startGesture(tester.getCenter(surface));
    await tester.pump();

    final animatedScale = tester.widget<AnimatedScale>(scale);
    expect(animatedScale.scale, 0.975);
    expect(animatedScale.duration, const Duration(milliseconds: 167));
    expect(
      (tester.widget<Container>(surface).decoration! as BoxDecoration).color,
      MetroThemeData.light().colors.background,
    );
    await gesture.up();
  });
}

List<MetroDataGridColumn<_Album>> _columns({double? fixedWidth}) {
  return <MetroDataGridColumn<_Album>>[
    MetroDataGridColumn<_Album>(
      key: 'title',
      label: const Text('TITLE'),
      semanticLabel: 'Sort by title',
      sortable: true,
      width: fixedWidth,
      cellBuilder: (context, row, index) => Text(row.title),
    ),
    MetroDataGridColumn<_Album>(
      key: 'artist',
      label: const Text('ARTIST'),
      width: fixedWidth,
      cellBuilder: (context, row, index) => Text(row.artist),
    ),
    MetroDataGridColumn<_Album>(
      key: 'year',
      label: const Text('YEAR'),
      width: fixedWidth ?? 80,
      alignment: AlignmentDirectional.centerEnd,
      headerAlignment: AlignmentDirectional.centerEnd,
      cellBuilder: (context, row, index) => Text('${row.year}'),
    ),
  ];
}

@immutable
class _Album {
  const _Album(this.title, this.artist, this.year);

  final String title;
  final String artist;
  final int year;

  @override
  bool operator ==(Object other) {
    return other is _Album &&
        other.title == title &&
        other.artist == artist &&
        other.year == year;
  }

  @override
  int get hashCode => Object.hash(title, artist, year);
}
