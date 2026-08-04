@Tags(['golden'])
library;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_ui/metro_ui.dart';

void main() {
  setUpAll(() async {
    final fontLoader = FontLoader('Metro UI Sans')
      ..addFont(rootBundle.load('assets/fonts/roboto-light.ttf'))
      ..addFont(rootBundle.load('assets/fonts/roboto-regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/roboto-medium.ttf'));
    await fontLoader.load();
  });

  for (final brightness in Brightness.values) {
    testWidgets('controls render in ${brightness.name} theme', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(720, 840);
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
          data: const MediaQueryData(size: Size(720, 840)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: MetroTheme(
              data: theme,
              child: RepaintBoundary(
                key: boundaryKey,
                child: ColoredBox(
                  color: colors.background,
                  child: Padding(
                    padding: const EdgeInsets.all(MetroSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Metro controls', style: theme.typography.header),
                        const SizedBox(height: MetroSpacing.lg),
                        Wrap(
                          spacing: MetroSpacing.sm,
                          runSpacing: MetroSpacing.sm,
                          children: [
                            MetroButton(
                              onPressed: () {},
                              child: const Text('STANDARD'),
                            ),
                            MetroButton.accent(
                              onPressed: () {},
                              child: const Text('ACCENT'),
                            ),
                            const MetroButton(
                              onPressed: null,
                              child: Text('DISABLED'),
                            ),
                          ],
                        ),
                        const SizedBox(height: MetroSpacing.lg),
                        Wrap(
                          spacing: MetroSpacing.lg,
                          runSpacing: MetroSpacing.sm,
                          children: [
                            MetroCheckBox(
                              value: true,
                              onChanged: (_) {},
                              label: const Text('Checked'),
                            ),
                            MetroCheckBox(
                              value: null,
                              tristate: true,
                              onChanged: (_) {},
                              label: const Text('Mixed'),
                            ),
                            MetroRadioButton<int>(
                              value: 1,
                              groupValue: 1,
                              onChanged: (_) {},
                              label: const Text('Selected'),
                            ),
                            MetroToggleSwitch(
                              value: true,
                              onChanged: (_) {},
                              label: const Text('Enabled'),
                            ),
                          ],
                        ),
                        const SizedBox(height: MetroSpacing.lg),
                        const SizedBox(
                          width: 420,
                          child: MetroTextField(
                            label: Text('Account'),
                            placeholder: 'name@example.com',
                          ),
                        ),
                        const SizedBox(height: MetroSpacing.lg),
                        const SizedBox(
                          width: 420,
                          child: Row(
                            children: [
                              Expanded(
                                child: MetroComboBox<String>(
                                  value: 'metro',
                                  items: [
                                    MetroComboBoxItem(
                                      value: 'metro',
                                      child: Text('Metro selection'),
                                    ),
                                    MetroComboBoxItem(
                                      value: 'modern',
                                      child: Text('Modern selection'),
                                    ),
                                  ],
                                  onChanged: _ignoreString,
                                ),
                              ),
                              SizedBox(width: MetroSpacing.sm),
                              SizedBox(
                                width: 140,
                                child: MetroComboBox<String>(
                                  disabledPlaceholder: Text('Unavailable'),
                                  items: [
                                    MetroComboBoxItem(
                                      value: 'disabled',
                                      child: Text('Disabled'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: MetroSpacing.lg),
                        SizedBox(
                          width: 420,
                          child: Column(
                            children: [
                              MetroListTile(
                                selected: true,
                                leading: const SizedBox.square(dimension: 20),
                                title: const Text('Selected item'),
                                subtitle: const Text('Secondary text'),
                                onPressed: () {},
                              ),
                              MetroListTile(
                                title: const Text('Normal item'),
                                subtitle: const Text('Secondary text'),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: MetroSpacing.lg),
                        const SizedBox(
                          width: 420,
                          child: MetroProgressBar(value: 0.64),
                        ),
                        const SizedBox(height: MetroSpacing.lg),
                        MetroTileGrid(
                          tileExtent: 120,
                          children: [
                            MetroTile(title: 'Square', onPressed: () {}),
                            MetroTile(
                              size: MetroTileSize.wide,
                              title: 'Wide tile',
                              backgroundColor: MetroColors.magenta,
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
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
        matchesGoldenFile('baselines/metro_controls_${brightness.name}.png'),
      );
    });
  }
}

void _ignoreString(String? value) {}
