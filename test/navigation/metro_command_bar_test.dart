import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_ui/metro_ui.dart';

import '../test_utils.dart';

void main() {
  testWidgets('command activates by pointer and keyboard', (tester) async {
    var activations = 0;
    await tester.pumpWidget(
      metroTestApp(
        child: MetroCommandBar(
          commands: [
            MetroCommandButton(
              autofocus: true,
              icon: const SizedBox.square(dimension: 16),
              label: const Text('Save'),
              onPressed: () => activations += 1,
            ),
          ],
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(activations, 1);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(activations, 2);
  });

  testWidgets('toggle command exposes selected semantics', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      metroTestApp(
        child: MetroCommandBar(
          commands: [
            MetroCommandButton(
              icon: const SizedBox.square(dimension: 16),
              label: const Text('Favorite'),
              onPressed: () {},
              selected: true,
              semanticLabel: 'Favorite item',
            ),
          ],
        ),
      ),
    );

    expect(
      tester.getSemantics(find.byType(MetroCommandButton)),
      matchesSemantics(
        label: 'Favorite item',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasToggledState: true,
        isToggled: true,
        hasTapAction: true,
        isFocusable: true,
        hasFocusAction: true,
      ),
    );
    semantics.dispose();
  });

  testWidgets('commands remain ordered and align to the trailing edge', (
    tester,
  ) async {
    await tester.pumpWidget(
      metroTestApp(
        mediaQueryData: const MediaQueryData(size: Size(240, 240)),
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 240,
            child: MetroCommandBar(
              commands: [
                for (var index = 0; index < 6; index++)
                  MetroCommandButton(
                    key: Key('command-$index'),
                    icon: const SizedBox.square(dimension: 16),
                    label: Text('$index'),
                    onPressed: () {},
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    final first = tester.getRect(find.byKey(const Key('command-0')));
    final last = tester.getRect(find.byKey(const Key('command-5')));
    expect(first.left, lessThan(last.left));
    expect(last.right, closeTo(224, 0.01));
    expect(first.left, lessThan(16));
  });

  testWidgets('widget button style overrides local command bar theme', (
    tester,
  ) async {
    const localColor = Color(0xFF123456);
    const widgetColor = Color(0xFF654321);
    await tester.pumpWidget(
      metroTestApp(
        child: MetroCommandBarTheme(
          data: const MetroCommandBarThemeData(
            buttonStyle: MetroCommandButtonStyle(
              borderColor: WidgetStatePropertyAll(localColor),
            ),
          ),
          child: MetroCommandBar(
            commands: [
              MetroCommandButton(
                icon: const SizedBox.square(dimension: 16),
                label: const Text('Local'),
                onPressed: () {},
              ),
              MetroCommandButton(
                icon: const SizedBox.square(dimension: 16),
                label: const Text('Widget'),
                onPressed: () {},
                style: const MetroCommandButtonStyle(
                  borderColor: WidgetStatePropertyAll(widgetColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final containers = tester.widgetList<AnimatedContainer>(
      find.descendant(
        of: find.byType(MetroCommandBar),
        matching: find.byType(AnimatedContainer),
      ),
    );
    final decorations = containers
        .map((container) => container.decoration! as BoxDecoration)
        .toList();
    expect(decorations[0].border!.top.color, localColor);
    expect(decorations[1].border!.top.color, widgetColor);
  });
}
