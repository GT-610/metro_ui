import 'package:flutter/widgets.dart';

/// Whether accessibility settings request that nonessential motion stop.
bool metroReduceMotion(BuildContext context) {
  final mediaQuery = MediaQuery.maybeOf(context);
  return mediaQuery?.disableAnimations == true ||
      mediaQuery?.accessibleNavigation == true;
}

/// Whether tickers are enabled for the nearest subtree.
bool metroTickerModeEnabled(BuildContext context) {
  // TickerMode.valuesOf is unavailable on the minimum Flutter version.
  // ignore: deprecated_member_use
  return TickerMode.of(context);
}

/// Whether focus chrome should be shown for the current input.
///
/// Modern UI drew focus outlines only while the user navigated with a keyboard.
/// Pointer and touch input changed a control's fill instead, so a control asks
/// this before drawing a focus ring and reads it during build: the platform
/// updates the highlight mode whenever the input method changes, which also
/// rebuilds the control that just gained focus.
bool metroFocusVisible() {
  final manager = FocusManager.instance;
  return switch (manager.highlightStrategy) {
    FocusHighlightStrategy.alwaysTraditional => true,
    FocusHighlightStrategy.alwaysTouch => false,
    FocusHighlightStrategy.automatic =>
      manager.highlightMode == FocusHighlightMode.traditional,
  };
}

/// Removes [WidgetState.focused] from [states] when focus chrome is hidden.
///
/// The caller's set is returned untouched while focus chrome is visible; the
/// filtered variant is always a copy, because a cascade in a conditional
/// expression would otherwise mutate the set the caller passed in.
Set<WidgetState> metroFocusStates(Set<WidgetState> states) {
  if (metroFocusVisible()) return states;
  final filtered = <WidgetState>{...states};
  filtered.remove(WidgetState.focused);
  return filtered;
}
