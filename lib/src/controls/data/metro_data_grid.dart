import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/metro_accessibility.dart';
import '../../localization/metro_localizations.dart';
import '../../theme/metro_spacing.dart';
import '../../theme/metro_theme.dart';
import '../../theme/metro_theme_data.dart';
import '../selection/metro_selection_group.dart';
import 'metro_data_grid_style.dart';

export 'metro_data_grid_style.dart';

/// Direction reported by a sortable data-grid column.
enum MetroDataGridSortDirection { ascending, descending }

/// Controlled sort state for a [MetroDataGrid].
@immutable
class MetroDataGridSort {
  const MetroDataGridSort({required this.columnKey, required this.direction});

  final Object columnKey;
  final MetroDataGridSortDirection direction;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MetroDataGridSort &&
            other.columnKey == columnKey &&
            other.direction == direction;
  }

  @override
  int get hashCode => Object.hash(columnKey, direction);
}

/// Builds one cell for [row] at [rowIndex].
typedef MetroDataGridCellBuilder<T extends Object> =
    Widget Function(BuildContext context, T row, int rowIndex);

/// Returns the stable identity used to retain row focus across data changes.
typedef MetroDataGridRowKeyBuilder<T extends Object> = Object Function(T row);

/// Builds the accessible label for a complete data-grid row.
typedef MetroDataGridRowSemanticLabelBuilder<T extends Object> =
    String Function(T row, int rowIndex);

/// Describes one fixed- or flexible-width data-grid column.
@immutable
class MetroDataGridColumn<T extends Object> {
  const MetroDataGridColumn({
    required this.key,
    required this.label,
    required this.cellBuilder,
    this.width,
    this.flex = 1,
    this.minimumWidth,
    this.maximumWidth = double.infinity,
    this.alignment = AlignmentDirectional.centerStart,
    this.headerAlignment = AlignmentDirectional.centerStart,
    this.sortable = false,
    this.semanticLabel,
  }) : assert(width == null || width >= 0),
       assert(flex > 0),
       assert(minimumWidth == null || minimumWidth >= 0),
       assert(maximumWidth >= 0),
       assert(width == null || minimumWidth == null || width >= minimumWidth),
       assert(width == null || width <= maximumWidth),
       assert(minimumWidth == null || minimumWidth <= maximumWidth);

  final Object key;
  final Widget label;
  final MetroDataGridCellBuilder<T> cellBuilder;
  final double? width;
  final int flex;
  final double? minimumWidth;
  final double maximumWidth;
  final AlignmentGeometry alignment;
  final AlignmentGeometry headerAlignment;
  final bool sortable;
  final String? semanticLabel;
}

/// A flat, keyboard-navigable Modern UI data grid.
///
/// Sorting is controlled: [sort] describes the visible state and
/// [onSortChanged] asks the application to reorder [rows]. Selection reuses a
/// [MetroSelectionController] supplied directly or by a matching
/// [MetroSelectionGroup].
class MetroDataGrid<T extends Object> extends StatefulWidget {
  const MetroDataGrid({
    required this.columns,
    required this.rows,
    this.sort,
    this.onSortChanged,
    this.selectionController,
    this.allowDeselection = false,
    this.onSelectionChanged,
    this.onRowPressed,
    this.rowKeyBuilder,
    this.rowEnabledBuilder,
    this.rowSemanticLabelBuilder,
    this.emptyState,
    this.height,
    this.showHeader = true,
    this.autofocus = false,
    this.horizontalScrollController,
    this.verticalScrollController,
    this.sortAscendingSemanticLabel,
    this.sortDescendingSemanticLabel,
    this.style,
    super.key,
  }) : assert(columns.length > 0),
       assert(height == null || height > 0);

  final List<MetroDataGridColumn<T>> columns;
  final List<T> rows;
  final MetroDataGridSort? sort;
  final ValueChanged<MetroDataGridSort>? onSortChanged;
  final MetroSelectionController<T>? selectionController;
  final bool allowDeselection;
  final void Function(T row, bool selected)? onSelectionChanged;
  final ValueChanged<T>? onRowPressed;
  final MetroDataGridRowKeyBuilder<T>? rowKeyBuilder;
  final bool Function(T row)? rowEnabledBuilder;
  final MetroDataGridRowSemanticLabelBuilder<T>? rowSemanticLabelBuilder;
  final Widget? emptyState;

  /// Enables a lazy vertical viewport when non-null.
  final double? height;

  final bool showHeader;
  final bool autofocus;
  final ScrollController? horizontalScrollController;
  final ScrollController? verticalScrollController;
  final String? sortAscendingSemanticLabel;
  final String? sortDescendingSemanticLabel;
  final MetroDataGridStyle? style;

  @override
  State<MetroDataGrid<T>> createState() => _MetroDataGridState<T>();
}

class _MetroDataGridState<T extends Object> extends State<MetroDataGrid<T>> {
  final Map<Object, FocusNode> _rowFocusNodes = <Object, FocusNode>{};
  final Map<Object, GlobalKey> _rowKeys = <Object, GlobalKey>{};
  ScrollController? _internalVerticalScrollController;

  ScrollController get _verticalScrollController =>
      widget.verticalScrollController ??
      (_internalVerticalScrollController ??= ScrollController());

  @override
  void initState() {
    super.initState();
    _reconcileRows();
  }

  @override
  void didUpdateWidget(MetroDataGrid<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _reconcileRows();
  }

  @override
  void dispose() {
    for (final node in _rowFocusNodes.values) {
      node.dispose();
    }
    _internalVerticalScrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = MetroTheme.of(context);
    final localizations = MetroLocalizations.of(context);
    final style = _defaultDataGridStyle(theme)
        .merge(theme.dataGridTheme.style)
        .merge(MetroDataGridTheme.maybeOf(context)?.style)
        .merge(widget.style);
    final controller =
        widget.selectionController ?? MetroSelectionGroup.maybeOf<T>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final minimumWidth = _minimumTableWidth(style);
        final viewportWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : minimumWidth;
        final widths = _resolveColumnWidths(
          widget.columns,
          math.max(viewportWidth, minimumWidth),
          style.minimumColumnWidth ?? 80,
        );
        final tableWidth = math.max(
          viewportWidth,
          widths.fold<double>(0, (sum, width) => sum + width),
        );

        Widget buildTable() {
          if (controller == null) {
            return _buildTable(
              controller: null,
              sortAscendingSemanticLabel:
                  widget.sortAscendingSemanticLabel ??
                  localizations.sortAscendingLabel,
              sortDescendingSemanticLabel:
                  widget.sortDescendingSemanticLabel ??
                  localizations.sortDescendingLabel,
              style: style,
              widths: widths,
            );
          }
          return AnimatedBuilder(
            animation: controller,
            builder: (context, child) => _buildTable(
              controller: controller,
              sortAscendingSemanticLabel:
                  widget.sortAscendingSemanticLabel ??
                  localizations.sortAscendingLabel,
              sortDescendingSemanticLabel:
                  widget.sortDescendingSemanticLabel ??
                  localizations.sortDescendingLabel,
              style: style,
              widths: widths,
            ),
          );
        }

        final horizontal = SingleChildScrollView(
          controller: widget.horizontalScrollController,
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: tableWidth,
            height: widget.height,
            child: buildTable(),
          ),
        );
        return ColoredBox(
          color: style.backgroundColor ?? theme.colors.background,
          child: widget.height == null
              ? horizontal
              : SizedBox(height: widget.height, child: horizontal),
        );
      },
    );
  }

  Widget _buildTable({
    required MetroSelectionController<T>? controller,
    required String sortAscendingSemanticLabel,
    required String sortDescendingSemanticLabel,
    required MetroDataGridStyle style,
    required List<double> widths,
  }) {
    final headerHeight = style.headerHeight ?? 44;
    final rowHeight = style.rowHeight ?? 44;
    final autofocusIndex = widget.autofocus ? _firstEnabledRow : -1;
    final children = <Widget>[
      if (widget.showHeader)
        _MetroDataGridHeader<T>(
          columns: widget.columns,
          height: headerHeight,
          onSortChanged: widget.onSortChanged,
          sort: widget.sort,
          sortAscendingSemanticLabel: sortAscendingSemanticLabel,
          sortDescendingSemanticLabel: sortDescendingSemanticLabel,
          style: style,
          widths: widths,
        ),
    ];

    if (widget.height != null) {
      return Column(
        children: [
          ...children,
          Expanded(
            child: widget.rows.isEmpty
                ? _emptyBody(rowHeight)
                : ListView.builder(
                    controller: _verticalScrollController,
                    itemCount: widget.rows.length,
                    itemExtent: rowHeight,
                    primary: false,
                    itemBuilder: (context, index) => _buildRow(
                      autofocusIndex: autofocusIndex,
                      controller: controller,
                      index: index,
                      rowHeight: rowHeight,
                      style: style,
                      widths: widths,
                    ),
                  ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...children,
        if (widget.rows.isEmpty)
          _emptyBody(rowHeight)
        else
          for (var index = 0; index < widget.rows.length; index += 1)
            _buildRow(
              autofocusIndex: autofocusIndex,
              controller: controller,
              index: index,
              rowHeight: rowHeight,
              style: style,
              widths: widths,
            ),
      ],
    );
  }

  Widget _emptyBody(double rowHeight) {
    return SizedBox(
      height: rowHeight,
      child: widget.emptyState == null
          ? const SizedBox.expand()
          : Center(child: widget.emptyState),
    );
  }

  Widget _buildRow({
    required int autofocusIndex,
    required MetroSelectionController<T>? controller,
    required int index,
    required double rowHeight,
    required MetroDataGridStyle style,
    required List<double> widths,
  }) {
    final row = widget.rows[index];
    final key = _keyFor(row);
    final enabled = widget.rowEnabledBuilder?.call(row) ?? true;
    final selected = controller?.isSelected(row) ?? false;
    return _MetroDataGridRow<T>(
      key: _rowKeyFor(key),
      actionable: controller != null || widget.onRowPressed != null,
      autofocus: index == autofocusIndex,
      columns: widget.columns,
      enabled: enabled,
      focusNode: _focusNodeFor(key),
      index: index,
      onActivate: () => _activateRow(row, controller),
      onMoveFocus: (movement) => _moveFocus(index, movement, rowHeight),
      onToggleSelection: controller == null
          ? null
          : () => _toggleSelection(row, controller),
      row: row,
      rowHeight: rowHeight,
      semanticLabel: widget.rowSemanticLabelBuilder?.call(row, index),
      selectionMode: controller?.mode,
      selected: selected,
      style: style,
      widths: widths,
    );
  }

  int get _firstEnabledRow {
    return widget.rows.indexWhere(
      (row) => widget.rowEnabledBuilder?.call(row) ?? true,
    );
  }

  void _activateRow(T row, MetroSelectionController<T>? controller) {
    if (controller != null) {
      _toggleSelection(row, controller);
    }
    widget.onRowPressed?.call(row);
  }

  void _toggleSelection(T row, MetroSelectionController<T> controller) {
    final selected = controller.isSelected(row);
    final changed = selected
        ? (controller.mode == MetroSelectionMode.multiple ||
                  widget.allowDeselection
              ? controller.deselect(row)
              : false)
        : controller.select(row);
    if (changed) {
      widget.onSelectionChanged?.call(row, !selected);
    }
  }

  void _moveFocus(int currentIndex, _GridMovement movement, double rowHeight) {
    if (widget.rows.isEmpty) return;
    final target = switch (movement) {
      _GridMovement.previous => currentIndex - 1,
      _GridMovement.next => currentIndex + 1,
      _GridMovement.pagePrevious => currentIndex - 10,
      _GridMovement.pageNext => currentIndex + 10,
      _GridMovement.first => 0,
      _GridMovement.last => widget.rows.length - 1,
    }.clamp(0, widget.rows.length - 1).toInt();
    final step = target < currentIndex ? -1 : 1;
    var index = target;
    while (index >= 0 && index < widget.rows.length) {
      final row = widget.rows[index];
      if (widget.rowEnabledBuilder?.call(row) ?? true) {
        final key = _keyFor(row);
        final focusNode = _focusNodeFor(key);
        final rowKey = _rowKeyFor(key);
        final rowContext = rowKey.currentContext;
        if (rowContext != null) {
          focusNode.requestFocus();
          Scrollable.ensureVisible(rowContext, alignment: 0.5);
        } else if (widget.height != null &&
            _verticalScrollController.hasClients) {
          final position = _verticalScrollController.position;
          final targetOffset = (index * rowHeight).clamp(
            position.minScrollExtent,
            position.maxScrollExtent,
          );
          _verticalScrollController.jumpTo(targetOffset);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted || _rowFocusNodes[key] != focusNode) return;
            focusNode.requestFocus();
            final builtContext = _rowKeys[key]?.currentContext;
            if (builtContext != null) {
              Scrollable.ensureVisible(builtContext, alignment: 0.5);
            }
          });
        }
        return;
      }
      index += step;
    }
  }

  double _minimumTableWidth(MetroDataGridStyle style) {
    final defaultMinimum = style.minimumColumnWidth ?? 80;
    return widget.columns.fold<double>(0, (sum, column) {
      return sum +
          (column.width ?? column.minimumWidth ?? defaultMinimum).clamp(
            0,
            column.maximumWidth,
          );
    });
  }

  Object _keyFor(T row) => widget.rowKeyBuilder?.call(row) ?? row;

  FocusNode _focusNodeFor(Object key) {
    return _rowFocusNodes.putIfAbsent(
      key,
      () => FocusNode(debugLabel: 'MetroDataGrid row $key'),
    );
  }

  GlobalKey _rowKeyFor(Object key) {
    return _rowKeys.putIfAbsent(key, GlobalKey.new);
  }

  void _reconcileRows() {
    final keys = <Object>{};
    for (final row in widget.rows) {
      final key = _keyFor(row);
      assert(!keys.contains(key), 'MetroDataGrid row keys must be unique.');
      keys.add(key);
    }
    final removed = _rowFocusNodes.keys
        .where((key) => !keys.contains(key))
        .toList();
    for (final key in removed) {
      _rowFocusNodes.remove(key)?.dispose();
    }
    _rowKeys.removeWhere((key, _) => !keys.contains(key));
  }
}

class _MetroDataGridHeader<T extends Object> extends StatelessWidget {
  const _MetroDataGridHeader({
    required this.columns,
    required this.height,
    required this.onSortChanged,
    required this.sort,
    required this.sortAscendingSemanticLabel,
    required this.sortDescendingSemanticLabel,
    required this.style,
    required this.widths,
  });

  final List<MetroDataGridColumn<T>> columns;
  final double height;
  final ValueChanged<MetroDataGridSort>? onSortChanged;
  final MetroDataGridSort? sort;
  final String sortAscendingSemanticLabel;
  final String sortDescendingSemanticLabel;
  final MetroDataGridStyle style;
  final List<double> widths;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          for (var index = 0; index < columns.length; index += 1)
            SizedBox(
              width: widths[index],
              child: _MetroDataGridHeaderCell<T>(
                column: columns[index],
                dividerAtEnd: index != columns.length - 1,
                onSortChanged: onSortChanged,
                sort: sort,
                sortAscendingSemanticLabel: sortAscendingSemanticLabel,
                sortDescendingSemanticLabel: sortDescendingSemanticLabel,
                style: style,
              ),
            ),
        ],
      ),
    );
  }
}

class _MetroDataGridHeaderCell<T extends Object> extends StatefulWidget {
  const _MetroDataGridHeaderCell({
    required this.column,
    required this.dividerAtEnd,
    required this.onSortChanged,
    required this.sort,
    required this.sortAscendingSemanticLabel,
    required this.sortDescendingSemanticLabel,
    required this.style,
  });

  final MetroDataGridColumn<T> column;
  final bool dividerAtEnd;
  final ValueChanged<MetroDataGridSort>? onSortChanged;
  final MetroDataGridSort? sort;
  final String sortAscendingSemanticLabel;
  final String sortDescendingSemanticLabel;
  final MetroDataGridStyle style;

  @override
  State<_MetroDataGridHeaderCell<T>> createState() =>
      _MetroDataGridHeaderCellState<T>();
}

class _MetroDataGridHeaderCellState<T extends Object>
    extends State<_MetroDataGridHeaderCell<T>> {
  bool _focused = false;
  bool _hovered = false;
  bool _pressed = false;

  bool get _enabled => widget.column.sortable && widget.onSortChanged != null;

  MetroDataGridSortDirection? get _direction {
    return widget.sort?.columnKey == widget.column.key
        ? widget.sort?.direction
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final states = <WidgetState>{
      if (_direction != null) WidgetState.selected,
      if (_focused) WidgetState.focused,
      if (_hovered) WidgetState.hovered,
      if (_pressed) WidgetState.pressed,
    };
    final background = widget.style.headerBackgroundColor?.resolve(states);
    final foreground = widget.style.headerForegroundColor?.resolve(states);
    final borderColor = widget.style.headerBorderColor?.resolve(states);
    final sortValue = switch (_direction) {
      MetroDataGridSortDirection.ascending => widget.sortAscendingSemanticLabel,
      MetroDataGridSortDirection.descending =>
        widget.sortDescendingSemanticLabel,
      null => null,
    };
    Widget visual = Container(
      alignment: widget.column.headerAlignment,
      padding:
          widget.style.headerPadding ??
          const EdgeInsets.symmetric(horizontal: MetroSpacing.sm),
      decoration: BoxDecoration(
        color: background,
        border: BorderDirectional(
          bottom: BorderSide(
            color: borderColor ?? const Color(0x00000000),
            width: widget.style.headerBorderWidth ?? 3,
          ),
          end: widget.dividerAtEnd
              ? BorderSide(
                  color: widget.style.dividerColor ?? const Color(0x00000000),
                  width: widget.style.dividerWidth ?? 1,
                )
              : BorderSide.none,
        ),
      ),
      child: DefaultTextStyle.merge(
        style: widget.style.headerTextStyle
            ?.resolve(states)
            ?.copyWith(color: foreground),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: widget.column.label),
            if (_direction != null) ...[
              const SizedBox(width: MetroSpacing.xs),
              _SortIndicator(
                color:
                    widget.style.sortIndicatorColor ??
                    foreground ??
                    const Color(0x00000000),
                direction: _direction!,
              ),
            ],
          ],
        ),
      ),
    );
    if (widget.column.semanticLabel != null) {
      visual = ExcludeSemantics(child: visual);
    }
    return Semantics(
      button: _enabled,
      label: widget.column.semanticLabel,
      onTap: _enabled ? _sort : null,
      value: sortValue,
      child: FocusableActionDetector(
        enabled: _enabled,
        mouseCursor: _enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (intent) {
              _sort();
              return null;
            },
          ),
        },
        onShowFocusHighlight: (value) => setState(() => _focused = value),
        onShowHoverHighlight: (value) => setState(() => _hovered = value),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTap: _enabled ? _sort : null,
          onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
          onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
          onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
          child: visual,
        ),
      ),
    );
  }

  void _sort() {
    if (!_enabled) return;
    final next = _direction == MetroDataGridSortDirection.ascending
        ? MetroDataGridSortDirection.descending
        : MetroDataGridSortDirection.ascending;
    widget.onSortChanged?.call(
      MetroDataGridSort(columnKey: widget.column.key, direction: next),
    );
  }
}

class _MetroDataGridRow<T extends Object> extends StatefulWidget {
  const _MetroDataGridRow({
    required this.actionable,
    required this.autofocus,
    required this.columns,
    required this.enabled,
    required this.focusNode,
    required this.index,
    required this.onActivate,
    required this.onMoveFocus,
    required this.onToggleSelection,
    required this.row,
    required this.rowHeight,
    required this.semanticLabel,
    required this.selectionMode,
    required this.selected,
    required this.style,
    required this.widths,
    super.key,
  });

  final bool actionable;
  final bool autofocus;
  final List<MetroDataGridColumn<T>> columns;
  final bool enabled;
  final FocusNode focusNode;
  final int index;
  final VoidCallback onActivate;
  final ValueChanged<_GridMovement> onMoveFocus;
  final VoidCallback? onToggleSelection;
  final T row;
  final double rowHeight;
  final String? semanticLabel;
  final MetroSelectionMode? selectionMode;
  final bool selected;
  final MetroDataGridStyle style;
  final List<double> widths;

  @override
  State<_MetroDataGridRow<T>> createState() => _MetroDataGridRowState<T>();
}

class _MetroDataGridRowState<T extends Object>
    extends State<_MetroDataGridRow<T>> {
  bool _focused = false;
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = MetroTheme.of(context);
    final states = <WidgetState>{
      if (!widget.enabled) WidgetState.disabled,
      if (widget.selected) WidgetState.selected,
      if (_focused) WidgetState.focused,
      if (_hovered) WidgetState.hovered,
      if (_pressed) WidgetState.pressed,
    };
    var background = widget.style.rowBackgroundColor?.resolve(states);
    if (widget.index.isOdd && !widget.selected && !_hovered && widget.enabled) {
      background = widget.style.alternateRowBackgroundColor ?? background;
    }
    final foreground = widget.style.rowForegroundColor?.resolve(states);
    Widget visual = AnimatedScale(
      key: ValueKey<String>('metro-data-grid-row-${widget.index}-scale'),
      scale: _pressed ? 0.975 : 1,
      duration: metroReduceMotion(context)
          ? Duration.zero
          : theme.motion.normal,
      curve: theme.motion.standardCurve,
      child: Container(
        key: ValueKey<String>('metro-data-grid-row-${widget.index}-surface'),
        height: widget.rowHeight,
        decoration: BoxDecoration(
          color: background,
          border: Border(
            bottom: BorderSide(
              color: widget.style.dividerColor ?? const Color(0x00000000),
              width: widget.style.dividerWidth ?? 1,
            ),
          ),
        ),
        foregroundDecoration: _focused
            ? BoxDecoration(
                border: Border.all(
                  color: widget.style.focusColor ?? const Color(0x00000000),
                  width: widget.style.focusWidth ?? 2,
                ),
              )
            : null,
        child: DefaultTextStyle.merge(
          style: widget.style.cellTextStyle
              ?.resolve(states)
              ?.copyWith(color: foreground),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          child: Row(
            children: [
              for (var index = 0; index < widget.columns.length; index += 1)
                SizedBox(
                  width: widget.widths[index],
                  child: Container(
                    alignment: widget.columns[index].alignment,
                    padding:
                        widget.style.cellPadding ??
                        const EdgeInsets.symmetric(horizontal: MetroSpacing.sm),
                    decoration: BoxDecoration(
                      border: index == widget.columns.length - 1
                          ? null
                          : BorderDirectional(
                              end: BorderSide(
                                color:
                                    widget.style.dividerColor ??
                                    const Color(0x00000000),
                                width: widget.style.dividerWidth ?? 1,
                              ),
                            ),
                    ),
                    child: widget.columns[index].cellBuilder(
                      context,
                      widget.row,
                      widget.index,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (widget.semanticLabel != null) {
      visual = ExcludeSemantics(child: visual);
    }
    final actionable = widget.enabled && widget.actionable;
    return Semantics(
      checked: widget.selectionMode == MetroSelectionMode.multiple
          ? widget.selected
          : null,
      enabled: widget.enabled,
      label: widget.semanticLabel,
      onTap: actionable ? widget.onActivate : null,
      selected: widget.selectionMode == MetroSelectionMode.single
          ? widget.selected
          : null,
      child: FocusableActionDetector(
        autofocus: widget.autofocus,
        enabled: widget.enabled,
        focusNode: widget.focusNode,
        mouseCursor: actionable
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        shortcuts: <ShortcutActivator, Intent>{
          ..._rowNavigationShortcuts,
          if (widget.actionable)
            const SingleActivator(LogicalKeyboardKey.enter):
                const _GridActivateIntent(),
          if (widget.onToggleSelection != null)
            const SingleActivator(LogicalKeyboardKey.space):
                const _GridToggleSelectionIntent(),
        },
        actions: <Type, Action<Intent>>{
          _GridMoveIntent: CallbackAction<_GridMoveIntent>(
            onInvoke: (intent) {
              widget.onMoveFocus(intent.movement);
              return null;
            },
          ),
          _GridActivateIntent: CallbackAction<_GridActivateIntent>(
            onInvoke: (intent) {
              widget.onActivate();
              return null;
            },
          ),
          _GridToggleSelectionIntent:
              CallbackAction<_GridToggleSelectionIntent>(
                onInvoke: (intent) {
                  widget.onToggleSelection?.call();
                  return null;
                },
              ),
        },
        onShowFocusHighlight: (value) => setState(() => _focused = value),
        onShowHoverHighlight: (value) => setState(() => _hovered = value),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTap: actionable ? widget.onActivate : null,
          onTapCancel: actionable
              ? () => setState(() => _pressed = false)
              : null,
          onTapDown: actionable
              ? (_) {
                  widget.focusNode.requestFocus();
                  setState(() => _pressed = true);
                }
              : null,
          onTapUp: actionable ? (_) => setState(() => _pressed = false) : null,
          child: visual,
        ),
      ),
    );
  }
}

enum _GridMovement { previous, next, pagePrevious, pageNext, first, last }

class _GridMoveIntent extends Intent {
  const _GridMoveIntent(this.movement);
  final _GridMovement movement;
}

class _GridActivateIntent extends Intent {
  const _GridActivateIntent();
}

class _GridToggleSelectionIntent extends Intent {
  const _GridToggleSelectionIntent();
}

const Map<ShortcutActivator, Intent> _rowNavigationShortcuts =
    <ShortcutActivator, Intent>{
      SingleActivator(LogicalKeyboardKey.arrowUp): _GridMoveIntent(
        _GridMovement.previous,
      ),
      SingleActivator(LogicalKeyboardKey.arrowDown): _GridMoveIntent(
        _GridMovement.next,
      ),
      SingleActivator(LogicalKeyboardKey.pageUp): _GridMoveIntent(
        _GridMovement.pagePrevious,
      ),
      SingleActivator(LogicalKeyboardKey.pageDown): _GridMoveIntent(
        _GridMovement.pageNext,
      ),
      SingleActivator(LogicalKeyboardKey.home): _GridMoveIntent(
        _GridMovement.first,
      ),
      SingleActivator(LogicalKeyboardKey.end): _GridMoveIntent(
        _GridMovement.last,
      ),
    };

class _SortIndicator extends StatelessWidget {
  const _SortIndicator({required this.color, required this.direction});

  final Color color;
  final MetroDataGridSortDirection direction;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SortIndicatorPainter(color: color, direction: direction),
      size: const Size(10, 12),
    );
  }
}

class _SortIndicatorPainter extends CustomPainter {
  const _SortIndicatorPainter({required this.color, required this.direction});

  final Color color;
  final MetroDataGridSortDirection direction;

  @override
  void paint(Canvas canvas, Size size) {
    final ascending = direction == MetroDataGridSortDirection.ascending;
    final path = Path()
      ..moveTo(size.width / 2, ascending ? 1 : size.height - 1)
      ..lineTo(1, ascending ? size.height - 3 : 3)
      ..lineTo(size.width - 1, ascending ? size.height - 3 : 3)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_SortIndicatorPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.direction != direction;
  }
}

List<double> _resolveColumnWidths<T extends Object>(
  List<MetroDataGridColumn<T>> columns,
  double availableWidth,
  double defaultMinimum,
) {
  var fixedWidth = 0.0;
  var flexMinimum = 0.0;
  var totalFlex = 0;
  for (final column in columns) {
    if (column.width case final width?) {
      fixedWidth += width.clamp(0, column.maximumWidth).toDouble();
    } else {
      flexMinimum += (column.minimumWidth ?? defaultMinimum).clamp(
        0,
        column.maximumWidth,
      );
      totalFlex += column.flex;
    }
  }
  final distributable = math.max(flexMinimum, availableWidth - fixedWidth);
  return <double>[
    for (final column in columns)
      if (column.width case final width?)
        width.clamp(0, column.maximumWidth).toDouble()
      else
        math
            .max(
              column.minimumWidth ?? defaultMinimum,
              distributable * column.flex / totalFlex,
            )
            .clamp(0, column.maximumWidth)
            .toDouble(),
  ];
}

MetroDataGridStyle _defaultDataGridStyle(MetroThemeData theme) {
  final colors = theme.colors;
  return MetroDataGridStyle(
    backgroundColor: colors.background,
    headerBackgroundColor: WidgetStateProperty.resolveWith((states) {
      return states.contains(WidgetState.hovered)
          ? colors.surfaceVariant
          : colors.surface;
    }),
    headerForegroundColor: WidgetStatePropertyAll(colors.foreground),
    headerBorderColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.focused)) return colors.focus;
      if (states.contains(WidgetState.selected) ||
          states.contains(WidgetState.hovered)) {
        return colors.accent;
      }
      return colors.border;
    }),
    rowBackgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return colors.disabledBackground;
      }
      if (states.contains(WidgetState.selected)) {
        if (states.contains(WidgetState.hovered)) {
          return colors.isHighContrast ? colors.accent : colors.accentHover;
        }
        return colors.accent;
      }
      if (states.contains(WidgetState.hovered)) {
        if (colors.isHighContrast) return colors.accent;
        return Color.alphaBlend(
          colors.foreground.withValues(alpha: 0.3),
          colors.background,
        );
      }
      return colors.background;
    }),
    alternateRowBackgroundColor: colors.surface,
    rowForegroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return colors.disabledForeground;
      }
      if (states.contains(WidgetState.selected) ||
          (colors.isHighContrast && states.contains(WidgetState.hovered))) {
        return colors.isHighContrast
            ? colors.onAccent
            : const Color(0xFFFFFFFF);
      }
      return colors.foreground;
    }),
    dividerColor: colors.border.withValues(alpha: 0.35),
    focusColor: colors.focus,
    sortIndicatorColor: colors.accent,
    headerTextStyle: WidgetStatePropertyAll(theme.typography.bodyStrong),
    cellTextStyle: WidgetStatePropertyAll(theme.typography.body),
    headerPadding: const EdgeInsets.symmetric(horizontal: MetroSpacing.sm),
    cellPadding: const EdgeInsets.symmetric(horizontal: MetroSpacing.sm),
    headerHeight: 44,
    rowHeight: 44,
    headerBorderWidth: 3,
    dividerWidth: 1,
    focusWidth: 2,
    minimumColumnWidth: 80,
  );
}
