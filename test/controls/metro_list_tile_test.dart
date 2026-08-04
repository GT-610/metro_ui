import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_ui/metro_ui.dart';

import '../test_utils.dart';

void main() {
  testWidgets('list tile activates with keyboard', (tester) async {
    var count = 0;
    await tester.pumpWidget(
      metroTestApp(
        child: Center(
          child: SizedBox(
            width: 320,
            child: MetroListTile(
              autofocus: true,
              title: const Text('Documents'),
              onPressed: () => count += 1,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(count, 1);
  });

  testWidgets('selected list tile exposes selected semantics', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      metroTestApp(
        child: Center(
          child: SizedBox(
            width: 320,
            child: MetroListTile(
              selected: true,
              semanticLabel: 'Selected documents',
              title: const Text('Documents'),
              onPressed: () {},
            ),
          ),
        ),
      ),
    );
    expect(
      tester.getSemantics(find.byType(MetroListTile)),
      matchesSemantics(
        label: 'Selected documents',
        isButton: true,
        hasSelectedState: true,
        isSelected: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
        isFocusable: true,
        hasFocusAction: true,
      ),
    );
    semantics.dispose();
  });

  testWidgets('local list-tile theme overrides the application theme', (
    tester,
  ) async {
    const localColor = Color(0xFF123456);
    await tester.pumpWidget(
      metroTestApp(
        theme: MetroThemeData.light().copyWith(
          listTileTheme: const MetroListTileThemeData(
            style: MetroListTileStyle(
              backgroundColor: WidgetStatePropertyAll(Color(0xFF654321)),
            ),
          ),
        ),
        child: MetroListTileTheme(
          data: const MetroListTileThemeData(
            style: MetroListTileStyle(
              backgroundColor: WidgetStatePropertyAll(localColor),
            ),
          ),
          child: Center(
            child: SizedBox(
              width: 320,
              child: MetroListTile(
                title: const Text('Local'),
                onPressed: () {},
              ),
            ),
          ),
        ),
      ),
    );

    final container = tester.widget<AnimatedContainer>(
      find.descendant(
        of: find.byType(MetroListTile),
        matching: find.byType(AnimatedContainer),
      ),
    );
    expect((container.decoration! as BoxDecoration).color, localColor);
  });
}
