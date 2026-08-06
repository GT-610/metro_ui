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
