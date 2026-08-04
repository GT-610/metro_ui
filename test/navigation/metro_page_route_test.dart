import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_ui/metro_ui.dart';

void main() {
  testWidgets('page route captures the Metro theme below the navigator', (
    tester,
  ) async {
    final theme = MetroThemeData.dark(accentColor: MetroColors.teal);
    await tester.pumpWidget(
      _routeTestApp(
        theme: theme,
        child: Builder(
          builder: (context) {
            return MetroButton(
              onPressed: () {
                Navigator.of(context).push(
                  MetroPageRoute<void>(
                    context: context,
                    transition: MetroPageTransition.fade,
                    builder: (context) {
                      return ColoredBox(
                        key: const Key('destination'),
                        color: MetroTheme.of(context).colors.accent,
                      );
                    },
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
    await tester.pumpAndSettle();
    final destination = tester.widget<ColoredBox>(
      find.byKey(const Key('destination')),
    );
    expect(destination.color, MetroColors.teal);
  });

  for (final direction in TextDirection.values) {
    testWidgets('forward slide follows ${direction.name} logical direction', (
      tester,
    ) async {
      await tester.pumpWidget(
        _routeTestApp(
          textDirection: direction,
          child: Builder(
            builder: (context) {
              return MetroButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MetroPageRoute<void>(
                      context: context,
                      transitionDuration: const Duration(seconds: 1),
                      builder: (_) => const ColoredBox(
                        key: Key('destination'),
                        color: MetroColors.cobalt,
                      ),
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
      final initialRect = tester.getRect(find.byKey(const Key('destination')));
      expect(
        initialRect.left,
        closeTo(direction == TextDirection.ltr ? 144 : -144, 0.01),
      );

      await tester.pumpAndSettle();
      expect(
        tester.getRect(find.byKey(const Key('destination'))).left,
        closeTo(0, 0.01),
      );
    });
  }

  testWidgets('page route removes motion when accessibility requests it', (
    tester,
  ) async {
    await tester.pumpWidget(
      _routeTestApp(
        mediaQueryData: const MediaQueryData(disableAnimations: true),
        child: Builder(
          builder: (context) {
            return MetroButton(
              onPressed: () {
                Navigator.of(context).push(
                  MetroPageRoute<void>(
                    context: context,
                    builder: (_) => const ColoredBox(
                      key: Key('destination'),
                      color: MetroColors.cobalt,
                    ),
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
    expect(
      tester.getRect(find.byKey(const Key('destination'))).left,
      closeTo(0, 0.01),
    );
  });
}

Widget _routeTestApp({
  required Widget child,
  MetroThemeData? theme,
  TextDirection textDirection = TextDirection.ltr,
  MediaQueryData mediaQueryData = const MediaQueryData(size: Size(800, 600)),
}) {
  return WidgetsApp(
    color: const Color(0xFF000000),
    onGenerateRoute: (_) => PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondaryAnimation) {
        return MediaQuery(
          data: mediaQueryData,
          child: Directionality(
            textDirection: textDirection,
            child: MetroTheme(
              data: theme ?? MetroThemeData.light(),
              child: child,
            ),
          ),
        );
      },
    ),
  );
}
