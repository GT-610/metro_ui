import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_ui/metro_ui.dart';

/// The canvas every package preview shares.
///
/// 1280 by 720 is the shape the pub.dev gallery presents: the first screenshot
/// becomes the package thumbnail, and a 16:9 card crops a portrait canvas down
/// to a strip. It is also wide enough for three columns of controls, so a
/// preview fills the frame instead of trailing off into empty page.
const Size previewCanvasSize = Size(1280, 720);

const double previewPadding = MetroSpacing.xxl;

/// Loads the bundled Selawik faces under the family the previews ask for.
///
/// The tests deliberately do not use a system family: a golden rendered with
/// whatever the host happens to have installed would not be reproducible on the
/// Windows renderer.
Future<void> loadPreviewFonts() async {
  final fontLoader = FontLoader(previewFontFamily)
    ..addFont(rootBundle.load('assets/fonts/selawik-light.ttf'))
    ..addFont(rootBundle.load('assets/fonts/selawik-regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/selawik-semibold.ttf'));
  await fontLoader.load();
}

const String previewFontFamily = 'Metro UI Sans';

/// Builds the theme a preview renders with, at the canvas size it will use.
MetroThemeData previewTheme(Brightness brightness) {
  final colors = brightness == Brightness.light
      ? MetroColorScheme.light()
      : MetroColorScheme.dark();
  return MetroThemeData(
    colors: colors,
    typography: MetroTypography.fromColorScheme(
      colors,
      fontFamily: previewFontFamily,
    ),
  );
}

/// A titled band of related controls.
class PreviewSection extends StatelessWidget {
  const PreviewSection({
    required this.title,
    required this.child,
    this.description,
    super.key,
  });

  final String title;
  final String? description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = MetroTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: theme.typography.caption.copyWith(
            color: theme.colors.mutedForeground,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        if (description case final description?) ...[
          const SizedBox(height: MetroSpacing.xxs),
          Text(description, style: theme.typography.body),
        ],
        const SizedBox(height: MetroSpacing.sm),
        child,
      ],
    );
  }
}

/// A fixed-width column so two sections can sit side by side without the
/// intrinsic widths of the controls deciding the layout.
class PreviewColumn extends StatelessWidget {
  const PreviewColumn({
    required this.children,
    this.width,
    this.spread = false,
    super.key,
  });

  final List<Widget> children;
  final double? width;

  /// Distributes the sections down the full column height instead of packing
  /// them against the top, which keeps a shorter column from leaving one band
  /// of empty page under the others.
  final bool spread;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: spread
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.start,
        children: [
          for (final (index, child) in children.indexed) ...[
            if (index > 0 && !spread) const SizedBox(height: MetroSpacing.xl),
            child,
          ],
        ],
      ),
    );
  }
}

/// Pumps one preview surface and hands back the boundary its golden is taken
/// from.
///
/// The canvas is pinned through `tester.view` rather than left to the default
/// 800 by 600 test window, so the golden is the size the README shows.
Future<GlobalKey> pumpPreview(
  WidgetTester tester, {
  required Brightness brightness,
  required Widget child,
  MetroThemeData? theme,
  bool padded = true,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = previewCanvasSize;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

  final effectiveTheme = theme ?? previewTheme(brightness);
  final boundaryKey = GlobalKey();

  await tester.pumpWidget(
    MediaQuery(
      data: const MediaQueryData(size: previewCanvasSize),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: MetroTheme(
          data: effectiveTheme,
          child: RepaintBoundary(
            key: boundaryKey,
            child: ColoredBox(
              color: effectiveTheme.colors.background,
              child: padded
                  ? Padding(
                      padding: const EdgeInsets.all(previewPadding),
                      child: child,
                    )
                  : child,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  return boundaryKey;
}

/// Asserts the pumped surface matches `baselines/<name>.png`.
///
/// Written as `await expectLater` on purpose: `expect` with an asynchronous
/// matcher reports success without waiting for the comparison, so a golden
/// checked that way never fails.
Future<void> expectPreview(
  WidgetTester tester,
  GlobalKey boundaryKey,
  String name,
) async {
  await expectLater(
    find.byKey(boundaryKey),
    matchesGoldenFile('baselines/$name.png'),
  );
}
