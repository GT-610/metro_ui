import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_ui/metro_ui.dart';

import '../test_utils.dart';

void main() {
  testWidgets('back button uses Windows 8 geometry and activates', (
    tester,
  ) async {
    var activations = 0;
    await tester.pumpWidget(
      metroTestApp(
        child: Center(
          child: MetroBackButton(
            autofocus: true,
            onPressed: () => activations += 1,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.getSize(find.byType(MetroBackButton)), const Size(41, 41));
    await tester.tap(find.byType(MetroBackButton));
    await tester.pump();
    expect(activations, 1);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(activations, 2);
  });

  testWidgets('pressed back button inverts its surface', (tester) async {
    await tester.pumpWidget(
      metroTestApp(
        child: Center(child: MetroBackButton(onPressed: () {})),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(MetroBackButton)),
    );
    await tester.pump();
    final box = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(MetroBackButton),
        matching: find.byType(DecoratedBox),
      ),
    );
    expect((box.decoration as BoxDecoration).color, const Color(0xFF000000));
    await gesture.up();
  });

  testWidgets('disabled back button keeps space but hides semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      metroTestApp(
        child: const Center(child: MetroBackButton(onPressed: null)),
      ),
    );

    expect(tester.getSize(find.byType(MetroBackButton)), const Size(41, 41));
    expect(find.bySemanticsLabel('Back'), findsNothing);
    semantics.dispose();
  });

  testWidgets('application back-button theme overrides geometry', (
    tester,
  ) async {
    await tester.pumpWidget(
      metroTestApp(
        theme: MetroThemeData.light().copyWith(
          backButtonTheme: const MetroBackButtonThemeData(
            style: MetroBackButtonStyle(size: 45),
          ),
        ),
        child: Center(child: MetroBackButton(onPressed: () {})),
      ),
    );

    expect(tester.getSize(find.byType(MetroBackButton)), const Size(45, 45));
  });
}
