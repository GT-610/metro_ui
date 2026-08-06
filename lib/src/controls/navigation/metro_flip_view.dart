import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/metro_interactive.dart';
import '../../localization/metro_localizations.dart';
import '../../theme/metro_spacing.dart';
import '../../theme/metro_theme.dart';
import '../../theme/metro_theme_data.dart';
import 'metro_flip_view_style.dart';

export 'metro_flip_view_style.dart';

/// Controls when FlipView previous and next buttons are displayed.
enum MetroFlipViewNavigationVisibility {
  /// Shows navigation while the FlipView is hovered or contains focus.
  auto,

  /// Keeps every currently available navigation button visible.
  always,

  /// Hides navigation buttons without disabling swipe or keyboard input.
  hidden,
}

/// Content, optional banner, and accessible label for one FlipView page.
@immutable
class MetroFlipViewItem {
  const MetroFlipViewItem({
    required this.child,
    this.banner,
    this.semanticLabel,
  });

  final Widget child;
  final Widget? banner;
  final String? semanticLabel;
}

/// A Windows 8-style single-item viewer with direct swipe navigation.
///
/// Supply [index] for controlled selection, or leave it null and use
/// [initialIndex] for internally managed selection. Circular navigation uses
/// one current and one incoming subtree, so pages containing global keys are
/// never duplicated merely to simulate wrapping.
class MetroFlipView extends StatefulWidget {
  const MetroFlipView({
    required this.items,
    this.index,
    this.initialIndex = 0,
    this.onChanged,
    this.axis = Axis.horizontal,
    this.circular = false,
    this.swipeEnabled = true,
    this.navigationEnabled = true,
    this.navigationVisibility = MetroFlipViewNavigationVisibility.auto,
    this.showIndicators = false,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.previousSemanticLabel,
    this.nextSemanticLabel,
    super.key,
  }) : assert(items.length > 0),
       assert(initialIndex >= 0 && initialIndex < items.length),
       assert(index == null || (index >= 0 && index < items.length));

  final List<MetroFlipViewItem> items;
  final int? index;
  final int initialIndex;
  final ValueChanged<int>? onChanged;
  final Axis axis;
  final bool circular;
  final bool swipeEnabled;
  final bool navigationEnabled;
  final MetroFlipViewNavigationVisibility navigationVisibility;
  final bool showIndicators;
  final MetroFlipViewStyle? style;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? semanticLabel;
  final String? previousSemanticLabel;
  final String? nextSemanticLabel;

  @override
  State<MetroFlipView> createState() => _MetroFlipViewState();
}

class _MetroFlipViewState extends State<MetroFlipView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  Animation<double>? _offsetAnimation;
  Animation<double>? _incomingOffsetAnimation;
  Animation<double>? _incomingOpacityAnimation;
  Animation<double>? _outgoingOpacityAnimation;
  FocusNode? _internalFocusNode;
  late int _displayedIndex = widget.index ?? widget.initialIndex;
  int? _incomingIndex;
  int _transitionDirection = 1;
  bool _commitAnimation = false;
  bool _programmaticTransition = false;
  bool _hovered = false;
  bool _focusWithin = false;
  double _dragOffset = 0;
  double _viewportExtent = 0;
  double _physicalForwardSign = 1;

  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode!;

  bool get _inputEnabled {
    return widget.navigationEnabled &&
        widget.items.length > 1 &&
        (widget.index == null || widget.onChanged != null);
  }

  bool get _isAnimating => _animationController.isAnimating;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this)
      ..addListener(_handleAnimationTick)
      ..addStatusListener(_handleAnimationStatus);
    if (widget.focusNode == null) {
      _internalFocusNode = FocusNode(debugLabel: 'MetroFlipView');
    }
  }

  @override
  void didUpdateWidget(MetroFlipView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      if (widget.focusNode == null) {
        _internalFocusNode = FocusNode(debugLabel: 'MetroFlipView');
      } else if (oldWidget.focusNode == null) {
        _internalFocusNode?.dispose();
        _internalFocusNode = null;
      }
    }

    final lastIndex = widget.items.length - 1;
    if (_displayedIndex > lastIndex ||
        (_incomingIndex != null && _incomingIndex! > lastIndex)) {
      _cancelAnimation();
      _displayedIndex = widget.index ?? math.min(_displayedIndex, lastIndex);
    }

    if (oldWidget.axis != widget.axis) {
      _cancelAnimation();
    }

    final controlledIndex = widget.index;
    if (controlledIndex != null &&
        controlledIndex != _displayedIndex &&
        controlledIndex != _incomingIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _startTransition(controlledIndex, notify: false);
        }
      });
    }
  }

  MetroFlipViewStyle _resolveStyle(BuildContext context) {
    final theme = MetroTheme.of(context);
    return _defaultStyle(theme)
        .merge(theme.flipViewTheme.style)
        .merge(MetroFlipViewTheme.maybeOf(context)?.style)
        .merge(widget.style);
  }

  int? _neighbor(int direction) {
    final target = _displayedIndex + direction;
    if (target >= 0 && target < widget.items.length) {
      return target;
    }
    if (!widget.circular || widget.items.length < 2) {
      return null;
    }
    return direction > 0 ? 0 : widget.items.length - 1;
  }

  bool get _canGoPrevious => _inputEnabled && _neighbor(-1) != null;

  bool get _canGoNext => _inputEnabled && _neighbor(1) != null;

  int _directionTo(int target) {
    if (!widget.circular) {
      return target > _displayedIndex ? 1 : -1;
    }
    final count = widget.items.length;
    final forward = (target - _displayedIndex + count) % count;
    final backward = (_displayedIndex - target + count) % count;
    return forward <= backward ? 1 : -1;
  }

  void _requestDelta(int direction) {
    if (!_inputEnabled || _isAnimating || _incomingIndex != null) {
      return;
    }
    final target = _neighbor(direction);
    if (target != null) {
      _startTransition(target, direction: direction, notify: true);
    }
  }

  void _requestIndex(int index) {
    if (!_inputEnabled ||
        index == _displayedIndex ||
        _isAnimating ||
        _incomingIndex != null) {
      return;
    }
    _startTransition(index, direction: _directionTo(index), notify: true);
  }

  void _startTransition(int target, {required bool notify, int? direction}) {
    if (target == _displayedIndex ||
        target < 0 ||
        target >= widget.items.length) {
      return;
    }
    _cancelAnimation();
    final resolvedDirection = direction ?? _directionTo(target);
    if (notify) {
      widget.onChanged?.call(target);
    }
    if (_reduceMotion(context) || _viewportExtent <= 0) {
      setState(() => _displayedIndex = target);
      _scheduleControlledReconciliation();
      return;
    }
    setState(() {
      _incomingIndex = target;
      _transitionDirection = resolvedDirection;
      _dragOffset = 0;
      _programmaticTransition = true;
    });
    final motion = MetroTheme.of(context).motion;
    _commitAnimation = true;
    _animationController.duration = motion.contentEntrance;
    _offsetAnimation = null;
    _incomingOffsetAnimation =
        Tween<double>(
          begin: _physicalForwardSign * resolvedDirection * 40,
          end: 0,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: motion.standardCurve,
          ),
        );
    _incomingOpacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: _phaseCurve(
          motion.contentFade,
          motion.contentEntrance,
          motion.standardCurve,
        ),
      ),
    );
    _outgoingOpacityAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: _phaseCurve(
          motion.normal,
          motion.contentEntrance,
          Curves.linear,
        ),
      ),
    );
    _animationController.forward(from: 0);
  }

  void _animateOffset({
    required double begin,
    required double end,
    required bool commit,
    required Duration duration,
  }) {
    _commitAnimation = commit;
    _programmaticTransition = false;
    _animationController.duration = duration;
    _incomingOffsetAnimation = null;
    _incomingOpacityAnimation = null;
    _outgoingOpacityAnimation = null;
    _offsetAnimation = Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: MetroTheme.of(context).motion.standardCurve,
      ),
    );
    _animationController.forward(from: 0);
  }

  void _handleAnimationTick() {
    if (!mounted) {
      return;
    }
    final offsetAnimation = _offsetAnimation;
    if (offsetAnimation != null || _programmaticTransition) {
      setState(() {
        if (offsetAnimation != null) {
          _dragOffset = offsetAnimation.value;
        }
      });
    }
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || !mounted) {
      return;
    }
    final target = _incomingIndex;
    final commit = _commitAnimation && target != null;
    _offsetAnimation = null;
    _incomingOffsetAnimation = null;
    _incomingOpacityAnimation = null;
    _outgoingOpacityAnimation = null;
    _programmaticTransition = false;
    _animationController.reset();
    setState(() {
      if (commit) {
        _displayedIndex = target;
      }
      _incomingIndex = null;
      _dragOffset = 0;
      _commitAnimation = false;
    });
    if (commit) {
      _scheduleControlledReconciliation();
    }
  }

  void _scheduleControlledReconciliation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final controlledIndex = widget.index;
      if (controlledIndex != null &&
          controlledIndex != _displayedIndex &&
          _incomingIndex == null) {
        _startTransition(controlledIndex, notify: false);
      }
    });
  }

  void _cancelAnimation() {
    _animationController.stop();
    _offsetAnimation = null;
    _incomingOffsetAnimation = null;
    _incomingOpacityAnimation = null;
    _outgoingOpacityAnimation = null;
    _programmaticTransition = false;
    _animationController.reset();
    _incomingIndex = null;
    _dragOffset = 0;
    _commitAnimation = false;
  }

  void _handleDragStart(DragStartDetails details) {
    if (!_inputEnabled || _isAnimating) {
      return;
    }
    _focusNode.requestFocus();
    setState(() {
      _incomingIndex = null;
      _dragOffset = 0;
      _programmaticTransition = false;
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_inputEnabled || _isAnimating || _viewportExtent <= 0) {
      return;
    }
    final delta = details.primaryDelta ?? 0;
    var candidate = (_dragOffset + delta).clamp(
      -_viewportExtent,
      _viewportExtent,
    );
    if (candidate == 0) {
      setState(() {
        _dragOffset = 0;
        _incomingIndex = null;
      });
      return;
    }
    final direction = candidate * _physicalForwardSign < 0 ? 1 : -1;
    final target = _neighbor(direction);
    if (target == null) {
      final limit = _viewportExtent * 0.12;
      candidate = candidate.clamp(-limit, limit) * 0.35;
    }
    setState(() {
      _dragOffset = candidate;
      _transitionDirection = direction;
      _incomingIndex = target;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    final target = _incomingIndex;
    if (!_inputEnabled || target == null || _viewportExtent <= 0) {
      _settleDrag(commit: false);
      return;
    }
    final velocity = (details.primaryVelocity ?? 0) * _physicalForwardSign;
    final velocityCommits = _transitionDirection > 0
        ? velocity < -500
        : velocity > 500;
    final distanceCommits = _dragOffset.abs() >= _viewportExtent * 0.2;
    final commit = velocityCommits || distanceCommits;
    if (commit) {
      widget.onChanged?.call(target);
    }
    _settleDrag(commit: commit);
  }

  void _settleDrag({required bool commit}) {
    if (_incomingIndex == null) {
      if (mounted && _dragOffset != 0) {
        setState(() => _dragOffset = 0);
      }
      return;
    }
    if (_reduceMotion(context)) {
      final target = _incomingIndex;
      setState(() {
        if (commit && target != null) {
          _displayedIndex = target;
        }
        _incomingIndex = null;
        _dragOffset = 0;
      });
      if (commit) {
        _scheduleControlledReconciliation();
      }
      return;
    }
    final end = commit
        ? -_physicalForwardSign * _transitionDirection * _viewportExtent
        : 0.0;
    _animateOffset(
      begin: _dragOffset,
      end: end,
      commit: commit,
      duration: MetroTheme.of(context).motion.fast,
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = _resolveStyle(context);
    final localizations = MetroLocalizations.of(context);
    final reduceMotion = _reduceMotion(context);
    final textDirection = Directionality.of(context);
    final surfaceStates = <WidgetState>{
      if (!_inputEnabled) WidgetState.disabled,
      if (_hovered) WidgetState.hovered,
      if (_focusWithin) WidgetState.focused,
    };
    final borderColor = style.borderColor!.resolve(surfaceStates);
    final borderWidth = style.borderWidth!.resolve(surfaceStates)!;
    final shortcuts = <ShortcutActivator, Intent>{
      if (widget.axis == Axis.horizontal) ...{
        const SingleActivator(
          LogicalKeyboardKey.arrowLeft,
        ): textDirection == TextDirection.ltr
            ? const _PreviousFlipViewIntent()
            : const _NextFlipViewIntent(),
        const SingleActivator(
          LogicalKeyboardKey.arrowRight,
        ): textDirection == TextDirection.ltr
            ? const _NextFlipViewIntent()
            : const _PreviousFlipViewIntent(),
      } else ...{
        const SingleActivator(LogicalKeyboardKey.arrowUp):
            const _PreviousFlipViewIntent(),
        const SingleActivator(LogicalKeyboardKey.arrowDown):
            const _NextFlipViewIntent(),
      },
      const SingleActivator(LogicalKeyboardKey.pageUp):
          const _PreviousFlipViewIntent(),
      const SingleActivator(LogicalKeyboardKey.pageDown):
          const _NextFlipViewIntent(),
      const SingleActivator(LogicalKeyboardKey.home):
          const _FirstFlipViewIntent(),
      const SingleActivator(LogicalKeyboardKey.end):
          const _LastFlipViewIntent(),
    };

    Widget surface = LayoutBuilder(
      builder: (context, constraints) {
        assert(
          widget.axis == Axis.horizontal
              ? constraints.hasBoundedWidth
              : constraints.hasBoundedHeight,
          'MetroFlipView must have a bounded extent along its navigation axis.',
        );
        _viewportExtent = widget.axis == Axis.horizontal
            ? constraints.maxWidth
            : constraints.maxHeight;
        _physicalForwardSign = widget.axis == Axis.vertical
            ? 1
            : textDirection == TextDirection.ltr
            ? 1
            : -1;

        final currentOffset = _primaryOffset(_dragOffset);
        final incomingIndex = _incomingIndex;
        final programmatic = _programmaticTransition && incomingIndex != null;
        final incomingStart = programmatic
            ? (_incomingOffsetAnimation?.value ?? 0)
            : _physicalForwardSign * _transitionDirection * _viewportExtent +
                  _dragOffset;
        final incomingOffset = _primaryOffset(incomingStart);
        final outgoingOpacity = programmatic
            ? (_outgoingOpacityAnimation?.value ?? 1)
            : 1.0;
        final incomingOpacity = programmatic
            ? (_incomingOpacityAnimation?.value ?? 0)
            : 1.0;

        Widget content = ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (incomingIndex != null)
                Transform.translate(
                  key: const ValueKey<String>('metro-flip-view-incoming-item'),
                  offset: incomingOffset,
                  child: Opacity(
                    opacity: incomingOpacity,
                    child: _buildItem(incomingIndex, selected: false),
                  ),
                ),
              Transform.translate(
                key: const ValueKey<String>('metro-flip-view-current-item'),
                offset: programmatic ? Offset.zero : currentOffset,
                child: Opacity(
                  opacity: outgoingOpacity,
                  child: _buildItem(_displayedIndex, selected: true),
                ),
              ),
            ],
          ),
        );
        content = GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _inputEnabled ? _focusNode.requestFocus : null,
          onHorizontalDragEnd:
              _inputEnabled &&
                  widget.swipeEnabled &&
                  widget.axis == Axis.horizontal
              ? _handleDragEnd
              : null,
          onHorizontalDragStart:
              _inputEnabled &&
                  widget.swipeEnabled &&
                  widget.axis == Axis.horizontal
              ? _handleDragStart
              : null,
          onHorizontalDragUpdate:
              _inputEnabled &&
                  widget.swipeEnabled &&
                  widget.axis == Axis.horizontal
              ? _handleDragUpdate
              : null,
          onVerticalDragEnd:
              _inputEnabled &&
                  widget.swipeEnabled &&
                  widget.axis == Axis.vertical
              ? _handleDragEnd
              : null,
          onVerticalDragStart:
              _inputEnabled &&
                  widget.swipeEnabled &&
                  widget.axis == Axis.vertical
              ? _handleDragStart
              : null,
          onVerticalDragUpdate:
              _inputEnabled &&
                  widget.swipeEnabled &&
                  widget.axis == Axis.vertical
              ? _handleDragUpdate
              : null,
          child: content,
        );

        return Container(
          key: const ValueKey<String>('metro-flip-view-surface'),
          decoration: BoxDecoration(
            color: style.backgroundColor,
            border: borderWidth > 0
                ? Border.all(
                    color: borderColor ?? const Color(0x00000000),
                    width: borderWidth,
                  )
                : null,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              content,
              _buildBanner(style, reduceMotion),
              if (widget.showIndicators && widget.items.length > 1)
                _buildIndicators(style),
              if (widget.navigationVisibility !=
                      MetroFlipViewNavigationVisibility.hidden &&
                  widget.items.length > 1) ...[
                _buildNavigationButton(
                  style: style,
                  forward: false,
                  available: _canGoPrevious,
                  semanticLabel:
                      widget.previousSemanticLabel ??
                      localizations.flipViewPreviousLabel,
                  reduceMotion: reduceMotion,
                ),
                _buildNavigationButton(
                  style: style,
                  forward: true,
                  available: _canGoNext,
                  semanticLabel:
                      widget.nextSemanticLabel ??
                      localizations.flipViewNextLabel,
                  reduceMotion: reduceMotion,
                ),
              ],
            ],
          ),
        );
      },
    );

    surface = FocusableActionDetector(
      actions: <Type, Action<Intent>>{
        _PreviousFlipViewIntent: CallbackAction<_PreviousFlipViewIntent>(
          onInvoke: (intent) {
            _requestDelta(-1);
            return null;
          },
        ),
        _NextFlipViewIntent: CallbackAction<_NextFlipViewIntent>(
          onInvoke: (intent) {
            _requestDelta(1);
            return null;
          },
        ),
        _FirstFlipViewIntent: CallbackAction<_FirstFlipViewIntent>(
          onInvoke: (intent) {
            _requestIndex(0);
            return null;
          },
        ),
        _LastFlipViewIntent: CallbackAction<_LastFlipViewIntent>(
          onInvoke: (intent) {
            _requestIndex(widget.items.length - 1);
            return null;
          },
        ),
      },
      autofocus: widget.autofocus,
      enabled: _inputEnabled,
      focusNode: _focusNode,
      shortcuts: shortcuts,
      child: surface,
    );
    surface = Focus(
      canRequestFocus: false,
      onFocusChange: (value) {
        if (_focusWithin != value) {
          setState(() => _focusWithin = value);
        }
      },
      skipTraversal: true,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: surface,
      ),
    );

    final position = localizations.flipViewItemPosition(
      _displayedIndex + 1,
      widget.items.length,
    );
    return Semantics(
      container: true,
      enabled: _inputEnabled,
      increasedValue: _canGoNext
          ? localizations.flipViewItemPosition(
              (_neighbor(1) ?? _displayedIndex) + 1,
              widget.items.length,
            )
          : null,
      decreasedValue: _canGoPrevious
          ? localizations.flipViewItemPosition(
              (_neighbor(-1) ?? _displayedIndex) + 1,
              widget.items.length,
            )
          : null,
      label: widget.semanticLabel,
      liveRegion: true,
      onDecrease: _canGoPrevious ? () => _requestDelta(-1) : null,
      onIncrease: _canGoNext ? () => _requestDelta(1) : null,
      value: position,
      child: surface,
    );
  }

  Offset _primaryOffset(double value) {
    return widget.axis == Axis.horizontal ? Offset(value, 0) : Offset(0, value);
  }

  Curve _phaseCurve(Duration phase, Duration total, Curve curve) {
    if (phase <= Duration.zero) {
      return const Threshold(0);
    }
    if (total <= Duration.zero || phase >= total) {
      return curve;
    }
    return Interval(
      0,
      phase.inMicroseconds / total.inMicroseconds,
      curve: curve,
    );
  }

  Widget _buildItem(int index, {required bool selected}) {
    final item = widget.items[index];
    return Semantics(
      container: true,
      excludeSemantics: item.semanticLabel != null,
      label: item.semanticLabel,
      selected: selected,
      child: KeyedSubtree(key: ValueKey<int>(index), child: item.child),
    );
  }

  Widget _buildBanner(MetroFlipViewStyle style, bool reduceMotion) {
    final banner = widget.items[_displayedIndex].banner;
    return PositionedDirectional(
      start: 0,
      end: 0,
      bottom: 0,
      child: IgnorePointer(
        child: AnimatedSwitcher(
          duration: reduceMotion
              ? Duration.zero
              : MetroTheme.of(context).motion.normal,
          child: banner == null
              ? const SizedBox.shrink(key: ValueKey<String>('empty-banner'))
              : SizedBox(
                  key: ValueKey<int>(_displayedIndex),
                  width: double.infinity,
                  child: ColoredBox(
                    color: style.bannerBackgroundColor!,
                    child: Padding(
                      padding: style.bannerPadding!,
                      child: DefaultTextStyle.merge(
                        style: style.bannerTextStyle!.copyWith(
                          color: style.bannerForegroundColor,
                        ),
                        child: banner,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildIndicators(MetroFlipViewStyle style) {
    final children = <Widget>[];
    for (var index = 0; index < widget.items.length; index += 1) {
      if (index != 0) {
        children.add(SizedBox.square(dimension: style.indicatorSpacing));
      }
      final selected = index == _displayedIndex;
      children.add(
        MetroInteractive(
          onPressed: _inputEnabled ? () => _requestIndex(index) : null,
          semanticLabel: MetroLocalizations.of(
            context,
          ).flipViewItemPosition(index + 1, widget.items.length),
          semanticSelected: selected,
          builder: (context, states) {
            return SizedBox.square(
              dimension: math.max(32, style.indicatorSize! + 12),
              child: Center(
                child: AnimatedContainer(
                  duration: _reduceMotion(context)
                      ? Duration.zero
                      : MetroTheme.of(context).motion.fast,
                  width: style.indicatorSize,
                  height: style.indicatorSize,
                  color: selected
                      ? style.selectedIndicatorColor
                      : style.indicatorColor,
                ),
              ),
            );
          },
        ),
      );
    }
    return Align(
      alignment: style.indicatorAlignment!,
      child: Padding(
        padding: style.indicatorPadding!,
        child: widget.axis == Axis.horizontal
            ? Row(mainAxisSize: MainAxisSize.min, children: children)
            : Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }

  Widget _buildNavigationButton({
    required MetroFlipViewStyle style,
    required bool forward,
    required bool available,
    required String semanticLabel,
    required bool reduceMotion,
  }) {
    final show =
        available &&
        switch (widget.navigationVisibility) {
          MetroFlipViewNavigationVisibility.auto => _hovered || _focusWithin,
          MetroFlipViewNavigationVisibility.always => true,
          MetroFlipViewNavigationVisibility.hidden => false,
        };
    final button = ExcludeSemantics(
      excluding: !show,
      child: IgnorePointer(
        ignoring: !show,
        child: AnimatedOpacity(
          duration: reduceMotion
              ? Duration.zero
              : MetroTheme.of(context).motion.normal,
          opacity: show ? 1 : 0,
          child: _MetroFlipViewNavigationButton(
            key: ValueKey<String>(
              forward ? 'metro-flip-view-next' : 'metro-flip-view-previous',
            ),
            axis: widget.axis,
            forward: forward,
            onPressed: available ? () => _requestDelta(forward ? 1 : -1) : null,
            semanticLabel: semanticLabel,
            style: style,
          ),
        ),
      ),
    );
    final alignment = widget.axis == Axis.horizontal
        ? forward
              ? AlignmentDirectional.centerEnd
              : AlignmentDirectional.centerStart
        : forward
        ? Alignment.bottomCenter
        : Alignment.topCenter;
    final padding = widget.axis == Axis.horizontal
        ? EdgeInsetsDirectional.only(
            start: forward ? 0 : style.navigationInset!,
            end: forward ? style.navigationInset! : 0,
          )
        : EdgeInsets.only(
            top: forward ? 0 : style.navigationInset!,
            bottom: forward ? style.navigationInset! : 0,
          );
    return Align(
      alignment: alignment,
      child: Padding(padding: padding, child: button),
    );
  }

  static MetroFlipViewStyle _defaultStyle(MetroThemeData theme) {
    final colors = theme.colors;
    return MetroFlipViewStyle(
      backgroundColor: const Color(0x00000000),
      borderColor: const WidgetStatePropertyAll(Color(0x00000000)),
      borderWidth: const WidgetStatePropertyAll(0),
      navigationBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (colors.isHighContrast) {
          if (states.contains(WidgetState.pressed)) {
            return colors.foreground;
          }
          if (states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.focused)) {
            return colors.accent;
          }
          return colors.background;
        }
        if (states.contains(WidgetState.pressed)) {
          return const Color(0xBD292929);
        }
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.focused)) {
          return const Color(0xF0D7D7D7);
        }
        return const Color(0x59D5D5D5);
      }),
      navigationForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (colors.isHighContrast) {
          if (states.contains(WidgetState.pressed)) {
            return colors.background;
          }
          if (states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.focused)) {
            return colors.onAccent;
          }
          return colors.foreground;
        }
        return states.contains(WidgetState.pressed)
            ? const Color(0xFFFFFFFF)
            : states.contains(WidgetState.hovered) ||
                  states.contains(WidgetState.focused)
            ? const Color(0xFF000000)
            : const Color(0x99000000);
      }),
      navigationBorderColor: WidgetStatePropertyAll(
        colors.isHighContrast ? colors.foreground : const Color(0x00000000),
      ),
      navigationBorderWidth: WidgetStatePropertyAll(
        colors.isHighContrast ? 2 : 0,
      ),
      navigationButtonExtent: 69,
      navigationButtonCrossExtent: 39,
      navigationInset: 0,
      bannerBackgroundColor: colors.accent.withValues(alpha: 0.92),
      bannerForegroundColor: colors.onAccent,
      bannerTextStyle: theme.typography.bodyStrong,
      bannerPadding: const EdgeInsets.symmetric(
        horizontal: MetroSpacing.md,
        vertical: MetroSpacing.sm,
      ),
      indicatorColor: colors.mutedForeground.withValues(alpha: 0.55),
      selectedIndicatorColor: colors.accent,
      indicatorSize: 8,
      indicatorSpacing: MetroSpacing.xxs,
      indicatorPadding: const EdgeInsets.all(MetroSpacing.sm),
      indicatorAlignment: AlignmentDirectional.topCenter,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _internalFocusNode?.dispose();
    super.dispose();
  }
}

class _MetroFlipViewNavigationButton extends StatelessWidget {
  const _MetroFlipViewNavigationButton({
    required this.axis,
    required this.forward,
    required this.onPressed,
    required this.semanticLabel,
    required this.style,
    super.key,
  });

  final Axis axis;
  final bool forward;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final MetroFlipViewStyle style;

  @override
  Widget build(BuildContext context) {
    final direction = Directionality.of(context);
    return MetroInteractive(
      onPressed: onPressed,
      semanticLabel: semanticLabel,
      builder: (context, states) {
        final background = style.navigationBackgroundColor!.resolve(states);
        final foreground = style.navigationForegroundColor!.resolve(states);
        final borderColor = style.navigationBorderColor!.resolve(states);
        final borderWidth = style.navigationBorderWidth!.resolve(states)!;
        return Container(
          key: ValueKey<String>(
            forward
                ? 'metro-flip-view-next-surface'
                : 'metro-flip-view-previous-surface',
          ),
          width: style.navigationButtonExtent,
          height: style.navigationButtonCrossExtent,
          decoration: BoxDecoration(
            color: background,
            border: borderWidth > 0
                ? Border.all(
                    color: borderColor ?? const Color(0x00000000),
                    width: borderWidth,
                  )
                : null,
          ),
          child: CustomPaint(
            painter: _MetroFlipViewChevronPainter(
              axis: axis,
              color: foreground ?? const Color(0x00000000),
              forward: forward,
              textDirection: direction,
            ),
          ),
        );
      },
    );
  }
}

class _MetroFlipViewChevronPainter extends CustomPainter {
  const _MetroFlipViewChevronPainter({
    required this.axis,
    required this.color,
    required this.forward,
    required this.textDirection,
  });

  final Axis axis;
  final Color color;
  final bool forward;
  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.miter
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final center = Offset(size.width / 2, size.height / 2);
    final path = Path();
    if (axis == Axis.horizontal) {
      final pointsRight = forward == (textDirection == TextDirection.ltr);
      final direction = pointsRight ? 1.0 : -1.0;
      path
        ..moveTo(center.dx - (direction * 5), center.dy - 8)
        ..lineTo(center.dx + (direction * 3), center.dy)
        ..lineTo(center.dx - (direction * 5), center.dy + 8);
    } else {
      final direction = forward ? 1.0 : -1.0;
      path
        ..moveTo(center.dx - 8, center.dy - (direction * 5))
        ..lineTo(center.dx, center.dy + (direction * 3))
        ..lineTo(center.dx + 8, center.dy - (direction * 5));
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_MetroFlipViewChevronPainter oldDelegate) {
    return axis != oldDelegate.axis ||
        color != oldDelegate.color ||
        forward != oldDelegate.forward ||
        textDirection != oldDelegate.textDirection;
  }
}

bool _reduceMotion(BuildContext context) {
  final media = MediaQuery.maybeOf(context);
  return media?.disableAnimations == true ||
      media?.accessibleNavigation == true;
}

class _PreviousFlipViewIntent extends Intent {
  const _PreviousFlipViewIntent();
}

class _NextFlipViewIntent extends Intent {
  const _NextFlipViewIntent();
}

class _FirstFlipViewIntent extends Intent {
  const _FirstFlipViewIntent();
}

class _LastFlipViewIntent extends Intent {
  const _LastFlipViewIntent();
}
