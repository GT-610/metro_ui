import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_ui/metro_ui.dart';

import '../test_utils.dart';

void main() {
  testWidgets('selection controls use WinJS desktop geometry and neutrals', (
    tester,
  ) async {
    await tester.pumpWidget(
      metroTestApp(
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MetroCheckBox(value: true, onChanged: (_) {}),
              const SizedBox(width: 16),
              MetroRadioButton<int>(value: 1, groupValue: 1, onChanged: (_) {}),
            ],
          ),
        ),
      ),
    );

    final checkFinder = find.byType(MetroCheckBox);
    final radioFinder = find.byType(MetroRadioButton<int>);
    final checkDecoration =
        tester
                .widget<DecoratedBox>(
                  find.descendant(
                    of: checkFinder,
                    matching: find.byType(DecoratedBox),
                  ),
                )
                .decoration
            as BoxDecoration;
    final radioDecoration =
        tester
                .widgetList<DecoratedBox>(
                  find.descendant(
                    of: radioFinder,
                    matching: find.byType(DecoratedBox),
                  ),
                )
                .first
                .decoration
            as BoxDecoration;

    expect(tester.getSize(checkFinder), const Size(21, 21));
    expect(tester.getSize(radioFinder), const Size(23, 23));
    expect(checkDecoration.color, const Color(0xCCFFFFFF));
    expect(checkDecoration.border!.top.color, const Color(0x45000000));
    expect(radioDecoration.color, const Color(0xCCFFFFFF));
    expect(radioDecoration.border!.top.color, const Color(0x45000000));
  });

  testWidgets('light selection controls invert immediately while pressed', (
    tester,
  ) async {
    await tester.pumpWidget(
      metroTestApp(
        child: Center(child: MetroCheckBox(value: true, onChanged: (_) {})),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(MetroCheckBox)),
    );
    await tester.pump();

    final decoration =
        tester
                .widget<DecoratedBox>(
                  find.descendant(
                    of: find.byType(MetroCheckBox),
                    matching: find.byType(DecoratedBox),
                  ),
                )
                .decoration
            as BoxDecoration;
    expect(decoration.color, const Color(0xFF000000));
    expect(decoration.border!.top.color, const Color(0x00000000));

    await gesture.up();
  });

  testWidgets('checkbox cycles by pointer and keyboard', (tester) async {
    bool? value = false;
    await tester.pumpWidget(
      metroTestApp(
        child: StatefulBuilder(
          builder: (context, setState) => Center(
            child: MetroCheckBox(
              autofocus: true,
              label: const Text('Sync'),
              value: value,
              onChanged: (next) => setState(() => value = next),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Sync'));
    await tester.pump();
    expect(value, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(value, isFalse);
  });

  testWidgets('tristate checkbox exposes mixed semantics', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      metroTestApp(
        child: const Center(
          child: MetroCheckBox(
            value: null,
            tristate: true,
            onChanged: null,
            semanticLabel: 'Select all',
          ),
        ),
      ),
    );
    expect(
      tester.getSemantics(find.byType(MetroCheckBox)),
      matchesSemantics(
        label: 'Select all',
        hasCheckedState: true,
        isCheckStateMixed: true,
        hasEnabledState: true,
      ),
    );
    semantics.dispose();
  });

  testWidgets('radio button reports and changes group value', (tester) async {
    var group = 1;
    await tester.pumpWidget(
      metroTestApp(
        child: StatefulBuilder(
          builder: (context, setState) => Center(
            child: MetroRadioButton<int>(
              value: 2,
              groupValue: group,
              label: const Text('Second'),
              onChanged: (next) => setState(() => group = next!),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Second'));
    await tester.pump();
    expect(group, 2);
  });

  testWidgets('selection controls consume their local component themes', (
    tester,
  ) async {
    await tester.pumpWidget(
      metroTestApp(
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MetroCheckBoxTheme(
                data: const MetroCheckBoxThemeData(
                  style: MetroSelectionControlStyle(size: 30),
                ),
                child: MetroCheckBox(value: true, onChanged: (_) {}),
              ),
              const SizedBox(width: 16),
              MetroRadioButtonTheme(
                data: const MetroRadioButtonThemeData(
                  style: MetroSelectionControlStyle(size: 34),
                ),
                child: MetroRadioButton<int>(
                  value: 1,
                  groupValue: 1,
                  onChanged: (_) {},
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(MetroCheckBox)).height, 30);
    expect(tester.getSize(find.byType(MetroRadioButton<int>)).height, 34);
  });
}
