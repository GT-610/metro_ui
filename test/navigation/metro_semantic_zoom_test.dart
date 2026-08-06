import 'dart:ui' show SemanticsAction;

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_ui/metro_ui.dart';

import '../test_utils.dart';

const _zoomedInKey = ValueKey<String>('metro-semantic-zoom-in-view');
const _zoomedOutKey = ValueKey<String>('metro-semantic-zoom-out-view');
const _buttonKey = ValueKey<String>('metro-semantic-zoom-button');

void main() {
  testWidgets('keyboard zoom uses the 333ms cross-scale transition', (
    tester,
  ) async {
    final changes = <bool>[];
    await tester.pumpWidget(
      _testApp(
        MetroSemanticZoom(
          autofocus: true,
          height: 200,
          onZoomedOutChanged: changes.add,
          zoomedInView: const ColoredBox(
            key: Key('details'),
            color: Color(0xFF0078D7),
          ),
          zoomedOutView: const ColoredBox(
            key: Key('summary'),
            color: Color(0xFFE3008C),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(_opacity(tester, _zoomedInKey), 1);
    expect(_opacity(tester, _zoomedOutKey), 0);
    expect(find.byKey(const Key('details')).hitTestable(), findsOneWidget);
    expect(find.byKey(const Key('summary')).hitTestable(), findsNothing);

    await _sendControlShortcut(tester, LogicalKeyboardKey.minus);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 166));

    expect(changes, [true]);
    expect(_opacity(tester, _zoomedInKey), inExclusiveRange(0, 1));
    expect(_opacity(tester, _zoomedOutKey), inExclusiveRange(0, 1));
    expect(_scale(tester, _zoomedInKey), inExclusiveRange(0.65, 1));
    expect(_scale(tester, _zoomedOutKey), greaterThan(1));

    await tester.pump(const Duration(milliseconds: 167));

    expect(_opacity(tester, _zoomedInKey), 0);
    expect(_opacity(tester, _zoomedOutKey), 1);
    expect(find.byKey(const Key('details')).hitTestable(), findsNothing);
    expect(find.byKey(const Key('summary')).hitTestable(), findsOneWidget);
  });

  testWidgets('controlled zoom waits for the owner to accept a request', (
    tester,
  ) async {
    var zoomedOut = false;
    late StateSetter setOwnerState;
    final requests = <bool>[];
    await tester.pumpWidget(
      _testApp(
        StatefulBuilder(
          builder: (context, setState) {
            setOwnerState = setState;
            return MetroSemanticZoom(
              autofocus: true,
              height: 200,
              zoomedOut: zoomedOut,
              onZoomedOutChanged: requests.add,
              zoomedInView: const SizedBox.expand(),
              zoomedOutView: const SizedBox.expand(),
            );
          },
        ),
      ),
    );
    await tester.pump();

    await _sendControlShortcut(tester, LogicalKeyboardKey.minus);
    await tester.pump(const Duration(milliseconds: 333));

    expect(requests, [true]);
    expect(_opacity(tester, _zoomedInKey), 1);
    expect(_opacity(tester, _zoomedOutKey), 0);

    setOwnerState(() => zoomedOut = true);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 333));

    expect(_opacity(tester, _zoomedInKey), 0);
    expect(_opacity(tester, _zoomedOutKey), 1);
  });

  testWidgets('two-pointer pinch switches in both directions', (tester) async {
    final changes = <bool>[];
    await tester.pumpWidget(
      _testApp(
        MetroSemanticZoom(
          height: 200,
          onZoomedOutChanged: changes.add,
          zoomedInView: const SizedBox.expand(),
          zoomedOutView: const SizedBox.expand(),
        ),
      ),
    );

    final first = await tester.createGesture(pointer: 1);
    final second = await tester.createGesture(pointer: 2);
    await first.down(const Offset(330, 300));
    await second.down(const Offset(470, 300));
    await first.moveTo(const Offset(370, 300));
    await first.up();
    await second.up();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 333));

    expect(changes, [true]);
    expect(_opacity(tester, _zoomedOutKey), 1);

    final third = await tester.createGesture(pointer: 3);
    final fourth = await tester.createGesture(pointer: 4);
    await third.down(const Offset(370, 300));
    await fourth.down(const Offset(430, 300));
    await third.moveTo(const Offset(320, 300));
    await third.up();
    await fourth.up();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 333));

    expect(changes, [true, false]);
    expect(_opacity(tester, _zoomedInKey), 1);
  });

  testWidgets('desktop button follows WinJS geometry and mirrors in RTL', (
    tester,
  ) async {
    const widgetColor = Color(0xFF778899);
    await tester.pumpWidget(
      _testApp(
        const Directionality(
          textDirection: TextDirection.rtl,
          child: MetroSemanticZoomTheme(
            data: MetroSemanticZoomThemeData(
              style: MetroSemanticZoomStyle(
                buttonBackgroundColor: WidgetStatePropertyAll(
                  Color(0xFF445566),
                ),
              ),
            ),
            child: MetroSemanticZoom(
              height: 200,
              style: MetroSemanticZoomStyle(
                buttonBackgroundColor: WidgetStatePropertyAll(widgetColor),
                buttonSize: 31,
              ),
              zoomedInView: SizedBox.expand(),
              zoomedOutView: SizedBox.expand(),
            ),
          ),
        ),
        theme: MetroThemeData.light().copyWith(
          semanticZoomTheme: const MetroSemanticZoomThemeData(
            style: MetroSemanticZoomStyle(
              buttonBackgroundColor: WidgetStatePropertyAll(Color(0xFF112233)),
            ),
          ),
        ),
      ),
    );

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(300, 250));
    await mouse.moveTo(const Offset(320, 250));
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byKey(_buttonKey).hitTestable(), findsOneWidget);
    final rootRect = tester.getRect(find.byType(MetroSemanticZoom));
    final buttonRect = tester.getRect(find.byKey(_buttonKey));
    expect(buttonRect.size, const Size.square(31));
    expect(buttonRect.left, closeTo(rootRect.left + 4, 0.01));
    expect(buttonRect.bottom, closeTo(rootRect.bottom - 21, 0.01));
    final decoration =
        tester
                .widget<DecoratedBox>(
                  find.descendant(
                    of: find.byKey(_buttonKey),
                    matching: find.byType(DecoratedBox),
                  ),
                )
                .decoration
            as BoxDecoration;
    expect(decoration.color, widgetColor);

    await mouse.removePointer();
  });

  testWidgets('button and assistive semantics provide alternate navigation', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final changes = <bool>[];
    await tester.pumpWidget(
      _testApp(
        MetroSemanticZoom(
          height: 200,
          semanticLabel: 'Collection navigation',
          onZoomedOutChanged: changes.add,
          zoomedInView: const Text('Detailed albums'),
          zoomedOutView: const Text('Album groups'),
        ),
      ),
    );

    var data = tester
        .getSemantics(find.bySemanticsLabel('Collection navigation'))
        .getSemanticsData();
    expect(data.value, 'Detailed view');
    expect(data.hasAction(SemanticsAction.tap), isTrue);
    expect(data.hasAction(SemanticsAction.decrease), isTrue);
    expect(data.hasAction(SemanticsAction.increase), isFalse);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(300, 250));
    await mouse.moveTo(const Offset(320, 250));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(find.byKey(_buttonKey));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 333));

    expect(changes, [true]);
    data = tester
        .getSemantics(find.bySemanticsLabel('Collection navigation'))
        .getSemanticsData();
    expect(data.value, 'Summary view');
    expect(data.hasAction(SemanticsAction.increase), isTrue);
    expect(data.hasAction(SemanticsAction.decrease), isFalse);
    expect(_semanticsExcluded(tester, _zoomedInKey), isTrue);
    expect(_semanticsExcluded(tester, _zoomedOutKey), isFalse);

    await mouse.removePointer();
    semantics.dispose();
  });

  testWidgets(
    'reduced motion commits immediately and locked mode ignores input',
    (tester) async {
      final reducedChanges = <bool>[];
      await tester.pumpWidget(
        _testApp(
          MetroSemanticZoom(
            key: const ValueKey<String>('locked-semantic-zoom'),
            autofocus: true,
            height: 200,
            onZoomedOutChanged: reducedChanges.add,
            zoomedInView: const SizedBox.expand(),
            zoomedOutView: const SizedBox.expand(),
          ),
          mediaQueryData: const MediaQueryData(
            size: Size(800, 600),
            disableAnimations: true,
          ),
        ),
      );
      await tester.pump();

      await _sendControlShortcut(tester, LogicalKeyboardKey.minus);
      await tester.pump();

      expect(reducedChanges, [true]);
      expect(_opacity(tester, _zoomedOutKey), 1);

      final lockedChanges = <bool>[];
      await tester.pumpWidget(
        _testApp(
          MetroSemanticZoom(
            autofocus: true,
            height: 200,
            locked: true,
            onZoomedOutChanged: lockedChanges.add,
            zoomedInView: const SizedBox.expand(),
            zoomedOutView: const SizedBox.expand(),
          ),
        ),
      );
      await tester.pump();

      await _sendControlShortcut(tester, LogicalKeyboardKey.minus);
      await tester.pump(const Duration(milliseconds: 333));

      expect(lockedChanges, isEmpty);
      expect(_opacity(tester, _zoomedInKey), 1);
    },
  );

  testWidgets('view state and prior focus survive semantic switches', (
    tester,
  ) async {
    final inFocus = FocusNode();
    final outFocus = FocusNode();
    addTearDown(inFocus.dispose);
    addTearDown(outFocus.dispose);
    await tester.pumpWidget(
      _testApp(
        MetroSemanticZoom(
          height: 200,
          zoomedInView: _CounterView(autofocus: true, focusNode: inFocus),
          zoomedOutView: MetroButton(
            focusNode: outFocus,
            onPressed: () {},
            child: const Text('Summary focus target'),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(FocusManager.instance.primaryFocus, same(inFocus));

    await tester.tap(find.text('COUNT 0'));
    await tester.pump();
    expect(find.text('COUNT 1'), findsOneWidget);
    expect(FocusManager.instance.primaryFocus, same(inFocus));
    await _sendControlShortcut(tester, LogicalKeyboardKey.minus);
    await tester.pumpAndSettle();
    expect(FocusManager.instance.primaryFocus, same(outFocus));

    await _sendControlShortcut(tester, LogicalKeyboardKey.equal);
    await tester.pumpAndSettle();

    expect(FocusManager.instance.primaryFocus, same(inFocus));
    expect(find.text('COUNT 1'), findsOneWidget);
  });
}

Widget _testApp(
  Widget child, {
  MetroThemeData? theme,
  MediaQueryData mediaQueryData = const MediaQueryData(size: Size(800, 600)),
}) {
  return metroTestApp(
    theme: theme,
    mediaQueryData: mediaQueryData,
    child: Center(child: SizedBox(width: 300, child: child)),
  );
}

double _opacity(WidgetTester tester, Key key) {
  return tester.widget<Opacity>(find.byKey(key)).opacity;
}

double _scale(WidgetTester tester, Key opacityKey) {
  final transform = tester.widget<Transform>(
    find.descendant(
      of: find.byKey(opacityKey),
      matching: find.byType(Transform),
    ),
  );
  return transform.transform.entry(0, 0).abs();
}

bool _semanticsExcluded(WidgetTester tester, Key opacityKey) {
  return tester
      .widget<ExcludeSemantics>(
        find
            .ancestor(
              of: find.byKey(opacityKey),
              matching: find.byType(ExcludeSemantics),
            )
            .first,
      )
      .excluding;
}

Future<void> _sendControlShortcut(
  WidgetTester tester,
  LogicalKeyboardKey key,
) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  await tester.sendKeyEvent(key);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
}

class _CounterView extends StatefulWidget {
  const _CounterView({required this.autofocus, required this.focusNode});

  final bool autofocus;
  final FocusNode focusNode;

  @override
  State<_CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<_CounterView> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return MetroButton(
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
      onPressed: () => setState(() => _count += 1),
      child: Text('COUNT $_count'),
    );
  }
}
