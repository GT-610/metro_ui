import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_ui/metro_ui.dart';

import '../test_utils.dart';

void main() {
  test('typography uses system Segoe UI on Windows', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    final typography = MetroTypography.fromColorScheme(
      MetroColorScheme.light(),
    );

    expect(typography.body.fontFamily, 'Segoe UI');
    expect(typography.hero.fontWeight, FontWeight.w300);
    expect(typography.bodyStrong.fontWeight, FontWeight.w600);
  });

  test('typography uses the bundled Metro family off Windows', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    final typography = MetroTypography.fromColorScheme(
      MetroColorScheme.light(),
    );

    expect(typography.body.fontFamily, 'packages/metro_ui/Metro UI Sans');
    expect(typography.body.fontFamilyFallback, const <String>[
      'Noto Sans',
      'Arial',
      'sans-serif',
    ]);
  });

  test('motion defaults match the Windows 8 animation recipes', () {
    const motion = MetroMotion();

    expect(motion.fast, const Duration(milliseconds: 100));
    expect(motion.normal, const Duration(milliseconds: 167));
    expect(motion.fadeIn, const Duration(milliseconds: 250));
    expect(motion.popupFade, const Duration(milliseconds: 83));
    expect(motion.navigationFade, const Duration(milliseconds: 170));
    expect(motion.exit, const Duration(milliseconds: 117));
    expect(motion.content, const Duration(milliseconds: 350));
    expect(motion.semanticZoom, const Duration(milliseconds: 333));
    expect(motion.contentFade, const Duration(milliseconds: 170));
    expect(motion.contentEntrance, const Duration(milliseconds: 550));
    expect(motion.entrance, const Duration(milliseconds: 367));
    expect(motion.panel, const Duration(milliseconds: 550));
    expect(motion.navigation, const Duration(milliseconds: 1000));
    expect(motion.standardCurve, const Cubic(0.1, 0.9, 0.2, 1));
    expect(motion.contentCurve, const Cubic(0.17, 0.79, 0.215, 1.0025));
    expect(
      motion.contentExitCurve,
      const Cubic(0.3825, 0.0025, 0.8775, -0.1075),
    );
  });

  test('bright accents receive a dark foreground', () {
    final scheme = MetroColorScheme.light(accent: MetroColors.yellow);

    expect(scheme.onAccent, const Color(0xFF000000));
  });

  test('high contrast palettes keep primary content at AAA contrast', () {
    for (final scheme in [
      MetroColorScheme.highContrastLight(),
      MetroColorScheme.highContrastDark(),
    ]) {
      expect(scheme.isHighContrast, isTrue);
      expect(
        _contrastRatio(scheme.foreground, scheme.background),
        greaterThanOrEqualTo(7),
      );
      expect(
        _contrastRatio(scheme.mutedForeground, scheme.background),
        greaterThanOrEqualTo(7),
      );
      expect(
        _contrastRatio(scheme.onAccent, scheme.accent),
        greaterThanOrEqualTo(7),
      );
    }
  });

  test('withAccent preserves custom typography', () {
    final customTypography = MetroTypography.fromColorScheme(
      MetroColorScheme.light(),
    ).copyWith(body: const TextStyle(fontSize: 18));
    final theme = MetroThemeData(
      colors: MetroColorScheme.light(),
      typography: customTypography,
    );

    expect(theme.withAccent(MetroColors.orange).typography, customTypography);
    expect(
      theme.withAccent(MetroColors.orange).colors.accent,
      MetroColors.orange,
    );
  });

  testWidgets('MetroTheme supplies typography and icon color', (tester) async {
    final theme = MetroThemeData.dark();

    await tester.pumpWidget(
      metroTestApp(
        theme: theme,
        child: Builder(
          builder: (context) {
            expect(MetroTheme.of(context), same(theme));
            expect(DefaultTextStyle.of(context).style, theme.typography.body);
            expect(IconTheme.of(context).color, theme.colors.foreground);
            return const SizedBox();
          },
        ),
      ),
    );
  });

  testWidgets('MetroTheme uses supplied high contrast data on request', (
    tester,
  ) async {
    final normal = MetroThemeData.light();
    final highContrast = MetroThemeData.highContrastDark();

    await tester.pumpWidget(
      metroTestApp(
        mediaQueryData: const MediaQueryData(highContrast: true),
        child: MetroTheme(
          data: normal,
          highContrastData: highContrast,
          child: Builder(
            builder: (context) {
              expect(MetroTheme.of(context), same(highContrast));
              expect(
                DefaultTextStyle.of(context).style,
                highContrast.typography.body,
              );
              expect(
                IconTheme.of(context).color,
                highContrast.colors.foreground,
              );
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  });

  testWidgets('AnimatedMetroTheme interpolates theme data', (tester) async {
    final light = MetroThemeData.light();
    final dark = MetroThemeData.dark();

    await tester.pumpWidget(
      metroTestApp(
        child: AnimatedMetroTheme(
          data: light,
          child: Builder(
            builder: (context) {
              return ColoredBox(
                color: MetroTheme.of(context).colors.background,
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpWidget(
      metroTestApp(
        child: AnimatedMetroTheme(
          data: dark,
          child: Builder(
            builder: (context) {
              return ColoredBox(
                color: MetroTheme.of(context).colors.background,
              );
            },
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    final box = tester.widget<ColoredBox>(find.byType(ColoredBox));
    expect(box.color, isNot(light.colors.background));
    expect(box.color, isNot(dark.colors.background));
  });
}

double _contrastRatio(Color first, Color second) {
  final lighter = first.computeLuminance() > second.computeLuminance()
      ? first.computeLuminance()
      : second.computeLuminance();
  final darker = first.computeLuminance() > second.computeLuminance()
      ? second.computeLuminance()
      : first.computeLuminance();
  return (lighter + 0.05) / (darker + 0.05);
}
