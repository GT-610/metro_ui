import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

typedef MetroInteractiveBuilder =
    Widget Function(BuildContext context, Set<WidgetState> states);

/// Shared mouse, touch, keyboard, focus, and semantics behavior.
class MetroInteractive extends StatefulWidget {
  const MetroInteractive({
    required this.builder,
    required this.onPressed,
    this.autofocus = false,
    this.focusNode,
    this.mouseCursor,
    this.onTapDown,
    this.semanticLabel,
    this.semanticButton = true,
    this.semanticChecked,
    this.semanticMixed,
    this.semanticSelected,
    this.semanticToggled,
    this.semanticMutuallyExclusive = false,
    super.key,
  });

  final MetroInteractiveBuilder builder;
  final VoidCallback? onPressed;
  final bool autofocus;
  final FocusNode? focusNode;
  final MouseCursor? mouseCursor;
  final ValueChanged<TapDownDetails>? onTapDown;
  final String? semanticLabel;
  final bool semanticButton;
  final bool? semanticChecked;
  final bool? semanticMixed;
  final bool? semanticSelected;
  final bool? semanticToggled;
  final bool semanticMutuallyExclusive;

  @override
  State<MetroInteractive> createState() => _MetroInteractiveState();
}

class _MetroInteractiveState extends State<MetroInteractive> {
  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null;

  Set<WidgetState> get _states => <WidgetState>{
    if (!_enabled) WidgetState.disabled,
    if (_enabled && _hovered) WidgetState.hovered,
    if (_enabled && _focused) WidgetState.focused,
    if (_enabled && _pressed) WidgetState.pressed,
  };

  void _updatePressed(bool value) {
    if (_pressed == value || !mounted) {
      return;
    }
    setState(() => _pressed = value);
  }

  @override
  void didUpdateWidget(MetroInteractive oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_enabled && (_hovered || _pressed)) {
      _hovered = false;
      _pressed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cursor =
        widget.mouseCursor ??
        (_enabled ? SystemMouseCursors.click : SystemMouseCursors.basic);
    final child = FocusableActionDetector(
      enabled: _enabled,
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
      mouseCursor: cursor,
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
      },
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (intent) {
            widget.onPressed?.call();
            return null;
          },
        ),
      },
      onShowFocusHighlight: (value) {
        if (_focused != value) {
          setState(() => _focused = value);
        }
      },
      onShowHoverHighlight: (value) {
        if (_hovered != value) {
          setState(() => _hovered = value);
        }
      },
      child: Builder(
        builder: (focusContext) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            onTap: widget.onPressed,
            onTapCancel: _enabled ? () => _updatePressed(false) : null,
            onTapDown: _enabled
                ? (details) {
                    Focus.of(focusContext).requestFocus();
                    _updatePressed(true);
                    widget.onTapDown?.call(details);
                  }
                : null,
            onTapUp: _enabled ? (_) => _updatePressed(false) : null,
            child: widget.semanticLabel == null
                ? widget.builder(context, _states)
                : ExcludeSemantics(child: widget.builder(context, _states)),
          );
        },
      ),
    );

    return Semantics(
      button: widget.semanticButton,
      checked: widget.semanticChecked,
      enabled: _enabled,
      inMutuallyExclusiveGroup: widget.semanticMutuallyExclusive,
      label: widget.semanticLabel,
      mixed: widget.semanticMixed,
      onTap: widget.onPressed,
      selected: widget.semanticSelected,
      toggled: widget.semanticToggled,
      child: child,
    );
  }
}
