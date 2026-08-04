// Flutter 3.32 does not re-export Brightness from widgets.dart.
// ignore: unnecessary_import
import 'dart:ui' show Brightness;

import 'package:flutter/widgets.dart';

import 'metro_colors.dart';

/// Semantic colors used by Metro UI widgets.
///
/// The accent remains stable across brightness modes while the neutral colors
/// invert. [onAccent] is calculated from the accent's luminance so bright
/// accents, such as yellow, retain readable content.
@immutable
class MetroColorScheme {
  const MetroColorScheme({
    required this.brightness,
    required this.accent,
    required this.onAccent,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.foreground,
    required this.mutedForeground,
    required this.border,
    required this.disabledForeground,
    required this.disabledBackground,
    required this.focus,
    required this.error,
    required this.success,
    this.isHighContrast = false,
  });

  factory MetroColorScheme.light({Color accent = MetroColors.cobalt}) {
    return MetroColorScheme(
      brightness: Brightness.light,
      accent: accent,
      onAccent: idealForegroundFor(accent),
      background: const Color(0xFFFFFFFF),
      surface: const Color(0xFFF4F4F4),
      surfaceVariant: const Color(0xFFE5E5E5),
      foreground: const Color(0xFF1D1D1D),
      mutedForeground: const Color(0xFF666666),
      border: const Color(0xFF777777),
      disabledForeground: const Color(0xFF9A9A9A),
      disabledBackground: const Color(0xFFE1E1E1),
      focus: const Color(0xFF1D1D1D),
      error: MetroColors.red,
      success: MetroColors.emerald,
    );
  }

  factory MetroColorScheme.dark({Color accent = MetroColors.cobalt}) {
    return MetroColorScheme(
      brightness: Brightness.dark,
      accent: accent,
      onAccent: idealForegroundFor(accent),
      background: const Color(0xFF1D1D1D),
      surface: const Color(0xFF252525),
      surfaceVariant: const Color(0xFF333333),
      foreground: const Color(0xFFFFFFFF),
      mutedForeground: const Color(0xFFB8B8B8),
      border: const Color(0xFF999999),
      disabledForeground: const Color(0xFF777777),
      disabledBackground: const Color(0xFF333333),
      focus: const Color(0xFFFFFFFF),
      error: const Color(0xFFFF655A),
      success: const Color(0xFF7AC943),
    );
  }

  /// A light palette with black structural colors and a WCAG AAA foreground.
  factory MetroColorScheme.highContrastLight({
    Color accent = const Color(0xFF0037DA),
  }) {
    return MetroColorScheme(
      brightness: Brightness.light,
      accent: accent,
      onAccent: idealForegroundFor(accent),
      background: const Color(0xFFFFFFFF),
      surface: const Color(0xFFFFFFFF),
      surfaceVariant: const Color(0xFFD9D9D9),
      foreground: const Color(0xFF000000),
      mutedForeground: const Color(0xFF000000),
      border: const Color(0xFF000000),
      disabledForeground: const Color(0xFF595959),
      disabledBackground: const Color(0xFFE6E6E6),
      focus: const Color(0xFF000000),
      error: const Color(0xFF8B0000),
      success: const Color(0xFF006400),
      isHighContrast: true,
    );
  }

  /// A dark palette with white structural colors and a yellow highlight.
  factory MetroColorScheme.highContrastDark({
    Color accent = MetroColors.yellow,
  }) {
    return MetroColorScheme(
      brightness: Brightness.dark,
      accent: accent,
      onAccent: idealForegroundFor(accent),
      background: const Color(0xFF000000),
      surface: const Color(0xFF000000),
      surfaceVariant: const Color(0xFF333333),
      foreground: const Color(0xFFFFFFFF),
      mutedForeground: const Color(0xFFFFFFFF),
      border: const Color(0xFFFFFFFF),
      disabledForeground: const Color(0xFFA6A6A6),
      disabledBackground: const Color(0xFF1A1A1A),
      focus: const Color(0xFFFFFFFF),
      error: const Color(0xFFFF6B6B),
      success: const Color(0xFF7FFF7F),
      isHighContrast: true,
    );
  }

  final Brightness brightness;
  final Color accent;
  final Color onAccent;
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color foreground;
  final Color mutedForeground;
  final Color border;
  final Color disabledForeground;
  final Color disabledBackground;
  final Color focus;
  final Color error;
  final Color success;

  /// Whether this palette is designed for a high-contrast presentation.
  final bool isHighContrast;

  bool get isDark => brightness == Brightness.dark;

  Color get accentHover => Color.lerp(accent, onAccent, 0.08)!;

  Color get accentPressed =>
      Color.lerp(accent, const Color(0xFF000000), isDark ? 0.12 : 0.18)!;

  MetroColorScheme copyWith({
    Color? accent,
    Color? onAccent,
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? foreground,
    Color? mutedForeground,
    Color? border,
    Color? disabledForeground,
    Color? disabledBackground,
    Color? focus,
    Color? error,
    Color? success,
    bool? isHighContrast,
  }) {
    final resolvedAccent = accent ?? this.accent;
    return MetroColorScheme(
      brightness: brightness,
      accent: resolvedAccent,
      onAccent:
          onAccent ??
          (accent == null ? this.onAccent : idealForegroundFor(resolvedAccent)),
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      foreground: foreground ?? this.foreground,
      mutedForeground: mutedForeground ?? this.mutedForeground,
      border: border ?? this.border,
      disabledForeground: disabledForeground ?? this.disabledForeground,
      disabledBackground: disabledBackground ?? this.disabledBackground,
      focus: focus ?? this.focus,
      error: error ?? this.error,
      success: success ?? this.success,
      isHighContrast: isHighContrast ?? this.isHighContrast,
    );
  }

  static MetroColorScheme lerp(
    MetroColorScheme a,
    MetroColorScheme b,
    double t,
  ) {
    return MetroColorScheme(
      brightness: t < 0.5 ? a.brightness : b.brightness,
      accent: Color.lerp(a.accent, b.accent, t)!,
      onAccent: Color.lerp(a.onAccent, b.onAccent, t)!,
      background: Color.lerp(a.background, b.background, t)!,
      surface: Color.lerp(a.surface, b.surface, t)!,
      surfaceVariant: Color.lerp(a.surfaceVariant, b.surfaceVariant, t)!,
      foreground: Color.lerp(a.foreground, b.foreground, t)!,
      mutedForeground: Color.lerp(a.mutedForeground, b.mutedForeground, t)!,
      border: Color.lerp(a.border, b.border, t)!,
      disabledForeground: Color.lerp(
        a.disabledForeground,
        b.disabledForeground,
        t,
      )!,
      disabledBackground: Color.lerp(
        a.disabledBackground,
        b.disabledBackground,
        t,
      )!,
      focus: Color.lerp(a.focus, b.focus, t)!,
      error: Color.lerp(a.error, b.error, t)!,
      success: Color.lerp(a.success, b.success, t)!,
      isHighContrast: t < 0.5 ? a.isHighContrast : b.isHighContrast,
    );
  }

  static Color idealForegroundFor(Color background) {
    return background.computeLuminance() > 0.179
        ? const Color(0xFF000000)
        : const Color(0xFFFFFFFF);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MetroColorScheme &&
            other.brightness == brightness &&
            other.accent == accent &&
            other.onAccent == onAccent &&
            other.background == background &&
            other.surface == surface &&
            other.surfaceVariant == surfaceVariant &&
            other.foreground == foreground &&
            other.mutedForeground == mutedForeground &&
            other.border == border &&
            other.disabledForeground == disabledForeground &&
            other.disabledBackground == disabledBackground &&
            other.focus == focus &&
            other.error == error &&
            other.success == success &&
            other.isHighContrast == isHighContrast;
  }

  @override
  int get hashCode => Object.hash(
    brightness,
    accent,
    onAccent,
    background,
    surface,
    surfaceVariant,
    foreground,
    mutedForeground,
    border,
    disabledForeground,
    disabledBackground,
    focus,
    error,
    success,
    isHighContrast,
  );
}
