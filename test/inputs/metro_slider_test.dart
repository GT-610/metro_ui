import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_ui/metro_ui.dart';

import '../test_utils.dart';

void main() {
  test('range values use value semantics', () {
    expect(const MetroRangeValues(2, 8), const MetroRangeValues(2, 8));
    expect(
      const MetroRangeValues(2, 8).copyWith(start: 3),
      const MetroRangeValues(3, 8),
    );
  });

  testWidgets('default slider geometry matches WinJS desktop range input', (
    tester,
  ) async {
    await tester.pumpWidget(
      metroTestApp(
        child: const Center(
          child: SizedBox(
            width: 280,
            child: MetroSlider(value: 0.5, onChanged: null),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(MetroSlider)), const Size(280, 60));
  });

  testWidgets('vertical slider uses WinJS cross extent and minimum length', (
    tester,
  ) async {
    await tester.pumpWidget(
      metroTestApp(
        child: const Center(
          child: SizedBox(
            height: 191,
            child: MetroSlider(
              axis: Axis.vertical,
              value: 0.5,
              onChanged: null,
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(MetroSlider)), const Size(45, 191));
  });

  testWidgets('slider changes from pointer and snaps to divisions', (
    tester,
  ) async {
    var value = 0.0;
    await tester.pumpWidget(
      metroTestApp(
        child: StatefulBuilder(
          builder: (context, setState) {
            return Center(
              child: SizedBox(
                width: 210,
                child: MetroSlider(
                  value: value,
                  max: 100,
                  divisions: 10,
                  onChanged: (next) => setState(() => value = next),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tapAt(tester.getCenter(find.byType(MetroSlider)));
    await tester.pump();

    expect(value, 50);
  });

  testWidgets('slider supports keyboard steps and range endpoints', (
    tester,
  ) async {
    var value = 50.0;
    await tester.pumpWidget(
      metroTestApp(
        child: StatefulBuilder(
          builder: (context, setState) {
            return Center(
              child: SizedBox(
                width: 240,
                child: MetroSlider(
                  autofocus: true,
                  value: value,
                  max: 100,
                  smallChange: 5,
                  largeChange: 20,
                  onChanged: (next) => setState(() => value = next),
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(value, 55);

    await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
    await tester.pump();
    expect(value, 75);

    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pump();
    expect(value, 0);

    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pump();
    expect(value, 100);
  });

  testWidgets('horizontal keyboard direction follows RTL geometry', (
    tester,
  ) async {
    var value = 50.0;
    await tester.pumpWidget(
      metroTestApp(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Center(
                child: SizedBox(
                  width: 240,
                  child: MetroSlider(
                    autofocus: true,
                    value: value,
                    max: 100,
                    smallChange: 5,
                    onChanged: (next) => setState(() => value = next),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();

    expect(value, 45);
  });

  testWidgets('vertical slider increases toward the top', (tester) async {
    var value = 0.0;
    await tester.pumpWidget(
      metroTestApp(
        child: StatefulBuilder(
          builder: (context, setState) {
            return Center(
              child: SizedBox(
                height: 210,
                child: MetroSlider(
                  axis: Axis.vertical,
                  value: value,
                  max: 100,
                  divisions: 10,
                  onChanged: (next) => setState(() => value = next),
                ),
              ),
            );
          },
        ),
      ),
    );

    final rect = tester.getRect(find.byType(MetroSlider));
    await tester.tapAt(Offset(rect.center.dx, rect.top + 5));
    await tester.pump();

    expect(value, 100);
  });

  testWidgets('slider exposes adjustable disabled semantics', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      metroTestApp(
        child: const Center(
          child: SizedBox(
            width: 240,
            child: MetroSlider(
              value: 40,
              max: 100,
              onChanged: null,
              semanticLabel: 'Volume',
            ),
          ),
        ),
      ),
    );

    expect(
      tester.getSemantics(find.bySemanticsLabel('Volume')),
      matchesSemantics(
        label: 'Volume',
        value: '40',
        increasedValue: '45',
        decreasedValue: '35',
        hasEnabledState: true,
        isSlider: true,
      ),
    );
    semantics.dispose();
  });

  testWidgets('widget style overrides a local slider theme', (tester) async {
    await tester.pumpWidget(
      metroTestApp(
        child: Center(
          child: MetroSliderTheme(
            data: const MetroSliderThemeData(
              style: MetroSliderStyle(minimumInteractiveExtent: 60),
            ),
            child: SizedBox(
              width: 240,
              child: MetroSlider(
                value: 0.5,
                onChanged: (_) {},
                style: const MetroSliderStyle(minimumInteractiveExtent: 52),
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(MetroSlider)).height, 52);
  });

  testWidgets('range slider keyboard adjusts independent thumbs', (
    tester,
  ) async {
    final startFocusNode = FocusNode();
    final endFocusNode = FocusNode();
    var values = const MetroRangeValues(20, 80);
    await tester.pumpWidget(
      metroTestApp(
        child: StatefulBuilder(
          builder: (context, setState) {
            return Center(
              child: SizedBox(
                width: 260,
                child: MetroRangeSlider(
                  values: values,
                  max: 100,
                  divisions: 10,
                  startFocusNode: startFocusNode,
                  endFocusNode: endFocusNode,
                  onChanged: (next) => setState(() => values = next),
                ),
              ),
            );
          },
        ),
      ),
    );

    startFocusNode.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(values, const MetroRangeValues(30, 80));

    endFocusNode.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(values, const MetroRangeValues(30, 70));

    startFocusNode.dispose();
    endFocusNode.dispose();
  });

  testWidgets('range slider enforces minimum range', (tester) async {
    final startFocusNode = FocusNode();
    final endFocusNode = FocusNode();
    var values = const MetroRangeValues(40, 60);
    await tester.pumpWidget(
      metroTestApp(
        child: StatefulBuilder(
          builder: (context, setState) {
            return Center(
              child: SizedBox(
                width: 260,
                child: MetroRangeSlider(
                  values: values,
                  max: 100,
                  divisions: 10,
                  minimumRange: 20,
                  startFocusNode: startFocusNode,
                  endFocusNode: endFocusNode,
                  onChanged: (next) => setState(() => values = next),
                ),
              ),
            );
          },
        ),
      ),
    );

    startFocusNode.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(values, const MetroRangeValues(40, 60));

    endFocusNode.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(values, const MetroRangeValues(40, 60));

    startFocusNode.dispose();
    endFocusNode.dispose();
  });

  testWidgets('range slider drags the selected segment', (tester) async {
    var values = const MetroRangeValues(20, 40);
    await tester.pumpWidget(
      metroTestApp(
        child: StatefulBuilder(
          builder: (context, setState) {
            return Center(
              child: SizedBox(
                width: 210,
                child: MetroRangeSlider(
                  values: values,
                  max: 100,
                  divisions: 10,
                  onChanged: (next) => setState(() => values = next),
                ),
              ),
            );
          },
        ),
      ),
    );

    final rect = tester.getRect(find.byType(MetroRangeSlider));
    await tester.dragFrom(
      Offset(rect.left + 65, rect.center.dy),
      const Offset(40, 0),
    );
    await tester.pump();

    expect(values, const MetroRangeValues(40, 60));
  });

  testWidgets('range slider exposes two adjustable semantic nodes', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      metroTestApp(
        child: Center(
          child: SizedBox(
            width: 260,
            child: MetroRangeSlider(
              values: const MetroRangeValues(20, 80),
              max: 100,
              onChanged: (_) {},
              startSemanticLabel: 'Minimum temperature',
              endSemanticLabel: 'Maximum temperature',
            ),
          ),
        ),
      ),
    );

    expect(
      tester.getSemantics(find.bySemanticsLabel('Minimum temperature')),
      matchesSemantics(
        label: 'Minimum temperature',
        value: '20',
        increasedValue: '25',
        decreasedValue: '15',
        hasEnabledState: true,
        isEnabled: true,
        isSlider: true,
        hasIncreaseAction: true,
        hasDecreaseAction: true,
        isFocusable: true,
        hasFocusAction: true,
      ),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Maximum temperature')),
      matchesSemantics(
        label: 'Maximum temperature',
        value: '80',
        increasedValue: '85',
        decreasedValue: '75',
        hasEnabledState: true,
        isEnabled: true,
        isSlider: true,
        hasIncreaseAction: true,
        hasDecreaseAction: true,
        isFocusable: true,
        hasFocusAction: true,
      ),
    );
    semantics.dispose();
  });
}
