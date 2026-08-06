import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/metro_accessibility.dart';
import '../../theme/metro_spacing.dart';
import '../../theme/metro_theme.dart';
import '../../theme/metro_theme_data.dart';
import 'metro_combo_box_style.dart';

export 'metro_combo_box_style.dart';

/// Builds the closed-field presentation for a selected combo-box item.
typedef MetroComboBoxSelectedItemBuilder<T extends Object> =
    Widget Function(BuildContext context, MetroComboBoxItem<T> item);

/// Immutable value, content, and availability metadata for a combo-box item.
@immutable
class MetroComboBoxItem<T extends Object> {
  const MetroComboBoxItem({
    required this.value,
    required this.child,
    this.enabled = true,
    this.semanticLabel,
  });

  final T value;
  final Widget child;
  final bool enabled;
  final String? semanticLabel;
}

/// A controlled, keyboard-navigable Metro drop-down selection field.
///
/// The application owns [value]. Choosing an enabled item invokes [onChanged]
/// and closes the popup. A null [onChanged], an empty item list, or a list with
/// no enabled items disables the field.
class MetroComboBox<T extends Object> extends StatefulWidget {
  const MetroComboBox({
    required this.items,
    this.value,
    this.onChanged,
    this.placeholder,
    this.disabledPlaceholder,
    this.selectedItemBuilder,
    this.icon,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.preferBelow = true,
    this.semanticLabel,
    super.key,
  });

  final List<MetroComboBoxItem<T>> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final Widget? placeholder;
  final Widget? disabledPlaceholder;
  final MetroComboBoxSelectedItemBuilder<T>? selectedItemBuilder;
  final Widget? icon;
  final MetroComboBoxStyle? style;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool preferBelow;
  final String? semanticLabel;

  @override
  State<MetroComboBox<T>> createState() => _MetroComboBoxState<T>();
}

class _MetroComboBoxState<T extends Object> extends State<MetroComboBox<T>> {
  final OverlayPortalController _overlayController = OverlayPortalController();
  final ScrollController _scrollController = ScrollController();
  FocusNode? _internalFocusNode;
  bool _hovered = false;
  bool _pressed = false;
  bool _open = false;
  int? _highlightedIndex;
  bool _closeScheduled = false;
  bool _scrollScheduled = false;

  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode!;

  bool get _enabled {
    return widget.onChanged != null && widget.items.any((item) => item.enabled);
  }

  int? get _selectedIndex {
    final value = widget.value;
    if (value == null) {
      return null;
    }
    final index = widget.items.indexWhere((item) => item.value == value);
    return index < 0 ? null : index;
  }

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) {
      _internalFocusNode = FocusNode(debugLabel: 'MetroComboBox');
    }
    _focusNode.addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(MetroComboBox<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      final oldFocusNode = oldWidget.focusNode ?? _internalFocusNode!;
      oldFocusNode.removeListener(_handleFocusChanged);
      if (widget.focusNode == null) {
        _internalFocusNode = FocusNode(debugLabel: 'MetroComboBox');
      } else if (oldWidget.focusNode == null) {
        _internalFocusNode?.dispose();
        _internalFocusNode = null;
      }
      _focusNode.addListener(_handleFocusChanged);
      if (_open && !_focusNode.hasFocus) {
        _scheduleMenuClose();
      }
    }

    if (_open && !_enabled) {
      _scheduleMenuClose();
      return;
    }

    if (_open &&
        (oldWidget.value != widget.value || oldWidget.items != widget.items)) {
      final highlighted = _highlightedIndex;
      if (highlighted == null ||
          highlighted >= widget.items.length ||
          !widget.items[highlighted].enabled) {
        _highlightedIndex = _selectedIndex ?? _firstEnabledIndex();
      }
      _scheduleHighlightedScroll();
    }
  }

  void _handleFocusChanged() {
    if (!_focusNode.hasFocus && _open) {
      _closeMenu(restoreFocus: false);
    } else if (mounted) {
      setState(() {});
    }
  }

  bool _debugValidateItems() {
    final values = <T>{};
    for (final item in widget.items) {
      if (!values.add(item.value)) {
        throw FlutterError(
          'MetroComboBox items must have unique values. '
          'The value ${item.value} occurs more than once.',
        );
      }
    }
    if (widget.value != null && !values.contains(widget.value)) {
      throw FlutterError(
        'MetroComboBox.value must match exactly one item. '
        'No item has the value ${widget.value}.',
      );
    }
    return true;
  }

  int? _firstEnabledIndex() {
    final index = widget.items.indexWhere((item) => item.enabled);
    return index < 0 ? null : index;
  }

  int? _lastEnabledIndex() {
    final index = widget.items.lastIndexWhere((item) => item.enabled);
    return index < 0 ? null : index;
  }

  int? _nextEnabledIndex(int? current, int delta) {
    if (widget.items.isEmpty) {
      return null;
    }
    if (current == null) {
      return delta > 0 ? _firstEnabledIndex() : _lastEnabledIndex();
    }
    final fallback = widget.items[current].enabled
        ? current
        : delta > 0
        ? _firstEnabledIndex()
        : _lastEnabledIndex();
    var index = current + delta;
    while (index >= 0 && index < widget.items.length) {
      if (widget.items[index].enabled) {
        return index;
      }
      index += delta;
    }
    return fallback;
  }

  void _openMenu({int movement = 0, bool toStart = false, bool toEnd = false}) {
    if (!_enabled || _open) {
      return;
    }
    _focusNode.requestFocus();
    var highlighted = _selectedIndex;
    if (toStart) {
      highlighted = _firstEnabledIndex();
    } else if (toEnd) {
      highlighted = _lastEnabledIndex();
    } else if (movement != 0) {
      highlighted = _nextEnabledIndex(highlighted, movement);
    } else if (highlighted == null || !widget.items[highlighted].enabled) {
      highlighted = _firstEnabledIndex();
    }
    setState(() {
      _open = true;
      _highlightedIndex = highlighted;
      _pressed = false;
    });
    _overlayController.show();
    _scheduleHighlightedScroll();
  }

  void _closeMenu({bool restoreFocus = true}) {
    if (!_open) {
      return;
    }
    _overlayController.hide();
    if (mounted) {
      setState(() {
        _open = false;
        _pressed = false;
      });
    }
    if (restoreFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _enabled) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  void _toggleMenu() {
    if (_open) {
      _closeMenu();
    } else {
      _openMenu();
    }
  }

  void _moveHighlight(int delta) {
    if (!_open) {
      _openMenu(movement: delta);
      return;
    }
    final next = _nextEnabledIndex(_highlightedIndex, delta);
    if (next == _highlightedIndex) {
      return;
    }
    setState(() => _highlightedIndex = next);
    _scheduleHighlightedScroll();
  }

  void _moveToBoundary({required bool end}) {
    if (!_open) {
      _openMenu(toStart: !end, toEnd: end);
      return;
    }
    final next = end ? _lastEnabledIndex() : _firstEnabledIndex();
    if (next == _highlightedIndex) {
      return;
    }
    setState(() => _highlightedIndex = next);
    _scheduleHighlightedScroll();
  }

  void _scheduleMenuClose() {
    if (_closeScheduled) {
      return;
    }
    _closeScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _closeScheduled = false;
      if (mounted) {
        _closeMenu(restoreFocus: false);
      }
    });
  }

  void _scheduleHighlightedScroll() {
    if (_scrollScheduled) {
      return;
    }
    _scrollScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollScheduled = false;
      if (mounted) {
        _scrollHighlightedIntoView();
      }
    });
  }

  void _activate() {
    if (!_open) {
      _openMenu();
      return;
    }
    final index = _highlightedIndex;
    if (index != null) {
      _selectIndex(index);
    }
  }

  void _selectIndex(int index) {
    if (!_enabled || index < 0 || index >= widget.items.length) {
      return;
    }
    final item = widget.items[index];
    if (!item.enabled) {
      return;
    }
    final onChanged = widget.onChanged;
    _closeMenu();
    onChanged?.call(item.value);
  }

  void _scrollHighlightedIntoView() {
    final index = _highlightedIndex;
    if (!_open || index == null || !_scrollController.hasClients) {
      return;
    }
    final style = _resolveStyle(context);
    final itemHeight = _effectiveItemHeight(context, style);
    final position = _scrollController.position;
    final itemTop = index * itemHeight;
    final itemBottom = itemTop + itemHeight;
    var target = position.pixels;
    if (itemTop < position.pixels) {
      target = itemTop;
    } else if (itemBottom > position.pixels + position.viewportDimension) {
      target = itemBottom - position.viewportDimension;
    }
    target = target.clamp(0.0, position.maxScrollExtent).toDouble();
    if (target != position.pixels) {
      _scrollController.jumpTo(target);
    }
  }

  MetroComboBoxStyle _resolveStyle(BuildContext context) {
    final theme = MetroTheme.of(context);
    return _defaultStyle(theme)
        .merge(theme.comboBoxTheme.style)
        .merge(MetroComboBoxTheme.maybeOf(context)?.style)
        .merge(widget.style);
  }

  @override
  Widget build(BuildContext context) {
    assert(_debugValidateItems());
    final theme = MetroTheme.of(context);
    final style = _resolveStyle(context);
    final states = <WidgetState>{
      if (!_enabled) WidgetState.disabled,
      if (_enabled && _hovered) WidgetState.hovered,
      if (_enabled && _focusNode.hasFocus) WidgetState.focused,
      if (_enabled && _pressed) WidgetState.pressed,
      if (_enabled && _open) WidgetState.selected,
    };
    final selectedIndex = _selectedIndex;
    final selectedItem = selectedIndex == null
        ? null
        : widget.items[selectedIndex];
    final background = style.backgroundColor!.resolve(states);
    final foreground = style.foregroundColor!.resolve(states);
    final placeholderColor = style.placeholderColor!.resolve(states);
    final borderColor = style.borderColor!.resolve(states);
    final borderWidth = style.borderWidth!.resolve(states)!;
    final iconColor = style.iconColor!.resolve(states);
    final textStyle = style.textStyle!
        .resolve(states)!
        .copyWith(color: foreground);
    final reduceMotion = metroReduceMotion(context);

    Widget selectedChild;
    if (selectedItem != null) {
      selectedChild =
          widget.selectedItemBuilder?.call(context, selectedItem) ??
          selectedItem.child;
    } else {
      selectedChild = !_enabled && widget.disabledPlaceholder != null
          ? widget.disabledPlaceholder!
          : widget.placeholder ?? const SizedBox.shrink();
      selectedChild = DefaultTextStyle.merge(
        style: textStyle.copyWith(color: placeholderColor),
        child: selectedChild,
      );
    }

    final field = LayoutBuilder(
      builder: (context, constraints) {
        final boundedWidth = constraints.hasBoundedWidth;
        final selected = DefaultTextStyle.merge(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textStyle,
          child: selectedChild,
        );
        return ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: math.min(style.minimumWidth!, constraints.maxWidth),
            minHeight: style.minimumHeight!,
          ),
          child: AnimatedContainer(
            duration: reduceMotion ? Duration.zero : theme.motion.fast,
            curve: theme.motion.standardCurve,
            padding: style.padding,
            decoration: BoxDecoration(
              color: background,
              border: Border.all(
                color: borderColor ?? const Color(0x00000000),
                width: borderWidth,
              ),
            ),
            child: Row(
              mainAxisSize: boundedWidth ? MainAxisSize.max : MainAxisSize.min,
              children: [
                if (boundedWidth)
                  Expanded(child: selected)
                else
                  Flexible(child: selected),
                const SizedBox(width: MetroSpacing.xs),
                IconTheme.merge(
                  data: IconThemeData(color: iconColor, size: style.iconSize),
                  child: AnimatedRotation(
                    duration: reduceMotion ? Duration.zero : theme.motion.fast,
                    curve: theme.motion.standardCurve,
                    turns: _open ? 0.5 : 0,
                    child:
                        widget.icon ??
                        SizedBox.square(
                          dimension: style.iconSize,
                          child: CustomPaint(
                            painter: _MetroComboBoxChevronPainter(
                              color: iconColor ?? const Color(0x00000000),
                            ),
                          ),
                        ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    final shortcuts = <ShortcutActivator, Intent>{
      const SingleActivator(LogicalKeyboardKey.enter): const ActivateIntent(),
      const SingleActivator(LogicalKeyboardKey.space): const ActivateIntent(),
      const SingleActivator(LogicalKeyboardKey.arrowDown):
          const _NextComboBoxItemIntent(),
      const SingleActivator(LogicalKeyboardKey.arrowDown, alt: true):
          const _ToggleComboBoxIntent(),
      const SingleActivator(LogicalKeyboardKey.arrowUp):
          const _PreviousComboBoxItemIntent(),
      const SingleActivator(LogicalKeyboardKey.arrowUp, alt: true):
          const _ToggleComboBoxIntent(),
      const SingleActivator(LogicalKeyboardKey.f4):
          const _ToggleComboBoxIntent(),
      const SingleActivator(LogicalKeyboardKey.home):
          const _FirstComboBoxItemIntent(),
      const SingleActivator(LogicalKeyboardKey.end):
          const _LastComboBoxItemIntent(),
      if (_open)
        const SingleActivator(LogicalKeyboardKey.escape): const DismissIntent(),
    };

    Widget interactive = FocusableActionDetector(
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (intent) {
            _activate();
            return null;
          },
        ),
        _NextComboBoxItemIntent: CallbackAction<_NextComboBoxItemIntent>(
          onInvoke: (intent) {
            _moveHighlight(1);
            return null;
          },
        ),
        _PreviousComboBoxItemIntent:
            CallbackAction<_PreviousComboBoxItemIntent>(
              onInvoke: (intent) {
                _moveHighlight(-1);
                return null;
              },
            ),
        _FirstComboBoxItemIntent: CallbackAction<_FirstComboBoxItemIntent>(
          onInvoke: (intent) {
            _moveToBoundary(end: false);
            return null;
          },
        ),
        _LastComboBoxItemIntent: CallbackAction<_LastComboBoxItemIntent>(
          onInvoke: (intent) {
            _moveToBoundary(end: true);
            return null;
          },
        ),
        _ToggleComboBoxIntent: CallbackAction<_ToggleComboBoxIntent>(
          onInvoke: (intent) {
            _toggleMenu();
            return null;
          },
        ),
        DismissIntent: CallbackAction<DismissIntent>(
          onInvoke: (intent) {
            _closeMenu();
            return null;
          },
        ),
      },
      autofocus: widget.autofocus,
      enabled: _enabled,
      focusNode: _focusNode,
      mouseCursor: _enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onShowHoverHighlight: (value) {
        if (_hovered != value) {
          setState(() => _hovered = value);
        }
      },
      shortcuts: shortcuts,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: _enabled ? _toggleMenu : null,
        onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
        onTapDown: _enabled
            ? (_) {
                _focusNode.requestFocus();
                setState(() => _pressed = true);
              }
            : null,
        onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
        child: field,
      ),
    );
    interactive = Semantics(
      button: true,
      enabled: _enabled,
      excludeSemantics: selectedItem?.semanticLabel != null,
      expanded: _open,
      label: widget.semanticLabel,
      onTap: _enabled ? _toggleMenu : null,
      value: selectedItem?.semanticLabel,
      child: interactive,
    );

    return OverlayPortal.overlayChildLayoutBuilder(
      controller: _overlayController,
      overlayChildBuilder: (context, info) {
        return _buildOverlay(context, info, style);
      },
      child: interactive,
    );
  }

  Widget _buildOverlay(
    BuildContext context,
    OverlayChildLayoutInfo info,
    MetroComboBoxStyle style,
  ) {
    final targetRect = MatrixUtils.transformRect(
      info.childPaintTransform,
      Offset.zero & info.childSize,
    );
    final borderWidth = style.menuBorderWidth!;
    final itemHeight = _effectiveItemHeight(context, style);
    final desiredHeight = math.min(
      style.menuMaxHeight!,
      (widget.items.length * itemHeight) + (borderWidth * 2),
    );
    final opensAbove = _shouldOpenAbove(
      overlayHeight: info.overlaySize.height,
      targetRect: targetRect,
      desiredHeight: desiredHeight,
      gap: style.menuGap!,
      preferBelow: widget.preferBelow,
    );
    final theme = MetroTheme.of(context);
    final reduceMotion = metroReduceMotion(context);
    final selectedIndex = _selectedIndex;

    return SizedBox.fromSize(
      size: info.overlaySize,
      child: Stack(
        children: [
          Positioned.fill(
            child: ExcludeSemantics(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _closeMenu,
              ),
            ),
          ),
          CustomSingleChildLayout(
            delegate: _MetroComboBoxMenuLayoutDelegate(
              gap: style.menuGap!,
              maxHeight: style.menuMaxHeight!,
              menuWidth: style.menuWidth,
              opensAbove: opensAbove,
              targetRect: targetRect,
              textDirection: Directionality.of(context),
            ),
            child: TweenAnimationBuilder<double>(
              duration: reduceMotion ? Duration.zero : theme.motion.entrance,
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, progress, child) {
                final durationMicros = theme.motion.entrance.inMicroseconds;
                final fadeDelay = durationMicros == 0
                    ? 0.0
                    : theme.motion.popupFade.inMicroseconds / durationMicros;
                final fadeLength = durationMicros == 0
                    ? 1.0
                    : theme.motion.popupFade.inMicroseconds / durationMicros;
                final movementProgress = theme.motion.standardCurve.transform(
                  progress,
                );
                final opacity = fadeLength <= 0
                    ? 1.0
                    : ((progress - fadeDelay) / fadeLength).clamp(0.0, 1.0);
                return Opacity(
                  opacity: opacity,
                  child: Transform.translate(
                    offset: Offset(0, 50 * (1 - movementProgress)),
                    child: child,
                  ),
                );
              },
              child: Semantics(
                container: true,
                explicitChildNodes: true,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: style.menuBackgroundColor,
                    border: Border.all(
                      color: style.menuBorderColor ?? const Color(0x00000000),
                      width: borderWidth,
                    ),
                  ),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: widget.items.length,
                    itemExtent: itemHeight,
                    padding: EdgeInsets.zero,
                    primary: false,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final item = widget.items[index];
                      return _MetroComboBoxMenuItem<T>(
                        item: item,
                        selected: index == selectedIndex,
                        highlighted: index == _highlightedIndex,
                        style: style,
                        motionDuration: reduceMotion
                            ? Duration.zero
                            : theme.motion.fast,
                        motionCurve: theme.motion.standardCurve,
                        onHighlighted: item.enabled
                            ? () {
                                if (_highlightedIndex != index) {
                                  setState(() => _highlightedIndex = index);
                                }
                              }
                            : null,
                        onSelected: item.enabled
                            ? () => _selectIndex(index)
                            : null,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static MetroComboBoxStyle _defaultStyle(MetroThemeData theme) {
    final colors = theme.colors;
    return MetroComboBoxStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.disabled)
            ? colors.disabledBackground
            : colors.background;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.disabled)
            ? colors.disabledForeground
            : colors.foreground;
      }),
      placeholderColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.disabled)
            ? colors.disabledForeground
            : colors.mutedForeground;
      }),
      borderColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.focused) ||
            states.contains(WidgetState.selected)) {
          return colors.accent;
        }
        if (states.contains(WidgetState.hovered)) {
          return colors.foreground;
        }
        return colors.border;
      }),
      borderWidth: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.focused) ||
                states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.selected)
            ? 2
            : 1;
      }),
      iconColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.disabled)
            ? colors.disabledForeground
            : colors.foreground;
      }),
      textStyle: WidgetStatePropertyAll(theme.typography.body),
      padding: const EdgeInsetsDirectional.fromSTEB(
        MetroSpacing.sm,
        MetroSpacing.xs,
        MetroSpacing.xs,
        MetroSpacing.xs,
      ),
      minimumWidth: 120,
      minimumHeight: 44,
      iconSize: 12,
      menuBackgroundColor: colors.background,
      menuBorderColor: colors.border,
      menuBorderWidth: colors.isHighContrast ? 2 : 1,
      menuMaxHeight: 320,
      menuGap: 2,
      itemBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return const Color(0x00000000);
        }
        if (states.contains(WidgetState.pressed)) {
          return colors.accentPressed;
        }
        if (states.contains(WidgetState.selected)) {
          return states.contains(WidgetState.hovered) ||
                  states.contains(WidgetState.focused)
              ? colors.accentHover
              : colors.accent;
        }
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.focused)) {
          return colors.surfaceVariant;
        }
        return const Color(0x00000000);
      }),
      itemForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.disabledForeground;
        }
        if (states.contains(WidgetState.selected) ||
            states.contains(WidgetState.pressed)) {
          return colors.onAccent;
        }
        return colors.foreground;
      }),
      itemTextStyle: WidgetStatePropertyAll(theme.typography.body),
      itemPadding: const EdgeInsets.symmetric(horizontal: MetroSpacing.sm),
      itemHeight: 40,
    );
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChanged);
    _internalFocusNode?.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class _MetroComboBoxMenuItem<T extends Object> extends StatefulWidget {
  const _MetroComboBoxMenuItem({
    required this.item,
    required this.selected,
    required this.highlighted,
    required this.style,
    required this.motionDuration,
    required this.motionCurve,
    required this.onHighlighted,
    required this.onSelected,
  });

  final MetroComboBoxItem<T> item;
  final bool selected;
  final bool highlighted;
  final MetroComboBoxStyle style;
  final Duration motionDuration;
  final Curve motionCurve;
  final VoidCallback? onHighlighted;
  final VoidCallback? onSelected;

  @override
  State<_MetroComboBoxMenuItem<T>> createState() =>
      _MetroComboBoxMenuItemState<T>();
}

class _MetroComboBoxMenuItemState<T extends Object>
    extends State<_MetroComboBoxMenuItem<T>> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onSelected != null;
    final states = <WidgetState>{
      if (!enabled) WidgetState.disabled,
      if (widget.selected) WidgetState.selected,
      if (widget.highlighted) WidgetState.focused,
      if (enabled && _hovered) WidgetState.hovered,
      if (enabled && _pressed) WidgetState.pressed,
    };
    final background = widget.style.itemBackgroundColor!.resolve(states);
    final foreground = widget.style.itemForegroundColor!.resolve(states);
    final textStyle = widget.style.itemTextStyle!
        .resolve(states)!
        .copyWith(color: foreground);

    Widget child = AnimatedContainer(
      duration: widget.motionDuration,
      curve: widget.motionCurve,
      color: background,
      padding: widget.style.itemPadding,
      alignment: AlignmentDirectional.centerStart,
      child: DefaultTextStyle.merge(
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textStyle,
        child: KeyedSubtree(
          key: ValueKey<T>(widget.item.value),
          child: widget.item.child,
        ),
      ),
    );
    child = MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: enabled
          ? (_) {
              setState(() => _hovered = true);
              widget.onHighlighted?.call();
            }
          : null,
      onExit: enabled ? (_) => setState(() => _hovered = false) : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: widget.onSelected,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        child: child,
      ),
    );
    return Semantics(
      button: true,
      enabled: enabled,
      excludeSemantics: widget.item.semanticLabel != null,
      label: widget.item.semanticLabel,
      onTap: widget.onSelected,
      selected: widget.selected,
      child: child,
    );
  }
}

class _MetroComboBoxMenuLayoutDelegate extends SingleChildLayoutDelegate {
  const _MetroComboBoxMenuLayoutDelegate({
    required this.targetRect,
    required this.opensAbove,
    required this.gap,
    required this.maxHeight,
    required this.menuWidth,
    required this.textDirection,
  });

  final Rect targetRect;
  final bool opensAbove;
  final double gap;
  final double maxHeight;
  final double? menuWidth;
  final TextDirection textDirection;

  static const double _screenMargin = MetroSpacing.xs;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final availableHeight = opensAbove
        ? targetRect.top - gap - _screenMargin
        : constraints.maxHeight - targetRect.bottom - gap - _screenMargin;
    final availableWidth = math.max(
      0.0,
      constraints.maxWidth - (_screenMargin * 2),
    );
    final width = (menuWidth ?? targetRect.width)
        .clamp(0.0, availableWidth)
        .toDouble();
    return BoxConstraints(
      minWidth: width,
      maxWidth: width,
      maxHeight: math.min(maxHeight, math.max(0.0, availableHeight)),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final desiredX = textDirection == TextDirection.ltr
        ? targetRect.left
        : targetRect.right - childSize.width;
    final maxX = math.max(
      _screenMargin,
      size.width - childSize.width - _screenMargin,
    );
    final x = desiredX.clamp(_screenMargin, maxX).toDouble();
    final desiredY = opensAbove
        ? targetRect.top - gap - childSize.height
        : targetRect.bottom + gap;
    final maxY = math.max(
      _screenMargin,
      size.height - childSize.height - _screenMargin,
    );
    final y = desiredY.clamp(_screenMargin, maxY).toDouble();
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_MetroComboBoxMenuLayoutDelegate oldDelegate) {
    return targetRect != oldDelegate.targetRect ||
        opensAbove != oldDelegate.opensAbove ||
        gap != oldDelegate.gap ||
        maxHeight != oldDelegate.maxHeight ||
        menuWidth != oldDelegate.menuWidth ||
        textDirection != oldDelegate.textDirection;
  }
}

class _MetroComboBoxChevronPainter extends CustomPainter {
  const _MetroComboBoxChevronPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.square
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final top = size.height * 0.35;
    final bottom = size.height * 0.65;
    final path = Path()
      ..moveTo(size.width * 0.2, top)
      ..lineTo(size.width * 0.5, bottom)
      ..lineTo(size.width * 0.8, top);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_MetroComboBoxChevronPainter oldDelegate) {
    return color != oldDelegate.color;
  }
}

bool _shouldOpenAbove({
  required double overlayHeight,
  required Rect targetRect,
  required double desiredHeight,
  required double gap,
  required bool preferBelow,
}) {
  const margin = MetroSpacing.xs;
  final below = math.max(0.0, overlayHeight - targetRect.bottom - gap - margin);
  final above = math.max(0.0, targetRect.top - gap - margin);
  if (preferBelow) {
    return below < desiredHeight && above > below;
  }
  return !(above >= desiredHeight || above >= below);
}

class _NextComboBoxItemIntent extends Intent {
  const _NextComboBoxItemIntent();
}

class _PreviousComboBoxItemIntent extends Intent {
  const _PreviousComboBoxItemIntent();
}

class _FirstComboBoxItemIntent extends Intent {
  const _FirstComboBoxItemIntent();
}

class _LastComboBoxItemIntent extends Intent {
  const _LastComboBoxItemIntent();
}

class _ToggleComboBoxIntent extends Intent {
  const _ToggleComboBoxIntent();
}

double _effectiveItemHeight(BuildContext context, MetroComboBoxStyle style) {
  const referenceFontSize = 14.0;
  final scaler =
      MediaQuery.maybeOf(context)?.textScaler ?? TextScaler.noScaling;
  final scale = scaler.scale(referenceFontSize) / referenceFontSize;
  return style.itemHeight! * math.max(1.0, scale);
}
