import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_ui/metro_ui.dart';

import '../test_utils.dart';

void main() {
  testWidgets('toggle changes by pointer and keyboard', (tester) async {
    var value = false;
    await tester.pumpWidget(
      metroTestApp(
        child: StatefulBuilder(
          builder: (context, setState) {
            return Center(
              child: MetroToggleSwitch(
                autofocus: true,
                label: const Text('Wi-Fi'),
                value: value,
                onChanged: (next) => setState(() => value = next),
              ),
            );
          },
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Wi-Fi'));
    await tester.pump();
    expect(value, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(value, isFalse);
  });

  testWidgets('toggle exposes toggled semantics', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      metroTestApp(
        child: Center(
          child: MetroToggleSwitch(
            value: true,
            onChanged: (_) {},
            semanticLabel: 'Airplane mode',
          ),
        ),
      ),
    );

    expect(
      tester.getSemantics(find.byType(MetroToggleSwitch)),
      matchesSemantics(
        label: 'Airplane mode',
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

  testWidgets('toggle uses the WinJS track, thumb, and timing', (tester) async {
    await tester.pumpWidget(
      metroTestApp(
        child: Center(child: MetroToggleSwitch(value: true, onChanged: (_) {})),
      ),
    );

    final track = tester.widget<AnimatedContainer>(
      find.descendant(
        of: find.byType(MetroToggleSwitch),
        matching: find.byType(AnimatedContainer),
      ),
    );
    final thumb = tester.widget<AnimatedPositionedDirectional>(
      find.descendant(
        of: find.byType(MetroToggleSwitch),
        matching: find.byType(AnimatedPositionedDirectional),
      ),
    );
    expect(
      tester.getSize(
        find.descendant(
          of: find.byType(MetroToggleSwitch),
          matching: find.byType(AnimatedContainer),
        ),
      ),
      const Size(50, 19),
    );
    expect(track.duration, const Duration(milliseconds: 100));
    expect(thumb.curve, MetroThemeData.light().motion.standardCurve);
    expect(thumb.width, 12);
    expect(thumb.height, 19);
    expect(thumb.start, 38);
  });

  testWidgets('local toggle theme overrides track geometry', (tester) async {
    await tester.pumpWidget(
      metroTestApp(
        child: Center(
          child: MetroToggleSwitchTheme(
            data: const MetroToggleSwitchThemeData(
              style: MetroToggleSwitchStyle(trackSize: Size(64, 28)),
            ),
            child: MetroToggleSwitch(value: true, onChanged: (_) {}),
          ),
        ),
      ),
    );

    expect(
      tester.getSize(
        find.descendant(
          of: find.byType(MetroToggleSwitch),
          matching: find.byType(AnimatedContainer),
        ),
      ),
      const Size(64, 28),
    );
  });
}
