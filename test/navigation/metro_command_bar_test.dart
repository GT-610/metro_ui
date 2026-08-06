import 'package:flutter/gestures.dart';
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
    expect(last.right, closeTo(230, 0.01));
    expect(first.left, lessThan(10));
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

  testWidgets('command bar layer toggles from secondary click and overlays', (
    tester,
  ) async {
    final changes = <bool>[];
    var contentTaps = 0;
    await tester.pumpWidget(
      metroTestApp(
        child: MetroCommandBarLayer(
          onOpenChanged: changes.add,
          commandBar: const SizedBox(
            key: Key('bar'),
            height: 80,
            child: ColoredBox(color: Color(0xFF000000)),
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => contentTaps += 1,
            child: const ColoredBox(
              key: Key('content'),
              color: Color(0xFFFFFFFF),
            ),
          ),
        ),
      ),
    );

    expect(_barTranslation(tester).dy, 1);
    expect(find.byKey(const Key('bar')).hitTestable(), findsNothing);

    await tester.tapAt(const Offset(400, 300), buttons: kSecondaryMouseButton);
    await tester.pump();

    expect(changes, [true]);
    await tester.pump(const Duration(milliseconds: 183));
    expect(_barTranslation(tester).dy, inExclusiveRange(0, 1));
    await tester.pump(const Duration(milliseconds: 184));
    expect(_barTranslation(tester), Offset.zero);
    expect(find.byKey(const Key('bar')).hitTestable(), findsOneWidget);

    await tester.tapAt(const Offset(400, 100));
    await tester.pump();
    expect(changes, [true, false]);
    expect(contentTaps, 0);
    await tester.pump(const Duration(milliseconds: 367));
    expect(_barTranslation(tester).dy, 1);
  });

  testWidgets('controlled layer waits for the owner to accept a request', (
    tester,
  ) async {
    var open = false;
    var requests = 0;
    await tester.pumpWidget(
      metroTestApp(
        child: MetroCommandBarLayer(
          open: open,
          onOpenChanged: (value) => requests += 1,
          commandBar: const SizedBox(height: 80),
          child: const SizedBox.expand(),
        ),
      ),
    );

    await tester.tapAt(const Offset(400, 300), buttons: kSecondaryMouseButton);
    await tester.pump(const Duration(milliseconds: 367));

    expect(requests, 1);
    expect(_barTranslation(tester).dy, 1);

    open = true;
    await tester.pumpWidget(
      metroTestApp(
        child: MetroCommandBarLayer(
          open: open,
          onOpenChanged: (value) => requests += 1,
          commandBar: const SizedBox(height: 80),
          child: const SizedBox.expand(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 367));

    expect(_barTranslation(tester), Offset.zero);
  });

  testWidgets('top placement mirrors the edge motion', (tester) async {
    await tester.pumpWidget(
      metroTestApp(
        child: const MetroCommandBarLayer(
          placement: MetroCommandBarPlacement.top,
          commandBar: SizedBox(height: 80),
          child: SizedBox.expand(),
        ),
      ),
    );

    expect(_barTranslation(tester).dy, -1);
  });

  testWidgets('edge swipes open and close the command surface', (tester) async {
    final changes = <bool>[];
    await tester.pumpWidget(
      metroTestApp(
        child: MetroCommandBarLayer(
          onOpenChanged: changes.add,
          commandBar: const SizedBox(height: 80),
          child: const SizedBox.expand(),
        ),
      ),
    );

    await tester.dragFrom(const Offset(400, 599), const Offset(0, -48));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 367));

    expect(changes, [true]);
    expect(_barTranslation(tester), Offset.zero);

    await tester.dragFrom(const Offset(400, 535), const Offset(0, 60));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 367));

    expect(changes, [true, false]);
    expect(_barTranslation(tester).dy, 1);
  });

  testWidgets('Escape dismisses an open command bar layer', (tester) async {
    final changes = <bool>[];
    await tester.pumpWidget(
      metroTestApp(
        child: MetroCommandBarLayer(
          initiallyOpen: true,
          onOpenChanged: changes.add,
          commandBar: MetroCommandBar(
            commands: [
              MetroCommandButton(
                autofocus: true,
                icon: const SizedBox.square(dimension: 16),
                label: const Text('Dismiss'),
                onPressed: () {},
              ),
            ],
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();

    expect(changes, [false]);
  });

  testWidgets('reduced motion commits edge visibility immediately', (
    tester,
  ) async {
    await tester.pumpWidget(
      metroTestApp(
        mediaQueryData: const MediaQueryData(
          size: Size(800, 600),
          disableAnimations: true,
        ),
        child: const MetroCommandBarLayer(
          initiallyOpen: true,
          commandBar: SizedBox(height: 80),
          child: SizedBox.expand(),
        ),
      ),
    );

    expect(_barTranslation(tester), Offset.zero);
  });
}

Offset _barTranslation(WidgetTester tester) {
  return tester
      .widget<FractionalTranslation>(find.byType(FractionalTranslation))
      .translation;
}
