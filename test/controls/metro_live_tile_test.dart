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
    await tester.pump(const Duration(milliseconds: 100));
    final midpoint = const MetroMotion().standardCurve.transform(0.5);
    expect(_opacityFor(tester, 'RAIN'), closeTo(midpoint, 0.01));
    expect(_opacityFor(tester, 'SUNNY'), closeTo(1 - midpoint, 0.01));
    await tester.pump(const Duration(milliseconds: 120));
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

  testWidgets('horizontal recipe follows Metro 4 live faces', (tester) async {
    await tester.pumpWidget(
      metroTestApp(
        child: Center(
          child: MetroLiveTile(
            key: const ValueKey<String>('slide-live-tile'),
            interval: const Duration(seconds: 1),
            transition: MetroLiveTileTransition.slideLeft,
            transitionDuration: const Duration(milliseconds: 200),
            onPressed: () {},
            frames: const [
              MetroLiveTileFrame(
                displayDuration: Duration(milliseconds: 100),
                child: Text('ONE'),
              ),
              MetroLiveTileFrame(child: Text('TWO')),
            ],
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));
    final incomingSlide = tester.widget<SlideTransition>(
      find.ancestor(
        of: find.text('TWO'),
        matching: find.byType(SlideTransition),
      ),
    );
    final outgoingSlide = tester.widget<SlideTransition>(
      find.ancestor(
        of: find.text('ONE'),
        matching: find.byType(SlideTransition),
      ),
    );
    expect(incomingSlide.position.value.dx, greaterThan(0));
    expect(outgoingSlide.position.value.dx, lessThan(0));
  });

  testWidgets('zoom recipe expands the outgoing Metro 4 live face', (
    tester,
  ) async {
    await tester.pumpWidget(
      metroTestApp(
        child: Center(
          child: MetroLiveTile(
            key: const ValueKey<String>('zoom-live-tile'),
            interval: const Duration(seconds: 1),
            transition: MetroLiveTileTransition.zoom,
            transitionDuration: const Duration(milliseconds: 200),
            onPressed: () {},
            frames: const [
              MetroLiveTileFrame(
                displayDuration: Duration(milliseconds: 100),
                child: Text('A'),
              ),
              MetroLiveTileFrame(child: Text('B')),
            ],
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));
    final incomingScale = tester.widget<ScaleTransition>(
      find.ancestor(of: find.text('B'), matching: find.byType(ScaleTransition)),
    );
    final outgoingScale = tester.widget<ScaleTransition>(
      find.ancestor(of: find.text('A'), matching: find.byType(ScaleTransition)),
    );
    expect(incomingScale.scale.value, greaterThan(1));
    expect(outgoingScale.scale.value, greaterThan(1));
  });
}

double _opacityFor(WidgetTester tester, String text) {
  return tester
      .widget<FadeTransition>(
        find.ancestor(
          of: find.text(text),
          matching: find.byType(FadeTransition),
        ),
      )
      .opacity
      .value;
}
