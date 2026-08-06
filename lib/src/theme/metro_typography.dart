import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'metro_color_scheme.dart';

/// Type ramp modeled after the typography-led hierarchy of Modern UI.
@immutable
class MetroTypography {
  const MetroTypography({
    required this.hero,
    required this.header,
    required this.subheader,
    required this.title,
    required this.body,
    required this.bodyStrong,
    required this.caption,
    required this.button,
    required this.tileTitle,
  });

  factory MetroTypography.fromColorScheme(
    MetroColorScheme colors, {
    String? fontFamily,
    String? fontPackage,
  }) {
    final useSystemSegoe =
        fontFamily == null &&
        !kIsWeb &&
        defaultTargetPlatform == TargetPlatform.windows;
    final resolvedFontFamily =
        fontFamily ?? (useSystemSegoe ? 'Segoe UI' : 'Metro UI Sans');
    final resolvedFontPackage =
        fontPackage ??
        (fontFamily == null && !useSystemSegoe ? 'metro_ui' : null);
    // TextStyle.package also prefixes every fallback family. Prefix only the
    // packaged primary face so system CJK and generic fallbacks remain usable.
    final packagedFontFamily = resolvedFontPackage == null
        ? resolvedFontFamily
        : 'packages/$resolvedFontPackage/$resolvedFontFamily';
    const fallbacks = <String>['Noto Sans', 'Arial', 'sans-serif'];
    final base = TextStyle(
      color: colors.foreground,
      fontFamily: packagedFontFamily,
      fontFamilyFallback: fallbacks,
      fontWeight: FontWeight.w400,
      height: 1.2,
      letterSpacing: 0.28,
    );
    return MetroTypography(
      hero: base.copyWith(
        fontSize: 56,
        fontWeight: FontWeight.w300,
        letterSpacing: 0,
      ),
      header: base.copyWith(
        fontSize: 40,
        fontWeight: FontWeight.w300,
        letterSpacing: 0,
      ),
      subheader: base.copyWith(fontSize: 26.667, fontWeight: FontWeight.w300),
      title: base.copyWith(fontSize: 20, fontWeight: FontWeight.w400),
      body: base.copyWith(fontSize: 14.667, height: 1.3636),
      bodyStrong: base.copyWith(
        fontSize: 14.667,
        fontWeight: FontWeight.w600,
        height: 1.3636,
      ),
      caption: base.copyWith(
        color: colors.mutedForeground,
        fontSize: 12,
        height: 1.6667,
      ),
      button: base.copyWith(
        fontSize: 14.667,
        fontWeight: FontWeight.w600,
        height: 1.3636,
      ),
      tileTitle: base.copyWith(fontSize: 16, fontWeight: FontWeight.w400),
    );
  }

  final TextStyle hero;
  final TextStyle header;
  final TextStyle subheader;
  final TextStyle title;
  final TextStyle body;
  final TextStyle bodyStrong;
  final TextStyle caption;
  final TextStyle button;
  final TextStyle tileTitle;

  MetroTypography copyWith({
    TextStyle? hero,
    TextStyle? header,
    TextStyle? subheader,
    TextStyle? title,
    TextStyle? body,
    TextStyle? bodyStrong,
    TextStyle? caption,
    TextStyle? button,
    TextStyle? tileTitle,
  }) {
    return MetroTypography(
      hero: hero ?? this.hero,
      header: header ?? this.header,
      subheader: subheader ?? this.subheader,
      title: title ?? this.title,
      body: body ?? this.body,
      bodyStrong: bodyStrong ?? this.bodyStrong,
      caption: caption ?? this.caption,
      button: button ?? this.button,
      tileTitle: tileTitle ?? this.tileTitle,
    );
  }

  static MetroTypography lerp(MetroTypography a, MetroTypography b, double t) {
    return MetroTypography(
      hero: TextStyle.lerp(a.hero, b.hero, t)!,
      header: TextStyle.lerp(a.header, b.header, t)!,
      subheader: TextStyle.lerp(a.subheader, b.subheader, t)!,
      title: TextStyle.lerp(a.title, b.title, t)!,
      body: TextStyle.lerp(a.body, b.body, t)!,
      bodyStrong: TextStyle.lerp(a.bodyStrong, b.bodyStrong, t)!,
      caption: TextStyle.lerp(a.caption, b.caption, t)!,
      button: TextStyle.lerp(a.button, b.button, t)!,
      tileTitle: TextStyle.lerp(a.tileTitle, b.tileTitle, t)!,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MetroTypography &&
            other.hero == hero &&
            other.header == header &&
            other.subheader == subheader &&
            other.title == title &&
            other.body == body &&
            other.bodyStrong == bodyStrong &&
            other.caption == caption &&
            other.button == button &&
            other.tileTitle == tileTitle;
  }

  @override
  int get hashCode => Object.hash(
    hero,
    header,
    subheader,
    title,
    body,
    bodyStrong,
    caption,
    button,
    tileTitle,
  );
}
