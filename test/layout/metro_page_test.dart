import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_ui/metro_ui.dart';

import '../test_utils.dart';

void main() {
  testWidgets('page uses theme background and header typography', (
    tester,
  ) async {
    final theme = MetroThemeData.dark();
    await tester.pumpWidget(
      metroTestApp(
        theme: theme,
        child: const MetroPage(title: Text('Settings'), child: Text('Content')),
      ),
    );

    final background = tester.widget<ColoredBox>(find.byType(ColoredBox));
    final title = tester.widget<Text>(find.text('Settings'));
    final titleStyle = DefaultTextStyle.of(
      tester.element(find.text('Settings')),
    ).style;

    expect(background.color, theme.colors.background);
    expect(title.data, 'Settings');
    expect(titleStyle.fontSize, theme.typography.hero.fontSize);
  });

  testWidgets('page aligns a Windows 8 back button before the title', (
    tester,
  ) async {
    await tester.pumpWidget(
      metroTestApp(
        child: MetroPage(
          leading: MetroBackButton(onPressed: () {}),
          title: const Text('Details'),
          child: const Text('Content'),
        ),
      ),
    );

    final back = tester.getRect(find.byType(MetroBackButton));
    final title = tester.getRect(find.text('Details'));
    expect(title.left - back.right, closeTo(20, 0.01));
    expect(title.top, closeTo(back.top, 0.01));
  });

  testWidgets('page places an optional bar below its content', (tester) async {
    await tester.pumpWidget(
      metroTestApp(
        child: const MetroPage(
          bottomBar: SizedBox(key: Key('bar'), height: 72),
          child: Text('Content'),
        ),
      ),
    );

    final content = tester.getRect(find.text('Content'));
    final bar = tester.getRect(find.byKey(const Key('bar')));
    expect(bar.top, greaterThan(content.bottom));
    expect(bar.bottom, 600);
  });
}
