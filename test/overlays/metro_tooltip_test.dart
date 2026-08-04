import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_ui/metro_ui.dart';

void main() {
  testWidgets('tooltip appears after hover delay and hides on exit', (
    tester,
  ) async {
    await tester.pumpWidget(
      _overlayTestApp(
        child: const Center(
          child: MetroTooltip(
            message: 'Open settings',
            waitDuration: Duration(milliseconds: 100),
            child: SizedBox(key: Key('target'), width: 80, height: 40),
          ),
        ),
      ),
    );
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer();
    await mouse.moveTo(tester.getCenter(find.byKey(const Key('target'))));
    await tester.pump(const Duration(milliseconds: 99));
    expect(find.text('Open settings'), findsNothing);

    await tester.pump(const Duration(milliseconds: 1));
    expect(find.text('Open settings'), findsOneWidget);

    await mouse.moveTo(Offset.zero);
    await tester.pump();
    expect(find.text('Open settings'), findsNothing);
  });

  testWidgets('tooltip flips above a target near the bottom edge', (
    tester,
  ) async {
    await tester.pumpWidget(
      _overlayTestApp(
        child: const Align(
          alignment: Alignment.bottomCenter,
          child: MetroTooltip(
            message: 'Bottom action',
            waitDuration: Duration.zero,
            child: SizedBox(key: Key('target'), width: 80, height: 40),
          ),
        ),
      ),
    );
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer();
    await mouse.moveTo(tester.getCenter(find.byKey(const Key('target'))));
    await tester.pumpAndSettle();

    final tooltip = tester.getRect(find.text('Bottom action'));
    final target = tester.getRect(find.byKey(const Key('target')));
    expect(tooltip.bottom, lessThan(target.top));
  });

  testWidgets('tooltip appears when a descendant receives keyboard focus', (
    tester,
  ) async {
    await tester.pumpWidget(
      _overlayTestApp(
        child: Center(
          child: MetroTooltip(
            message: 'Focused action',
            waitDuration: Duration.zero,
            child: MetroButton(
              autofocus: true,
              onPressed: () {},
              child: const Text('ACTION'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Focused action'), findsOneWidget);
  });

  testWidgets('long press shows a temporary touch tooltip', (tester) async {
    await tester.pumpWidget(
      _overlayTestApp(
        child: Center(
          child: MetroTooltip(
            message: 'Touch action',
            waitDuration: const Duration(seconds: 5),
            showDuration: const Duration(seconds: 1),
            child: MetroButton(onPressed: () {}, child: const Text('ACTION')),
          ),
        ),
      ),
    );

    await tester.longPress(find.text('ACTION'));
    await tester.pump();
    expect(find.text('Touch action'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1001));
    expect(find.text('Touch action'), findsNothing);
  });

  testWidgets('widget values override the local tooltip theme', (tester) async {
    const localColor = Color(0xFF123456);
    const widgetColor = Color(0xFF654321);
    await tester.pumpWidget(
      _overlayTestApp(
        child: const Center(
          child: MetroTooltipTheme(
            data: MetroTooltipThemeData(backgroundColor: localColor),
            child: MetroTooltip(
              message: 'Themed tooltip',
              backgroundColor: widgetColor,
              waitDuration: Duration.zero,
              child: SizedBox(key: Key('target'), width: 80, height: 40),
            ),
          ),
        ),
      ),
    );
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer();
    await mouse.moveTo(tester.getCenter(find.byKey(const Key('target'))));
    await tester.pumpAndSettle();

    final box = tester.widget<DecoratedBox>(
      find.ancestor(
        of: find.text('Themed tooltip'),
        matching: find.byType(DecoratedBox),
      ),
    );
    expect((box.decoration as BoxDecoration).color, widgetColor);
  });

  testWidgets('tooltip message is available to semantics while hidden', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _overlayTestApp(
        child: const MetroTooltip(
          message: 'Helpful description',
          child: SizedBox(width: 40, height: 40),
        ),
      ),
    );

    final tooltipSemantics = find.descendant(
      of: find.byType(MetroTooltip),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.tooltip == 'Helpful description',
      ),
    );
    expect(tooltipSemantics, findsOneWidget);
    expect(
      tester.getSemantics(tooltipSemantics),
      matchesSemantics(tooltip: 'Helpful description'),
    );
    semantics.dispose();
  });
}

Widget _overlayTestApp({required Widget child}) {
  return WidgetsApp(
    color: const Color(0xFF000000),
    onGenerateRoute: (_) => PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondaryAnimation) {
        return MetroTheme(data: MetroThemeData.light(), child: child);
      },
    ),
  );
}
