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
    testWidgets('navigation surfaces render in ${brightness.name} theme', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(800, 600);
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
          data: const MediaQueryData(size: Size(800, 600)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: MetroTheme(
              data: theme,
              child: RepaintBoundary(
                key: boundaryKey,
                child: ColoredBox(
                  color: colors.background,
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: MetroDialog(
                                title: const Text('Delete item?'),
                                content: const Text(
                                  'This action cannot be undone.',
                                ),
                                actions: [
                                  MetroButton(
                                    onPressed: () {},
                                    child: const Text('CANCEL'),
                                  ),
                                  MetroButton.accent(
                                    onPressed: () {},
                                    child: const Text('DELETE'),
                                  ),
                                ],
                              ),
                            ),
                            MetroFlyout(
                              title: const Text('Settings'),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Experience',
                                    style: theme.typography.title,
                                  ),
                                  const SizedBox(height: MetroSpacing.md),
                                  MetroToggleSwitch(
                                    value: true,
                                    onChanged: (_) {},
                                    label: const Text('Notifications'),
                                  ),
                                  const SizedBox(height: MetroSpacing.md),
                                  MetroCheckBox(
                                    value: false,
                                    onChanged: (_) {},
                                    label: const Text('Sync settings'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      MetroCommandBar(
                        leading: const Text('COMMANDS'),
                        commands: [
                          MetroCommandButton(
                            icon: const Text('+'),
                            label: const Text('Add'),
                            onPressed: () {},
                          ),
                          MetroCommandButton(
                            icon: const Text('*'),
                            label: const Text('Favorite'),
                            onPressed: () {},
                            selected: true,
                          ),
                          const MetroCommandButton(
                            icon: Text('x'),
                            label: Text('Disabled'),
                            onPressed: null,
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
      );
      await tester.pump();

      expect(
        find.byKey(boundaryKey),
        matchesGoldenFile('baselines/metro_navigation_${brightness.name}.png'),
      );
    });
  }
}
