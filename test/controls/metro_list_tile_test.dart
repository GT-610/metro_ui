import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_ui/metro_ui.dart';

import '../test_utils.dart';

void main() {
  final surface = find.byKey(const ValueKey<String>('metro-list-tile-surface'));
  final outline = find.byKey(const ValueKey<String>('metro-list-tile-outline'));
  final scale = find.byKey(const ValueKey<String>('metro-list-tile-scale'));
  final checkmark = find.byKey(
    const ValueKey<String>('metro-list-tile-selection-checkmark'),
  );

  Widget buildTile({
    MetroThemeData? theme,
    bool selected = false,
    bool autofocus = false,
    TextDirection textDirection = TextDirection.ltr,
    MediaQueryData mediaQueryData = const MediaQueryData(size: Size(800, 600)),
  }) {
    return metroTestApp(
      theme: theme,
      mediaQueryData: mediaQueryData,
      child: Directionality(
        textDirection: textDirection,
        child: Center(
          child: SizedBox(
            width: 320,
            child: MetroListTile(
              autofocus: autofocus,
              selected: selected,
              title: const Text('Documents'),
              onPressed: () {},
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('list tile activates with keyboard', (tester) async {
    var count = 0;
    await tester.pumpWidget(
      metroTestApp(
        child: Center(
          child: SizedBox(
            width: 320,
            child: MetroListTile(
              autofocus: true,
              title: const Text('Documents'),
              onPressed: () => count += 1,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(count, 1);
  });

  testWidgets('selected list tile exposes selected semantics', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      metroTestApp(
        child: Center(
          child: SizedBox(
            width: 320,
            child: MetroListTile(
              selected: true,
              semanticLabel: 'Selected documents',
              title: const Text('Documents'),
              onPressed: () {},
            ),
          ),
        ),
      ),
    );
    expect(
      tester.getSemantics(find.byType(MetroListTile)),
      matchesSemantics(
        label: 'Selected documents',
        isButton: true,
        hasSelectedState: true,
        isSelected: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
        isFocusable: true,
        hasFocusAction: true,
      ),
    );
    semantics.dispose();
  });

  testWidgets('local list-tile theme overrides the application theme', (
    tester,
  ) async {
    const localColor = Color(0xFF123456);
    await tester.pumpWidget(
      metroTestApp(
        theme: MetroThemeData.light().copyWith(
          listTileTheme: const MetroListTileThemeData(
            style: MetroListTileStyle(
              backgroundColor: WidgetStatePropertyAll(Color(0xFF654321)),
            ),
          ),
        ),
        child: MetroListTileTheme(
          data: const MetroListTileThemeData(
            style: MetroListTileStyle(
              backgroundColor: WidgetStatePropertyAll(localColor),
            ),
          ),
          child: Center(
            child: SizedBox(
              width: 320,
              child: MetroListTile(
                title: const Text('Local'),
                onPressed: () {},
              ),
            ),
          ),
        ),
      ),
    );

    final container = tester.widget<Container>(surface);
    expect((container.decoration! as BoxDecoration).color, localColor);
  });

  testWidgets('uses WinJS desktop item backgrounds and package row height', (
    tester,
  ) async {
    await tester.pumpWidget(buildTile());

    var container = tester.widget<Container>(surface);
    expect(container.constraints!.minHeight, 52);
    expect(
      (container.decoration! as BoxDecoration).color,
      const Color(0xFFFFFFFF),
    );

    await tester.pumpWidget(buildTile(theme: MetroThemeData.dark()));
    container = tester.widget<Container>(surface);
    expect(
      (container.decoration! as BoxDecoration).color,
      const Color(0xFF1D1D1D),
    );
  });

  testWidgets('hover uses a three pixel full outline and filled hover well', (
    tester,
  ) async {
    final previousStrategy = FocusManager.instance.highlightStrategy;
    addTearDown(() {
      FocusManager.instance.highlightStrategy = previousStrategy;
    });
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    final theme = MetroThemeData.light();
    await tester.pumpWidget(buildTile(theme: theme));
    final position = tester.getCenter(surface);
    await tester.sendEventToBinding(
      const PointerAddedEvent(kind: PointerDeviceKind.mouse),
    );
    await tester.sendEventToBinding(
      PointerHoverEvent(kind: PointerDeviceKind.mouse, position: position),
    );
    await tester.pump();

    final decoration = tester.widget<DecoratedBox>(outline).decoration;
    final border = (decoration as BoxDecoration).border! as Border;
    expect(border.top.width, 3);
    expect(border.top.color, theme.colors.foreground.withValues(alpha: 0.3));
    expect(border.top, border.right);
    expect(border.top, border.bottom);
    expect(border.top, border.left);
    expect(
      (tester.widget<Container>(surface).decoration! as BoxDecoration).color,
      Color.alphaBlend(
        theme.colors.foreground.withValues(alpha: 0.3),
        const Color(0xFFFFFFFF),
      ),
    );
    await tester.sendEventToBinding(
      PointerRemovedEvent(kind: PointerDeviceKind.mouse, position: position),
    );
  });

  testWidgets('keyboard focus uses a two pixel full outline', (tester) async {
    final previousStrategy = FocusManager.instance.highlightStrategy;
    addTearDown(() {
      FocusManager.instance.highlightStrategy = previousStrategy;
    });
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    await tester.pumpWidget(buildTile(autofocus: true));
    await tester.pump();

    final decoration = tester.widget<DecoratedBox>(outline).decoration;
    final border = (decoration as BoxDecoration).border! as Border;
    expect(border.top.width, 2);
    expect(border.top.color, MetroThemeData.light().colors.focus);
    expect(border.top, border.right);
    expect(border.top, border.bottom);
    expect(border.top, border.left);
  });

  testWidgets('outline stays visible between adjacent list tiles', (
    tester,
  ) async {
    await tester.pumpWidget(
      metroTestApp(
        child: Center(
          child: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MetroListTile(
                  key: const ValueKey<String>('first-list-tile'),
                  style: const MetroListTileStyle(
                    borderColor: WidgetStatePropertyAll(Color(0xFF000000)),
                    borderWidth: WidgetStatePropertyAll(2),
                  ),
                  title: const Text('Documents'),
                  onPressed: () {},
                ),
                MetroListTile(title: const Text('Pictures'), onPressed: () {}),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final firstTile = find.byKey(const ValueKey<String>('first-list-tile'));
    final firstSurface = find.descendant(of: firstTile, matching: surface);
    final firstOutline = find.descendant(of: firstTile, matching: outline);
    expect(firstSurface, findsOneWidget);
    expect(firstOutline, findsOneWidget);
    expect(tester.getRect(firstOutline), tester.getRect(firstSurface));
  });

  testWidgets(
    'filled selection uses accent, white content, and a top-end mark',
    (tester) async {
      final theme = MetroThemeData.light();
      await tester.pumpWidget(buildTile(theme: theme, selected: true));

      expect(
        (tester.widget<Container>(surface).decoration! as BoxDecoration).color,
        theme.colors.accent,
      );
      expect(
        DefaultTextStyle.of(tester.element(find.text('Documents'))).style.color,
        const Color(0xFFFFFFFF),
      );
      final markTopRight = tester.getTopRight(checkmark);
      final surfaceTopRight = tester.getTopRight(surface);
      expect(markTopRight.dx, closeTo(surfaceTopRight.dx, 0.01));
      expect(markTopRight.dy, closeTo(surfaceTopRight.dy, 0.01));
    },
  );

  testWidgets('selection checkmark mirrors to logical top-end in RTL', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTile(selected: true, textDirection: TextDirection.rtl),
    );

    final markTopLeft = tester.getTopLeft(checkmark);
    final surfaceTopLeft = tester.getTopLeft(surface);
    expect(markTopLeft.dx, closeTo(surfaceTopLeft.dx, 0.01));
    expect(markTopLeft.dy, closeTo(surfaceTopLeft.dy, 0.01));
  });

  testWidgets('pointer press uses the WinJS 0.975 scale recipe', (
    tester,
  ) async {
    await tester.pumpWidget(buildTile());
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(MetroListTile)),
    );
    await tester.pump();

    var animatedScale = tester.widget<AnimatedScale>(scale);
    expect(animatedScale.scale, 0.975);
    expect(animatedScale.duration, const Duration(milliseconds: 167));
    expect(animatedScale.curve, MetroThemeData.light().motion.standardCurve);

    await gesture.up();
    await tester.pump();
    animatedScale = tester.widget<AnimatedScale>(scale);
    expect(animatedScale.scale, 1);
  });

  testWidgets('reduced motion makes the press transform immediate', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTile(
        mediaQueryData: const MediaQueryData(
          size: Size(800, 600),
          disableAnimations: true,
        ),
      ),
    );

    expect(tester.widget<AnimatedScale>(scale).duration, Duration.zero);
  });
}
