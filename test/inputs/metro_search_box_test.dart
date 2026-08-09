import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_ui/metro_ui.dart';

void main() {
  testWidgets('filters suggestions and reports a selected result', (
    tester,
  ) async {
    final controller = TextEditingController();
    final changes = <(String, MetroSearchBoxChangeReason)>[];
    MetroSearchBoxItem<String>? selected;
    await tester.pumpWidget(
      _searchTestApp(
        child: Center(
          child: SizedBox(
            width: 280,
            child: MetroSearchBox<String>(
              controller: controller,
              items: _cityItems,
              onChanged: (query, reason) => changes.add((query, reason)),
              onSelected: (item) => selected = item,
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(EditableText), 'sea');
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('seattle')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('london')), findsNothing);

    await tester.tap(find.byKey(const ValueKey<String>('seattle')));
    await tester.pumpAndSettle();

    expect(controller.text, 'Seattle');
    expect(selected?.value, 'seattle');
    expect(changes, const <(String, MetroSearchBoxChangeReason)>[
      ('sea', MetroSearchBoxChangeReason.userInput),
      ('Seattle', MetroSearchBoxChangeReason.suggestionSelected),
    ]);
    expect(find.byKey(const ValueKey<String>('seattle')), findsNothing);
    controller.dispose();
  });

  testWidgets('clear and submit actions have separate contracts', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'metro');
    final changes = <(String, MetroSearchBoxChangeReason)>[];
    final submissions = <String>[];
    await tester.pumpWidget(
      _searchTestApp(
        child: Center(
          child: SizedBox(
            width: 280,
            child: MetroSearchBox<String>(
              controller: controller,
              items: const [],
              onChanged: (query, reason) => changes.add((query, reason)),
              onSubmitted: submissions.add,
            ),
          ),
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('metro-search-box-submit')),
    );
    await tester.pump();
    expect(submissions, const ['metro']);

    await tester.tap(
      find.byKey(const ValueKey<String>('metro-search-box-clear')),
    );
    await tester.pump();
    expect(controller.text, isEmpty);
    expect(changes, const <(String, MetroSearchBoxChangeReason)>[
      ('', MetroSearchBoxChangeReason.cleared),
    ]);

    expect(
      tester
          .getSemantics(find.bySemanticsLabel('Search'))
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isFalse,
    );
    controller.dispose();
  });

  testWidgets('keyboard navigation skips disabled suggestions', (tester) async {
    final controller = TextEditingController(text: 'a');
    String? selected;
    await tester.pumpWidget(
      _searchTestApp(
        child: Center(
          child: SizedBox(
            width: 280,
            child: MetroSearchBox<String>(
              autofocus: true,
              controller: controller,
              items: const [
                MetroSearchBoxItem(
                  value: 'alpha',
                  queryText: 'Alpha',
                  child: Text('Alpha'),
                ),
                MetroSearchBoxItem(
                  value: 'beta',
                  queryText: 'Beta',
                  enabled: false,
                  semanticLabel: 'Beta unavailable',
                  child: Text('Beta'),
                ),
                MetroSearchBoxItem(
                  value: 'gamma',
                  queryText: 'Gamma',
                  child: Text('Gamma'),
                ),
              ],
              onSelected: (item) => selected = item.value,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(selected, 'gamma');
    expect(controller.text, 'Gamma');
    expect(find.text('Beta'), findsNothing);
    controller.dispose();
  });

  testWidgets('open popup reacts to asynchronously replaced items', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'lon');
    late StateSetter setHostState;
    var items = const <MetroSearchBoxItem<String>>[];
    await tester.pumpWidget(
      _searchTestApp(
        child: StatefulBuilder(
          builder: (context, setState) {
            setHostState = setState;
            return Center(
              child: SizedBox(
                width: 280,
                child: MetroSearchBox<String>(
                  autofocus: true,
                  controller: controller,
                  items: items,
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No suggestions'), findsOneWidget);
    setHostState(() => items = _cityItems);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('london')), findsOneWidget);
    expect(find.text('No suggestions'), findsNothing);
    controller.dispose();
  });

  testWidgets('clicking outside dismisses suggestions without clearing text', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'o');
    await tester.pumpWidget(
      _searchTestApp(
        child: Column(
          children: [
            const SizedBox(key: Key('outside'), width: 320, height: 160),
            SizedBox(
              width: 280,
              child: MetroSearchBox<String>(
                autofocus: true,
                controller: controller,
                items: _cityItems,
              ),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('london')), findsOneWidget);

    await tester.tapAt(tester.getCenter(find.byKey(const Key('outside'))));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('london')), findsNothing);
    expect(controller.text, 'o');

    await tester.tap(find.byType(EditableText));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('london')), findsOneWidget);
    controller.dispose();
  });

  testWidgets('popup flips above and respects its maximum height', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'item');
    await tester.pumpWidget(
      _searchTestApp(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: 220,
            child: MetroSearchBox<int>(
              autofocus: true,
              controller: controller,
              style: const MetroSearchBoxStyle(
                itemHeight: 40,
                popupMaxHeight: 110,
              ),
              items: [
                for (var index = 0; index < 8; index += 1)
                  MetroSearchBoxItem(
                    value: index,
                    queryText: 'Item $index',
                    child: Text('Item $index'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final target = tester.getRect(find.byType(MetroSearchBox<int>));
    final popup = tester.getRect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down,
      ),
    );
    expect(popup.height, lessThanOrEqualTo(110));
    expect(popup.bottom, lessThan(target.top));
    controller.dispose();
  });

  testWidgets('widget style overrides local and application themes', (
    tester,
  ) async {
    await tester.pumpWidget(
      _searchTestApp(
        theme: MetroThemeData.light().copyWith(
          searchBoxTheme: const MetroSearchBoxThemeData(
            style: MetroSearchBoxStyle(searchButtonExtent: 60),
          ),
        ),
        child: Center(
          child: MetroSearchBoxTheme(
            data: const MetroSearchBoxThemeData(
              style: MetroSearchBoxStyle(searchButtonExtent: 56),
            ),
            child: SizedBox(
              width: 280,
              child: MetroSearchBox<String>(
                style: const MetroSearchBoxStyle(searchButtonExtent: 52),
                items: const [],
                onSubmitted: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    final button = find.descendant(
      of: find.byKey(const ValueKey<String>('metro-search-box-submit')),
      matching: find.byType(AnimatedContainer),
    );
    expect(tester.getSize(button).height, 52);
    expect(tester.getSize(button).width, 52);
  });

  testWidgets('reduced motion removes the popup entrance duration', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'sea');
    await tester.pumpWidget(
      _searchTestApp(
        mediaQueryData: const MediaQueryData(
          disableAnimations: true,
          size: Size(800, 600),
        ),
        child: Center(
          child: SizedBox(
            width: 280,
            child: MetroSearchBox<String>(
              autofocus: true,
              controller: controller,
              items: _cityItems,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final popupAnimation = tester.widget<TweenAnimationBuilder<double>>(
      find.byWidgetPredicate(
        (widget) =>
            widget is TweenAnimationBuilder<double> && widget.tween.end == 1,
      ),
    );
    expect(popupAnimation.duration, Duration.zero);
    controller.dispose();
  });

  testWidgets('suggestion fade-in uses the standard ease-out curve', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'sea');
    await tester.pumpWidget(
      _searchTestApp(
        child: Center(
          child: SizedBox(
            width: 280,
            child: MetroSearchBox<String>(
              autofocus: true,
              controller: controller,
              items: _cityItems,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 125));

    final opacity = tester.widget<Opacity>(
      find
          .ancestor(
            of: find.byKey(
              const ValueKey<String>('metro-search-box-popup-motion'),
            ),
            matching: find.byType(Opacity),
          )
          .first,
    );
    expect(
      opacity.opacity,
      closeTo(const MetroMotion().standardCurve.transform(42 / 83), 0.02),
    );
    controller.dispose();
  });

  testWidgets('suggestion hover moves immediately above the popup surface', (
    tester,
  ) async {
    const hoverColor = Color(0xFFABCDEF);
    final controller = TextEditingController();
    await tester.pumpWidget(
      _searchTestApp(
        child: Center(
          child: SizedBox(
            width: 280,
            child: MetroSearchBox<String>(
              controller: controller,
              style: MetroSearchBoxStyle(
                itemBackgroundColor: WidgetStateProperty.resolveWith((states) {
                  return states.contains(WidgetState.hovered)
                      ? hoverColor
                      : const Color(0xFFFFFFFF);
                }),
              ),
              items: _cityItems,
              filter: (_, _) => true,
              onChanged: (_, _) {},
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(EditableText), 'a');
    await tester.pumpAndSettle();
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer();
    await mouse.moveTo(
      tester.getCenter(find.byKey(const ValueKey<String>('london'))),
    );
    await tester.pumpAndSettle();

    final hoveredItem = tester.widget<Container>(
      find
          .ancestor(
            of: find.byKey(const ValueKey<String>('london')),
            matching: find.byType(Container),
          )
          .first,
    );
    expect(hoveredItem.color, hoverColor);

    await mouse.moveTo(
      tester.getCenter(find.byKey(const ValueKey<String>('seattle'))),
    );
    await tester.pump();
    final previousItem = tester.widget<Container>(
      find
          .ancestor(
            of: find.byKey(const ValueKey<String>('london')),
            matching: find.byType(Container),
          )
          .first,
    );
    final nextItem = tester.widget<Container>(
      find
          .ancestor(
            of: find.byKey(const ValueKey<String>('seattle')),
            matching: find.byType(Container),
          )
          .first,
    );
    expect(previousItem.color, const Color(0xFFFFFFFF));
    expect(nextItem.color, hoverColor);
    controller.dispose();
  });

  test('built-in Chinese localization includes SearchBox strings', () {
    const localizations = MetroLocalizationsZh();

    expect(localizations.searchBoxSearchLabel, '\u641c\u7d22');
    expect(localizations.searchBoxClearLabel, '\u6e05\u9664\u641c\u7d22');
    expect(localizations.searchBoxNoResultsLabel, '\u6ca1\u6709\u5efa\u8bae');
  });
}

const _cityItems = <MetroSearchBoxItem<String>>[
  MetroSearchBoxItem(
    value: 'london',
    queryText: 'London',
    child: Text('London'),
  ),
  MetroSearchBoxItem(
    value: 'seattle',
    queryText: 'Seattle',
    child: Text('Seattle'),
  ),
  MetroSearchBoxItem(value: 'tokyo', queryText: 'Tokyo', child: Text('Tokyo')),
];

Widget _searchTestApp({
  required Widget child,
  MetroThemeData? theme,
  TextDirection textDirection = TextDirection.ltr,
  MediaQueryData mediaQueryData = const MediaQueryData(size: Size(800, 600)),
}) {
  return MediaQuery(
    data: mediaQueryData,
    child: Directionality(
      textDirection: textDirection,
      child: MetroTheme(
        data: theme ?? MetroThemeData.light(),
        child: Overlay(
          initialEntries: [OverlayEntry(builder: (context) => child)],
        ),
      ),
    ),
  );
}
