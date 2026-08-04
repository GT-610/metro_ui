import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_ui/metro_ui.dart';

import '../test_utils.dart';

void main() {
  test('single controller replaces its value and can require a selection', () {
    final controller = MetroSelectionController<int>(
      allowEmptySelection: false,
      selectedValues: const [1],
    );
    addTearDown(controller.dispose);

    expect(controller.select(2), isTrue);
    expect(controller.selectedValues, {2});
    expect(controller.deselect(2), isFalse);
    expect(controller.clear(), isFalse);
  });

  test('multiple controller enforces its maximum selection count', () {
    final controller = MetroSelectionController<int>(
      mode: MetroSelectionMode.multiple,
      maxSelectionCount: 2,
    );
    addTearDown(controller.dispose);

    expect(controller.selectAll(const [1, 2, 3]), isTrue);
    expect(controller.selectedValues, {1, 2});
    expect(controller.select(3), isFalse);
    expect(controller.toggle(1), isTrue);
    expect(controller.select(3), isTrue);
    expect(controller.selectedValues, {2, 3});
  });

  testWidgets('radio buttons consume a single selection group', (tester) async {
    final controller = MetroSelectionController<int>(selectedValues: const [1]);
    addTearDown(controller.dispose);
    Set<int>? lastSelection;
    await tester.pumpWidget(
      metroTestApp(
        child: MetroSelectionGroup<int>(
          controller: controller,
          onChanged: (values) => lastSelection = values,
          child: const Row(
            children: [
              MetroRadioButton<int>(value: 1, label: Text('One')),
              MetroRadioButton<int>(value: 2, label: Text('Two')),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('Two'));
    await tester.pump();
    expect(controller.selectedValue, 2);
    expect(lastSelection, {2});
  });

  testWidgets('selectable list tile supports multi-select semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final controller = MetroSelectionController<String>(
      mode: MetroSelectionMode.multiple,
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      metroTestApp(
        child: MetroSelectionGroup<String>(
          controller: controller,
          child: const Column(
            children: [
              MetroSelectableListTile<String>(
                value: 'documents',
                title: Text('Documents'),
                semanticLabel: 'Select documents',
              ),
              MetroSelectableListTile<String>(
                autofocus: true,
                value: 'pictures',
                title: Text('Pictures'),
                semanticLabel: 'Select pictures',
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    await tester.tap(find.text('Documents'));
    await tester.pump();

    expect(controller.selectedValues, {'documents', 'pictures'});
    final documents = tester.getSemantics(
      find.bySemanticsLabel('Select documents'),
    );
    expect(
      documents,
      containsMetroSemantics(
        hasSelectedState: true,
        isSelected: true,
        hasCheckedState: true,
        isChecked: true,
      ),
    );
    semantics.dispose();
  });
}
