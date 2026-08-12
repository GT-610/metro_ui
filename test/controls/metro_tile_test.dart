import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_ui/metro_ui.dart';

import '../test_utils.dart';

void main() {
  testWidgets('square and wide tiles use the grid measurements', (
    tester,
  ) async {
    await tester.pumpWidget(
      metroTestApp(
        child: Center(
          child: SizedBox(
            width: 500,
            child: MetroTileGrid(
              tileExtent: 140,
              spacing: 8,
              children: [
                MetroTile(title: 'Square', onPressed: () {}),
                MetroTile(
                  size: MetroTileSize.wide,
                  title: 'Wide',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.widgetWithText(MetroTile, 'Square')),
      const Size(140, 140),
    );
    expect(
      tester.getSize(find.widgetWithText(MetroTile, 'Wide')),
      const Size(288, 140),
    );
  });

  testWidgets('wide tiles clamp to a narrow grid', (tester) async {
    await tester.pumpWidget(
      metroTestApp(
        child: Center(
          child: SizedBox(
            width: 200,
            child: MetroTileGrid(
              children: [
                MetroTile(
                  size: MetroTileSize.wide,
                  title: 'Responsive',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.widgetWithText(MetroTile, 'Responsive')).width,
      200,
    );
  });

  testWidgets('grid clamps tile width when padding exceeds its width', (
    tester,
  ) async {
    await tester.pumpWidget(
      metroTestApp(
        child: Center(
          child: SizedBox(
            width: 40,
            child: MetroTileGrid(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              children: [
                MetroTile(
                  style: const MetroTileStyle(padding: EdgeInsets.zero),
                  onPressed: () {},
                  child: const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(MetroTile)).width, 0);
  });

  test('tile and grid reject invalid geometry', () {
    expect(
      () => MetroTile(title: 'Invalid', width: 0, onPressed: () {}),
      throwsAssertionError,
    );
    expect(
      () => MetroTile(
        title: 'Invalid',
        height: double.infinity,
        onPressed: () {},
      ),
      throwsAssertionError,
    );
    expect(
      () => MetroTileGrid(tileExtent: double.nan, children: const []),
      throwsAssertionError,
    );
    expect(
      () => MetroTileGrid(spacing: -1, children: const []),
      throwsAssertionError,
    );
    expect(
      () => MetroTileGrid(runSpacing: double.infinity, children: const []),
      throwsAssertionError,
    );
  });

  testWidgets('local tile theme supplies grid metrics and tile style', (
    tester,
  ) async {
    const localColor = Color(0xFF123456);
    await tester.pumpWidget(
      metroTestApp(
        child: Center(
          child: MetroTileTheme(
            data: const MetroTileThemeData(
              extent: 100,
              spacing: 6,
              style: MetroTileStyle(
                backgroundColor: WidgetStatePropertyAll(localColor),
              ),
            ),
            child: SizedBox(
              width: 320,
              child: MetroTileGrid(
                children: [MetroTile(title: 'Local tile', onPressed: () {})],
              ),
            ),
          ),
        ),
      ),
    );

    final tile = find.widgetWithText(MetroTile, 'Local tile');
    expect(tester.getSize(tile), const Size(100, 100));
    final container = tester.widget<AnimatedContainer>(
      find.descendant(of: tile, matching: find.byType(AnimatedContainer)),
    );
    expect((container.decoration! as BoxDecoration).color, localColor);
  });

  testWidgets('pressing a tile applies and releases perspective transform', (
    tester,
  ) async {
    await tester.pumpWidget(
      metroTestApp(
        child: Center(
          child: MetroTile(title: 'Press me', onPressed: () {}),
        ),
      ),
    );
    final tile = find.byType(MetroTile);
    final gesture = await tester.startGesture(
      tester.getTopLeft(tile) + const Offset(12, 12),
    );
    await tester.pump(const Duration(milliseconds: 120));

    var container = tester.widget<AnimatedContainer>(
      find.descendant(of: tile, matching: find.byType(AnimatedContainer)),
    );
    expect(container.transform, isNot(Matrix4.identity()));
    expect(container.transform!.storage[2], lessThan(0));
    expect(container.transform!.storage[6], lessThan(0));

    await gesture.up();
    await tester.pump(const Duration(milliseconds: 120));
    container = tester.widget<AnimatedContainer>(
      find.descendant(of: tile, matching: find.byType(AnimatedContainer)),
    );
    expect(container.transform, Matrix4.identity());
  });

  testWidgets('reduced motion disables the perspective transform', (
    tester,
  ) async {
    await tester.pumpWidget(
      metroTestApp(
        mediaQueryData: const MediaQueryData(
          size: Size(800, 600),
          disableAnimations: true,
        ),
        child: Center(
          child: MetroTile(title: 'Static', onPressed: () {}),
        ),
      ),
    );
    final tile = find.byType(MetroTile);
    final gesture = await tester.startGesture(
      tester.getTopLeft(tile) + const Offset(12, 12),
    );
    await tester.pump();

    final container = tester.widget<AnimatedContainer>(
      find.descendant(of: tile, matching: find.byType(AnimatedContainer)),
    );
    expect(container.transform, Matrix4.identity());
    await gesture.up();
  });

  testWidgets('disabled tile exposes its accessible name and state', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      metroTestApp(
        child: const Center(
          child: MetroTile(
            title: 'Mail',
            semanticLabel: 'Mail tile',
            onPressed: null,
          ),
        ),
      ),
    );

    expect(
      tester.getSemantics(find.bySemanticsLabel('Mail tile')),
      matchesSemantics(
        label: 'Mail tile',
        isButton: true,
        hasEnabledState: true,
      ),
    );
    semantics.dispose();
  });

  testWidgets('tile badge uses Metro notification geometry', (tester) async {
    const badgeColor = Color(0xFF123456);
    await tester.pumpWidget(
      metroTestApp(
        child: MetroTileTheme(
          data: const MetroTileThemeData(
            style: MetroTileStyle(
              badgeBackgroundColor: WidgetStatePropertyAll(badgeColor),
            ),
          ),
          child: Center(
            child: MetroTile(
              title: 'Mail',
              badge: const Text('3'),
              badgePosition: MetroTileBadgePosition.topEnd,
              onPressed: () {},
            ),
          ),
        ),
      ),
    );

    final tile = tester.getRect(find.byType(MetroTile));
    final badge = tester.getRect(
      find.byKey(const ValueKey<String>('metro-tile-badge')),
    );
    expect(badge.top - tile.top, 10);
    expect(tile.right - badge.right, 10);
    final decoration =
        tester
                .widget<DecoratedBox>(
                  find.byKey(const ValueKey<String>('metro-tile-badge')),
                )
                .decoration
            as BoxDecoration;
    expect(decoration.color, badgeColor);
  });

  testWidgets('hover uses the Metro 4 four-pixel tile outline', (tester) async {
    final previousStrategy = FocusManager.instance.highlightStrategy;
    addTearDown(() {
      FocusManager.instance.highlightStrategy = previousStrategy;
    });
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    await tester.pumpWidget(
      metroTestApp(
        child: Center(
          child: MetroTile(title: 'Hover', onPressed: () {}),
        ),
      ),
    );

    final position = tester.getCenter(find.byType(MetroTile));
    await tester.sendEventToBinding(
      const PointerAddedEvent(kind: PointerDeviceKind.mouse),
    );
    await tester.sendEventToBinding(
      PointerHoverEvent(kind: PointerDeviceKind.mouse, position: position),
    );
    await tester.pump();

    final outline = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey<String>('metro-tile-outline')),
    );
    final decoration = outline.decoration as BoxDecoration;
    expect(decoration.border!.top.width, 4);
  });
}
