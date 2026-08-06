import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_ui/metro_ui.dart';

import '../test_utils.dart';

void main() {
  testWidgets(
    'bar defaults match WinJS determinate and indeterminate metrics',
    (tester) async {
      await tester.pumpWidget(
        metroTestApp(
          child: const Center(
            child: SizedBox(width: 180, child: MetroProgressBar(value: 0.5)),
          ),
        ),
      );

      var paintFinder = find.descendant(
        of: find.byType(MetroProgressBar),
        matching: find.byType(CustomPaint),
      );
      expect(tester.getSize(find.byType(MetroProgressBar)).height, 6);
      expect(
        paintFinder,
        paints
          ..rect(color: const Color(0x33000000))
          ..rect(color: MetroColors.cobalt),
      );

      await tester.pumpWidget(
        metroTestApp(
          mediaQueryData: const MediaQueryData(
            size: Size(800, 600),
            disableAnimations: true,
          ),
          child: const Center(
            child: SizedBox(width: 180, child: MetroProgressBar()),
          ),
        ),
      );
      paintFinder = find.descendant(
        of: find.byType(MetroProgressBar),
        matching: find.byType(CustomPaint),
      );
      expect(tester.getSize(find.byType(MetroProgressBar)).height, 4);
      expect(
        paintFinder,
        paints
          ..rect(color: const Color(0x00000000))
          ..circle(color: MetroColors.cobalt),
      );
    },
  );

  testWidgets('determinate bar exposes progress semantics', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      metroTestApp(
        child: const Center(
          child: SizedBox(
            width: 240,
            child: MetroProgressBar(
              value: 0.42,
              semanticLabel: 'Install progress',
            ),
          ),
        ),
      ),
    );
    expect(
      tester.getSemantics(find.byType(MetroProgressBar)),
      matchesSemantics(label: 'Install progress', value: '42%'),
    );
    semantics.dispose();
  });

  testWidgets('reduced motion leaves indeterminate bar stable', (tester) async {
    await tester.pumpWidget(
      metroTestApp(
        mediaQueryData: const MediaQueryData(
          size: Size(800, 600),
          disableAnimations: true,
        ),
        child: const Center(
          child: SizedBox(width: 240, child: MetroProgressBar()),
        ),
      ),
    );
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('indeterminate bar accepts a localized semantic value', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      metroTestApp(
        mediaQueryData: const MediaQueryData(
          size: Size(800, 600),
          disableAnimations: true,
        ),
        child: const Center(
          child: SizedBox(
            width: 240,
            child: MetroProgressBar(
              semanticLabel: 'Install progress',
              semanticValue: 'Working',
            ),
          ),
        ),
      ),
    );

    expect(
      tester.getSemantics(find.byType(MetroProgressBar)),
      matchesSemantics(label: 'Install progress', value: 'Working'),
    );
    semantics.dispose();
  });

  testWidgets('inactive indeterminate bar does not schedule animation', (
    tester,
  ) async {
    await tester.pumpWidget(
      metroTestApp(
        child: const Center(
          child: SizedBox(width: 240, child: MetroProgressBar(active: false)),
        ),
      ),
    );

    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('local progress-bar theme overrides application metrics', (
    tester,
  ) async {
    await tester.pumpWidget(
      metroTestApp(
        theme: MetroThemeData.light().copyWith(
          progressBarTheme: const MetroProgressBarThemeData(height: 6),
        ),
        child: const Center(
          child: MetroProgressBarTheme(
            data: MetroProgressBarThemeData(height: 10),
            child: SizedBox(width: 200, child: MetroProgressBar(value: 0.5)),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(MetroProgressBar)).height, 10);
  });

  testWidgets('determinate bar fills from the logical start edge', (
    tester,
  ) async {
    Future<CustomPainter> pumpWithDirection(TextDirection direction) async {
      await tester.pumpWidget(
        metroTestApp(
          child: Center(
            child: Directionality(
              textDirection: direction,
              child: const SizedBox(
                width: 100,
                child: MetroProgressBar(value: 0.25),
              ),
            ),
          ),
        ),
      );
      return tester
          .widget<CustomPaint>(
            find.descendant(
              of: find.byType(MetroProgressBar),
              matching: find.byType(CustomPaint),
            ),
          )
          .painter!;
    }

    final ltrPainter = await pumpWithDirection(TextDirection.ltr);
    final rtlPainter = await pumpWithDirection(TextDirection.rtl);

    expect(rtlPainter.shouldRepaint(ltrPainter), isTrue);
  });
}
