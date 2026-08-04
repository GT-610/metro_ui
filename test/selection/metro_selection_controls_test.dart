import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_ui/metro_ui.dart';

import '../test_utils.dart';

void main() {
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
