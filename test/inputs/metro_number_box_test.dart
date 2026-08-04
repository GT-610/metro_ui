import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_ui/metro_ui.dart';

void main() {
  testWidgets('spin buttons change a controlled value and honor bounds', (
    tester,
  ) async {
    var value = 5;
    var changes = 0;
    await tester.pumpWidget(
      _numberBoxTestApp(
        child: StatefulBuilder(
          builder: (context, setState) {
            return Center(
              child: SizedBox(
                width: 260,
                child: MetroNumberBox<int>(
                  value: value,
                  min: 4,
                  max: 6,
                  onChanged: (next) {
                    changes += 1;
                    setState(() => value = next!);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );

    final increment = find.byKey(
      const ValueKey<String>('metro-number-box-increment'),
    );
    final decrement = find.byKey(
      const ValueKey<String>('metro-number-box-decrement'),
    );
    await tester.tap(increment);
    await tester.pump();
    expect(value, 6);

    await tester.tap(increment);
    await tester.pump();
    expect(value, 6);
    expect(changes, 1);

    await tester.tap(decrement);
    await tester.pump();
    await tester.tap(decrement);
    await tester.pump();
    expect(value, 4);

    await tester.tap(decrement);
    await tester.pump();
    expect(value, 4);
    expect(changes, 3);
  });

  testWidgets('typed values commit with snapping and clamping', (tester) async {
    var value = 2;
    await tester.pumpWidget(
      _numberBoxTestApp(
        child: StatefulBuilder(
          builder: (context, setState) {
            return Center(
              child: SizedBox(
                width: 260,
                child: MetroNumberBox<int>(
                  value: value,
                  min: 2,
                  max: 11,
                  smallChange: 3,
                  largeChange: 6,
                  snapToStep: true,
                  onChanged: (next) => setState(() => value = next!),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.enterText(find.byType(EditableText), '9');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(value, 8);
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).controller.text,
      '8',
    );

    await tester.enterText(find.byType(EditableText), '99');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(value, 11);
  });

  testWidgets('the application remains authoritative after a request', (
    tester,
  ) async {
    int? requested;
    await tester.pumpWidget(
      _numberBoxTestApp(
        child: Center(
          child: SizedBox(
            width: 260,
            child: MetroNumberBox<int>(
              value: 2,
              onChanged: (next) => requested = next,
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(EditableText), '9');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(requested, 9);
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).controller.text,
      '2',
    );
  });

  testWidgets('focus loss commits text and an empty nullable draft', (
    tester,
  ) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    int? value = 3;
    await tester.pumpWidget(
      _numberBoxTestApp(
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              children: [
                SizedBox(
                  width: 260,
                  child: MetroNumberBox<int>(
                    autofocus: true,
                    focusNode: focusNode,
                    value: value,
                    semanticLabel: 'Quantity',
                    onChanged: (next) => setState(() => value = next),
                  ),
                ),
                MetroButton(onPressed: () {}, child: const Text('Outside')),
              ],
            );
          },
        ),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(EditableText), '7');
    await tester.tap(find.text('Outside'));
    await tester.pump();
    expect(value, 7);

    await tester.tap(find.byType(EditableText));
    await tester.enterText(find.byType(EditableText), '');
    await tester.tap(find.text('Outside'));
    await tester.pump();
    expect(value, isNull);
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('Quantity'))
          .getSemanticsData()
          .value,
      'No value',
    );
  });

  testWidgets('integer boxes reject fractions and restore their value', (
    tester,
  ) async {
    String? invalidText;
    await tester.pumpWidget(
      _numberBoxTestApp(
        child: Center(
          child: SizedBox(
            width: 260,
            child: MetroNumberBox<int>(
              value: 3,
              onChanged: (_) {},
              onInvalidInput: (text) => invalidText = text,
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(EditableText), '3.5');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(invalidText, '3.5');
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).controller.text,
      '3',
    );
  });

  testWidgets('invalid draft text can remain visible until corrected', (
    tester,
  ) async {
    var value = 4;
    await tester.pumpWidget(
      _numberBoxTestApp(
        child: StatefulBuilder(
          builder: (context, setState) {
            return Center(
              child: SizedBox(
                width: 260,
                child: MetroNumberBox<int>(
                  value: value,
                  invalidInputBehavior:
                      MetroNumberBoxInvalidInputBehavior.keepText,
                  onChanged: (next) => setState(() => value = next!),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.enterText(find.byType(EditableText), 'not a number');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(
      tester
          .widget<MetroTextField>(find.byType(MetroTextField))
          .validationState,
      MetroTextFieldValidationState.error,
    );
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).controller.text,
      'not a number',
    );

    await tester.enterText(find.byType(EditableText), '7');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(value, 7);
    expect(
      tester
          .widget<MetroTextField>(find.byType(MetroTextField))
          .validationState,
      MetroTextFieldValidationState.none,
    );
  });

  testWidgets('custom parsers and formatters support domain-specific text', (
    tester,
  ) async {
    var value = 1.5;
    await tester.pumpWidget(
      _numberBoxTestApp(
        child: StatefulBuilder(
          builder: (context, setState) {
            return Center(
              child: SizedBox(
                width: 260,
                child: MetroNumberBox<double>(
                  value: value,
                  formatter: (current) =>
                      current == null ? '' : '${current.toStringAsFixed(1)} kg',
                  parser: (text) => double.tryParse(
                    text.replaceAll(',', '.').replaceAll('kg', '').trim(),
                  ),
                  onChanged: (next) => setState(() => value = next!),
                ),
              ),
            );
          },
        ),
      ),
    );

    expect(
      tester.widget<EditableText>(find.byType(EditableText)).controller.text,
      '1.5 kg',
    );
    await tester.enterText(find.byType(EditableText), '2,75');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(value, 2.75);
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).controller.text,
      '2.8 kg',
    );
  });

  testWidgets('keyboard commands apply small, large, and boundary changes', (
    tester,
  ) async {
    var value = 2;
    await tester.pumpWidget(
      _numberBoxTestApp(
        child: StatefulBuilder(
          builder: (context, setState) {
            return Center(
              child: SizedBox(
                width: 260,
                child: MetroNumberBox<int>(
                  autofocus: true,
                  value: value,
                  min: 0,
                  max: 20,
                  onChanged: (next) => setState(() => value = next!),
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(value, 3);

    await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
    await tester.pump();
    expect(value, 13);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(value, 12);

    await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
    await tester.pump();
    expect(value, 2);

    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pump();
    expect(value, 20);

    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pump();
    expect(value, 0);
  });

  testWidgets('the focused field responds to the mouse wheel', (tester) async {
    var value = 5;
    await tester.pumpWidget(
      _numberBoxTestApp(
        child: StatefulBuilder(
          builder: (context, setState) {
            return Center(
              child: SizedBox(
                width: 260,
                child: MetroNumberBox<int>(
                  autofocus: true,
                  value: value,
                  onChanged: (next) => setState(() => value = next!),
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pump();

    await tester.sendEventToBinding(
      PointerScrollEvent(
        position: tester.getCenter(find.byType(MetroNumberBox<int>)),
        scrollDelta: const Offset(0, -20),
      ),
    );
    await tester.pump();
    expect(value, 6);

    await tester.sendEventToBinding(
      PointerScrollEvent(
        position: tester.getCenter(find.byType(MetroNumberBox<int>)),
        scrollDelta: const Offset(0, 20),
      ),
    );
    await tester.pump();
    expect(value, 5);
  });

  testWidgets('holding a spin button repeats and release stops it', (
    tester,
  ) async {
    var value = 0;
    await tester.pumpWidget(
      _numberBoxTestApp(
        child: StatefulBuilder(
          builder: (context, setState) {
            return Center(
              child: SizedBox(
                width: 260,
                child: MetroNumberBox<int>(
                  value: value,
                  repeatDelay: const Duration(milliseconds: 100),
                  repeatInterval: const Duration(milliseconds: 50),
                  onChanged: (next) => setState(() => value = next!),
                ),
              ),
            );
          },
        ),
      ),
    );

    final increment = find.byKey(
      const ValueKey<String>('metro-number-box-increment'),
    );
    final gesture = await tester.startGesture(tester.getCenter(increment));
    await tester.pump();
    expect(value, 1);

    await tester.pump(const Duration(milliseconds: 220));
    expect(value, greaterThanOrEqualTo(4));

    await gesture.up();
    await tester.pump();
    final releasedValue = value;
    await tester.pump(const Duration(milliseconds: 250));
    expect(value, releasedValue);
  });

  testWidgets('widget style wins and reduced motion removes button animation', (
    tester,
  ) async {
    await tester.pumpWidget(
      _numberBoxTestApp(
        mediaQueryData: const MediaQueryData(
          disableAnimations: true,
          size: Size(800, 600),
        ),
        theme: MetroThemeData.light().copyWith(
          numberBoxTheme: const MetroNumberBoxThemeData(
            style: MetroNumberBoxStyle(buttonExtent: 60),
          ),
        ),
        child: Center(
          child: MetroNumberBoxTheme(
            data: const MetroNumberBoxThemeData(
              style: MetroNumberBoxStyle(buttonExtent: 56),
            ),
            child: SizedBox(
              width: 280,
              child: MetroNumberBox<int>(
                value: 4,
                style: const MetroNumberBoxStyle(buttonExtent: 52),
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    final buttonAnimation = tester.widget<AnimatedContainer>(
      find.descendant(
        of: find.byKey(const ValueKey<String>('metro-number-box-increment')),
        matching: find.byType(AnimatedContainer),
      ),
    );
    expect(buttonAnimation.duration, Duration.zero);
    expect(buttonAnimation.constraints?.minWidth, 52);
    expect(buttonAnimation.constraints?.minHeight, 52);
  });

  testWidgets('semantics expose value adjustment and disabled buttons', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _numberBoxTestApp(
        child: Center(
          child: SizedBox(
            width: 260,
            child: MetroNumberBox<int>(
              value: 4,
              onChanged: (_) {},
              semanticLabel: 'Quantity',
            ),
          ),
        ),
      ),
    );

    final adjustable = tester.getSemantics(find.bySemanticsLabel('Quantity'));
    final adjustableData = adjustable.getSemanticsData();
    expect(adjustableData.value, '4');
    expect(adjustableData.increasedValue, '5');
    expect(adjustableData.decreasedValue, '3');
    expect(adjustableData.hasAction(SemanticsAction.increase), isTrue);
    expect(adjustableData.hasAction(SemanticsAction.decrease), isTrue);

    await tester.pumpWidget(
      _numberBoxTestApp(
        child: const Center(
          child: SizedBox(
            width: 260,
            child: MetroNumberBox<int>(value: 4, onChanged: null),
          ),
        ),
      ),
    );
    final increment = tester.getSemantics(
      find.bySemanticsLabel('Increase value'),
    );
    final decrement = tester.getSemantics(
      find.bySemanticsLabel('Decrease value'),
    );
    expect(
      increment.getSemanticsData().hasAction(SemanticsAction.tap),
      isFalse,
    );
    expect(
      decrement.getSemanticsData().hasAction(SemanticsAction.tap),
      isFalse,
    );
    semantics.dispose();
  });

  test('built-in Chinese localization includes NumberBox strings', () {
    const localizations = MetroLocalizationsZh();

    expect(localizations.numberBoxIncrementLabel, '\u589e\u52a0\u6570\u503c');
    expect(localizations.numberBoxDecrementLabel, '\u51cf\u5c11\u6570\u503c');
    expect(localizations.numberBoxEmptyValueLabel, '\u65e0\u6570\u503c');
  });
}

Widget _numberBoxTestApp({
  required Widget child,
  MetroThemeData? theme,
  MediaQueryData mediaQueryData = const MediaQueryData(size: Size(800, 600)),
}) {
  return MediaQuery(
    data: mediaQueryData,
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: MetroTheme(data: theme ?? MetroThemeData.light(), child: child),
    ),
  );
}
