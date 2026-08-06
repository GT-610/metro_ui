import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_ui/metro_ui.dart';

import '../test_utils.dart';

void main() {
  Widget buildPivot({
    ValueChanged<int>? onChanged,
    bool autofocus = false,
    TextDirection textDirection = TextDirection.ltr,
    MediaQueryData mediaQueryData = const MediaQueryData(size: Size(800, 600)),
  }) {
    return metroTestApp(
      mediaQueryData: mediaQueryData,
      child: Directionality(
        textDirection: textDirection,
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
      ),
    );
  }

  testWidgets('pivot uses WinJS header scale, opacity, and content insets', (
    tester,
  ) async {
    await tester.pumpWidget(
      metroTestApp(
        child: Center(
          child: SizedBox(
            width: 500,
            height: 240,
            child: MetroPivot(
              autofocus: true,
              items: const <MetroPivotItem>[
                MetroPivotItem(
                  header: Text('FIRST'),
                  child: SizedBox(key: ValueKey('first-content')),
                ),
                MetroPivotItem(
                  header: Text('SECOND'),
                  child: SizedBox(key: ValueKey('second-content')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final styles = tester.widgetList<AnimatedDefaultTextStyle>(
      find.descendant(
        of: find.byType(MetroPivot),
        matching: find.byType(AnimatedDefaultTextStyle),
      ),
    );
    expect(styles.first.style.fontSize, 60);
    expect(styles.first.style.fontWeight, FontWeight.w400);
    expect(styles.first.style.color, const Color(0xFF1D1D1D));
    expect(styles.last.style.color, const Color(0x331D1D1D));
    expect(styles.first.duration, const Duration(milliseconds: 167));
    expect(styles.first.curve, Curves.linear);

    final firstRight = tester.getTopRight(find.text('FIRST')).dx;
    final secondLeft = tester.getTopLeft(find.text('SECOND')).dx;
    expect(secondLeft - firstRight, closeTo(18, 0.01));

    final contentPadding = tester.widget<Padding>(
      find
          .ancestor(
            of: find.byKey(const ValueKey('first-content')),
            matching: find.byType(Padding),
          )
          .first,
    );
    expect(
      contentPadding.padding,
      const EdgeInsetsDirectional.symmetric(horizontal: 19),
    );

    final focusedHeader = tester.widgetList<CustomPaint>(
      find.descendant(
        of: find.byType(MetroPivot),
        matching: find.byType(CustomPaint),
      ),
    );
    expect(
      focusedHeader.any((paint) => paint.foregroundPainter != null),
      isTrue,
    );
  });

  testWidgets('pivot changes page from its header', (tester) async {
    var index = 0;
    await tester.pumpWidget(buildPivot(onChanged: (next) => index = next));

    await tester.ensureVisible(find.text('FAVORITES'));
    await tester.pump();
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

  testWidgets('programmatic content uses distinct WinJS in and out curves', (
    tester,
  ) async {
    const motion = MetroMotion();
    await tester.pumpWidget(buildPivot());

    await tester.ensureVisible(find.text('FAVORITES'));
    await tester.pump();
    await tester.tap(find.text('FAVORITES'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 175));

    final outgoing = tester.widget<Transform>(
      find.byKey(const ValueKey<String>('metro-pivot-page-0-transform')),
    );
    final incoming = tester.widget<Transform>(
      find.byKey(const ValueKey<String>('metro-pivot-page-1-transform')),
    );
    expect(
      outgoing.transform.getTranslation().x,
      closeTo(-500 * motion.contentExitCurve.transform(0.5), 0.5),
    );
    expect(
      incoming.transform.getTranslation().x,
      closeTo(500 * (1 - motion.contentCurve.transform(0.5)), 0.5),
    );
    expect(
      outgoing.transform.getTranslation().x.abs(),
      lessThan(500 - incoming.transform.getTranslation().x),
    );

    await tester.pumpAndSettle();
    expect(find.text('Favorite content'), findsOneWidget);
  });

  testWidgets('direct swipe retains full-page manipulation and settles', (
    tester,
  ) async {
    var index = 0;
    await tester.pumpWidget(buildPivot(onChanged: (next) => index = next));

    await tester.timedDrag(
      find.text('Recent content'),
      const Offset(-300, 0),
      const Duration(milliseconds: 100),
    );
    await tester.pumpAndSettle();

    expect(index, 1);
    expect(find.text('Favorite content'), findsOneWidget);
  });

  testWidgets('programmatic content motion mirrors in RTL', (tester) async {
    const motion = MetroMotion();
    await tester.pumpWidget(buildPivot(textDirection: TextDirection.rtl));

    await tester.ensureVisible(find.text('FAVORITES'));
    await tester.pump();
    await tester.tap(find.text('FAVORITES'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 175));

    final outgoing = tester.widget<Transform>(
      find.byKey(const ValueKey<String>('metro-pivot-page-0-transform')),
    );
    final incoming = tester.widget<Transform>(
      find.byKey(const ValueKey<String>('metro-pivot-page-1-transform')),
    );
    expect(
      outgoing.transform.getTranslation().x,
      closeTo(500 * motion.contentExitCurve.transform(0.5), 0.5),
    );
    expect(
      incoming.transform.getTranslation().x,
      closeTo(-500 * (1 - motion.contentCurve.transform(0.5)), 0.5),
    );
  });

  testWidgets('Pivot honors reduced motion', (tester) async {
    await tester.pumpWidget(
      buildPivot(
        textDirection: TextDirection.rtl,
        mediaQueryData: const MediaQueryData(
          size: Size(800, 600),
          disableAnimations: true,
        ),
      ),
    );

    await tester.ensureVisible(find.text('FAVORITES'));
    await tester.pump();
    await tester.tap(find.text('FAVORITES'));
    await tester.pump();

    expect(find.text('Favorite content'), findsOneWidget);
    final incoming = tester.widget<Transform>(
      find.byKey(const ValueKey<String>('metro-pivot-page-1-transform')),
    );
    expect(incoming.transform.getTranslation().x, 0);
  });

  testWidgets('Pivot keeps item state mounted across navigation', (
    tester,
  ) async {
    await tester.pumpWidget(
      metroTestApp(
        child: Center(
          child: SizedBox(
            width: 500,
            height: 300,
            child: MetroPivot(
              items: const <MetroPivotItem>[
                MetroPivotItem(
                  header: Text('FIRST'),
                  child: _PivotCounterPage(),
                ),
                MetroPivotItem(
                  header: Text('SECOND'),
                  child: Center(child: Text('Second content')),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('INCREMENT'));
    await tester.pump();
    expect(find.text('Count 1'), findsOneWidget);

    await tester.ensureVisible(find.text('SECOND'));
    await tester.pump();
    await tester.tap(find.text('SECOND'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('FIRST'));
    await tester.pump();
    await tester.tap(find.text('FIRST'));
    await tester.pumpAndSettle();

    expect(find.text('Count 1'), findsOneWidget);
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

class _PivotCounterPage extends StatefulWidget {
  const _PivotCounterPage();

  @override
  State<_PivotCounterPage> createState() => _PivotCounterPageState();
}

class _PivotCounterPageState extends State<_PivotCounterPage> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Count $_count'),
          MetroButton(
            onPressed: () => setState(() => _count += 1),
            child: const Text('INCREMENT'),
          ),
        ],
      ),
    );
  }
}
