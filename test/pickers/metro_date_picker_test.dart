import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_ui/metro_ui.dart';

import 'picker_test_utils.dart';

void main() {
  test('date field order follows common locale conventions', () {
    expect(metroDatePickerFieldOrderForLocale(const Locale('en', 'US')), const [
      MetroDatePickerField.month,
      MetroDatePickerField.day,
      MetroDatePickerField.year,
    ]);
    expect(metroDatePickerFieldOrderForLocale(const Locale('zh', 'CN')), const [
      MetroDatePickerField.year,
      MetroDatePickerField.month,
      MetroDatePickerField.day,
    ]);
    expect(metroDatePickerFieldOrderForLocale(const Locale('fr', 'FR')), const [
      MetroDatePickerField.day,
      MetroDatePickerField.month,
      MetroDatePickerField.year,
    ]);
  });

  testWidgets('date field respects explicit ordering and formatters', (
    tester,
  ) async {
    await tester.pumpWidget(
      pickerTestApp(
        child: MetroDatePicker(
          selected: DateTime(2024, 7, 9),
          onChanged: (_) {},
          fieldOrder: const [
            MetroDatePickerField.year,
            MetroDatePickerField.month,
            MetroDatePickerField.day,
          ],
          monthFormatter: (context, value) => 'M$value',
          semanticLabel: 'Departure date',
        ),
      ),
    );

    final yearX = tester.getCenter(find.text('2024')).dx;
    final monthX = tester.getCenter(find.text('M7')).dx;
    final dayX = tester.getCenter(find.text('09')).dx;
    expect(yearX, lessThan(monthX));
    expect(monthX, lessThan(dayX));
    expect(find.bySemanticsLabel('Departure date'), findsOneWidget);
  });

  testWidgets('date field lays out with finite height inside a Wrap', (
    tester,
  ) async {
    await tester.pumpWidget(
      pickerTestApp(
        child: Wrap(
          children: [
            SizedBox(
              width: 320,
              child: MetroDatePicker(
                selected: DateTime(2024, 7, 9),
                onChanged: (_) {},
              ),
            ),
          ],
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    final size = tester.getSize(find.byType(MetroDatePicker));
    expect(size.width, 320);
    expect(size.height.isFinite, isTrue);
    expect(size.height, inInclusiveRange(44, 48));
  });

  testWidgets('date dialog clamps the day when the month changes', (
    tester,
  ) async {
    DateTime? selected;
    await tester.pumpWidget(
      pickerTestApp(
        child: MetroDatePicker(
          selected: DateTime(2024, 1, 31),
          firstDate: DateTime(2024),
          lastDate: DateTime(2025, 12, 31),
          onChanged: (value) => selected = value,
          semanticLabel: 'Departure date',
        ),
      ),
    );

    await tester.tap(find.bySemanticsLabel('Departure date'));
    await tester.pumpAndSettle();
    expect(find.text('SELECT DATE'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('DONE'));
    await tester.pumpAndSettle();

    expect(selected, DateTime(2024, 2, 29));
  });

  testWidgets('escape cancels a date selection', (tester) async {
    var cancellations = 0;
    await tester.pumpWidget(
      pickerTestApp(
        child: MetroDatePicker(
          selected: DateTime(2024, 7, 9),
          onChanged: (_) {},
          onCancel: () => cancellations += 1,
          semanticLabel: 'Cancelable date',
        ),
      ),
    );

    await tester.tap(find.bySemanticsLabel('Cancelable date'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(cancellations, 1);
    expect(find.text('SELECT DATE'), findsNothing);
  });

  testWidgets('local picker theme reaches the date dialog', (tester) async {
    const selectedColor = Color(0xFF123456);
    await tester.pumpWidget(
      pickerTestApp(
        child: MetroPickerTheme(
          data: const MetroPickerThemeData(
            selectedBackgroundColor: selectedColor,
          ),
          child: MetroDatePicker(
            selected: DateTime(2024, 7, 9),
            onChanged: (_) {},
            semanticLabel: 'Themed date',
          ),
        ),
      ),
    );

    await tester.tap(find.bySemanticsLabel('Themed date'));
    await tester.pumpAndSettle();

    final selectedRows = tester.widgetList<AnimatedContainer>(
      find.descendant(
        of: find.byType(ListWheelScrollView),
        matching: find.byType(AnimatedContainer),
      ),
    );
    expect(
      selectedRows.any(
        (container) =>
            (container.decoration as BoxDecoration?)?.color == selectedColor,
      ),
      isTrue,
    );
  });
}
