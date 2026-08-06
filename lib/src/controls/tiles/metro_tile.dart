import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../foundation/metro_accessibility.dart';
import '../../foundation/metro_interactive.dart';
import '../../theme/metro_spacing.dart';
import '../../theme/metro_theme.dart';
import '../../theme/metro_theme_data.dart';
import 'metro_tile_grid_scope.dart';
import 'metro_tile_style.dart';

export 'metro_tile_style.dart';

/// Standard square or double-width Metro tile geometry.
enum MetroTileSize { square, wide }

/// A signature Modern UI tile with optional location-aware press tilt.
class MetroTile extends StatefulWidget {
  const MetroTile({
    required this.onPressed,
    this.size = MetroTileSize.square,
    this.icon,
    this.title,
    this.subtitle,
    this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.style,
    this.width,
    this.height,
    this.enablePressTilt = true,
    this.autofocus = false,
    this.focusNode,
    this.semanticLabel,
    super.key,
  }) : assert(
         icon != null || title != null || child != null,
         'A MetroTile needs an icon, title, or child.',
       );

  final VoidCallback? onPressed;
  final MetroTileSize size;
  final Widget? icon;
  final String? title;
  final String? subtitle;
  final Widget? child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final MetroTileStyle? style;
  final double? width;
  final double? height;
  final bool enablePressTilt;
  final bool autofocus;
  final FocusNode? focusNode;
  final String? semanticLabel;

  @override
  State<MetroTile> createState() => _MetroTileState();
}

class _MetroTileState extends State<MetroTile> {
  Offset _pressPosition = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final theme = MetroTheme.of(context);
    final tileTheme = theme.tileTheme.merge(MetroTileTheme.maybeOf(context));
    final metrics = MetroTileGridScope.maybeOf(context);
    final extent = metrics?.extent ?? tileTheme.extent;
    final spacing = metrics?.spacing ?? tileTheme.spacing;
    final desiredWidth = switch (widget.size) {
      MetroTileSize.square => extent,
      MetroTileSize.wide => extent * 2 + spacing,
    };
    final availableWidth = metrics?.maxWidth;
    final width =
        widget.width ??
        (availableWidth == null
            ? desiredWidth
            : math.min(desiredWidth, availableWidth));
    final height = widget.height ?? extent;

    var effectiveStyle = _defaultStyle(
      theme,
    ).merge(tileTheme.style).merge(widget.style);
    if (widget.backgroundColor != null || widget.foregroundColor != null) {
      effectiveStyle = effectiveStyle.merge(
        MetroTileStyle(
          backgroundColor: widget.backgroundColor == null
              ? null
              : WidgetStatePropertyAll(widget.backgroundColor),
          foregroundColor: widget.foregroundColor == null
              ? null
              : WidgetStatePropertyAll(widget.foregroundColor),
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: MetroInteractive(
        autofocus: widget.autofocus,
        focusNode: widget.focusNode,
        onPressed: widget.onPressed,
        onTapDown: (details) {
          setState(() => _pressPosition = details.localPosition);
        },
        semanticLabel: widget.semanticLabel ?? widget.title,
        builder: (context, states) {
          final reduceMotion = metroReduceMotion(context);
          final pressed = states.contains(WidgetState.pressed);
          final background = effectiveStyle.backgroundColor?.resolve(states);
          final foreground = effectiveStyle.foregroundColor?.resolve(states);
          final overlay = effectiveStyle.overlayColor?.resolve(states);
          final borderColor = effectiveStyle.borderColor?.resolve(states);
          final borderWidth = effectiveStyle.borderWidth?.resolve(states) ?? 0;
          final transform = pressed && widget.enablePressTilt && !reduceMotion
              ? _pressedTransform(width, height)
              : Matrix4.identity();

          return AnimatedContainer(
            duration: reduceMotion ? Duration.zero : theme.motion.normal,
            curve: theme.motion.standardCurve,
            transform: transform,
            transformAlignment: Alignment.center,
            decoration: BoxDecoration(
              color: background,
              border: borderWidth == 0
                  ? null
                  : Border.all(
                      color: borderColor ?? const Color(0x00000000),
                      width: borderWidth,
                    ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Padding(
                  padding:
                      effectiveStyle.padding ??
                      const EdgeInsets.all(MetroSpacing.sm),
                  child: _TileContents(
                    foreground: foreground,
                    icon: widget.icon,
                    title: widget.title,
                    subtitle: widget.subtitle,
                    titleStyle: effectiveStyle.titleStyle?.resolve(states),
                    subtitleStyle: effectiveStyle.subtitleStyle?.resolve(
                      states,
                    ),
                    child: widget.child,
                  ),
                ),
                if (overlay != null) ColoredBox(color: overlay),
              ],
            ),
          );
        },
      ),
    );
  }

  Matrix4 _pressedTransform(double width, double height) {
    final x = ((_pressPosition.dx / width) - 0.5).clamp(-0.5, 0.5) * 2;
    final y = ((_pressPosition.dy / height) - 0.5).clamp(-0.5, 0.5) * 2;
    final transform = Matrix4.identity()
      ..setEntry(3, 2, 0.0015)
      ..rotateX(-y * 0.035)
      ..rotateY(x * 0.035);
    final storage = transform.storage;
    for (var index = 0; index < 4; index++) {
      storage[index] *= 0.975;
      storage[index + 4] *= 0.975;
    }
    return transform;
  }

  static MetroTileStyle _defaultStyle(MetroThemeData theme) {
    final colors = theme.colors;
    return MetroTileStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.disabledBackground;
        }
        return colors.accent;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.disabledForeground;
        }
        return colors.onAccent;
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return const Color(0x24000000);
        }
        if (states.contains(WidgetState.hovered)) {
          return const Color(0x18FFFFFF);
        }
        return const Color(0x00000000);
      }),
      borderColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.focused)) {
          return colors.focus;
        }
        if (states.contains(WidgetState.hovered)) {
          return colors.onAccent.withValues(alpha: 0.85);
        }
        return const Color(0x00000000);
      }),
      borderWidth: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.focused) ||
                states.contains(WidgetState.hovered)
            ? 2
            : 0;
      }),
      titleStyle: WidgetStatePropertyAll(theme.typography.tileTitle),
      subtitleStyle: WidgetStatePropertyAll(theme.typography.caption),
      padding: const EdgeInsets.all(MetroSpacing.sm),
    );
  }
}

class _TileContents extends StatelessWidget {
  const _TileContents({
    required this.foreground,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.titleStyle,
    required this.subtitleStyle,
    required this.child,
  });

  final Color? foreground;
  final Widget? icon;
  final String? title;
  final String? subtitle;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return IconTheme.merge(
      data: IconThemeData(color: foreground, size: 44),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: foreground),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (child != null) Expanded(child: child!),
            if (child == null && icon != null)
              Expanded(child: Center(child: icon)),
            if (child == null && icon == null) const Spacer(),
            if (title != null)
              Text(
                title!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: titleStyle?.copyWith(color: foreground),
              ),
            if (subtitle != null) ...[
              const SizedBox(height: MetroSpacing.xxs),
              Text(
                subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: subtitleStyle?.copyWith(color: foreground),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
