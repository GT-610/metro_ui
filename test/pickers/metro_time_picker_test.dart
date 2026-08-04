import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_ui/metro_ui.dart';

import 'picker_test_utils.dart';

void main() {
  test('MetroTime is an immutable value object', () {
    expect(
      const MetroTime(hour: 9, minute: 30),
      const MetroTime(hour: 9, minute: 30),
    );
    expect(
      const MetroTime(hour: 9, minute: 30).copyWith(minute: 45),
      const MetroTime(hour: 9, minute: 45),
    );
  });

  testWidgets('24-hour field omits the day period', (tester) async {
    await tester.pumpWidget(
      pickerTestApp(
        child: MetroTimePicker(
          selected: const MetroTime(hour: 21, minute: 5),
          hourFormat: MetroHourFormat.twentyFourHour,
          onChanged: (_) {},
          semanticLabel: 'Meeting time',
        ),
      ),
    );

    expect(find.text('21'), findsOneWidget);
    expect(find.text('05'), findsOneWidget);
    expect(find.text('PM'), findsNothing);
    expect(find.bySemanticsLabel('Meeting time'), findsOneWidget);
  });

  testWidgets('time dialog supports keyboard columns and minute increments', (
    tester,
  ) async {
    MetroTime? selected;
    await tester.pumpWidget(
      pickerTestApp(
        child: MetroTimePicker(
          selected: const MetroTime(hour: 11, minute: 7),
          minuteIncrement: 15,
          onChanged: (value) => selected = value,
          semanticLabel: 'Meeting time',
        ),
      ),
    );

    await tester.tap(find.bySemanticsLabel('Meeting time'));
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();

    await tester.tap(find.text('DONE'));
    await tester.pumpAndSettle();
    expect(selected, const MetroTime(hour: 12, minute: 15));
  });

  testWidgets('disabled time picker exposes disabled button semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      pickerTestApp(
        child: const MetroTimePicker(
          selected: MetroTime(hour: 9, minute: 30),
          onChanged: null,
          semanticLabel: 'Unavailable time',
        ),
      ),
    );

    expect(
      tester.getSemantics(find.bySemanticsLabel('Unavailable time')),
      matchesSemantics(
        label: 'Unavailable time',
        isButton: true,
        hasEnabledState: true,
      ),
    );
    semantics.dispose();
  });

  testWidgets('reduced motion opens and adjusts without scheduled animation', (
    tester,
  ) async {
    await tester.pumpWidget(
      pickerTestApp(
        mediaQueryData: const MediaQueryData(
          size: Size(800, 600),
          disableAnimations: true,
        ),
        child: MetroTimePicker(
          selected: const MetroTime(hour: 9, minute: 30),
          onChanged: (_) {},
          semanticLabel: 'Reduced motion time',
        ),
      ),
    );

    await tester.tap(find.bySemanticsLabel('Reduced motion time'));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.pumpAndSettle();
    expect(tester.binding.hasScheduledFrame, isFalse);
  });
}
