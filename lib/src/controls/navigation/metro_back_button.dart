import 'package:flutter/widgets.dart';

import '../../foundation/metro_interactive.dart';
import '../../foundation/state_property.dart';
import '../../localization/metro_localizations.dart';
import '../../theme/metro_theme.dart';
import '../../theme/metro_theme_data.dart';

/// Stateful visual properties for a [MetroBackButton].
@immutable
class MetroBackButtonStyle {
  const MetroBackButtonStyle({
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth,
    this.size,
    this.iconSize,
    this.mouseCursor,
  });

  final WidgetStateProperty<Color?>? backgroundColor;
  final WidgetStateProperty<Color?>? foregroundColor;
  final WidgetStateProperty<Color?>? borderColor;
  final WidgetStateProperty<double?>? borderWidth;
  final double? size;
  final double? iconSize;
  final MouseCursor? mouseCursor;

  MetroBackButtonStyle copyWith({
    WidgetStateProperty<Color?>? backgroundColor,
    WidgetStateProperty<Color?>? foregroundColor,
    WidgetStateProperty<Color?>? borderColor,
    WidgetStateProperty<double?>? borderWidth,
    double? size,
    double? iconSize,
    MouseCursor? mouseCursor,
  }) {
    return MetroBackButtonStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      size: size ?? this.size,
      iconSize: iconSize ?? this.iconSize,
      mouseCursor: mouseCursor ?? this.mouseCursor,
    );
  }

  MetroBackButtonStyle merge(MetroBackButtonStyle? other) {
    if (other == null) return this;
    return copyWith(
      backgroundColor: other.backgroundColor,
      foregroundColor: other.foregroundColor,
      borderColor: other.borderColor,
      borderWidth: other.borderWidth,
      size: other.size,
      iconSize: other.iconSize,
      mouseCursor: other.mouseCursor,
    );
  }

  static MetroBackButtonStyle lerp(
    MetroBackButtonStyle? a,
    MetroBackButtonStyle? b,
    double t,
  ) {
    final first = a ?? const MetroBackButtonStyle();
    final second = b ?? const MetroBackButtonStyle();
    return MetroBackButtonStyle(
      backgroundColor: lerpStateProperty(
        first.backgroundColor,
        second.backgroundColor,
        t,
        Color.lerp,
      ),
      foregroundColor: lerpStateProperty(
        first.foregroundColor,
        second.foregroundColor,
        t,
        Color.lerp,
      ),
      borderColor: lerpStateProperty(
        first.borderColor,
        second.borderColor,
        t,
        Color.lerp,
      ),
      borderWidth: lerpStateProperty(
        first.borderWidth,
        second.borderWidth,
        t,
        lerpDouble,
      ),
      size: lerpDouble(first.size, second.size, t),
      iconSize: lerpDouble(first.iconSize, second.iconSize, t),
      mouseCursor: lerpDiscrete(first.mouseCursor, second.mouseCursor, t),
    );
  }
}

/// Application-level styling for Metro navigation back buttons.
@immutable
class MetroBackButtonThemeData {
  const MetroBackButtonThemeData({this.style});

  final MetroBackButtonStyle? style;

  MetroBackButtonThemeData copyWith({MetroBackButtonStyle? style}) {
    return MetroBackButtonThemeData(style: style ?? this.style);
  }

  MetroBackButtonThemeData merge(MetroBackButtonThemeData? other) {
    if (other == null) return this;
    return MetroBackButtonThemeData(
      style: style?.merge(other.style) ?? other.style,
    );
  }

  static MetroBackButtonThemeData lerp(
    MetroBackButtonThemeData a,
    MetroBackButtonThemeData b,
    double t,
  ) {
    return MetroBackButtonThemeData(
      style: MetroBackButtonStyle.lerp(a.style, b.style, t),
    );
  }
}

/// Overrides back-button styling for a subtree.
class MetroBackButtonTheme extends InheritedTheme {
  const MetroBackButtonTheme({
    required this.data,
    required super.child,
    super.key,
  });

  final MetroBackButtonThemeData data;

  static MetroBackButtonThemeData? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MetroBackButtonTheme>()
        ?.data;
  }

  static MetroBackButtonThemeData of(BuildContext context) {
    return maybeOf(context) ?? const MetroBackButtonThemeData();
  }

  @override
  bool updateShouldNotify(MetroBackButtonTheme oldWidget) =>
      data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) {
    return MetroBackButtonTheme(data: data, child: child);
  }
}

/// The circular Windows 8 navigation back button.
///
/// The control mirrors automatically in right-to-left layouts. Windows 8
/// reserved the circular outline for navigation and AppBar commands; it does
/// not imply rounded geometry for ordinary buttons or surfaces.
class MetroBackButton extends StatelessWidget {
  const MetroBackButton({
    required this.onPressed,
    this.style,
    this.hideWhenDisabled = true,
    this.autofocus = false,
    this.focusNode,
    this.semanticLabel,
    super.key,
  });

  final VoidCallback? onPressed;
  final MetroBackButtonStyle? style;

  /// Whether a disabled button keeps its layout space while becoming hidden.
  ///
  /// This matches the original WinJS navigation back-button treatment.
  final bool hideWhenDisabled;

  final bool autofocus;
  final FocusNode? focusNode;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = MetroTheme.of(context);
    final backButtonTheme = theme.backButtonTheme.merge(
      MetroBackButtonTheme.maybeOf(context),
    );
    final effectiveStyle = _defaultStyle(
      theme,
    ).merge(backButtonTheme.style).merge(style);
    final size = effectiveStyle.size ?? 41;
    final iconSize = effectiveStyle.iconSize ?? 18.667;

    final button = MetroInteractive(
      autofocus: autofocus,
      focusNode: focusNode,
      mouseCursor: effectiveStyle.mouseCursor,
      onPressed: onPressed,
      semanticLabel:
          semanticLabel ?? MetroLocalizations.of(context).backButtonLabel,
      builder: (context, states) {
        final foreground = effectiveStyle.foregroundColor?.resolve(states);
        return SizedBox.square(
          dimension: size,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: effectiveStyle.backgroundColor?.resolve(states),
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    effectiveStyle.borderColor?.resolve(states) ??
                    const Color(0x00000000),
                width: effectiveStyle.borderWidth?.resolve(states) ?? 2,
              ),
            ),
            child: Center(
              child: CustomPaint(
                size: Size.square(iconSize),
                painter: _BackArrowPainter(
                  color: foreground ?? const Color(0x00000000),
                  textDirection: Directionality.of(context),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (onPressed == null && hideWhenDisabled) {
      return Visibility(
        visible: false,
        maintainState: true,
        maintainAnimation: true,
        maintainSize: true,
        child: button,
      );
    }
    return button;
  }

  static MetroBackButtonStyle _defaultStyle(MetroThemeData theme) {
    final colors = theme.colors;
    final foreground = colors.isDark
        ? const Color(0xFFFFFFFF)
        : const Color(0xFF000000);
    final inverse = colors.isDark
        ? const Color(0xFF000000)
        : const Color(0xFFFFFFFF);
    return MetroBackButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) return foreground;
        if (states.contains(WidgetState.hovered)) {
          return foreground.withValues(alpha: 0.13);
        }
        return const Color(0x00000000);
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return foreground.withValues(alpha: 0.4);
        }
        if (states.contains(WidgetState.pressed)) return inverse;
        return foreground;
      }),
      borderColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return foreground.withValues(alpha: 0.4);
        }
        return foreground;
      }),
      borderWidth: const WidgetStatePropertyAll(2),
      size: 41,
      iconSize: 18.667,
    );
  }
}

class _BackArrowPainter extends CustomPainter {
  const _BackArrowPainter({required this.color, required this.textDirection});

  final Color color;
  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final direction = textDirection == TextDirection.ltr ? 1.0 : -1.0;
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.miter
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(center.dx + direction * size.width * 0.3, center.dy)
      ..lineTo(center.dx - direction * size.width * 0.22, center.dy)
      ..moveTo(center.dx - direction * size.width * 0.22, center.dy)
      ..lineTo(
        center.dx + direction * size.width * 0.02,
        center.dy - size.height * 0.24,
      )
      ..moveTo(center.dx - direction * size.width * 0.22, center.dy)
      ..lineTo(
        center.dx + direction * size.width * 0.02,
        center.dy + size.height * 0.24,
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BackArrowPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.textDirection != textDirection;
  }
}
