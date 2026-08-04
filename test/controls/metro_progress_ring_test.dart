import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_ui/metro_ui.dart';

import '../test_utils.dart';

void main() {
  testWidgets('determinate ring exposes progress semantics', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      metroTestApp(
        child: const Center(
          child: MetroProgressRing(
            value: 0.68,
            semanticLabel: 'Download progress',
          ),
        ),
      ),
    );

    expect(
      tester.getSemantics(find.byType(MetroProgressRing)),
      matchesSemantics(label: 'Download progress', value: '68%'),
    );
    semantics.dispose();
  });

  testWidgets('theme controls the default ring dimensions', (tester) async {
    await tester.pumpWidget(
      metroTestApp(
        theme: MetroThemeData.light().copyWith(
          progressRingTheme: const MetroProgressRingThemeData(size: 48),
        ),
        child: const Center(child: MetroProgressRing(value: 0.5)),
      ),
    );

    expect(
      tester.getSize(find.byType(MetroProgressRing)),
      const Size.square(48),
    );
  });

  testWidgets('local ring theme overrides the application theme', (
    tester,
  ) async {
    await tester.pumpWidget(
      metroTestApp(
        theme: MetroThemeData.light().copyWith(
          progressRingTheme: const MetroProgressRingThemeData(size: 40),
        ),
        child: const Center(
          child: MetroProgressRingTheme(
            data: MetroProgressRingThemeData(size: 52),
            child: MetroProgressRing(value: 0.5),
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(MetroProgressRing)),
      const Size.square(52),
    );
  });

  testWidgets('reduced motion leaves indeterminate ring stable', (
    tester,
  ) async {
    await tester.pumpWidget(
      metroTestApp(
        mediaQueryData: const MediaQueryData(
          size: Size(800, 600),
          disableAnimations: true,
        ),
        child: const Center(child: MetroProgressRing()),
      ),
    );

    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('indeterminate ring supports activity and semantic overrides', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      metroTestApp(
        child: const Center(
          child: MetroProgressRing(
            active: false,
            semanticLabel: 'Sync progress',
            semanticValue: 'Paused',
          ),
        ),
      ),
    );

    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(
      tester.getSemantics(find.byType(MetroProgressRing)),
      matchesSemantics(label: 'Sync progress', value: 'Paused'),
    );
    semantics.dispose();
  });

  test('ring theme switches from five to six dots at the large threshold', () {
    const theme = MetroProgressRingThemeData();

    expect(theme.smallDotCount, 5);
    expect(theme.largeDotCount, 6);
    expect(theme.largeSizeThreshold, 40);
  });
}
