import 'package:flutter/widgets.dart';

/// Groups controls under a persistent focus scope with Metro-friendly edge
/// behavior.
///
/// The default configuration is intended for desktop layouts: Tab traversal
/// can continue into the parent scope, while directional traversal stops at
/// the local edge. Use [MetroFocusTraversalGroup.spatial] for a contained
/// keyboard, gamepad, or TV-style surface that loops at every edge.
class MetroFocusTraversalGroup extends StatefulWidget {
  const MetroFocusTraversalGroup({
    required this.child,
    this.policy,
    this.traversalEdgeBehavior = TraversalEdgeBehavior.parentScope,
    this.directionalTraversalEdgeBehavior = TraversalEdgeBehavior.stop,
    this.autofocus = false,
    this.descendantsAreFocusable = true,
    this.descendantsAreTraversable = true,
    this.onFocusChange,
    this.debugLabel,
    super.key,
  });

  /// Creates a contained spatial group whose Tab and directional traversal
  /// both wrap within the group.
  const MetroFocusTraversalGroup.spatial({
    required this.child,
    this.policy,
    this.traversalEdgeBehavior = TraversalEdgeBehavior.closedLoop,
    this.directionalTraversalEdgeBehavior = TraversalEdgeBehavior.closedLoop,
    this.autofocus = false,
    this.descendantsAreFocusable = true,
    this.descendantsAreTraversable = true,
    this.onFocusChange,
    this.debugLabel,
    super.key,
  });

  final Widget child;

  /// The traversal policy used inside the group.
  ///
  /// Defaults to Flutter's direction-aware [ReadingOrderTraversalPolicy].
  final FocusTraversalPolicy? policy;
  final TraversalEdgeBehavior traversalEdgeBehavior;
  final TraversalEdgeBehavior directionalTraversalEdgeBehavior;
  final bool autofocus;
  final bool descendantsAreFocusable;
  final bool descendantsAreTraversable;
  final ValueChanged<bool>? onFocusChange;
  final String? debugLabel;

  @override
  State<MetroFocusTraversalGroup> createState() =>
      _MetroFocusTraversalGroupState();
}

class _MetroFocusTraversalGroupState extends State<MetroFocusTraversalGroup> {
  final FocusTraversalPolicy _defaultPolicy = ReadingOrderTraversalPolicy();
  late final FocusScopeNode _scopeNode = FocusScopeNode();

  @override
  void initState() {
    super.initState();
    _syncScopeNode();
  }

  @override
  void didUpdateWidget(MetroFocusTraversalGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncScopeNode();
  }

  void _syncScopeNode() {
    _scopeNode
      ..debugLabel = widget.debugLabel
      ..descendantsAreFocusable = widget.descendantsAreFocusable
      ..descendantsAreTraversable = widget.descendantsAreTraversable
      ..traversalEdgeBehavior = widget.traversalEdgeBehavior
      ..directionalTraversalEdgeBehavior =
          widget.directionalTraversalEdgeBehavior;
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope.withExternalFocusNode(
      focusScopeNode: _scopeNode,
      autofocus: widget.autofocus,
      onFocusChange: widget.onFocusChange,
      child: FocusTraversalGroup(
        policy: widget.policy ?? _defaultPolicy,
        descendantsAreFocusable: widget.descendantsAreFocusable,
        descendantsAreTraversable: widget.descendantsAreTraversable,
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    _scopeNode.dispose();
    super.dispose();
  }
}
