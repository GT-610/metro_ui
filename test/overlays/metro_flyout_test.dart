import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_ui/metro_ui.dart';

void main() {
  testWidgets('end flyout is full height and returns a result', (tester) async {
    final semantics = tester.ensureSemantics();
    String? result;
    await tester.pumpWidget(
      _overlayTestApp(
        child: Builder(
          builder: (context) {
            return MetroButton(
              onPressed: () async {
                result = await showMetroFlyout<String>(
                  context: context,
                  builder: (flyoutContext) {
                    return MetroFlyout(
                      semanticLabel: 'Settings flyout',
                      title: const Text('Settings'),
                      actions: [
                        MetroIconButton(
                          icon: const SizedBox.square(dimension: 16),
                          onPressed: () {
                            Navigator.of(flyoutContext).pop('closed');
                          },
                          semanticLabel: 'Close settings',
                        ),
                      ],
                      child: const Text('Flyout content'),
                    );
                  },
                );
              },
              child: const Text('OPEN'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('OPEN'));
    await tester.pump();
    expect(tester.getRect(find.byType(MetroFlyout)).left, closeTo(800, 0.01));
    await tester.pumpAndSettle();
    final panel = tester.getRect(find.byType(MetroFlyout));
    expect(panel.width, 346);
    expect(panel.right, 800);
    expect(panel.top, 0);
    expect(panel.bottom, 600);
    expect(find.bySemanticsLabel('Settings flyout'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Close settings'));
    await tester.pumpAndSettle();
    expect(result, 'closed');
    semantics.dispose();
  });

  testWidgets('start flyout uses the logical leading edge', (tester) async {
    await tester.pumpWidget(
      _overlayTestApp(
        child: Builder(
          builder: (context) {
            return MetroButton(
              onPressed: () {
                showMetroFlyout<void>(
                  context: context,
                  side: MetroFlyoutSide.start,
                  builder: (_) =>
                      const MetroFlyout(child: Text('Leading content')),
                );
              },
              child: const Text('OPEN'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('OPEN'));
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byType(MetroFlyout)).left, 0);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Leading content'), findsNothing);
  });

  testWidgets('local flyout theme is captured by the overlay route', (
    tester,
  ) async {
    const customColor = Color(0xFF123456);
    await tester.pumpWidget(
      _overlayTestApp(
        child: MetroFlyoutTheme(
          data: const MetroFlyoutThemeData(backgroundColor: customColor),
          child: Builder(
            builder: (context) {
              return MetroButton(
                onPressed: () {
                  showMetroFlyout<void>(
                    context: context,
                    builder: (_) =>
                        const MetroFlyout(child: Text('Themed content')),
                  );
                },
                child: const Text('OPEN'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('OPEN'));
    await tester.pumpAndSettle();
    final backgrounds = tester.widgetList<ColoredBox>(
      find.descendant(
        of: find.byType(MetroFlyout),
        matching: find.byType(ColoredBox),
      ),
    );
    expect(backgrounds.first.color, customColor);
  });

  testWidgets('the panel edge is outlined against the shared background', (
    tester,
  ) async {
    await tester.pumpWidget(
      _overlayTestApp(
        // An edge-docked panel gets loose constraints from the route, which is
        // what lets it take its declared width.
        child: const Align(
          alignment: AlignmentDirectional.centerEnd,
          child: MetroFlyout(
            title: Text('Settings'),
            child: Text('Flyout content'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final colors = MetroColorScheme.light();
    final outline =
        tester
                .widget<DecoratedBox>(
                  find.byKey(const ValueKey<String>('metro-flyout-panel')),
                )
                .decoration
            as BoxDecoration;
    final border = outline.border! as Border;

    expect(border.top.color, colors.foreground);
    expect(border.top.width, 1);
    // The outline covers the panel edge instead of insetting the content, so
    // the panel still measures the width the theme asks for.
    expect(
      tester
          .getSize(find.byKey(const ValueKey<String>('metro-flyout-panel')))
          .width,
      346,
    );
  });

  testWidgets('the panel outline follows the flyout theme', (tester) async {
    const outline = Color(0xFF123456);
    await tester.pumpWidget(
      _overlayTestApp(
        child: const MetroFlyoutTheme(
          data: MetroFlyoutThemeData(borderColor: outline),
          child: MetroFlyout(child: Text('Themed content')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final decoration =
        tester
                .widget<DecoratedBox>(
                  find.byKey(const ValueKey<String>('metro-flyout-panel')),
                )
                .decoration
            as BoxDecoration;
    expect((decoration.border! as Border).top.color, outline);
  });

  testWidgets('flyout entrance and exit share the same ease-out progress', (
    tester,
  ) async {
    const motion = MetroMotion();
    await tester.pumpWidget(
      _overlayTestApp(
        child: Builder(
          builder: (context) {
            return MetroButton(
              onPressed: () {
                showMetroFlyout<void>(
                  context: context,
                  builder: (flyoutContext) => MetroFlyout(
                    actions: <Widget>[
                      MetroButton(
                        onPressed: () => Navigator.of(flyoutContext).pop(),
                        child: const Text('CLOSE'),
                      ),
                    ],
                    child: const Text('Timed flyout'),
                  ),
                );
              },
              child: const Text('OPEN'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('OPEN'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 275));
    final entrancePanel = tester.getRect(find.byType(MetroFlyout));
    final entranceDistance = 800 - entrancePanel.left;
    expect(
      entranceDistance,
      closeTo(346 * motion.standardCurve.transform(0.5), 0.5),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('CLOSE'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 275));

    final panel = tester.getRect(find.byType(MetroFlyout));
    final exitDistance = panel.left - (800 - panel.width);
    expect(
      exitDistance,
      closeTo(346 * motion.standardCurve.transform(0.5), 0.5),
    );
    expect(exitDistance, closeTo(entranceDistance, 0.01));
    expect(panel.right, greaterThan(800));
    expect(find.text('Timed flyout'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 274));
    expect(find.text('Timed flyout'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Timed flyout'), findsNothing);
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
