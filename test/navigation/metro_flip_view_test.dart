import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_ui/metro_ui.dart';

import '../test_utils.dart';

void main() {
  test('built-in Chinese localization includes FlipView strings', () {
    const localizations = MetroLocalizationsZh();

    expect(localizations.flipViewPreviousLabel, '\u4e0a\u4e00\u9879');
    expect(localizations.flipViewNextLabel, '\u4e0b\u4e00\u9879');
    expect(
      localizations.flipViewItemPosition(2, 5),
      '\u7b2c 2 \u9879\uff0c\u5171 5 \u9879',
    );
  });

  Widget buildFlipView({
    int? index,
    int initialIndex = 0,
    ValueChanged<int>? onChanged,
    bool circular = false,
    bool autofocus = false,
    Axis axis = Axis.horizontal,
    MetroFlipViewNavigationVisibility navigationVisibility =
        MetroFlipViewNavigationVisibility.always,
    MetroFlipViewStyle? style,
    List<MetroFlipViewItem> items = _items,
    TextDirection textDirection = TextDirection.ltr,
    MetroThemeData? theme,
    MediaQueryData mediaQueryData = const MediaQueryData(size: Size(800, 600)),
  }) {
    return metroTestApp(
      mediaQueryData: mediaQueryData,
      theme: theme,
      child: Center(
        child: Directionality(
          textDirection: textDirection,
          child: SizedBox(
            width: 320,
            height: 180,
            child: MetroFlipView(
              index: index,
              initialIndex: initialIndex,
              onChanged: onChanged,
              circular: circular,
              autofocus: autofocus,
              axis: axis,
              navigationVisibility: navigationVisibility,
              showIndicators: true,
              style: style,
              semanticLabel: 'Feature gallery',
              items: items,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('uncontrolled navigation changes the page and banner', (
    tester,
  ) async {
    final changes = <int>[];
    await tester.pumpWidget(buildFlipView(onChanged: changes.add));

    expect(find.text('FIRST'), findsOneWidget);
    expect(find.text('First banner'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('metro-flip-view-previous')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<AnimatedOpacity>(
            find.ancestor(
              of: find.byKey(
                const ValueKey<String>('metro-flip-view-previous'),
              ),
              matching: find.byType(AnimatedOpacity),
            ),
          )
          .opacity,
      0,
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('metro-flip-view-next')),
    );
    await tester.pumpAndSettle();

    expect(changes, const <int>[1]);
    expect(find.text('FIRST'), findsNothing);
    expect(find.text('SECOND'), findsOneWidget);
    expect(find.text('Second banner'), findsOneWidget);
  });

  testWidgets('controlled selection returns to the application-owned index', (
    tester,
  ) async {
    final changes = <int>[];
    await tester.pumpWidget(buildFlipView(index: 0, onChanged: changes.add));

    await tester.tap(
      find.byKey(const ValueKey<String>('metro-flip-view-next')),
    );
    await tester.pumpAndSettle();

    expect(changes, const <int>[1]);
    expect(find.text('FIRST'), findsOneWidget);
    expect(find.text('SECOND'), findsNothing);
  });

  testWidgets('controlled selection persists when the application updates it', (
    tester,
  ) async {
    var index = 0;
    await tester.pumpWidget(
      metroTestApp(
        child: StatefulBuilder(
          builder: (context, setState) {
            return Center(
              child: SizedBox(
                width: 320,
                height: 180,
                child: MetroFlipView(
                  index: index,
                  navigationVisibility:
                      MetroFlipViewNavigationVisibility.always,
                  items: _items,
                  onChanged: (value) => setState(() => index = value),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('metro-flip-view-next')),
    );
    await tester.pumpAndSettle();

    expect(index, 1);
    expect(find.text('SECOND'), findsOneWidget);
  });

  testWidgets('direct horizontal drag commits the next item', (tester) async {
    final changes = <int>[];
    await tester.pumpWidget(buildFlipView(onChanged: changes.add));

    await tester.drag(find.byType(MetroFlipView), const Offset(-120, 0));
    await tester.pumpAndSettle();

    expect(changes, const <int>[1]);
    expect(find.text('SECOND'), findsOneWidget);
  });

  testWidgets('direct drag keeps full-page manipulation geometry', (
    tester,
  ) async {
    await tester.pumpWidget(buildFlipView(onChanged: (_) {}));

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(MetroFlipView)),
    );
    await gesture.moveBy(const Offset(-20, 0));
    await gesture.moveBy(const Offset(-80, 0));
    await tester.pump();

    final current = tester.widget<Transform>(
      find.byKey(const ValueKey<String>('metro-flip-view-current-item')),
    );
    final incoming = tester.widget<Transform>(
      find.byKey(const ValueKey<String>('metro-flip-view-incoming-item')),
    );
    expect(current.transform.getTranslation().x, closeTo(-80, 0.01));
    expect(incoming.transform.getTranslation().x, closeTo(240, 0.01));

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('navigation buttons use WinJS geometry and neutral states', (
    tester,
  ) async {
    final previousHighlightStrategy =
        tester.binding.focusManager.highlightStrategy;
    addTearDown(() {
      tester.binding.focusManager.highlightStrategy = previousHighlightStrategy;
    });
    tester.binding.focusManager.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    await tester.pumpWidget(buildFlipView(initialIndex: 1));

    const nextKey = ValueKey<String>('metro-flip-view-next-surface');
    final flipRect = tester.getRect(find.byType(MetroFlipView));
    final nextRect = tester.getRect(find.byKey(nextKey));
    BoxDecoration decoration() {
      return tester.widget<Container>(find.byKey(nextKey)).decoration!
          as BoxDecoration;
    }

    expect(nextRect.size, const Size(69, 39));
    expect(nextRect.right, flipRect.right);
    expect(nextRect.center.dy, flipRect.center.dy);
    expect(decoration().color, const Color(0x59D5D5D5));
    expect(decoration().border, isNull);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer();
    await mouse.moveTo(nextRect.center);
    await tester.pumpAndSettle();
    expect(decoration().color, const Color(0xF0D7D7D7));

    await mouse.down(nextRect.center);
    await tester.pump();
    expect(decoration().color, const Color(0xBD292929));
    await mouse.up();
  });

  testWidgets('high contrast navigation buttons keep a two-pixel border', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildFlipView(initialIndex: 1, theme: MetroThemeData.highContrastLight()),
    );

    final decoration =
        tester
                .widget<Container>(
                  find.byKey(
                    const ValueKey<String>('metro-flip-view-next-surface'),
                  ),
                )
                .decoration!
            as BoxDecoration;
    expect(decoration.border!.top.width, 2);
  });

  testWidgets('automatic navigation visibility uses standard easing', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildFlipView(
        initialIndex: 1,
        navigationVisibility: MetroFlipViewNavigationVisibility.auto,
      ),
    );

    final animatedOpacity = find.ancestor(
      of: find.byKey(const ValueKey<String>('metro-flip-view-next')),
      matching: find.byType(AnimatedOpacity),
    );
    double opacity() {
      return tester
          .widget<FadeTransition>(
            find.descendant(
              of: animatedOpacity,
              matching: find.byType(FadeTransition),
            ),
          )
          .opacity
          .value;
    }

    expect(opacity(), 0);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer();
    await mouse.moveTo(tester.getCenter(find.byType(MetroFlipView)));
    await tester.pump();
    expect(opacity(), 0);

    await tester.pump(const Duration(milliseconds: 83));
    expect(
      opacity(),
      closeTo(const MetroMotion().standardCurve.transform(83 / 167), 0.01),
    );
    await tester.pump(const Duration(milliseconds: 84));
    expect(opacity(), 1);
  });

  testWidgets('programmatic navigation uses WinJS content transition', (
    tester,
  ) async {
    await tester.pumpWidget(buildFlipView(onChanged: (_) {}));

    await tester.tap(
      find.byKey(const ValueKey<String>('metro-flip-view-next')),
    );
    await tester.pump();

    Transform currentTransform() => tester.widget<Transform>(
      find.byKey(const ValueKey<String>('metro-flip-view-current-item')),
    );
    Transform incomingTransform() => tester.widget<Transform>(
      find.byKey(const ValueKey<String>('metro-flip-view-incoming-item')),
    );
    double opacityOf(Transform transform) {
      return (transform.child! as Opacity).opacity;
    }

    expect(currentTransform().transform.getTranslation().x, 0);
    expect(incomingTransform().transform.getTranslation().x, 40);
    expect(opacityOf(currentTransform()), 1);
    expect(opacityOf(incomingTransform()), 0);

    await tester.pump(const Duration(milliseconds: 83));
    expect(
      opacityOf(currentTransform()),
      closeTo(1 - const MetroMotion().standardCurve.transform(83 / 167), 0.01),
    );
    await tester.pump(const Duration(milliseconds: 84));
    expect(currentTransform().transform.getTranslation().x, 0);
    expect(opacityOf(currentTransform()), closeTo(0, 0.001));
    expect(
      incomingTransform().transform.getTranslation().x,
      allOf(greaterThan(0), lessThan(40)),
    );
    expect(opacityOf(incomingTransform()), lessThan(1));

    await tester.pump(const Duration(milliseconds: 3));
    expect(opacityOf(incomingTransform()), closeTo(1, 0.001));
    expect(
      incomingTransform().transform.getTranslation().x,
      allOf(greaterThan(0), lessThan(40)),
    );

    await tester.pump(const Duration(milliseconds: 379));
    expect(find.text('FIRST'), findsOneWidget);
    expect(find.text('SECOND'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2));
    expect(find.text('FIRST'), findsNothing);
    expect(find.text('SECOND'), findsOneWidget);
  });

  testWidgets('RTL keyboard navigation follows logical direction', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildFlipView(autofocus: true, textDirection: TextDirection.rtl),
    );
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(find.text('SECOND'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pumpAndSettle();
    expect(find.text('THIRD'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pumpAndSettle();
    expect(find.text('FIRST'), findsOneWidget);
  });

  testWidgets('circular transitions do not duplicate keyed page subtrees', (
    tester,
  ) async {
    final keys = List<GlobalKey>.generate(3, (_) => GlobalKey());
    final items = <MetroFlipViewItem>[
      for (var index = 0; index < keys.length; index += 1)
        MetroFlipViewItem(
          child: SizedBox(key: keys[index], child: Text('PAGE $index')),
        ),
    ];
    await tester.pumpWidget(
      buildFlipView(initialIndex: 2, circular: true, items: items),
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('metro-flip-view-next')),
    );
    await tester.pump(const Duration(milliseconds: 40));

    expect(tester.takeException(), isNull);
    expect(find.byKey(keys[2]), findsOneWidget);
    expect(find.byKey(keys[0]), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byKey(keys[0]), findsOneWidget);
    expect(find.byKey(keys[2]), findsNothing);
  });

  testWidgets('semantics expose position, actions, and navigation labels', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(buildFlipView(circular: true));

    final data = tester
        .getSemantics(find.bySemanticsLabel(RegExp('Feature gallery')))
        .getSemanticsData();
    expect(data.value, 'Item 1 of 3');
    expect(data.increasedValue, 'Item 2 of 3');
    expect(data.decreasedValue, 'Item 3 of 3');
    expect(data.hasAction(SemanticsAction.increase), isTrue);
    expect(data.hasAction(SemanticsAction.decrease), isTrue);
    expect(find.bySemanticsLabel('Previous item'), findsOneWidget);
    expect(find.bySemanticsLabel('Next item'), findsOneWidget);

    handle.dispose();
  });

  testWidgets('widget style overrides local and application themes', (
    tester,
  ) async {
    const applicationColor = Color(0xFF112233);
    const localColor = Color(0xFF445566);
    const widgetColor = Color(0xFF778899);

    Widget themedFlipView({
      MetroFlipViewStyle? widgetStyle,
      bool local = true,
    }) {
      Widget child = SizedBox(
        width: 320,
        height: 180,
        child: MetroFlipView(
          navigationVisibility: MetroFlipViewNavigationVisibility.hidden,
          style: widgetStyle,
          items: _items,
        ),
      );
      if (local) {
        child = MetroFlipViewTheme(
          data: const MetroFlipViewThemeData(
            style: MetroFlipViewStyle(backgroundColor: localColor),
          ),
          child: child,
        );
      }
      return metroTestApp(
        theme: MetroThemeData.light().copyWith(
          flipViewTheme: const MetroFlipViewThemeData(
            style: MetroFlipViewStyle(backgroundColor: applicationColor),
          ),
        ),
        child: Center(child: child),
      );
    }

    Color surfaceColor() {
      final container = tester.widget<Container>(
        find.byKey(const ValueKey<String>('metro-flip-view-surface')),
      );
      return (container.decoration! as BoxDecoration).color!;
    }

    await tester.pumpWidget(
      themedFlipView(
        widgetStyle: const MetroFlipViewStyle(backgroundColor: widgetColor),
      ),
    );
    expect(surfaceColor(), widgetColor);

    await tester.pumpWidget(themedFlipView());
    await tester.pumpAndSettle();
    expect(surfaceColor(), localColor);

    await tester.pumpWidget(themedFlipView(local: false));
    await tester.pumpAndSettle();
    expect(surfaceColor(), applicationColor);
  });

  testWidgets('reduced motion commits navigation without a transition frame', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildFlipView(
        mediaQueryData: const MediaQueryData(
          size: Size(800, 600),
          disableAnimations: true,
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('metro-flip-view-next')),
    );
    await tester.pump();

    expect(find.text('FIRST'), findsNothing);
    expect(find.text('SECOND'), findsOneWidget);
  });
}

const _items = <MetroFlipViewItem>[
  MetroFlipViewItem(
    semanticLabel: 'First page',
    banner: Text('First banner'),
    child: Center(child: Text('FIRST')),
  ),
  MetroFlipViewItem(
    semanticLabel: 'Second page',
    banner: Text('Second banner'),
    child: Center(child: Text('SECOND')),
  ),
  MetroFlipViewItem(
    semanticLabel: 'Third page',
    banner: Text('Third banner'),
    child: Center(child: Text('THIRD')),
  ),
];
