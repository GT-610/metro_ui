import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../localization/metro_localizations.dart';
import '../../theme/metro_theme.dart';
import '../../theme/metro_theme_data.dart';
import 'metro_semantic_zoom_style.dart';

export 'metro_semantic_zoom_style.dart';

const _semanticZoomButtonKey = ValueKey<String>('metro-semantic-zoom-button');
const _zoomedInViewKey = ValueKey<String>('metro-semantic-zoom-in-view');
const _zoomedOutViewKey = ValueKey<String>('metro-semantic-zoom-out-view');

/// Switches between detailed and summarized views of the same information.
///
/// This is semantic rather than optical zoom: [zoomedInView] and
/// [zoomedOutView] are separate, state-preserving widget subtrees. The
/// transition uses the WinJS 0.65 default scale and 333ms cross-scale recipe.
/// Users can switch with a two-pointer pinch, Ctrl+mouse wheel, Ctrl+Plus or
/// Ctrl+Minus, assistive-technology actions, or the transient desktop minus
/// button. Applications remain responsible for mapping a selected summary
/// item to the corresponding detailed content.
class MetroSemanticZoom extends StatefulWidget {
  const MetroSemanticZoom({
    required this.zoomedInView,
    required this.zoomedOutView,
    this.zoomedOut,
    this.initiallyZoomedOut = false,
    this.onZoomedOutChanged,
    this.zoomFactor = 0.65,
    this.locked = false,
    this.enableButton = true,
    this.width,
    this.height = 400,
    this.autofocus = false,
    this.focusNode,
    this.semanticLabel,
    this.style,
    this.clipBehavior = Clip.hardEdge,
    super.key,
  }) : assert(zoomFactor >= 0.2 && zoomFactor <= 0.8),
       assert(width == null || width > 0),
       assert(height == null || height > 0);

  /// Detailed collection view.
  final Widget zoomedInView;

  /// Summarized group or category view.
  final Widget zoomedOutView;

  /// Controlled view state, or null to use [initiallyZoomedOut].
  final bool? zoomedOut;

  /// Initial view state when [zoomedOut] is null.
  final bool initiallyZoomedOut;

  /// Reports user-requested view changes.
  final ValueChanged<bool>? onZoomedOutChanged;

  /// Scale used by the outgoing detailed view and incoming summary view.
  ///
  /// WinJS accepts values from 0.2 through 0.8 and defaults to 0.65.
  final double zoomFactor;

  /// Whether all view switching is disabled.
  final bool locked;

  /// Whether pointer movement reveals the desktop minus button.
  final bool enableButton;

  final double? width;
  final double? height;
  final bool autofocus;
  final FocusNode? focusNode;
  final String? semanticLabel;
  final MetroSemanticZoomStyle? style;
  final Clip clipBehavior;

  @override
  State<MetroSemanticZoom> createState() => _MetroSemanticZoomState();
}

class _MetroSemanticZoomState extends State<MetroSemanticZoom>
    with SingleTickerProviderStateMixin {
  static const _zoomOutDistanceFactor = 0.8;
  static const _zoomInDistanceFactor = 1.45;
  static const _buttonMovementThreshold = 8.0;

  late bool _internalZoomedOut = widget.initiallyZoomedOut;
  late bool _targetZoomedOut = _effectiveZoomedOut;
  late final AnimationController _controller = AnimationController(
    vsync: this,
    value: _targetZoomedOut ? 1 : 0,
  );
  late final FocusNode _internalFocusNode = FocusNode(
    debugLabel: 'MetroSemanticZoom',
  );
  final FocusScopeNode _zoomedInFocusScope = FocusScopeNode(
    debugLabel: 'MetroSemanticZoom zoomed-in view',
  );
  final FocusScopeNode _zoomedOutFocusScope = FocusScopeNode(
    debugLabel: 'MetroSemanticZoom zoomed-out view',
  );
  final Map<int, Offset> _pointerPositions = <int, Offset>{};

  Timer? _buttonTimer;
  Offset? _lastMousePosition;
  Offset? _pinchCenter;
  Offset? _pendingZoomCenter;
  double? _pinchStartDistance;
  bool _pinchTriggered = false;
  bool _buttonShown = false;
  bool _buttonHovered = false;
  bool _buttonPressed = false;
  bool _pendingFocusRestore = false;

  bool get _effectiveZoomedOut => widget.zoomedOut ?? _internalZoomedOut;

  FocusNode get _effectiveFocusNode => widget.focusNode ?? _internalFocusNode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncMotion(commitReducedMotion: true);
  }

  @override
  void didUpdateWidget(MetroSemanticZoom oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncMotion();
    final next = _effectiveZoomedOut;
    if (next != _targetZoomedOut) {
      _targetZoomedOut = next;
      _beginTransition(
        next,
        focalPoint: _pendingZoomCenter,
        restoreFocus: _pendingFocusRestore || _containsFocus,
      );
      _pendingZoomCenter = null;
      _pendingFocusRestore = false;
    }
    if (widget.locked || !widget.enableButton || next) {
      _hideButton();
    }
  }

  bool get _containsFocus =>
      _effectiveFocusNode.hasFocus ||
      _zoomedInFocusScope.hasFocus ||
      _zoomedOutFocusScope.hasFocus;

  void _syncMotion({bool commitReducedMotion = false}) {
    final reduceMotion = _reduceMotion(context);
    _controller.duration = reduceMotion
        ? Duration.zero
        : MetroTheme.of(context).motion.semanticZoom;
    if (commitReducedMotion && reduceMotion) {
      _controller.value = _targetZoomedOut ? 1 : 0;
    }
  }

  void _requestZoom(bool zoomedOut, {Offset? focalPoint}) {
    if (widget.locked || zoomedOut == _effectiveZoomedOut) return;
    _hideButton();
    _pendingZoomCenter = focalPoint;
    _pendingFocusRestore = _containsFocus;
    if (widget.zoomedOut == null) {
      setState(() {
        _internalZoomedOut = zoomedOut;
        _targetZoomedOut = zoomedOut;
      });
      _beginTransition(
        zoomedOut,
        focalPoint: focalPoint,
        restoreFocus: _pendingFocusRestore,
      );
      _pendingZoomCenter = null;
      _pendingFocusRestore = false;
    }
    widget.onZoomedOutChanged?.call(zoomedOut);
  }

  void _beginTransition(
    bool zoomedOut, {
    required bool restoreFocus,
    Offset? focalPoint,
  }) {
    _pinchCenter = focalPoint;
    final reduceMotion = _reduceMotion(context);
    if (reduceMotion) {
      _controller.value = zoomedOut ? 1 : 0;
      if (restoreFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && zoomedOut == _effectiveZoomedOut) {
            _restoreFocus(zoomedOut);
          }
        });
      }
      return;
    }
    _controller
        .animateTo(zoomedOut ? 1 : 0, curve: Curves.easeInOut)
        .whenCompleteOrCancel(() {
          if (restoreFocus && mounted && zoomedOut == _effectiveZoomedOut) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && zoomedOut == _effectiveZoomedOut) {
                _restoreFocus(zoomedOut);
              }
            });
          }
        });
  }

  void _restoreFocus(bool zoomedOut) {
    final scope = zoomedOut ? _zoomedOutFocusScope : _zoomedInFocusScope;
    final previousChild = scope.focusedChild;
    if (previousChild != null && previousChild.canRequestFocus) {
      previousChild.requestFocus();
      return;
    }
    for (final node in scope.traversalDescendants) {
      if (node.canRequestFocus && !node.skipTraversal) {
        scope.requestFocus(node);
        return;
      }
    }
    scope.requestFocus();
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (!_tracksPinch(event.kind)) return;
    _pointerPositions[event.pointer] = event.localPosition;
    if (_pointerPositions.length == 2) {
      final positions = _pointerPositions.values.toList(growable: false);
      _pinchStartDistance = (positions[0] - positions[1]).distance;
      _pinchTriggered = false;
    } else if (_pointerPositions.length > 2) {
      _resetPinch();
    }
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (!_pointerPositions.containsKey(event.pointer)) return;
    _pointerPositions[event.pointer] = event.localPosition;
    if (widget.locked ||
        _pointerPositions.length != 2 ||
        _pinchTriggered ||
        _pinchStartDistance == null ||
        _pinchStartDistance == 0) {
      return;
    }
    final positions = _pointerPositions.values.toList(growable: false);
    final currentDistance = (positions[0] - positions[1]).distance;
    final distanceFactor = currentDistance / _pinchStartDistance!;
    final center = Offset(
      (positions[0].dx + positions[1].dx) / 2,
      (positions[0].dy + positions[1].dy) / 2,
    );
    if (distanceFactor <= _zoomOutDistanceFactor) {
      _pinchTriggered = true;
      _requestZoom(true, focalPoint: center);
    } else if (distanceFactor >= _zoomInDistanceFactor) {
      _pinchTriggered = true;
      _requestZoom(false, focalPoint: center);
    }
  }

  void _handlePointerEnd(PointerEvent event) {
    _pointerPositions.remove(event.pointer);
    if (_pointerPositions.length < 2) {
      _pinchStartDistance = null;
      _pinchTriggered = false;
    }
  }

  void _resetPinch() {
    _pointerPositions.clear();
    _pinchStartDistance = null;
    _pinchTriggered = false;
  }

  bool _tracksPinch(PointerDeviceKind kind) {
    return kind == PointerDeviceKind.touch ||
        kind == PointerDeviceKind.stylus ||
        kind == PointerDeviceKind.invertedStylus;
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (widget.locked ||
        event is! PointerScrollEvent ||
        !HardwareKeyboard.instance.isControlPressed) {
      return;
    }
    final delta = event.scrollDelta.dy.abs() >= event.scrollDelta.dx.abs()
        ? event.scrollDelta.dy
        : event.scrollDelta.dx;
    if (delta == 0) return;
    _requestZoom(delta > 0, focalPoint: event.localPosition);
  }

  void _handleMouseHover(PointerHoverEvent event, Duration showDuration) {
    final previous = _lastMousePosition;
    _lastMousePosition = event.position;
    if (previous == null ||
        (event.position - previous).distance > _buttonMovementThreshold) {
      _showButton(showDuration);
    }
  }

  void _showButton(Duration showDuration) {
    if (!widget.enableButton || widget.locked || _effectiveZoomedOut) return;
    _buttonTimer?.cancel();
    if (!_buttonShown) setState(() => _buttonShown = true);
    _buttonTimer = Timer(showDuration, _hideButton);
  }

  void _hideButton() {
    _buttonTimer?.cancel();
    _buttonTimer = null;
    if (_buttonShown && mounted) {
      setState(() {
        _buttonShown = false;
        _buttonHovered = false;
        _buttonPressed = false;
      });
    }
  }

  void _setButtonHovered(bool value) {
    if (_buttonHovered == value) return;
    setState(() => _buttonHovered = value);
  }

  void _setButtonPressed(bool value) {
    if (_buttonPressed == value) return;
    setState(() => _buttonPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = MetroTheme.of(context);
    final localTheme = MetroSemanticZoomTheme.maybeOf(context);
    final effectiveStyle = _defaultStyle(theme)
        .merge(theme.semanticZoomTheme.style)
        .merge(localTheme?.style)
        .merge(widget.style);
    final localizations = MetroLocalizations.of(context);
    final buttonShowDuration =
        effectiveStyle.buttonShowDuration ?? const Duration(seconds: 3);
    final bindings = <ShortcutActivator, VoidCallback>{
      const SingleActivator(LogicalKeyboardKey.minus, control: true): () {
        _requestZoom(true);
      },
      const SingleActivator(
        LogicalKeyboardKey.numpadSubtract,
        control: true,
      ): () {
        _requestZoom(true);
      },
      const SingleActivator(LogicalKeyboardKey.equal, control: true): () {
        _requestZoom(false);
      },
      const SingleActivator(
        LogicalKeyboardKey.equal,
        control: true,
        shift: true,
      ): () {
        _requestZoom(false);
      },
      const SingleActivator(LogicalKeyboardKey.numpadAdd, control: true): () {
        _requestZoom(false);
      },
    };

    final content = SizedBox(
      width: widget.width,
      height: widget.height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          final alignment = _alignmentFor(size, _pinchCenter);
          return ClipRect(
            clipBehavior: widget.clipBehavior,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final progress = _controller.value;
                final inScale = 1 - (1 - widget.zoomFactor) * progress;
                final outScale =
                    (1 / widget.zoomFactor) -
                    ((1 / widget.zoomFactor) - 1) * progress;
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildView(
                      key: _zoomedInViewKey,
                      child: widget.zoomedInView,
                      focusScope: _zoomedInFocusScope,
                      active: !_effectiveZoomedOut,
                      opacity: 1 - progress,
                      scale: inScale,
                      alignment: alignment,
                    ),
                    _buildView(
                      key: _zoomedOutViewKey,
                      child: widget.zoomedOutView,
                      focusScope: _zoomedOutFocusScope,
                      active: _effectiveZoomedOut,
                      opacity: progress,
                      scale: outScale,
                      alignment: alignment,
                    ),
                    _buildButton(theme, effectiveStyle, buttonShowDuration),
                  ],
                );
              },
            ),
          );
        },
      ),
    );

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.semanticLabel ?? localizations.semanticZoomLabel,
      value: _effectiveZoomedOut
          ? localizations.semanticZoomedOutLabel
          : localizations.semanticZoomedInLabel,
      increasedValue: _effectiveZoomedOut
          ? localizations.semanticZoomedInLabel
          : null,
      decreasedValue: _effectiveZoomedOut
          ? null
          : localizations.semanticZoomedOutLabel,
      toggled: _effectiveZoomedOut,
      onTap: widget.locked ? null : () => _requestZoom(!_effectiveZoomedOut),
      onIncrease: widget.locked || !_effectiveZoomedOut
          ? null
          : () => _requestZoom(false),
      onDecrease: widget.locked || _effectiveZoomedOut
          ? null
          : () => _requestZoom(true),
      child: CallbackShortcuts(
        bindings: bindings,
        child: Focus(
          autofocus: widget.autofocus,
          focusNode: _effectiveFocusNode,
          canRequestFocus: !widget.locked,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              _hideButton();
              return false;
            },
            child: MouseRegion(
              onHover: (event) => _handleMouseHover(event, buttonShowDuration),
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: _handlePointerDown,
                onPointerMove: _handlePointerMove,
                onPointerUp: _handlePointerEnd,
                onPointerCancel: _handlePointerEnd,
                onPointerSignal: _handlePointerSignal,
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildView({
    required Key key,
    required Widget child,
    required FocusScopeNode focusScope,
    required bool active,
    required double opacity,
    required double scale,
    required Alignment alignment,
  }) {
    return IgnorePointer(
      ignoring: !active,
      child: ExcludeFocus(
        excluding: !active,
        child: ExcludeSemantics(
          excluding: !active,
          child: Opacity(
            key: key,
            opacity: opacity.clamp(0, 1),
            child: Transform.scale(
              scale: scale,
              alignment: alignment,
              child: FocusScope(node: focusScope, child: child),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
    MetroThemeData theme,
    MetroSemanticZoomStyle style,
    Duration showDuration,
  ) {
    final visible =
        _buttonShown &&
        widget.enableButton &&
        !widget.locked &&
        !_effectiveZoomedOut;
    final states = <WidgetState>{
      if (_buttonHovered) WidgetState.hovered,
      if (_buttonPressed) WidgetState.pressed,
    };
    final size = style.buttonSize ?? 25;
    final iconSize = style.buttonIconSize ?? 14.667;
    final borderWidth = style.buttonBorderWidth?.resolve(states) ?? 0;
    return PositionedDirectional(
      end: style.buttonEndInset ?? 4,
      bottom: style.buttonBottomInset ?? 21,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: _reduceMotion(context)
            ? Duration.zero
            : visible
            ? theme.motion.fadeIn
            : theme.motion.normal,
        child: IgnorePointer(
          ignoring: !visible,
          child: ExcludeSemantics(
            child: MouseRegion(
              cursor: style.buttonMouseCursor ?? SystemMouseCursors.click,
              onEnter: (_) {
                _setButtonHovered(true);
                _showButton(showDuration);
              },
              onExit: (_) => _setButtonHovered(false),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (_) => _setButtonPressed(true),
                onTapUp: (_) => _setButtonPressed(false),
                onTapCancel: () => _setButtonPressed(false),
                onTap: () => _requestZoom(true),
                child: SizedBox.square(
                  key: _semanticZoomButtonKey,
                  dimension: size,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: style.buttonBackgroundColor?.resolve(states),
                      border: Border.all(
                        color:
                            style.buttonBorderColor?.resolve(states) ??
                            const Color(0x00000000),
                        width: borderWidth,
                      ),
                    ),
                    child: Center(
                      child: CustomPaint(
                        size: Size.square(iconSize),
                        painter: _MinusPainter(
                          color:
                              style.buttonForegroundColor?.resolve(states) ??
                              const Color(0x00000000),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Alignment _alignmentFor(Size size, Offset? focalPoint) {
    if (focalPoint == null ||
        !size.width.isFinite ||
        !size.height.isFinite ||
        size.width == 0 ||
        size.height == 0) {
      return Alignment.center;
    }
    return Alignment(
      (focalPoint.dx / size.width).clamp(0, 1) * 2 - 1,
      (focalPoint.dy / size.height).clamp(0, 1) * 2 - 1,
    );
  }

  MetroSemanticZoomStyle _defaultStyle(MetroThemeData theme) {
    final colors = theme.colors;
    final foreground = colors.foreground;
    final inverse = colors.background;
    return MetroSemanticZoomStyle(
      buttonBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) return foreground;
        if (colors.isHighContrast && states.contains(WidgetState.hovered)) {
          return colors.accent;
        }
        if (states.contains(WidgetState.hovered)) {
          return const Color(0xFFD8D8D8);
        }
        return const Color(0x54D8D8D8);
      }),
      buttonForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) return inverse;
        if (colors.isHighContrast && states.contains(WidgetState.hovered)) {
          return colors.onAccent;
        }
        return foreground;
      }),
      buttonBorderColor: WidgetStatePropertyAll(
        colors.isHighContrast ? foreground : const Color(0x00000000),
      ),
      buttonBorderWidth: WidgetStatePropertyAll(colors.isHighContrast ? 2 : 0),
      buttonSize: 25,
      buttonIconSize: 14.667,
      buttonEndInset: 4,
      buttonBottomInset: 21,
      buttonShowDuration: const Duration(seconds: 3),
      buttonMouseCursor: SystemMouseCursors.click,
    );
  }

  @override
  void dispose() {
    _buttonTimer?.cancel();
    _controller.dispose();
    _internalFocusNode.dispose();
    _zoomedInFocusScope.dispose();
    _zoomedOutFocusScope.dispose();
    super.dispose();
  }
}

class _MinusPainter extends CustomPainter {
  const _MinusPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.square;
    canvas.drawLine(
      Offset(size.width * 0.2, size.height / 2),
      Offset(size.width * 0.8, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(_MinusPainter oldDelegate) => oldDelegate.color != color;
}

bool _reduceMotion(BuildContext context) {
  final media = MediaQuery.maybeOf(context);
  return media?.disableAnimations == true ||
      media?.accessibleNavigation == true;
}
