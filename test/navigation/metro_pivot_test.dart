import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_ui/metro_ui.dart';

import '../test_utils.dart';

void main() {
  Widget buildPivot({ValueChanged<int>? onChanged, bool autofocus = false}) {
    return metroTestApp(
      child: Center(
        child: SizedBox(
          width: 500,
          height: 300,
          child: MetroPivot(
            autofocus: autofocus,
            onChanged: onChanged,
            items: const [
              MetroPivotItem(
                header: Text('RECENT'),
                child: Center(child: Text('Recent content')),
              ),
              MetroPivotItem(
                header: Text('FAVORITES'),
                child: Center(child: Text('Favorite content')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('pivot changes page from its header', (tester) async {
    var index = 0;
    await tester.pumpWidget(buildPivot(onChanged: (next) => index = next));

    await tester.tap(find.text('FAVORITES'));
    await tester.pumpAndSettle();

    expect(index, 1);
    expect(find.text('Favorite content'), findsOneWidget);
  });

  testWidgets('arrow keys move between pivot items', (tester) async {
    var index = 0;
    await tester.pumpWidget(
      buildPivot(autofocus: true, onChanged: (next) => index = next),
    );
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump(const Duration(milliseconds: 700));

    expect(index, 1);
  });

  testWidgets('pivot headers expose button and selected semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(buildPivot());

    expect(
      tester.getSemantics(find.bySemanticsLabel('RECENT')),
      matchesSemantics(
        label: 'RECENT',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasSelectedState: true,
        isSelected: true,
        hasTapAction: true,
        isFocusable: true,
        hasFocusAction: true,
      ),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('FAVORITES')),
      matchesSemantics(
        label: 'FAVORITES',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasSelectedState: true,
        hasTapAction: true,
        isFocusable: true,
        hasFocusAction: true,
      ),
    );
    semantics.dispose();
  });

  testWidgets('local Pivot theme overrides application typography', (
    tester,
  ) async {
    const localColor = Color(0xFF123456);
    await tester.pumpWidget(
      metroTestApp(
        theme: MetroThemeData.light().copyWith(
          pivotTheme: const MetroPivotThemeData(
            selectedHeaderStyle: TextStyle(color: Color(0xFF654321)),
          ),
        ),
        child: Center(
          child: SizedBox(
            width: 500,
            height: 300,
            child: MetroPivotTheme(
              data: const MetroPivotThemeData(
                selectedHeaderStyle: TextStyle(color: localColor),
              ),
              child: MetroPivot(
                items: const [
                  MetroPivotItem(header: Text('LOCAL'), child: SizedBox()),
                  MetroPivotItem(header: Text('OTHER'), child: SizedBox()),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final selectedStyle = tester
        .widgetList<AnimatedDefaultTextStyle>(
          find.descendant(
            of: find.byType(MetroPivot),
            matching: find.byType(AnimatedDefaultTextStyle),
          ),
        )
        .first
        .style;
    expect(selectedStyle.color, localColor);
  });
}
