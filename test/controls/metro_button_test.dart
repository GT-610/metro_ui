import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_ui/metro_ui.dart';

import '../test_utils.dart';

void main() {
  testWidgets('button activates by pointer and keyboard', (tester) async {
    var activations = 0;
    await tester.pumpWidget(
      metroTestApp(
        child: Center(
          child: MetroButton(
            autofocus: true,
            onPressed: () => activations += 1,
            child: const Text('OPEN'),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('OPEN'));
    await tester.pump();
    expect(activations, 1);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(activations, 2);

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(activations, 3);
  });

  testWidgets('disabled button exposes disabled semantics', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      metroTestApp(
        child: const Center(
          child: MetroButton(
            onPressed: null,
            semanticLabel: 'Unavailable action',
            child: Text('DISABLED'),
          ),
        ),
      ),
    );

    expect(
      tester.getSemantics(find.byType(MetroButton)),
      matchesSemantics(
        label: 'Unavailable action',
        isButton: true,
        hasEnabledState: true,
      ),
    );
    semantics.dispose();
  });

  testWidgets('standard button uses WinJS geometry and pressed inversion', (
    tester,
  ) async {
    await tester.pumpWidget(
      metroTestApp(
        child: Center(
          child: MetroButton(onPressed: () {}, child: const Text('OPEN')),
        ),
      ),
    );

    expect(tester.getSize(find.byType(MetroButton)), const Size(90, 32));
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(MetroButton)),
    );
    await tester.pump();
    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(MetroButton),
        matching: find.byType(Container),
      ),
    );
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, const Color(0xFF000000));
    final scale = tester.widget<AnimatedScale>(
      find.descendant(
        of: find.byType(MetroButton),
        matching: find.byKey(const ValueKey<String>('metro-button-scale')),
      ),
    );
    expect(scale.scale, 0.975);
    expect(scale.duration, const Duration(milliseconds: 167));
    await gesture.up();
  });

  testWidgets('button press motion can be styled and respects reduced motion', (
    tester,
  ) async {
    await tester.pumpWidget(
      metroTestApp(
        mediaQueryData: const MediaQueryData(
          size: Size(800, 600),
          disableAnimations: true,
        ),
        child: Center(
          child: MetroButton(
            onPressed: () {},
            style: const MetroButtonStyle(pressScale: 0.9),
            child: const Text('PRESS'),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(MetroButton)),
    );
    await tester.pump();

    final scale = tester.widget<AnimatedScale>(
      find.byKey(const ValueKey<String>('metro-button-scale')),
    );
    expect(scale.scale, 0.9);
    expect(scale.duration, Duration.zero);
    await gesture.up();
  });

  testWidgets('widget style overrides the component theme', (tester) async {
    const customColor = Color(0xFF123456);
    const localBorderColor = Color(0xFFABCDEF);
    await tester.pumpWidget(
      metroTestApp(
        theme: MetroThemeData.light().copyWith(
          buttonTheme: const MetroButtonThemeData(
            style: MetroButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Color(0xFF654321)),
            ),
          ),
        ),
        child: MetroButtonTheme(
          data: const MetroButtonThemeData(
            style: MetroButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Color(0xFF112233)),
              borderColor: WidgetStatePropertyAll(localBorderColor),
            ),
          ),
          child: Center(
            child: MetroButton(
              onPressed: () {},
              style: const MetroButtonStyle(
                backgroundColor: WidgetStatePropertyAll(customColor),
              ),
              child: const Text('CUSTOM'),
            ),
          ),
        ),
      ),
    );

    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(MetroButton),
        matching: find.byType(Container),
      ),
    );
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, customColor);
    expect(decoration.border!.top.color, localBorderColor);
  });

  testWidgets('icon button requires and exposes an accessible name', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      metroTestApp(
        child: Center(
          child: MetroIconButton(
            icon: const SizedBox.square(dimension: 16),
            onPressed: () {},
            semanticLabel: 'Settings',
          ),
        ),
      ),
    );

    expect(
      tester.getSemantics(find.byType(MetroIconButton)),
      matchesSemantics(
        label: 'Settings',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
        isFocusable: true,
        hasFocusAction: true,
      ),
    );
    semantics.dispose();
  });
}
