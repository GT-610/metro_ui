import 'package:flutter/widgets.dart';

import '../theme/metro_color_scheme.dart';

/// Shared surface, border, and text colors for Metro text-entry fields.
///
/// Text inputs, combo boxes, number boxes, search boxes, and picker segments
/// share one field treatment in this era: a light translucent box with a two
/// pixel border that becomes opaque white while focused. Keeping the recipes in
/// one place stops individual controls from drifting into different surfaces.
///
/// The values follow the Windows 8 and Windows 8.1 intrinsics: a translucent
/// white box in both brightness modes with black content, a darker border on
/// hover, a stronger border on focus, and a flat grey box when disabled.
abstract final class MetroFieldSurface {
  /// Border thickness shared by every field in the family.
  static const double borderWidth = 2;

  /// Smallest height of a single-line text entry box.
  static const double minimumHeight = 28;

  /// Smallest height of a field that carries a trailing affordance, such as a
  /// drop-down chevron or a search button.
  static const double minimumAffordanceHeight = 32;

  /// Field fill for the current interaction [states].
  static Color backgroundColor(
    MetroColorScheme colors,
    Set<WidgetState> states,
  ) {
    if (colors.isHighContrast) {
      return colors.background;
    }
    if (states.contains(WidgetState.disabled)) {
      return colors.isDark ? const Color(0x00000000) : const Color(0x66CACACA);
    }
    if (states.contains(WidgetState.focused)) {
      return const Color(0xFFFFFFFF);
    }
    return states.contains(WidgetState.hovered)
        ? const Color(0xDEFFFFFF)
        : const Color(0xCCFFFFFF);
  }

  /// Field border for the current interaction [states].
  static Color borderColor(MetroColorScheme colors, Set<WidgetState> states) {
    if (colors.isHighContrast) {
      return states.contains(WidgetState.disabled)
          ? colors.disabledForeground
          : colors.border;
    }
    if (states.contains(WidgetState.disabled)) {
      return colors.isDark ? const Color(0x66FFFFFF) : const Color(0x26000000);
    }
    // Dark-theme fields are light boxes whose border stays invisible; the
    // opaque fill carries the focus cue instead.
    if (colors.isDark) {
      return const Color(0x00000000);
    }
    if (states.contains(WidgetState.focused)) {
      return const Color(0x99000000);
    }
    return states.contains(WidgetState.hovered)
        ? const Color(0x70000000)
        : const Color(0x45000000);
  }

  /// Field content color for the current interaction [states].
  static Color foregroundColor(
    MetroColorScheme colors,
    Set<WidgetState> states,
  ) {
    if (colors.isHighContrast) {
      return states.contains(WidgetState.disabled)
          ? colors.disabledForeground
          : colors.foreground;
    }
    if (states.contains(WidgetState.disabled)) {
      return colors.isDark ? const Color(0x66FFFFFF) : const Color(0x66000000);
    }
    return const Color(0xFF000000);
  }

  /// Placeholder and prompt color for the current interaction [states].
  static Color placeholderColor(
    MetroColorScheme colors,
    Set<WidgetState> states,
  ) {
    if (colors.isHighContrast) {
      return states.contains(WidgetState.disabled)
          ? colors.disabledForeground
          : colors.mutedForeground;
    }
    if (states.contains(WidgetState.disabled)) {
      return colors.isDark ? const Color(0x38FFFFFF) : const Color(0x38000000);
    }
    return const Color(0x99000000);
  }
}
