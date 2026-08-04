import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_ui/metro_ui.dart';

import '../test_utils.dart';

void main() {
  testWidgets('live tile advances frames and updates semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    int? frameIndex;
    await tester.pumpWidget(
      metroTestApp(
        child: Center(
          child: MetroLiveTile(
            title: 'Weather',
            interval: const Duration(seconds: 2),
            transitionDuration: const Duration(milliseconds: 200),
            onFrameChanged: (index) => frameIndex = index,
            onPressed: () {},
            frames: const [
              MetroLiveTileFrame(
                id: 'sunny',
                displayDuration: Duration(milliseconds: 500),
                semanticLabel: 'Sunny, 24 degrees',
                child: Center(child: Text('SUNNY')),
              ),
              MetroLiveTileFrame(
                id: 'rain',
                semanticLabel: 'Rain expected',
                child: Center(child: Text('RAIN')),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('SUNNY'), findsOneWidget);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Sunny, 24 degrees')),
      matchesSemantics(
        label: 'Sunny, 24 degrees',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
        isFocusable: true,
        hasFocusAction: true,
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));
    expect(frameIndex, 1);
    expect(find.text('RAIN'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 220));
    expect(find.text('SUNNY'), findsNothing);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Rain expected')),
      matchesSemantics(
        label: 'Rain expected',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
        isFocusable: true,
        hasFocusAction: true,
      ),
    );
    semantics.dispose();
  });

  testWidgets('reduced motion freezes automatic frame changes', (tester) async {
    await tester.pumpWidget(
      metroTestApp(
        mediaQueryData: const MediaQueryData(
          size: Size(800, 600),
          disableAnimations: true,
        ),
        child: Center(
          child: MetroLiveTile(
            interval: const Duration(milliseconds: 100),
            onPressed: () {},
            frames: const [
              MetroLiveTileFrame(child: Text('FIRST')),
              MetroLiveTileFrame(child: Text('SECOND')),
            ],
          ),
        ),
      ),
    );

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('FIRST'), findsOneWidget);
    expect(find.text('SECOND'), findsNothing);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('live tile keeps Metro keyboard activation', (tester) async {
    var activations = 0;
    await tester.pumpWidget(
      metroTestApp(
        child: Center(
          child: MetroLiveTile(
            autofocus: true,
            active: false,
            onPressed: () => activations += 1,
            frames: const [MetroLiveTileFrame(child: Text('NEWS'))],
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(activations, 1);
  });

  testWidgets('stable ids retain the visible frame across list updates', (
    tester,
  ) async {
    late StateSetter setHostState;
    var reversed = false;
    await tester.pumpWidget(
      metroTestApp(
        child: StatefulBuilder(
          builder: (context, setState) {
            setHostState = setState;
            final frames = <MetroLiveTileFrame>[
              const MetroLiveTileFrame(id: 'one', child: Text('ONE')),
              const MetroLiveTileFrame(id: 'two', child: Text('TWO')),
            ];
            return MetroLiveTile(
              active: false,
              initialIndex: 1,
              onPressed: () {},
              frames: reversed ? frames.reversed.toList() : frames,
            );
          },
        ),
      ),
    );

    expect(find.text('TWO'), findsOneWidget);
    setHostState(() => reversed = true);
    await tester.pump();
    expect(find.text('TWO'), findsOneWidget);
    expect(find.text('ONE'), findsNothing);
  });
}
