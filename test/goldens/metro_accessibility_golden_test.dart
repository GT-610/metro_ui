@Tags(['golden'])
library;

import 'package:flutter/rendering.dart';
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

  testWidgets('accessibility surface renders at two times raster density', (
    tester,
  ) async {
    final boundaryKey = await _pumpSurface(
      tester,
      theme: _theme(Brightness.dark),
    );
    final boundary =
        boundaryKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;

    await expectLater(
      boundary.toImage(pixelRatio: 2),
      matchesGoldenFile('baselines/metro_accessibility_dpr_2.png'),
    );
  });

  testWidgets('accessibility surface adapts to 1.5 text scale', (tester) async {
    final boundaryKey = await _pumpSurface(
      tester,
      mediaQueryData: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
      theme: _theme(Brightness.light),
    );

    expect(
      find.byKey(boundaryKey),
      matchesGoldenFile('baselines/metro_accessibility_text_scale_1_5.png'),
    );
  });

  testWidgets('accessibility surface renders a requested high contrast theme', (
    tester,
  ) async {
    final boundaryKey = await _pumpSurface(
      tester,
      highContrastTheme: _theme(Brightness.dark, highContrast: true),
      mediaQueryData: const MediaQueryData(highContrast: true),
      theme: _theme(Brightness.dark),
    );

    expect(
      find.byKey(boundaryKey),
      matchesGoldenFile('baselines/metro_accessibility_high_contrast.png'),
    );
  });
}

Future<GlobalKey> _pumpSurface(
  WidgetTester tester, {
  required MetroThemeData theme,
  MetroThemeData? highContrastTheme,
  MediaQueryData mediaQueryData = const MediaQueryData(),
}) async {
  const size = Size(720, 820);
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

  final boundaryKey = GlobalKey();
  await tester.pumpWidget(
    MediaQuery(
      data: mediaQueryData.copyWith(size: size),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: MetroTheme(
          data: theme,
          highContrastData: highContrastTheme,
          child: RepaintBoundary(
            key: boundaryKey,
            child: const _AccessibilitySurface(),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  return boundaryKey;
}

MetroThemeData _theme(Brightness brightness, {bool highContrast = false}) {
  final colors = switch ((brightness, highContrast)) {
    (Brightness.light, false) => MetroColorScheme.light(),
    (Brightness.dark, false) => MetroColorScheme.dark(),
    (Brightness.light, true) => MetroColorScheme.highContrastLight(),
    (Brightness.dark, true) => MetroColorScheme.highContrastDark(),
  };
  return MetroThemeData(
    colors: colors,
    typography: MetroTypography.fromColorScheme(
      colors,
      fontFamily: 'Metro UI Sans',
    ),
  );
}

class _AccessibilitySurface extends StatelessWidget {
  const _AccessibilitySurface();

  @override
  Widget build(BuildContext context) {
    final theme = MetroTheme.of(context);
    return ColoredBox(
      color: theme.colors.background,
      child: Padding(
        padding: const EdgeInsets.all(MetroSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Accessibility', style: theme.typography.header),
            const SizedBox(height: MetroSpacing.xs),
            const Text('Density, readable type, state, and focus geometry.'),
            const SizedBox(height: MetroSpacing.lg),
            const Wrap(
              spacing: MetroSpacing.sm,
              runSpacing: MetroSpacing.sm,
              children: [
                MetroButton(onPressed: _doNothing, child: Text('OPEN')),
                MetroButton.accent(
                  onPressed: _doNothing,
                  child: Text('CONTINUE'),
                ),
                MetroButton(onPressed: null, child: Text('UNAVAILABLE')),
              ],
            ),
            const SizedBox(height: MetroSpacing.lg),
            const Wrap(
              spacing: MetroSpacing.lg,
              runSpacing: MetroSpacing.sm,
              children: [
                MetroCheckBox(
                  value: true,
                  onChanged: _ignoreNullableBool,
                  label: Text('Keep me signed in'),
                ),
                MetroRadioButton<int>(
                  value: 1,
                  groupValue: 1,
                  onChanged: _ignoreInt,
                  label: Text('Recommended option'),
                ),
                MetroToggleSwitch(
                  value: true,
                  onChanged: _ignoreBool,
                  label: Text('Notifications'),
                ),
              ],
            ),
            const SizedBox(height: MetroSpacing.lg),
            const SizedBox(
              width: 500,
              child: MetroTextField(
                label: Text('Account name'),
                placeholder: 'name@example.com',
                supportingText: Text('Used to identify this device.'),
              ),
            ),
            const SizedBox(height: MetroSpacing.lg),
            const SizedBox(
              width: 620,
              child: MetroListTile(
                selected: true,
                title: Text('Selected library item'),
                subtitle: Text('Secondary text remains readable.'),
                onPressed: _doNothing,
              ),
            ),
            const SizedBox(height: MetroSpacing.lg),
            SizedBox(
              width: 620,
              child: MetroDataGrid<String>(
                columns: [
                  const MetroDataGridColumn<String>(
                    key: 'name',
                    label: Text('NAME'),
                    cellBuilder: _nameCell,
                  ),
                  const MetroDataGridColumn<String>(
                    key: 'state',
                    label: Text('STATE'),
                    width: 150,
                    cellBuilder: _stateCell,
                  ),
                ],
                rows: const ['Primary item', 'Secondary item'],
              ),
            ),
            const SizedBox(height: MetroSpacing.lg),
            const SizedBox(width: 620, child: MetroProgressBar(value: 0.68)),
          ],
        ),
      ),
    );
  }
}

void _doNothing() {}

void _ignoreBool(bool value) {}

void _ignoreNullableBool(bool? value) {}

void _ignoreInt(int? value) {}

Widget _nameCell(BuildContext context, String row, int index) => Text(row);

Widget _stateCell(BuildContext context, String row, int index) =>
    Text(index == 0 ? 'Ready' : 'Waiting');
