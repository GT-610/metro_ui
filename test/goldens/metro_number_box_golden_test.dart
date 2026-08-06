@Tags(['golden'])
library;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_ui/metro_ui.dart';

void main() {
  setUpAll(() async {
    final fontLoader = FontLoader('Metro UI Sans')
      ..addFont(rootBundle.load('assets/fonts/selawik-light.ttf'))
      ..addFont(rootBundle.load('assets/fonts/selawik-regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/selawik-semibold.ttf'));
    await fontLoader.load();
  });

  for (final brightness in Brightness.values) {
    testWidgets('NumberBox renders in ${brightness.name} theme', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(480, 300);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      final colors = brightness == Brightness.light
          ? MetroColorScheme.light()
          : MetroColorScheme.dark();
      final theme = MetroThemeData(
        colors: colors,
        typography: MetroTypography.fromColorScheme(
          colors,
          fontFamily: 'Metro UI Sans',
        ),
      );
      final boundaryKey = GlobalKey();

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(480, 300)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: MetroTheme(
              data: theme,
              child: RepaintBoundary(
                key: boundaryKey,
                child: ColoredBox(
                  color: colors.background,
                  child: const Center(
                    child: SizedBox(
                      width: 360,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MetroNumberBox<int>(
                            value: 4,
                            min: 1,
                            max: 12,
                            prefix: Text('COPIES'),
                            onChanged: _ignoreInt,
                          ),
                          SizedBox(height: MetroSpacing.md),
                          MetroNumberBoxTheme(
                            data: MetroNumberBoxThemeData(
                              style: MetroNumberBoxStyle(
                                buttonBackgroundColor: WidgetStatePropertyAll(
                                  MetroColors.orange,
                                ),
                              ),
                            ),
                            child: MetroNumberBox<double>(
                              value: 21.5,
                              decimalPlaces: 1,
                              formatter: _formatTemperature,
                              parser: _parseTemperature,
                              onChanged: _ignoreDouble,
                            ),
                          ),
                          SizedBox(height: MetroSpacing.md),
                          MetroNumberBox<int>(value: 10, onChanged: null),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(boundaryKey),
        matchesGoldenFile('baselines/metro_number_box_${brightness.name}.png'),
      );
    });
  }
}

String _formatTemperature(double? value) {
  return value == null ? '' : '${value.toStringAsFixed(1)} °C';
}

double? _parseTemperature(String text) {
  return double.tryParse(text.replaceAll('°C', '').trim());
}

void _ignoreInt(int? value) {}

void _ignoreDouble(double? value) {}
