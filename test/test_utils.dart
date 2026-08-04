import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_ui/metro_ui.dart';

Matcher containsMetroSemantics({
  bool? hasCheckedState,
  bool? isChecked,
  bool? hasSelectedState,
  bool? isSelected,
  bool? isTextField,
  bool? hasEnabledState,
  bool? isEnabled,
  bool? isObscured,
  bool? hasExpandedState,
  bool? isExpanded,
}) {
  // isSemantics is unavailable on the minimum Flutter version.
  // ignore: deprecated_member_use
  return containsSemantics(
    hasCheckedState: hasCheckedState,
    isChecked: isChecked,
    hasSelectedState: hasSelectedState,
    isSelected: isSelected,
    isTextField: isTextField,
    hasEnabledState: hasEnabledState,
    isEnabled: isEnabled,
    isObscured: isObscured,
    hasExpandedState: hasExpandedState,
    isExpanded: isExpanded,
  );
}

Widget metroTestApp({
  required Widget child,
  MetroThemeData? theme,
  MediaQueryData mediaQueryData = const MediaQueryData(size: Size(800, 600)),
}) {
  return MediaQuery(
    data: mediaQueryData,
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: MetroTheme(data: theme ?? MetroThemeData.light(), child: child),
    ),
  );
}
