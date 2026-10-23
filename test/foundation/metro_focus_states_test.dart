import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
// The focus helpers are internal to the controls, so the test reaches them
// through the implementation library instead of the public barrel.
import 'package:metro_ui/src/foundation/metro_accessibility.dart';

void main() {
  late FocusHighlightStrategy previousStrategy;

  setUp(() {
    previousStrategy = FocusManager.instance.highlightStrategy;
  });

  tearDown(() {
    FocusManager.instance.highlightStrategy = previousStrategy;
  });

  testWidgets('hiding focus chrome never mutates the caller set', (
    tester,
  ) async {
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTouch;
    final states = <WidgetState>{WidgetState.focused, WidgetState.hovered};

    final filtered = metroFocusStates(states);

    expect(filtered, <WidgetState>{WidgetState.hovered});
    expect(states, <WidgetState>{
      WidgetState.focused,
      WidgetState.hovered,
    }, reason: 'the widget resolves many properties from the same set');
  });

  testWidgets('showing focus chrome passes the caller set through', (
    tester,
  ) async {
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    final states = <WidgetState>{WidgetState.focused};

    expect(identical(metroFocusStates(states), states), isTrue);
  });
}
