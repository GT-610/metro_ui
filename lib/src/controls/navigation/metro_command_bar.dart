import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/metro_accessibility.dart';
import '../../foundation/metro_interactive.dart';
import '../../theme/metro_color_scheme.dart';
import '../../theme/metro_spacing.dart';
import '../../theme/metro_theme.dart';
import '../../theme/metro_theme_data.dart';
import 'metro_command_bar_style.dart';

export 'metro_command_bar_style.dart';

/// Logical alignment of commands within a [MetroCommandBar].
enum MetroCommandBarAlignment { start, end }

/// Screen edge used by a [MetroCommandBarLayer].
enum MetroCommandBarPlacement { top, bottom }

/// Places a command bar over content using the Windows 8 AppBar interaction.
///
/// The bar can be controlled through [open], or it can own its state when
/// [open] is null. A secondary click or inward edge swipe opens it by default.
/// While open, a primary click outside the bar, Escape, or an outward bar drag
/// requests dismissal. The command surface slides by its complete height using
/// the WinJS edge-UI recipe and does not take layout space away from [child].
class MetroCommandBarLayer extends StatefulWidget {
  const MetroCommandBarLayer({
    required this.child,
    required this.commandBar,
    this.open,
    this.initiallyOpen = false,
    this.placement = MetroCommandBarPlacement.bottom,
    this.dismissible = true,
    this.toggleOnSecondaryTap = true,
    this.edgeSwipeEnabled = true,
    this.edgeSwipeExtent = 20,
    this.edgeSwipeThreshold = 24,
    this.onOpenChanged,
    super.key,
  }) : assert(edgeSwipeExtent > 0),
       assert(edgeSwipeThreshold > 0);

  /// Content that remains behind the transient command surface.
  final Widget child;

  /// Usually a [MetroCommandBar], positioned at [placement].
  final Widget commandBar;

  /// Controlled visibility, or null to use [initiallyOpen] and internal state.
  final bool? open;

  /// Initial visibility when [open] is null.
  final bool initiallyOpen;

  /// Edge from which the command surface enters and exits.
  final MetroCommandBarPlacement placement;

  /// Whether outside primary clicks and Escape request dismissal.
  final bool dismissible;

  /// Whether a secondary click anywhere in the layer toggles the bar.
  final bool toggleOnSecondaryTap;

  /// Whether an inward drag from [placement] opens the command surface.
  final bool edgeSwipeEnabled;

  /// Thickness of the invisible edge gesture target while the bar is closed.
  final double edgeSwipeExtent;

  /// Inward or outward drag distance required to change visibility.
  final double edgeSwipeThreshold;

  /// Reports user-requested visibility changes.
  final ValueChanged<bool>? onOpenChanged;

  @override
  State<MetroCommandBarLayer> createState() => _MetroCommandBarLayerState();
}

class _MetroCommandBarLayerState extends State<MetroCommandBarLayer>
    with SingleTickerProviderStateMixin {
  late bool _internalOpen = widget.initiallyOpen;
  double _edgeDragDistance = 0;
  late final AnimationController _controller = AnimationController(
    vsync: this,
    value: _effectiveOpen ? 1 : 0,
  );

  bool get _effectiveOpen => widget.open ?? _internalOpen;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncMotion(commitReducedMotion: true);
  }

  @override
  void didUpdateWidget(MetroCommandBarLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncMotion();
    if (_effectiveOpen != (oldWidget.open ?? _internalOpen)) {
      _animateToEffectiveState();
    }
  }

  void _syncMotion({bool commitReducedMotion = false}) {
    final reduceMotion = metroReduceMotion(context);
    _controller.duration = reduceMotion
        ? Duration.zero
        : MetroTheme.of(context).motion.entrance;
    if (commitReducedMotion && reduceMotion) {
      _controller.value = _effectiveOpen ? 1 : 0;
    }
  }

  void _animateToEffectiveState() {
    if (_effectiveOpen) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _requestOpen(bool value) {
    if (value == _effectiveOpen) return;
    if (widget.open == null) {
      setState(() => _internalOpen = value);
      _animateToEffectiveState();
    }
    widget.onOpenChanged?.call(value);
  }

  void _toggleFromSecondaryTap() {
    if (widget.toggleOnSecondaryTap) {
      _requestOpen(!_effectiveOpen);
    }
  }

  void _dismiss() {
    if (widget.dismissible) {
      _requestOpen(false);
    }
  }

  void _startEdgeDrag(DragStartDetails details) {
    _edgeDragDistance = 0;
  }

  void _updateEdgeDrag(DragUpdateDetails details) {
    final inwardDelta = widget.placement == MetroCommandBarPlacement.bottom
        ? -details.delta.dy
        : details.delta.dy;
    _edgeDragDistance = (_edgeDragDistance + inwardDelta).clamp(
      0,
      double.infinity,
    );
  }

  void _endEdgeDrag(DragEndDetails details) {
    if (_edgeDragDistance >= widget.edgeSwipeThreshold) {
      _requestOpen(true);
    }
    _edgeDragDistance = 0;
  }

  void _startBarDrag(DragStartDetails details) {
    _edgeDragDistance = 0;
  }

  void _updateBarDrag(DragUpdateDetails details) {
    final outwardDelta = widget.placement == MetroCommandBarPlacement.bottom
        ? details.delta.dy
        : -details.delta.dy;
    _edgeDragDistance = (_edgeDragDistance + outwardDelta).clamp(
      0,
      double.infinity,
    );
  }

  void _endBarDrag(DragEndDetails details) {
    if (_edgeDragDistance >= widget.edgeSwipeThreshold) {
      _requestOpen(false);
    }
    _edgeDragDistance = 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = MetroTheme.of(context);
    final shortcuts = <ShortcutActivator, VoidCallback>{
      if (_effectiveOpen && widget.dismissible)
        const SingleActivator(LogicalKeyboardKey.escape): _dismiss,
    };
    return CallbackShortcuts(
      bindings: shortcuts,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onSecondaryTap: widget.toggleOnSecondaryTap
            ? _toggleFromSecondaryTap
            : null,
        child: Stack(
          fit: StackFit.expand,
          children: [
            widget.child,
            if (_effectiveOpen && widget.dismissible)
              Positioned.fill(
                child: ExcludeSemantics(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _dismiss,
                  ),
                ),
              ),
            if (!_effectiveOpen && widget.edgeSwipeEnabled)
              Positioned(
                left: 0,
                right: 0,
                top: widget.placement == MetroCommandBarPlacement.top
                    ? 0
                    : null,
                bottom: widget.placement == MetroCommandBarPlacement.bottom
                    ? 0
                    : null,
                height: widget.edgeSwipeExtent,
                child: ExcludeSemantics(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onVerticalDragStart: _startEdgeDrag,
                    onVerticalDragUpdate: _updateEdgeDrag,
                    onVerticalDragEnd: _endEdgeDrag,
                  ),
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              top: widget.placement == MetroCommandBarPlacement.top ? 0 : null,
              bottom: widget.placement == MetroCommandBarPlacement.bottom
                  ? 0
                  : null,
              child: AnimatedBuilder(
                animation: _controller,
                child: widget.commandBar,
                builder: (context, child) {
                  final progress = theme.motion.standardCurve.transform(
                    _controller.value,
                  );
                  final direction =
                      widget.placement == MetroCommandBarPlacement.top ? -1 : 1;
                  final dismissed = _controller.isDismissed;
                  return IgnorePointer(
                    ignoring: !_effectiveOpen,
                    child: ExcludeSemantics(
                      excluding: dismissed,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onVerticalDragStart: widget.edgeSwipeEnabled
                            ? _startBarDrag
                            : null,
                        onVerticalDragUpdate: widget.edgeSwipeEnabled
                            ? _updateBarDrag
                            : null,
                        onVerticalDragEnd: widget.edgeSwipeEnabled
                            ? _endBarDrag
                            : null,
                        child: FractionalTranslation(
                          translation: Offset(0, direction * (1 - progress)),
                          child: child,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// A high-contrast bottom bar for page-level commands.
///
/// Commands are horizontally scrollable when the available width is too
/// narrow. The default end alignment mirrors Windows 8's primary AppBar
/// command placement.
class MetroCommandBar extends StatelessWidget {
  const MetroCommandBar({
    required this.commands,
    this.leading,
    this.alignment = MetroCommandBarAlignment.end,
    this.backgroundColor,
    this.height,
    this.padding,
    this.spacing,
    this.buttonStyle,
    super.key,
  }) : assert(height == null || height > 0),
       assert(spacing == null || spacing >= 0);

  final List<Widget> commands;
  final Widget? leading;
  final MetroCommandBarAlignment alignment;
  final Color? backgroundColor;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double? spacing;
  final MetroCommandButtonStyle? buttonStyle;

  @override
  Widget build(BuildContext context) {
    final theme = MetroTheme.of(context);
    final defaults = MetroCommandBarThemeData(
      backgroundColor: theme.colors.isDark
          ? const Color(0xFF000000)
          : const Color(0xFFF0F0F0),
      height: 80,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 10),
      spacing: 0,
    );
    final widgetOverrides = MetroCommandBarThemeData(
      backgroundColor: backgroundColor,
      height: height,
      padding: padding,
      spacing: spacing,
      buttonStyle: buttonStyle,
    );
    final effectiveTheme = defaults
        .merge(theme.commandBarTheme)
        .merge(MetroCommandBarTheme.maybeOf(context))
        .merge(widgetOverrides);
    final effectiveBackground = effectiveTheme.backgroundColor!;
    final effectiveForeground = MetroColorScheme.idealForegroundFor(
      effectiveBackground,
    );
    final effectiveSpacing = effectiveTheme.spacing!;

    return _MetroCommandBarScope(
      backgroundColor: effectiveBackground,
      buttonStyle: effectiveTheme.buttonStyle,
      child: IconTheme.merge(
        data: IconThemeData(color: effectiveForeground),
        child: DefaultTextStyle.merge(
          style: theme.typography.body.copyWith(color: effectiveForeground),
          child: ColoredBox(
            color: effectiveBackground,
            child: SizedBox(
              height: effectiveTheme.height,
              child: Padding(
                padding: effectiveTheme.padding!,
                child: Row(
                  children: [
                    if (leading != null) ...[
                      leading!,
                      if (commands.isNotEmpty)
                        SizedBox(width: effectiveSpacing),
                    ],
                    if (commands.isNotEmpty)
                      Expanded(
                        child: SingleChildScrollView(
                          reverse: alignment == MetroCommandBarAlignment.end,
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: _withSpacing(commands, effectiveSpacing),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static List<Widget> _withSpacing(List<Widget> children, double spacing) {
    return <Widget>[
      for (var index = 0; index < children.length; index++) ...[
        if (index > 0) SizedBox(width: spacing),
        children[index],
      ],
    ];
  }
}

/// A Windows 8-style AppBar command with a circular glyph and a text label.
///
/// The circular outline is intentionally limited to this historical command
/// pattern; other Metro controls remain square by default.
class MetroCommandButton extends StatelessWidget {
  const MetroCommandButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.selected,
    this.style,
    this.autofocus = false,
    this.focusNode,
    this.semanticLabel,
    super.key,
  });

  final Widget icon;
  final Widget label;
  final VoidCallback? onPressed;
  final bool? selected;
  final MetroCommandButtonStyle? style;
  final bool autofocus;
  final FocusNode? focusNode;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = MetroTheme.of(context);
    final scope = _MetroCommandBarScope.maybeOf(context);
    final localTheme = MetroCommandBarTheme.maybeOf(context);
    final background =
        scope?.backgroundColor ??
        localTheme?.backgroundColor ??
        theme.commandBarTheme.backgroundColor ??
        (theme.colors.isDark
            ? const Color(0xFF000000)
            : const Color(0xFFF0F0F0));
    final themedStyle =
        scope?.buttonStyle ??
        theme.commandBarTheme.buttonStyle?.merge(localTheme?.buttonStyle) ??
        localTheme?.buttonStyle;
    final effectiveStyle = _defaultStyle(
      theme,
      background,
    ).merge(themedStyle).merge(style);

    return MetroInteractive(
      autofocus: autofocus,
      focusNode: focusNode,
      mouseCursor: effectiveStyle.mouseCursor,
      onPressed: onPressed,
      semanticLabel: semanticLabel,
      semanticToggled: selected,
      builder: (context, states) {
        final effectiveStates = <WidgetState>{
          ...states,
          if (selected == true) WidgetState.selected,
        };
        final circleColor = effectiveStyle.circleColor?.resolve(
          effectiveStates,
        );
        final foreground = effectiveStyle.foregroundColor?.resolve(
          effectiveStates,
        );
        final borderColor = effectiveStyle.borderColor?.resolve(
          effectiveStates,
        );
        final borderWidth =
            effectiveStyle.borderWidth?.resolve(effectiveStates) ?? 2;
        final labelStyle = effectiveStyle.labelStyle?.resolve(effectiveStates);
        final minimumSize = effectiveStyle.minimumSize ?? const Size(100, 80);
        final focused = states.contains(WidgetState.focused);

        final command = ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: minimumSize.width,
            minHeight: minimumSize.height,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                width: 40,
                height: 40,
                duration: Duration.zero,
                curve: theme.motion.standardCurve,
                decoration: BoxDecoration(
                  color: circleColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: borderColor ?? const Color(0x00000000),
                    width: borderWidth,
                  ),
                ),
                child: IconTheme.merge(
                  data: IconThemeData(color: foreground, size: 20),
                  child: Center(child: icon),
                ),
              ),
              const SizedBox(height: MetroSpacing.xxs),
              DefaultTextStyle(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    labelStyle?.copyWith(color: foreground) ??
                    TextStyle(color: foreground),
                textAlign: TextAlign.center,
                child: label,
              ),
            ],
          ),
        );
        return DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: focused
                  ? MetroColorScheme.idealForegroundFor(background)
                  : const Color(0x00000000),
              width: 2,
            ),
          ),
          child: command,
        );
      },
    );
  }

  static MetroCommandButtonStyle _defaultStyle(
    MetroThemeData theme,
    Color barBackground,
  ) {
    final barForeground = MetroColorScheme.idealForegroundFor(barBackground);
    return MetroCommandButtonStyle(
      circleColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return const Color(0x00000000);
        }
        if (states.contains(WidgetState.selected)) {
          if (states.contains(WidgetState.pressed)) {
            return const Color(0x00000000);
          }
          if (states.contains(WidgetState.hovered)) {
            return Color.lerp(barForeground, barBackground, 0.13);
          }
          return barForeground;
        }
        if (states.contains(WidgetState.pressed)) {
          return barForeground;
        }
        if (states.contains(WidgetState.hovered)) {
          return barForeground.withValues(alpha: 0.13);
        }
        return const Color(0x00000000);
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return barForeground.withValues(alpha: 0.4);
        }
        final selected = states.contains(WidgetState.selected);
        final pressed = states.contains(WidgetState.pressed);
        if ((selected && !pressed) || (!selected && pressed)) {
          return barBackground;
        }
        return barForeground;
      }),
      borderColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return barForeground.withValues(alpha: 0.4);
        }
        return barForeground;
      }),
      borderWidth: const WidgetStatePropertyAll(2),
      labelStyle: WidgetStatePropertyAll(
        theme.typography.caption.copyWith(color: barForeground),
      ),
      minimumSize: const Size(100, 80),
    );
  }
}

class _MetroCommandBarScope extends InheritedWidget {
  const _MetroCommandBarScope({
    required this.backgroundColor,
    required this.buttonStyle,
    required super.child,
  });

  final Color backgroundColor;
  final MetroCommandButtonStyle? buttonStyle;

  static _MetroCommandBarScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_MetroCommandBarScope>();
  }

  @override
  bool updateShouldNotify(_MetroCommandBarScope oldWidget) {
    return backgroundColor != oldWidget.backgroundColor ||
        buttonStyle != oldWidget.buttonStyle;
  }
}
