import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../foundation/metro_accessibility.dart';
import '../../theme/metro_theme.dart';
import 'metro_tooltip_theme.dart';

export 'metro_tooltip_theme.dart';

/// A square Metro tooltip shown by hover, descendant focus, or long press.
class MetroTooltip extends StatefulWidget {
  const MetroTooltip({
    required this.message,
    required this.child,
    this.preferBelow = false,
    this.enabled = true,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.textStyle,
    this.padding,
    this.maxWidth,
    this.waitDuration,
    this.showDuration,
    this.verticalOffset,
    this.mouseOffset,
    this.keyboardOffset,
    this.touchOffset,
    super.key,
  });

  final String message;
  final Widget child;
  final bool preferBelow;
  final bool enabled;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final double? maxWidth;
  final Duration? waitDuration;
  final Duration? showDuration;
  final double? verticalOffset;
  final double? mouseOffset;
  final double? keyboardOffset;
  final double? touchOffset;

  @override
  State<MetroTooltip> createState() => _MetroTooltipState();
}

class _MetroTooltipState extends State<MetroTooltip>
    with SingleTickerProviderStateMixin {
  final OverlayPortalController _controller = OverlayPortalController();
  late final AnimationController _opacityController;
  Timer? _showTimer;
  Timer? _hideTimer;
  bool _hovered = false;
  bool _focused = false;
  Offset? _contactPoint;
  _MetroTooltipTrigger _trigger = _MetroTooltipTrigger.keyboard;
  int _visibilityEpoch = 0;
  bool _hideOnDismiss = false;

  @override
  void initState() {
    super.initState();
    _opacityController = AnimationController(vsync: this)
      ..addStatusListener(_handleOpacityStatus);
  }

  void _handleOpacityStatus(AnimationStatus status) {
    if (status == AnimationStatus.dismissed &&
        _hideOnDismiss &&
        _controller.isShowing) {
      _hideOnDismiss = false;
      _controller.hide();
    }
  }

  @override
  void didUpdateWidget(MetroTooltip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled && !widget.enabled) {
      _showTimer?.cancel();
      _hideTimer?.cancel();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _hide(immediate: true);
        }
      });
    }
  }

  void _scheduleShow({
    required _MetroTooltipTrigger trigger,
    bool immediate = false,
    bool autoHide = true,
  }) {
    if (!widget.enabled) {
      return;
    }
    _trigger = trigger;
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
    final epoch = ++_visibilityEpoch;
    final reduceMotion = metroReduceMotion(context);
    final motion = MetroTheme.of(context).motion;
    _hideOnDismiss = false;
    _opacityController.duration = motion.fadeIn;
    _opacityController.reverseDuration = motion.normal;
    if (!_controller.isShowing) {
      _opacityController.value = 0;
      _controller.show();
    }
    if (reduceMotion) {
      _opacityController.value = 1;
      _scheduleAutoHide(autoHide: autoHide, epoch: epoch, theme: theme);
    } else {
      _opacityController.forward().whenCompleteOrCancel(() {
        if (mounted && epoch == _visibilityEpoch) {
          _scheduleAutoHide(autoHide: autoHide, epoch: epoch, theme: theme);
        }
      });
    }
  }

  void _scheduleAutoHide({
    required bool autoHide,
    required int epoch,
    required MetroTooltipThemeData theme,
  }) {
    if (!autoHide || !mounted || epoch != _visibilityEpoch) {
      return;
    }
    _hideTimer = Timer(theme.showDuration!, () {
      if (mounted && epoch == _visibilityEpoch) {
        _hide();
      }
    });
  }

  void _hide({bool immediate = false}) {
    _showTimer?.cancel();
    _hideTimer?.cancel();
    _visibilityEpoch += 1;
    if (!_controller.isShowing) {
      return;
    }
    if (immediate ||
        metroReduceMotion(context) ||
        _opacityController.value == 0) {
      _hideOnDismiss = false;
      _opacityController.value = 0;
      _controller.hide();
      return;
    }
    _hideOnDismiss = true;
    _opacityController.reverse();
  }

  void _handleFocusChanged(bool focused) {
    _focused = focused;
    if (focused) {
      _contactPoint = null;
      _scheduleShow(trigger: _MetroTooltipTrigger.keyboard);
    } else if (!_hovered) {
      _hide();
    }
  }

  MetroTooltipThemeData _resolveTheme(BuildContext context) {
    final theme = MetroTheme.of(context);
    final highContrast = theme.colors.isHighContrast;
    final defaults = MetroTooltipThemeData(
      backgroundColor: highContrast
          ? theme.colors.background
          : const Color(0xFFFFFFFF),
      borderColor: highContrast
          ? theme.colors.foreground
          : const Color(0xFF808080),
      borderWidth: 2,
      textStyle: theme.typography.caption.copyWith(
        color: highContrast ? theme.colors.foreground : const Color(0x99000000),
      ),
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 7),
      maxWidth: 380,
      waitDuration: const Duration(milliseconds: 800),
      showDuration: const Duration(milliseconds: 5000),
      mouseOffset: 20,
      keyboardOffset: 12,
      touchOffset: 45,
    );
    final widgetOverrides = MetroTooltipThemeData(
      backgroundColor: widget.backgroundColor,
      borderColor: widget.borderColor,
      borderWidth: widget.borderWidth,
      textStyle: widget.textStyle,
      padding: widget.padding,
      maxWidth: widget.maxWidth,
      waitDuration: widget.waitDuration,
      showDuration: widget.showDuration,
      verticalOffset: widget.verticalOffset,
      mouseOffset: widget.mouseOffset,
      keyboardOffset: widget.keyboardOffset,
      touchOffset: widget.touchOffset,
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
        final effectiveTarget = switch (_trigger) {
          _MetroTooltipTrigger.keyboard => targetRect,
          _MetroTooltipTrigger.mouse || _MetroTooltipTrigger.touch =>
            _contactPoint == null
                ? targetRect
                : Rect.fromLTWH(_contactPoint!.dx, _contactPoint!.dy, 1, 1),
        };
        final offset =
            theme.verticalOffset ??
            switch (_trigger) {
              _MetroTooltipTrigger.mouse => theme.mouseOffset!,
              _MetroTooltipTrigger.keyboard => theme.keyboardOffset!,
              _MetroTooltipTrigger.touch => theme.touchOffset!,
            };
        return SizedBox.fromSize(
          size: info.overlaySize,
          child: CustomSingleChildLayout(
            delegate: _MetroTooltipLayoutDelegate(
              maxWidth: theme.maxWidth!,
              preferBelow: widget.preferBelow,
              targetRect: effectiveTarget,
              verticalOffset: offset,
            ),
            child: IgnorePointer(
              child: FadeTransition(
                opacity: _opacityController,
                child: Semantics(
                  container: true,
                  label: widget.message,
                  liveRegion: true,
                  child: ExcludeSemantics(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: theme.backgroundColor,
                        border: Border.all(
                          color: theme.borderColor!,
                          width: theme.borderWidth!,
                        ),
                      ),
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
            onEnter: (event) {
              _hovered = true;
              _contactPoint = event.position;
              _scheduleShow(trigger: _MetroTooltipTrigger.mouse);
            },
            onHover: (event) => _contactPoint = event.position,
            onExit: (_) {
              _hovered = false;
              if (!_focused) {
                _hide();
              }
            },
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              excludeFromSemantics: true,
              onLongPressStart: widget.enabled
                  ? (details) {
                      _contactPoint = details.globalPosition;
                      _scheduleShow(
                        trigger: _MetroTooltipTrigger.touch,
                        immediate: true,
                      );
                    }
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
    _opacityController.dispose();
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

  static const double _screenMargin = 0;
  static const double _safetyGap = 1;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final availableWidth = math.max(0.0, constraints.maxWidth - _safetyGap);
    return BoxConstraints(maxWidth: math.min(maxWidth, availableWidth));
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final centeredX = targetRect.center.dx - (childSize.width / 2);
    final maxX = math.max(0.0, size.width - childSize.width - _safetyGap);
    final x = centeredX.clamp(_screenMargin, maxX).toDouble();
    final below = targetRect.bottom + verticalOffset;
    final above = targetRect.top - verticalOffset - childSize.height;
    final fitsBelow = below + childSize.height <= size.height - _safetyGap;
    final fitsAbove = above >= 0;
    if ((preferBelow && fitsBelow) ||
        (!preferBelow && !fitsAbove && fitsBelow)) {
      return Offset(x, below);
    }
    if ((!preferBelow && fitsAbove) ||
        (preferBelow && !fitsBelow && fitsAbove)) {
      return Offset(x, above);
    }

    final centeredY = targetRect.center.dy - (childSize.height / 2);
    final maxY = math.max(0.0, size.height - childSize.height - _safetyGap);
    final y = centeredY.clamp(0.0, maxY).toDouble();
    final left = targetRect.left - verticalOffset - childSize.width;
    if (left >= 0) {
      return Offset(left, y);
    }
    final right = targetRect.right + verticalOffset;
    if (right + childSize.width <= size.width - _safetyGap) {
      return Offset(right, y);
    }

    final preferredY = preferBelow ? below : above;
    return Offset(x, preferredY.clamp(0.0, maxY).toDouble());
  }

  @override
  bool shouldRelayout(_MetroTooltipLayoutDelegate oldDelegate) {
    return targetRect != oldDelegate.targetRect ||
        preferBelow != oldDelegate.preferBelow ||
        verticalOffset != oldDelegate.verticalOffset ||
        maxWidth != oldDelegate.maxWidth;
  }
}

enum _MetroTooltipTrigger { mouse, keyboard, touch }
