import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../foundation/metro_accessibility.dart';
import '../../theme/metro_theme.dart';
import 'metro_tile.dart';

/// Face-change recipe used by a [MetroLiveTile].
enum MetroLiveTileTransition { slideUp, slideDown, fade, none }

/// One notification-like content frame shown by a [MetroLiveTile].
@immutable
class MetroLiveTileFrame {
  const MetroLiveTileFrame({
    required this.child,
    this.id,
    this.semanticLabel,
    this.displayDuration,
  });

  /// Stable identity used to retain the current frame when the list changes.
  final Object? id;
  final Widget child;
  final String? semanticLabel;

  /// Overrides the tile's default interval while this frame is visible.
  final Duration? displayDuration;
}

/// A Windows 8-inspired tile that cycles through notification content.
class MetroLiveTile extends StatefulWidget {
  const MetroLiveTile({
    required this.frames,
    required this.onPressed,
    this.size = MetroTileSize.square,
    this.title,
    this.subtitle,
    this.backgroundColor,
    this.foregroundColor,
    this.style,
    this.width,
    this.height,
    this.enablePressTilt = true,
    this.active = true,
    this.initialIndex = 0,
    this.interval = const Duration(seconds: 5),
    this.transition = MetroLiveTileTransition.slideUp,
    this.transitionDuration,
    this.onFrameChanged,
    this.autofocus = false,
    this.focusNode,
    this.semanticLabel,
    super.key,
  }) : assert(initialIndex >= 0);

  /// The non-empty sequence of content frames shown by this tile.
  final List<MetroLiveTileFrame> frames;
  final VoidCallback? onPressed;
  final MetroTileSize size;
  final String? title;
  final String? subtitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final MetroTileStyle? style;
  final double? width;
  final double? height;
  final bool enablePressTilt;

  /// Whether automatic frame advancement is enabled.
  final bool active;
  final int initialIndex;
  final Duration interval;
  final MetroLiveTileTransition transition;
  final Duration? transitionDuration;
  final ValueChanged<int>? onFrameChanged;
  final bool autofocus;
  final FocusNode? focusNode;

  /// Overrides both the persistent title and frame-specific semantic labels.
  final String? semanticLabel;

  @override
  State<MetroLiveTile> createState() => _MetroLiveTileState();
}

class _MetroLiveTileState extends State<MetroLiveTile> {
  Timer? _timer;
  late int _index = widget.frames.isEmpty
      ? 0
      : widget.initialIndex % widget.frames.length;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncTimer();
  }

  @override
  void didUpdateWidget(MetroLiveTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    _retainCurrentFrame(oldWidget.frames);
    _syncTimer();
  }

  void _retainCurrentFrame(List<MetroLiveTileFrame> oldFrames) {
    if (widget.frames.isEmpty) {
      _index = 0;
      return;
    }
    if (oldFrames.isNotEmpty && _index < oldFrames.length) {
      final currentId = oldFrames[_index].id;
      if (currentId != null) {
        final retainedIndex = widget.frames.indexWhere(
          (frame) => frame.id == currentId,
        );
        if (retainedIndex != -1) {
          _index = retainedIndex;
          return;
        }
      }
    }
    _index %= widget.frames.length;
  }

  void _syncTimer() {
    _timer?.cancel();
    _timer = null;
    if (widget.frames.length < 2 ||
        !widget.active ||
        !metroTickerModeEnabled(context) ||
        metroReduceMotion(context)) {
      return;
    }
    final duration = widget.frames[_index].displayDuration ?? widget.interval;
    assert(duration > Duration.zero, 'Live tile durations must be positive.');
    if (duration <= Duration.zero) {
      return;
    }
    _timer = Timer(duration, _advance);
  }

  void _advance() {
    if (!mounted || widget.frames.length < 2) {
      return;
    }
    setState(() => _index = (_index + 1) % widget.frames.length);
    widget.onFrameChanged?.call(_index);
    _syncTimer();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.frames.isEmpty) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('MetroLiveTile requires at least one frame.'),
        ErrorDescription(
          'The frames list was empty, so the tile has no content to display.',
        ),
      ]);
    }

    final theme = MetroTheme.of(context);
    final frame = widget.frames[_index];
    final frameKey = ValueKey<(String, Object)>(
      frame.id == null ? ('index', _index) : ('id', frame.id!),
    );
    final reduceMotion = metroReduceMotion(context);
    final duration =
        reduceMotion || widget.transition == MetroLiveTileTransition.none
        ? Duration.zero
        : widget.transitionDuration ?? theme.motion.entrance;

    return MetroTile(
      autofocus: widget.autofocus,
      backgroundColor: widget.backgroundColor,
      enablePressTilt: widget.enablePressTilt,
      focusNode: widget.focusNode,
      foregroundColor: widget.foregroundColor,
      height: widget.height,
      onPressed: widget.onPressed,
      semanticLabel:
          widget.semanticLabel ?? frame.semanticLabel ?? widget.title,
      size: widget.size,
      style: widget.style,
      subtitle: widget.subtitle,
      title: widget.title,
      width: widget.width,
      child: ClipRect(
        child: AnimatedSwitcher(
          duration: duration,
          reverseDuration: duration,
          switchInCurve: theme.motion.standardCurve,
          switchOutCurve: theme.motion.standardCurve,
          transitionBuilder: (child, animation) => _buildTransition(
            animation: animation,
            child: child,
            incoming: child.key == frameKey,
          ),
          child: KeyedSubtree(key: frameKey, child: frame.child),
        ),
      ),
    );
  }

  Widget _buildTransition({
    required Animation<double> animation,
    required Widget child,
    required bool incoming,
  }) {
    final fade = FadeTransition(opacity: animation, child: child);
    return switch (widget.transition) {
      MetroLiveTileTransition.slideUp => SlideTransition(
        position: Tween<Offset>(
          begin: incoming ? const Offset(0, 1) : const Offset(0, -1),
          end: Offset.zero,
        ).animate(animation),
        child: fade,
      ),
      MetroLiveTileTransition.slideDown => SlideTransition(
        position: Tween<Offset>(
          begin: incoming ? const Offset(0, -1) : const Offset(0, 1),
          end: Offset.zero,
        ).animate(animation),
        child: fade,
      ),
      MetroLiveTileTransition.fade => fade,
      MetroLiveTileTransition.none => child,
    };
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
