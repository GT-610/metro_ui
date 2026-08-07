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
}
