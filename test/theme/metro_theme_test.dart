import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_ui/metro_ui.dart';

import '../test_utils.dart';

void main() {
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
