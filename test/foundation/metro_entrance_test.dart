import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_ui/metro_ui.dart';

import '../test_utils.dart';

void main() {
  const motion = MetroMotion();

  testWidgets('entrance follows the page recipe and logical direction', (
    tester,
  ) async {
    await tester.pumpWidget(
      metroTestApp(child: const MetroEntrance(child: Text('CONTENT'))),
    );

    var transform = tester.widget<Transform>(
      find
          .ancestor(of: find.text('CONTENT'), matching: find.byType(Transform))
          .first,
    );
    expect(transform.transform.getTranslation().x, closeTo(100, 0.01));

    await tester.pump(motion.navigationFade);
    final opacity = tester.widget<Opacity>(
      find.ancestor(of: find.text('CONTENT'), matching: find.byType(Opacity)),
    );
    expect(opacity.opacity, closeTo(1, 0.01));

    await tester.pump(motion.navigation - motion.navigationFade);
    transform = tester.widget<Transform>(
      find
          .ancestor(of: find.text('CONTENT'), matching: find.byType(Transform))
          .first,
    );
    expect(transform.transform.getTranslation().x, closeTo(0, 0.01));
  });

  testWidgets('indexed entrances use the configured stagger', (tester) async {
    await tester.pumpWidget(
      metroTestApp(
        child: const MetroEntrance(
          index: 2,
          stagger: Duration(milliseconds: 75),
          child: Text('DELAYED'),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 149));
    var opacity = tester.widget<Opacity>(
      find.ancestor(of: find.text('DELAYED'), matching: find.byType(Opacity)),
    );
    expect(opacity.opacity, 0);

    await tester.pump(const Duration(milliseconds: 86));
    opacity = tester.widget<Opacity>(
      find.ancestor(of: find.text('DELAYED'), matching: find.byType(Opacity)),
    );
    expect(opacity.opacity, greaterThan(0));
  });

  testWidgets('forward entrance mirrors in RTL', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(800, 600)),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: MetroTheme(
            data: MetroThemeData.light(),
            child: const MetroEntrance(child: Text('RTL')),
          ),
        ),
      ),
    );

    final transform = tester.widget<Transform>(
      find
          .ancestor(of: find.text('RTL'), matching: find.byType(Transform))
          .first,
    );
    expect(transform.transform.getTranslation().x, closeTo(-100, 0.01));
  });

  testWidgets('reduced motion presents entrance content immediately', (
    tester,
  ) async {
    await tester.pumpWidget(
      metroTestApp(
        mediaQueryData: const MediaQueryData(
          size: Size(800, 600),
          disableAnimations: true,
        ),
        child: const MetroEntrance(index: 4, child: Text('STATIC')),
      ),
    );

    final opacity = tester.widget<Opacity>(
      find.ancestor(of: find.text('STATIC'), matching: find.byType(Opacity)),
    );
    final transform = tester.widget<Transform>(
      find
          .ancestor(of: find.text('STATIC'), matching: find.byType(Transform))
          .first,
    );
    expect(opacity.opacity, 1);
    expect(transform.transform.getTranslation().x, 0);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('disabled ticker mode presents entrance content immediately', (
    tester,
  ) async {
    await tester.pumpWidget(
      metroTestApp(
        child: const TickerMode(
          enabled: false,
          child: MetroEntrance(index: 4, child: Text('STATIC')),
        ),
      ),
    );

    final opacity = tester.widget<Opacity>(
      find.ancestor(of: find.text('STATIC'), matching: find.byType(Opacity)),
    );
    final transform = tester.widget<Transform>(
      find
          .ancestor(of: find.text('STATIC'), matching: find.byType(Transform))
          .first,
    );
    expect(opacity.opacity, 1);
    expect(transform.transform.getTranslation().x, 0);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });
}
