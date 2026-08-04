import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../theme/metro_spacing.dart';
import '../../theme/metro_theme.dart';
import 'metro_tooltip_theme.dart';

export 'metro_tooltip_theme.dart';

/// A square Metro tooltip shown by hover, descendant focus, or long press.
class MetroTooltip extends StatefulWidget {
  const MetroTooltip({
    required this.message,
    required this.child,
    this.preferBelow = true,
    this.enabled = true,
    this.backgroundColor,
    this.textStyle,
    this.padding,
    this.maxWidth,
    this.waitDuration,
    this.showDuration,
    this.verticalOffset,
    super.key,
  });

  final String message;
  final Widget child;
  final bool preferBelow;
  final bool enabled;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final double? maxWidth;
  final Duration? waitDuration;
  final Duration? showDuration;
  final double? verticalOffset;

  @override
  State<MetroTooltip> createState() => _MetroTooltipState();
}

class _MetroTooltipState extends State<MetroTooltip> {
  final OverlayPortalController _controller = OverlayPortalController();
  Timer? _showTimer;
  Timer? _hideTimer;
  bool _hovered = false;
  bool _focused = false;

  @override
  void didUpdateWidget(MetroTooltip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled && !widget.enabled) {
      _showTimer?.cancel();
      _hideTimer?.cancel();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _controller.isShowing) {
          _controller.hide();
        }
      });
    }
  }

  void _scheduleShow({bool immediate = false, bool autoHide = false}) {
    if (!widget.enabled) {
      return;
    }
    _showTimer?.cancel();
    _hideTimer?.cancel();
    final theme = _resolveTheme(context);
    final delay = immediate ? Duration.zero : theme.waitDuration!;
    if (delay == Duration.zero) {
      _show(autoHide: autoHide, theme: theme);
      return;
    }
    _showTimer = Timer(delay, () {
      if (mounted) {
        _show(autoHide: autoHide, theme: _resolveTheme(context));
      }
    });
  }

  void _show({required bool autoHide, required MetroTooltipThemeData theme}) {
    if (!mounted || !widget.enabled) {
      return;
    }
    _controller.show();
    if (autoHide) {
      _hideTimer = Timer(theme.showDuration!, () {
        if (mounted && !_hovered) {
          _hide();
        }
      });
    }
  }

  void _hide() {
    _showTimer?.cancel();
    _hideTimer?.cancel();
    if (_controller.isShowing) {
      _controller.hide();
    }
  }

  void _handleFocusChanged(bool focused) {
    _focused = focused;
    if (focused) {
      _scheduleShow();
    } else if (!_hovered) {
      _hide();
    }
  }

  MetroTooltipThemeData _resolveTheme(BuildContext context) {
    final theme = MetroTheme.of(context);
    final defaults = MetroTooltipThemeData(
      backgroundColor: theme.colors.foreground,
      textStyle: theme.typography.caption.copyWith(
        color: theme.colors.background,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: MetroSpacing.xs,
        vertical: MetroSpacing.xxs,
      ),
      maxWidth: 320,
      waitDuration: const Duration(milliseconds: 500),
      showDuration: const Duration(milliseconds: 1500),
      verticalOffset: MetroSpacing.xs,
    );
    final widgetOverrides = MetroTooltipThemeData(
      backgroundColor: widget.backgroundColor,
      textStyle: widget.textStyle,
      padding: widget.padding,
      maxWidth: widget.maxWidth,
      waitDuration: widget.waitDuration,
      showDuration: widget.showDuration,
      verticalOffset: widget.verticalOffset,
    );
    return defaults
        .merge(theme.tooltipTheme)
        .merge(MetroTooltipTheme.maybeOf(context))
        .merge(widgetOverrides);
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal.overlayChildLayoutBuilder(
      controller: _controller,
      overlayChildBuilder: (context, info) {
        final theme = _resolveTheme(context);
        final targetRect = MatrixUtils.transformRect(
          info.childPaintTransform,
          Offset.zero & info.childSize,
        );
        final reduceMotion = _reduceMotion(context);
        final motion = MetroTheme.of(context).motion;
        return SizedBox.fromSize(
          size: info.overlaySize,
          child: CustomSingleChildLayout(
            delegate: _MetroTooltipLayoutDelegate(
              maxWidth: theme.maxWidth!,
              preferBelow: widget.preferBelow,
              targetRect: targetRect,
              verticalOffset: theme.verticalOffset!,
            ),
            child: IgnorePointer(
              child: TweenAnimationBuilder<double>(
                duration: reduceMotion ? Duration.zero : motion.fast,
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, opacity, child) {
                  return Opacity(opacity: opacity, child: child);
                },
                child: Semantics(
                  container: true,
                  label: widget.message,
                  liveRegion: true,
                  child: ExcludeSemantics(
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: theme.backgroundColor),
                      child: Padding(
                        padding: theme.padding!,
                        child: DefaultTextStyle(
                          style: theme.textStyle!,
                          child: Text(widget.message),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      child: Semantics(
        tooltip: widget.enabled ? widget.message : null,
        child: Focus(
          canRequestFocus: false,
          onFocusChange: _handleFocusChanged,
          skipTraversal: true,
          child: MouseRegion(
            onEnter: (_) {
              _hovered = true;
              _scheduleShow();
            },
            onExit: (_) {
              _hovered = false;
              if (!_focused) {
                _hide();
              }
            },
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              excludeFromSemantics: true,
              onLongPress: widget.enabled
                  ? () => _scheduleShow(immediate: true, autoHide: true)
                  : null,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _showTimer?.cancel();
    _hideTimer?.cancel();
    super.dispose();
  }
}

class _MetroTooltipLayoutDelegate extends SingleChildLayoutDelegate {
  const _MetroTooltipLayoutDelegate({
    required this.targetRect,
    required this.preferBelow,
    required this.verticalOffset,
    required this.maxWidth,
  });

  final Rect targetRect;
  final bool preferBelow;
  final double verticalOffset;
  final double maxWidth;

  static const double _screenMargin = MetroSpacing.xs;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final availableWidth = math.max(
      0.0,
      constraints.maxWidth - (_screenMargin * 2),
    );
    return BoxConstraints(maxWidth: math.min(maxWidth, availableWidth));
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final centeredX = targetRect.center.dx - (childSize.width / 2);
    final maxX = math.max(
      _screenMargin,
      size.width - childSize.width - _screenMargin,
    );
    final x = centeredX.clamp(_screenMargin, maxX).toDouble();
    final below = targetRect.bottom + verticalOffset;
    final above = targetRect.top - verticalOffset - childSize.height;
    final fitsBelow = below + childSize.height <= size.height - _screenMargin;
    final fitsAbove = above >= _screenMargin;
    final preferredY = preferBelow
        ? fitsBelow || !fitsAbove
              ? below
              : above
        : fitsAbove || !fitsBelow
        ? above
        : below;
    final maxY = math.max(
      _screenMargin,
      size.height - childSize.height - _screenMargin,
    );
    final y = preferredY.clamp(_screenMargin, maxY).toDouble();
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_MetroTooltipLayoutDelegate oldDelegate) {
    return targetRect != oldDelegate.targetRect ||
        preferBelow != oldDelegate.preferBelow ||
        verticalOffset != oldDelegate.verticalOffset ||
        maxWidth != oldDelegate.maxWidth;
  }
}

bool _reduceMotion(BuildContext context) {
  final mediaQuery = MediaQuery.maybeOf(context);
  return mediaQuery?.disableAnimations == true ||
      mediaQuery?.accessibleNavigation == true;
}
