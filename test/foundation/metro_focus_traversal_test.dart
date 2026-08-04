import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_ui/metro_ui.dart';

void main() {
  testWidgets('desktop group lets Tab traversal continue to its parent', (
    tester,
  ) async {
    final first = FocusNode(debugLabel: 'first');
    final second = FocusNode(debugLabel: 'second');
    final after = FocusNode(debugLabel: 'after');
    addTearDown(first.dispose);
    addTearDown(second.dispose);
    addTearDown(after.dispose);

    await tester.pumpWidget(
      _focusTestApp(
        Column(
          children: [
            MetroFocusTraversalGroup(
              child: Row(
                children: [
                  MetroButton(
                    focusNode: first,
                    onPressed: () {},
                    child: const Text('First'),
                  ),
                  MetroButton(
                    focusNode: second,
                    onPressed: () {},
                    child: const Text('Second'),
                  ),
                ],
              ),
            ),
            MetroButton(
              focusNode: after,
              onPressed: () {},
              child: const Text('After'),
            ),
          ],
        ),
      ),
    );

    first.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(second.hasPrimaryFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(after.hasPrimaryFocus, isTrue);
  });

  testWidgets('spatial group follows geometry and preserves activation', (
    tester,
  ) async {
    final topLeft = FocusNode(debugLabel: 'top-left');
    final topRight = FocusNode(debugLabel: 'top-right');
    final bottomLeft = FocusNode(debugLabel: 'bottom-left');
    final bottomRight = FocusNode(debugLabel: 'bottom-right');
    addTearDown(topLeft.dispose);
    addTearDown(topRight.dispose);
    addTearDown(bottomLeft.dispose);
    addTearDown(bottomRight.dispose);
    String? activated;
    FocusScopeNode? scope;

    Widget button(String label, FocusNode node) {
      return SizedBox(
        width: 120,
        child: MetroButton(
          focusNode: node,
          onPressed: () => activated = label,
          child: Text(label),
        ),
      );
    }

    await tester.pumpWidget(
      _focusTestApp(
        MetroFocusTraversalGroup.spatial(
          child: Builder(
            builder: (context) {
              scope = FocusScope.of(context);
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      button('Top left', topLeft),
                      const SizedBox(width: 24),
                      button('Top right', topRight),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      button('Bottom left', bottomLeft),
                      const SizedBox(width: 24),
                      button('Bottom right', bottomRight),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );

    expect(scope!.traversalEdgeBehavior, TraversalEdgeBehavior.closedLoop);
    expect(
      scope!.directionalTraversalEdgeBehavior,
      TraversalEdgeBehavior.closedLoop,
    );

    topLeft.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(topRight.hasPrimaryFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(bottomRight.hasPrimaryFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(activated, 'Bottom right');

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(topLeft.hasPrimaryFocus, isTrue);
  });
}

Widget _focusTestApp(Widget child) {
  return WidgetsApp(
    color: const Color(0xFF000000),
    builder: (context, _) => MetroTheme(
      data: MetroThemeData.light(),
      child: Center(child: child),
    ),
  );
}
