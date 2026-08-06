import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/metro_interactive.dart';
import '../../localization/metro_localizations.dart';
import '../../theme/metro_spacing.dart';
import '../../theme/metro_theme.dart';
import '../../theme/metro_theme_data.dart';
import 'metro_search_box_style.dart';
import 'metro_text_field.dart';

export 'metro_search_box_style.dart';

/// Why the visible query in a [MetroSearchBox] changed.
enum MetroSearchBoxChangeReason {
  /// The user edited the text field.
  userInput,

  /// The user chose a suggestion.
  suggestionSelected,

  /// The user activated the clear button.
  cleared,
}

/// Reports a search query together with the reason it changed.
typedef MetroSearchBoxQueryChanged =
    void Function(String query, MetroSearchBoxChangeReason reason);

/// Decides whether a search suggestion matches the current query.
typedef MetroSearchBoxFilter<T extends Object> =
    bool Function(String query, MetroSearchBoxItem<T> item);

/// Immutable value, query text, content, and availability for one suggestion.
@immutable
class MetroSearchBoxItem<T extends Object> {
  const MetroSearchBoxItem({
    required this.value,
    required this.queryText,
    required this.child,
    this.enabled = true,
    this.semanticLabel,
  });

  final T value;
  final String queryText;
  final Widget child;
  final bool enabled;
  final String? semanticLabel;
}

/// A Windows 8-style search field with query submission and suggestions.
///
/// Suggestions are filtered locally by [filter]. Applications can instead
/// replace [items] from [onChanged] to provide asynchronous results. Choosing
/// a suggestion updates the effective text controller and reports
/// [MetroSearchBoxChangeReason.suggestionSelected] without implicitly
/// submitting the query.
class MetroSearchBox<T extends Object> extends StatefulWidget {
  const MetroSearchBox({
    required this.items,
    this.controller,
    this.focusNode,
    this.placeholder,
    this.prefix,
    this.onChanged,
    this.onSubmitted,
    this.onSelected,
    this.filter,
    this.noResultsBuilder,
    this.showNoResults = true,
    this.showSuggestionsOnFocus = false,
    this.minimumQueryLength = 1,
    this.clearButtonEnabled = true,
    this.allowEmptyQuery = false,
    this.preferBelow = true,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.inputFormatters,
    this.style,
    this.semanticLabel,
    this.searchButtonSemanticLabel,
    this.clearButtonSemanticLabel,
    super.key,
  }) : assert(minimumQueryLength >= 0);

  final List<MetroSearchBoxItem<T>> items;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? placeholder;
  final Widget? prefix;
  final MetroSearchBoxQueryChanged? onChanged;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<MetroSearchBoxItem<T>>? onSelected;
  final MetroSearchBoxFilter<T>? filter;
  final WidgetBuilder? noResultsBuilder;
  final bool showNoResults;
  final bool showSuggestionsOnFocus;
  final int minimumQueryLength;
  final bool clearButtonEnabled;
  final bool allowEmptyQuery;
  final bool preferBelow;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final bool autocorrect;
  final bool enableSuggestions;
  final List<TextInputFormatter>? inputFormatters;
  final MetroSearchBoxStyle? style;
  final String? semanticLabel;
  final String? searchButtonSemanticLabel;
  final String? clearButtonSemanticLabel;

  @override
  State<MetroSearchBox<T>> createState() => _MetroSearchBoxState<T>();
}

class _MetroSearchBoxState<T extends Object> extends State<MetroSearchBox<T>> {
  final OverlayPortalController _overlayController = OverlayPortalController();
  final ScrollController _scrollController = ScrollController();
  TextEditingController? _internalController;
  FocusNode? _internalFocusNode;
  int? _highlightedIndex;
  bool _open = false;

  TextEditingController get _controller =>
      widget.controller ?? _internalController!;

  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode!;

  bool get _canEdit => widget.enabled && !widget.readOnly;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = TextEditingController();
    }
    if (widget.focusNode == null) {
      _internalFocusNode = FocusNode(debugLabel: 'MetroSearchBox');
    }
    _controller.addListener(_handleControllerChanged);
    _focusNode.addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(MetroSearchBox<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      final oldController = oldWidget.controller ?? _internalController!;
      oldController.removeListener(_handleControllerChanged);
      if (widget.controller == null) {
        _internalController = TextEditingController.fromValue(
          oldWidget.controller!.value,
        );
      } else if (oldWidget.controller == null) {
        _internalController?.dispose();
        _internalController = null;
      }
      _controller.addListener(_handleControllerChanged);
      _highlightedIndex = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _syncOverlay();
        }
      });
    }
    if (oldWidget.focusNode != widget.focusNode) {
      final oldFocusNode = oldWidget.focusNode ?? _internalFocusNode!;
      oldFocusNode.removeListener(_handleFocusChanged);
      if (widget.focusNode == null) {
        _internalFocusNode = FocusNode(debugLabel: 'MetroSearchBox');
      } else if (oldWidget.focusNode == null) {
        _internalFocusNode?.dispose();
        _internalFocusNode = null;
      }
      _focusNode.addListener(_handleFocusChanged);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _syncOverlay();
        }
      });
    }

    if (oldWidget.items != widget.items ||
        oldWidget.filter != widget.filter ||
        oldWidget.minimumQueryLength != widget.minimumQueryLength ||
        oldWidget.showSuggestionsOnFocus != widget.showSuggestionsOnFocus ||
        oldWidget.showNoResults != widget.showNoResults ||
        oldWidget.enabled != widget.enabled ||
        oldWidget.readOnly != widget.readOnly) {
      _highlightedIndex = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _syncOverlay();
        }
      });
    }
  }

  bool _debugValidateItems() {
    final values = <T>{};
    for (final item in widget.items) {
      if (!values.add(item.value)) {
        throw FlutterError(
          'MetroSearchBox items must have unique values. '
          'The value ${item.value} occurs more than once.',
        );
      }
    }
    return true;
  }

  List<MetroSearchBoxItem<T>> _filteredItems() {
    final query = _controller.text;
    final filter = widget.filter;
    if (filter != null) {
      return widget.items
          .where((item) => filter(query, item))
          .toList(growable: false);
    }
    final normalizedQuery = query.toLowerCase();
    return widget.items
        .where((item) => item.queryText.toLowerCase().contains(normalizedQuery))
        .toList(growable: false);
  }

  bool _queryCanShowSuggestions() {
    final queryLength = _controller.text.trim().runes.length;
    if (queryLength == 0) {
      return widget.minimumQueryLength == 0 || widget.showSuggestionsOnFocus;
    }
    return queryLength >= widget.minimumQueryLength;
  }

  bool _shouldShowSuggestions(List<MetroSearchBoxItem<T>> items) {
    return _canEdit &&
        _focusNode.hasFocus &&
        _queryCanShowSuggestions() &&
        (items.isNotEmpty || widget.showNoResults);
  }

  void _handleControllerChanged() {
    if (!mounted) {
      return;
    }
    setState(() => _highlightedIndex = null);
    _syncOverlay();
  }

  void _handleFocusChanged() {
    if (!mounted) {
      return;
    }
    if (_focusNode.hasFocus) {
      _syncOverlay();
    } else {
      _closeSuggestions();
    }
  }

  void _syncOverlay() {
    final items = _filteredItems();
    if (_shouldShowSuggestions(items)) {
      _openSuggestions();
    } else {
      _closeSuggestions();
    }
  }

  void _openSuggestions() {
    if (_open) {
      setState(() {});
      return;
    }
    _overlayController.show();
    setState(() => _open = true);
  }

  void _closeSuggestions() {
    if (!_open) {
      return;
    }
    _overlayController.hide();
    setState(() {
      _open = false;
      _highlightedIndex = null;
    });
  }

  void _handleUserChanged(String query) {
    widget.onChanged?.call(query, MetroSearchBoxChangeReason.userInput);
  }

  void _clearQuery() {
    if (!_canEdit || _controller.text.isEmpty) {
      return;
    }
    _controller.clear();
    widget.onChanged?.call('', MetroSearchBoxChangeReason.cleared);
    _focusNode.requestFocus();
  }

  void _submitQuery() {
    final query = _controller.text;
    if (!widget.enabled ||
        widget.onSubmitted == null ||
        (!widget.allowEmptyQuery && query.trim().isEmpty)) {
      return;
    }
    _closeSuggestions();
    widget.onSubmitted!(query);
  }

  void _handleSubmitted(String query) {
    final highlighted = _highlightedIndex;
    if (_open && highlighted != null) {
      _selectIndex(highlighted);
      return;
    }
    if (!widget.enabled ||
        widget.onSubmitted == null ||
        (!widget.allowEmptyQuery && query.trim().isEmpty)) {
      return;
    }
    _closeSuggestions();
    widget.onSubmitted!(query);
  }

  int? _firstEnabledIndex(List<MetroSearchBoxItem<T>> items) {
    final index = items.indexWhere((item) => item.enabled);
    return index < 0 ? null : index;
  }

  int? _lastEnabledIndex(List<MetroSearchBoxItem<T>> items) {
    final index = items.lastIndexWhere((item) => item.enabled);
    return index < 0 ? null : index;
  }

  int? _nextEnabledIndex(
    List<MetroSearchBoxItem<T>> items,
    int? current,
    int delta,
  ) {
    if (items.isEmpty) {
      return null;
    }
    if (current == null) {
      return delta > 0 ? _firstEnabledIndex(items) : _lastEnabledIndex(items);
    }
    var index = current + delta;
    while (index >= 0 && index < items.length) {
      if (items[index].enabled) {
        return index;
      }
      index += delta;
    }
    return current;
  }

  void _moveHighlight(int delta) {
    final items = _filteredItems();
    if (!_shouldShowSuggestions(items)) {
      return;
    }
    _openSuggestions();
    _setHighlightedIndex(_nextEnabledIndex(items, _highlightedIndex, delta));
  }

  void _setHighlightedIndex(int? index) {
    if (_highlightedIndex == index) {
      return;
    }
    setState(() => _highlightedIndex = index);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scrollHighlightedIntoView();
      }
    });
  }

  void _scrollHighlightedIntoView() {
    final index = _highlightedIndex;
    if (index == null || !_scrollController.hasClients) {
      return;
    }
    final style = _resolveStyle(context);
    final itemHeight = _effectiveSearchItemHeight(context, style);
    final position = _scrollController.position;
    final itemStart = index * itemHeight;
    final itemEnd = itemStart + itemHeight;
    var target = position.pixels;
    if (itemStart < position.pixels) {
      target = itemStart;
    } else if (itemEnd > position.pixels + position.viewportDimension) {
      target = itemEnd - position.viewportDimension;
    }
    if (target != position.pixels) {
      position.jumpTo(target.clamp(0.0, position.maxScrollExtent));
    }
  }

  void _selectIndex(int index) {
    final items = _filteredItems();
    if (index < 0 || index >= items.length || !items[index].enabled) {
      return;
    }
    final item = items[index];
    _controller.value = TextEditingValue(
      text: item.queryText,
      selection: TextSelection.collapsed(offset: item.queryText.length),
    );
    widget.onChanged?.call(
      item.queryText,
      MetroSearchBoxChangeReason.suggestionSelected,
    );
    widget.onSelected?.call(item);
    _closeSuggestions();
    _focusNode.requestFocus();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (!_canEdit || (event is! KeyDownEvent && event is! KeyRepeatEvent)) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape && _open) {
      _closeSuggestions();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown) {
      _moveHighlight(1);
      return _open ? KeyEventResult.handled : KeyEventResult.ignored;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      _moveHighlight(-1);
      return _open ? KeyEventResult.handled : KeyEventResult.ignored;
    }
    if (_open && key == LogicalKeyboardKey.home) {
      _setHighlightedIndex(_firstEnabledIndex(_filteredItems()));
      return KeyEventResult.handled;
    }
    if (_open && key == LogicalKeyboardKey.end) {
      _setHighlightedIndex(_lastEnabledIndex(_filteredItems()));
      return KeyEventResult.handled;
    }
    if (_open && _highlightedIndex != null && key == LogicalKeyboardKey.enter) {
      _selectIndex(_highlightedIndex!);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  MetroSearchBoxStyle _resolveStyle(BuildContext context) {
    final theme = MetroTheme.of(context);
    return _defaultStyle(theme)
        .merge(theme.searchBoxTheme.style)
        .merge(MetroSearchBoxTheme.maybeOf(context)?.style)
        .merge(widget.style);
  }

  @override
  Widget build(BuildContext context) {
    assert(_debugValidateItems());
    final style = _resolveStyle(context);
    final localizations = MetroLocalizations.of(context);
    final query = _controller.text;
    final canSubmit =
        widget.enabled &&
        widget.onSubmitted != null &&
        (widget.allowEmptyQuery || query.trim().isNotEmpty);
    final suffix = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.clearButtonEnabled && _canEdit && query.isNotEmpty)
          _MetroSearchActionButton(
            key: const ValueKey<String>('metro-search-box-clear'),
            backgroundColor: style.clearButtonBackgroundColor!,
            foregroundColor: style.clearButtonForegroundColor!,
            extent: style.clearButtonExtent!,
            iconSize: style.iconSize!,
            icon: _MetroSearchActionIcon.clear,
            onPressed: _clearQuery,
            semanticLabel:
                widget.clearButtonSemanticLabel ??
                localizations.searchBoxClearLabel,
          ),
        _MetroSearchActionButton(
          key: const ValueKey<String>('metro-search-box-submit'),
          backgroundColor: style.searchButtonBackgroundColor!,
          foregroundColor: style.searchButtonForegroundColor!,
          extent: style.searchButtonExtent!,
          iconSize: style.iconSize!,
          icon: _MetroSearchActionIcon.search,
          onPressed: canSubmit ? _submitQuery : null,
          semanticLabel:
              widget.searchButtonSemanticLabel ??
              localizations.searchBoxSearchLabel,
        ),
      ],
    );

    Widget field = Focus(
      canRequestFocus: false,
      onKeyEvent: _handleKeyEvent,
      skipTraversal: true,
      child: MetroTextField(
        controller: _controller,
        focusNode: _focusNode,
        placeholder: widget.placeholder,
        prefix: widget.prefix,
        suffix: suffix,
        style: style.fieldStyle,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        autofocus: widget.autofocus,
        autocorrect: widget.autocorrect,
        enableSuggestions: widget.enableSuggestions,
        inputFormatters: widget.inputFormatters,
        textInputAction: TextInputAction.search,
        onChanged: _handleUserChanged,
        onSubmitted: _handleSubmitted,
        semanticLabel: widget.semanticLabel,
      ),
    );
    field = Listener(
      onPointerDown: _canEdit
          ? (_) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _syncOverlay();
                }
              });
            }
          : null,
      child: field,
    );
    return OverlayPortal.overlayChildLayoutBuilder(
      controller: _overlayController,
      overlayChildBuilder: (context, info) {
        return _buildOverlay(context, info, style);
      },
      child: field,
    );
  }

  Widget _buildOverlay(
    BuildContext context,
    OverlayChildLayoutInfo info,
    MetroSearchBoxStyle style,
  ) {
    final items = _filteredItems();
    final targetRect = MatrixUtils.transformRect(
      info.childPaintTransform,
      Offset.zero & info.childSize,
    );
    final borderWidth = style.popupBorderWidth!;
    final itemHeight = _effectiveSearchItemHeight(context, style);
    final rowCount = math.max(items.length, 1);
    final desiredHeight = math.min(
      style.popupMaxHeight!,
      (rowCount * itemHeight) + (borderWidth * 2),
    );
    final opensAbove = _shouldSearchOpenAbove(
      overlayHeight: info.overlaySize.height,
      targetRect: targetRect,
      desiredHeight: desiredHeight,
      gap: style.popupGap!,
      preferBelow: widget.preferBelow,
    );
    final theme = MetroTheme.of(context);
    final reduceMotion = _reduceMotion(context);

    Widget content;
    if (items.isEmpty) {
      content = Semantics(
        liveRegion: true,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: itemHeight),
          child: Padding(
            padding: style.noResultsPadding!,
            child: DefaultTextStyle.merge(
              style: style.noResultsTextStyle,
              child:
                  widget.noResultsBuilder?.call(context) ??
                  Text(MetroLocalizations.of(context).searchBoxNoResultsLabel),
            ),
          ),
        ),
      );
    } else {
      content = ListView.builder(
        controller: _scrollController,
        itemCount: items.length,
        itemExtent: itemHeight,
        padding: EdgeInsets.zero,
        primary: false,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final item = items[index];
          return _MetroSearchSuggestionRow<T>(
            item: item,
            highlighted: index == _highlightedIndex,
            style: style,
            motionDuration: reduceMotion ? Duration.zero : theme.motion.fast,
            motionCurve: theme.motion.standardCurve,
            onHighlighted: item.enabled
                ? () => _setHighlightedIndex(index)
                : null,
            onSelected: item.enabled ? () => _selectIndex(index) : null,
          );
        },
      );
    }

    return SizedBox.fromSize(
      size: info.overlaySize,
      child: Stack(
        children: [
          ..._buildDismissRegions(info.overlaySize, targetRect),
          CustomSingleChildLayout(
            delegate: _MetroSearchPopupLayoutDelegate(
              targetRect: targetRect,
              opensAbove: opensAbove,
              gap: style.popupGap!,
              maxHeight: style.popupMaxHeight!,
              popupWidth: style.popupWidth,
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
                    color: style.popupBackgroundColor,
                    border: Border.all(
                      color: style.popupBorderColor ?? const Color(0x00000000),
                      width: borderWidth,
                    ),
                  ),
                  child: content,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDismissRegions(Size overlaySize, Rect targetRect) {
    final target = Rect.fromLTRB(
      targetRect.left.clamp(0.0, overlaySize.width),
      targetRect.top.clamp(0.0, overlaySize.height),
      targetRect.right.clamp(0.0, overlaySize.width),
      targetRect.bottom.clamp(0.0, overlaySize.height),
    );

    Widget region({
      double? left,
      double? top,
      double? right,
      double? bottom,
      double? width,
      double? height,
    }) {
      return Positioned(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
        width: width,
        height: height,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTap: _closeSuggestions,
          child: const SizedBox.expand(),
        ),
      );
    }

    return <Widget>[
      if (target.top > 0) region(left: 0, top: 0, right: 0, height: target.top),
      if (target.bottom < overlaySize.height)
        region(left: 0, top: target.bottom, right: 0, bottom: 0),
      if (target.left > 0)
        region(
          left: 0,
          top: target.top,
          width: target.left,
          height: target.height,
        ),
      if (target.right < overlaySize.width)
        region(
          left: target.right,
          top: target.top,
          right: 0,
          height: target.height,
        ),
    ];
  }

  static MetroSearchBoxStyle _defaultStyle(MetroThemeData theme) {
    final colors = theme.colors;
    return MetroSearchBoxStyle(
      fieldStyle: const MetroTextFieldStyle(
        padding: EdgeInsetsDirectional.only(start: MetroSpacing.sm),
      ),
      searchButtonBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.disabledBackground;
        }
        if (states.contains(WidgetState.pressed)) {
          return colors.accentPressed;
        }
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.focused)) {
          return colors.accentHover;
        }
        return colors.accent;
      }),
      searchButtonForegroundColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.disabled)
            ? colors.disabledForeground
            : colors.onAccent;
      }),
      clearButtonBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return colors.border;
        }
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.focused)) {
          return colors.surfaceVariant;
        }
        return const Color(0x00000000);
      }),
      clearButtonForegroundColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.disabled)
            ? colors.disabledForeground
            : colors.foreground;
      }),
      searchButtonExtent: 44,
      clearButtonExtent: 36,
      iconSize: 16,
      popupBackgroundColor: colors.background,
      popupBorderColor: colors.border,
      popupBorderWidth: colors.isHighContrast ? 2 : 1,
      popupMaxHeight: 320,
      popupGap: 2,
      itemBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return const Color(0x00000000);
        }
        if (states.contains(WidgetState.pressed)) {
          return colors.accentPressed;
        }
        if (states.contains(WidgetState.focused) ||
            states.contains(WidgetState.hovered)) {
          return colors.accent;
        }
        return const Color(0x00000000);
      }),
      itemForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.disabledForeground;
        }
        if (states.contains(WidgetState.focused) ||
            states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.pressed)) {
          return colors.onAccent;
        }
        return colors.foreground;
      }),
      itemTextStyle: WidgetStatePropertyAll(theme.typography.body),
      itemPadding: const EdgeInsets.symmetric(horizontal: MetroSpacing.sm),
      itemHeight: 40,
      noResultsTextStyle: theme.typography.body.copyWith(
        color: colors.mutedForeground,
      ),
      noResultsPadding: const EdgeInsets.symmetric(
        horizontal: MetroSpacing.sm,
        vertical: MetroSpacing.xs,
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChanged);
    _focusNode.removeListener(_handleFocusChanged);
    _internalController?.dispose();
    _internalFocusNode?.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

enum _MetroSearchActionIcon { search, clear }

class _MetroSearchActionButton extends StatelessWidget {
  const _MetroSearchActionButton({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.extent,
    required this.iconSize,
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    super.key,
  });

  final WidgetStateProperty<Color?> backgroundColor;
  final WidgetStateProperty<Color?> foregroundColor;
  final double extent;
  final double iconSize;
  final _MetroSearchActionIcon icon;
  final VoidCallback? onPressed;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return MetroInteractive(
      onPressed: onPressed,
      semanticLabel: semanticLabel,
      builder: (context, states) {
        return AnimatedContainer(
          duration: _reduceMotion(context)
              ? Duration.zero
              : MetroTheme.of(context).motion.fast,
          width: extent,
          height: extent,
          color: backgroundColor.resolve(states),
          child: CustomPaint(
            painter: _MetroSearchActionPainter(
              color: foregroundColor.resolve(states) ?? const Color(0x00000000),
              icon: icon,
              iconSize: iconSize,
            ),
          ),
        );
      },
    );
  }
}

class _MetroSearchActionPainter extends CustomPainter {
  const _MetroSearchActionPainter({
    required this.color,
    required this.icon,
    required this.iconSize,
  });

  final Color color;
  final _MetroSearchActionIcon icon;
  final double iconSize;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.square
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;
    final center = Offset(size.width / 2, size.height / 2);
    if (icon == _MetroSearchActionIcon.clear) {
      final radius = iconSize * 0.32;
      canvas
        ..drawLine(
          Offset(center.dx - radius, center.dy - radius),
          Offset(center.dx + radius, center.dy + radius),
          paint,
        )
        ..drawLine(
          Offset(center.dx + radius, center.dy - radius),
          Offset(center.dx - radius, center.dy + radius),
          paint,
        );
      return;
    }
    final radius = iconSize * 0.32;
    final circleCenter = Offset(center.dx - 1.5, center.dy - 1.5);
    canvas
      ..drawCircle(circleCenter, radius, paint)
      ..drawLine(
        Offset(
          circleCenter.dx + (radius * 0.7),
          circleCenter.dy + (radius * 0.7),
        ),
        Offset(center.dx + (iconSize * 0.38), center.dy + (iconSize * 0.38)),
        paint,
      );
  }

  @override
  bool shouldRepaint(_MetroSearchActionPainter oldDelegate) {
    return color != oldDelegate.color ||
        icon != oldDelegate.icon ||
        iconSize != oldDelegate.iconSize;
  }
}

class _MetroSearchSuggestionRow<T extends Object> extends StatefulWidget {
  const _MetroSearchSuggestionRow({
    required this.item,
    required this.highlighted,
    required this.style,
    required this.motionDuration,
    required this.motionCurve,
    required this.onHighlighted,
    required this.onSelected,
  });

  final MetroSearchBoxItem<T> item;
  final bool highlighted;
  final MetroSearchBoxStyle style;
  final Duration motionDuration;
  final Curve motionCurve;
  final VoidCallback? onHighlighted;
  final VoidCallback? onSelected;

  @override
  State<_MetroSearchSuggestionRow<T>> createState() =>
      _MetroSearchSuggestionRowState<T>();
}

class _MetroSearchSuggestionRowState<T extends Object>
    extends State<_MetroSearchSuggestionRow<T>> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onSelected != null;
    final states = <WidgetState>{
      if (!enabled) WidgetState.disabled,
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
      selected: widget.highlighted,
      child: child,
    );
  }
}

class _MetroSearchPopupLayoutDelegate extends SingleChildLayoutDelegate {
  const _MetroSearchPopupLayoutDelegate({
    required this.targetRect,
    required this.opensAbove,
    required this.gap,
    required this.maxHeight,
    required this.popupWidth,
    required this.textDirection,
  });

  final Rect targetRect;
  final bool opensAbove;
  final double gap;
  final double maxHeight;
  final double? popupWidth;
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
    final width = (popupWidth ?? targetRect.width)
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
  bool shouldRelayout(_MetroSearchPopupLayoutDelegate oldDelegate) {
    return targetRect != oldDelegate.targetRect ||
        opensAbove != oldDelegate.opensAbove ||
        gap != oldDelegate.gap ||
        maxHeight != oldDelegate.maxHeight ||
        popupWidth != oldDelegate.popupWidth ||
        textDirection != oldDelegate.textDirection;
  }
}

bool _shouldSearchOpenAbove({
  required double overlayHeight,
  required Rect targetRect,
  required double desiredHeight,
  required double gap,
  required bool preferBelow,
}) {
  final spaceBelow = overlayHeight - targetRect.bottom - gap;
  final spaceAbove = targetRect.top - gap;
  if (preferBelow) {
    return spaceBelow < desiredHeight && spaceAbove > spaceBelow;
  }
  return spaceAbove >= desiredHeight || spaceAbove > spaceBelow;
}

double _effectiveSearchItemHeight(
  BuildContext context,
  MetroSearchBoxStyle style,
) {
  final textScale = MediaQuery.maybeTextScalerOf(context)?.scale(1) ?? 1;
  return style.itemHeight! * textScale.clamp(1.0, 1.5);
}

bool _reduceMotion(BuildContext context) {
  final media = MediaQuery.maybeOf(context);
  return media?.disableAnimations == true ||
      media?.accessibleNavigation == true;
}
