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
    testWidgets('FlipView renders in ${brightness.name} theme', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(720, 360);
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
          data: const MediaQueryData(size: Size(720, 360)),
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
                    child: MetroFlipView(
                      initialIndex: 1,
                      circular: true,
                      navigationVisibility:
                          MetroFlipViewNavigationVisibility.always,
                      showIndicators: true,
                      semanticLabel: 'Feature stories',
                      items: const [
                        MetroFlipViewItem(
                          banner: Text('DIRECT INTERACTION'),
                          child: _GoldenStory(
                            color: MetroColors.cobalt,
                            eyebrow: 'MODERN UI',
                            title: 'CONTENT FIRST',
                          ),
                        ),
                        MetroFlipViewItem(
                          banner: Text('BOLD TYPE CREATES HIERARCHY'),
                          child: _GoldenStory(
                            color: MetroColors.magenta,
                            eyebrow: 'TYPOGRAPHY',
                            title: 'CLEAR AND CONFIDENT',
                          ),
                        ),
                        MetroFlipViewItem(
                          banner: Text('DIRECTION PRESERVES CONTEXT'),
                          child: _GoldenStory(
                            color: MetroColors.emerald,
                            eyebrow: 'MOTION',
                            title: 'THE NEXT STORY',
                          ),
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
        matchesGoldenFile('baselines/metro_flip_view_${brightness.name}.png'),
      );
    });
  }
}

class _GoldenStory extends StatelessWidget {
  const _GoldenStory({
    required this.color,
    required this.eyebrow,
    required this.title,
  });

  final Color color;
  final String eyebrow;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(64, MetroSpacing.xl, 64, 72),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eyebrow,
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontFamily: 'Metro UI Sans',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: MetroSpacing.sm),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontFamily: 'Metro UI Sans',
                fontSize: 42,
                fontWeight: FontWeight.w300,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
