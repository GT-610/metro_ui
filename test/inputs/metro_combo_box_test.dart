import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_ui/metro_ui.dart';

import '../test_utils.dart';

void main() {
  testWidgets('selects an item and closes the popup', (tester) async {
    String? value;
    await tester.pumpWidget(
      _comboTestApp(
        child: StatefulBuilder(
          builder: (context, setState) {
            return Center(
              child: SizedBox(
                width: 220,
                child: MetroComboBox<String>(
                  value: value,
                  placeholder: const Text('Choose a city'),
                  items: _stringItems,
                  onChanged: (next) => setState(() => value = next),
                ),
              ),
            );
          },
        ),
      ),
    );

    expect(find.text('Choose a city'), findsOneWidget);
    await tester.tap(find.byType(MetroComboBox<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('seattle')));
    await tester.pumpAndSettle();

    expect(value, 'seattle');
    expect(find.byKey(const ValueKey<String>('seattle')), findsNothing);
    expect(find.text('Seattle'), findsOneWidget);
  });

  testWidgets('keyboard navigation skips disabled items', (tester) async {
    var value = 'alpha';
    await tester.pumpWidget(
      _comboTestApp(
        child: StatefulBuilder(
          builder: (context, setState) {
            return Center(
              child: SizedBox(
                width: 220,
                child: MetroComboBox<String>(
                  autofocus: true,
                  value: value,
                  items: const [
                    MetroComboBoxItem(value: 'alpha', child: Text('Alpha')),
                    MetroComboBoxItem(
                      value: 'beta',
                      enabled: false,
                      semanticLabel: 'Beta unavailable',
                      child: Text('Beta'),
                    ),
                    MetroComboBoxItem(value: 'gamma', child: Text('Gamma')),
                  ],
                  onChanged: (next) => setState(() => value = next!),
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(value, 'gamma');
    expect(find.byKey(const ValueKey<String>('beta')), findsNothing);
  });

  testWidgets('Home, End, and Escape preserve controlled selection and focus', (
    tester,
  ) async {
    final focusNode = FocusNode();
    var value = 'seattle';
    await tester.pumpWidget(
      _comboTestApp(
        child: StatefulBuilder(
          builder: (context, setState) {
            return Center(
              child: SizedBox(
                width: 220,
                child: MetroComboBox<String>(
                  autofocus: true,
                  focusNode: focusNode,
                  value: value,
                  items: _stringItems,
                  onChanged: (next) => setState(() => value = next!),
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(value, 'tokyo');

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(value, 'tokyo');
    expect(find.byKey(const ValueKey<String>('london')), findsNothing);
    expect(focusNode.hasFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.f4);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('london')), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.f4);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('london')), findsNothing);
    focusNode.dispose();
  });

  testWidgets('clicking outside dismisses without changing the value', (
    tester,
  ) async {
    var changes = 0;
    await tester.pumpWidget(
      _comboTestApp(
        child: Column(
          children: [
            const SizedBox(key: Key('outside'), width: 300, height: 180),
            SizedBox(
              width: 220,
              child: MetroComboBox<String>(
                value: 'london',
                items: _stringItems,
                onChanged: (_) => changes += 1,
              ),
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.byType(MetroComboBox<String>));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('tokyo')), findsOneWidget);

    await tester.tapAt(tester.getCenter(find.byKey(const Key('outside'))));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('tokyo')), findsNothing);
    expect(changes, 0);
  });

  testWidgets('popup flips above and obeys its maximum height', (tester) async {
    await tester.pumpWidget(
      _comboTestApp(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: 180,
            child: MetroComboBox<int>(
              style: const MetroComboBoxStyle(
                itemHeight: 40,
                menuMaxHeight: 110,
              ),
              items: [
                for (var index = 0; index < 8; index += 1)
                  MetroComboBoxItem(value: index, child: Text('Item $index')),
              ],
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    final target = tester.getRect(find.byType(MetroComboBox<int>));
    await tester.tap(find.byType(MetroComboBox<int>));
    await tester.pumpAndSettle();

    final popup = tester.getRect(find.byType(Scrollable));
    expect(popup.height, lessThanOrEqualTo(110));
    expect(popup.bottom, lessThan(target.top));
  });

  testWidgets('wider popup aligns to the logical start edge in RTL', (
    tester,
  ) async {
    await tester.pumpWidget(
      _comboTestApp(
        textDirection: TextDirection.rtl,
        child: Center(
          child: SizedBox(
            width: 140,
            child: MetroComboBox<String>(
              style: const MetroComboBoxStyle(menuWidth: 240),
              items: _stringItems,
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    final target = tester.getRect(find.byType(MetroComboBox<String>));
    await tester.tap(find.byType(MetroComboBox<String>));
    await tester.pumpAndSettle();
    final popup = tester.getRect(find.byType(Scrollable));

    expect(popup.width, 240);
    expect(popup.right, closeTo(target.right, 0.01));
  });

  testWidgets('widget style overrides local and application themes', (
    tester,
  ) async {
    await tester.pumpWidget(
      _comboTestApp(
        theme: MetroThemeData.light().copyWith(
          comboBoxTheme: const MetroComboBoxThemeData(
            style: MetroComboBoxStyle(minimumHeight: 72),
          ),
        ),
        child: Center(
          child: MetroComboBoxTheme(
            data: const MetroComboBoxThemeData(
              style: MetroComboBoxStyle(minimumHeight: 64),
            ),
            child: MetroComboBox<String>(
              style: const MetroComboBoxStyle(minimumHeight: 52),
              items: _stringItems,
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(MetroComboBox<String>)).height, 52);
  });

  testWidgets('semantics expose expanded, selected, and disabled states', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _comboTestApp(
        child: Center(
          child: SizedBox(
            width: 220,
            child: MetroComboBox<String>(
              semanticLabel: 'Travel destination',
              value: 'seattle',
              items: const [
                MetroComboBoxItem(
                  value: 'seattle',
                  semanticLabel: 'Seattle selected',
                  child: Text('Seattle'),
                ),
                MetroComboBoxItem(
                  value: 'closed',
                  enabled: false,
                  semanticLabel: 'Closed destination',
                  child: Text('Closed'),
                ),
              ],
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    final field = tester.getSemantics(
      find.bySemanticsLabel('Travel destination'),
    );
    expect(field.label, 'Travel destination');
    expect(field.value, 'Seattle selected');
    expect(
      field,
      containsMetroSemantics(hasExpandedState: true, isExpanded: false),
    );

    await tester.tap(find.byType(MetroComboBox<String>));
    await tester.pumpAndSettle();
    final expandedField = tester.getSemantics(
      find.bySemanticsLabel('Travel destination'),
    );
    final disabledItem = tester.getSemantics(
      find.bySemanticsLabel('Closed destination'),
    );
    expect(
      expandedField,
      containsMetroSemantics(hasExpandedState: true, isExpanded: true),
    );
    expect(
      disabledItem,
      containsMetroSemantics(hasEnabledState: true, isEnabled: false),
    );
    semantics.dispose();
  });

  testWidgets('reduced motion removes the popup entrance duration', (
    tester,
  ) async {
    await tester.pumpWidget(
      _comboTestApp(
        mediaQueryData: const MediaQueryData(
          disableAnimations: true,
          size: Size(800, 600),
        ),
        child: Center(
          child: SizedBox(
            width: 220,
            child: MetroComboBox<String>(
              items: _stringItems,
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(MetroComboBox<String>));
    await tester.pump();

    final popupAnimation = tester.widget<TweenAnimationBuilder<double>>(
      find.byWidgetPredicate(
        (widget) =>
            widget is TweenAnimationBuilder<double> && widget.tween.end == 1.0,
      ),
    );
    expect(popupAnimation.duration, Duration.zero);
  });

  testWidgets('popup rows grow with the ambient text scaler', (tester) async {
    await tester.pumpWidget(
      _comboTestApp(
        mediaQueryData: const MediaQueryData(
          size: Size(800, 600),
          textScaler: TextScaler.linear(1.5),
        ),
        child: Center(
          child: SizedBox(
            width: 220,
            child: MetroComboBox<String>(
              style: const MetroComboBoxStyle(menuMaxHeight: 200),
              items: const [
                MetroComboBoxItem(value: 'large', child: Text('Large text')),
              ],
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(MetroComboBox<String>));
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byType(Scrollable)).height, 60);
  });
}

const _stringItems = <MetroComboBoxItem<String>>[
  MetroComboBoxItem(value: 'london', child: Text('London')),
  MetroComboBoxItem(value: 'seattle', child: Text('Seattle')),
  MetroComboBoxItem(value: 'tokyo', child: Text('Tokyo')),
];

Widget _comboTestApp({
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
