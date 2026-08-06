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
    testWidgets('SearchBox renders in ${brightness.name} theme', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(480, 360);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      final controller = TextEditingController(text: 'met');
      addTearDown(controller.dispose);
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
          data: const MediaQueryData(size: Size(480, 360)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: MetroTheme(
              data: theme,
              child: RepaintBoundary(
                key: boundaryKey,
                child: ColoredBox(
                  color: colors.background,
                  child: Overlay(
                    initialEntries: [
                      OverlayEntry(
                        builder: (context) {
                          return Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: MetroSpacing.xl,
                              ),
                              child: SizedBox(
                                width: 360,
                                child: MetroSearchBox<String>(
                                  autofocus: true,
                                  controller: controller,
                                  placeholder: 'Search controls',
                                  semanticLabel: 'Search the gallery',
                                  items: const [
                                    MetroSearchBoxItem(
                                      value: 'metro-ui',
                                      queryText: 'Metro UI components',
                                      child: Text('Metro UI components'),
                                    ),
                                    MetroSearchBoxItem(
                                      value: 'typography',
                                      queryText: 'Metro typography',
                                      child: Text('Metro typography'),
                                    ),
                                    MetroSearchBoxItem(
                                      value: 'motion',
                                      queryText: 'Directional motion',
                                      child: Text('Directional motion'),
                                    ),
                                  ],
                                  onSubmitted: _ignoreQuery,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(boundaryKey),
        matchesGoldenFile('baselines/metro_search_box_${brightness.name}.png'),
      );
    });
  }
}

void _ignoreQuery(String query) {}
