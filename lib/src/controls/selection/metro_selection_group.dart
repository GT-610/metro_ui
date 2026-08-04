import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Cardinality policy used by a [MetroSelectionController].
enum MetroSelectionMode { single, multiple }

/// Mutable selection state shared by Metro selection controls.
class MetroSelectionController<T> extends ChangeNotifier {
  MetroSelectionController({
    this.mode = MetroSelectionMode.single,
    Iterable<T> selectedValues = const [],
    this.allowEmptySelection = true,
    this.maxSelectionCount,
  }) {
    if (maxSelectionCount != null && maxSelectionCount! <= 0) {
      throw ArgumentError.value(
        maxSelectionCount,
        'maxSelectionCount',
        'Must be greater than zero.',
      );
    }
    _selectedValues = LinkedHashSet<T>.of(selectedValues);
    _validateSelection(_selectedValues);
  }

  final MetroSelectionMode mode;
  final bool allowEmptySelection;
  final int? maxSelectionCount;

  late LinkedHashSet<T> _selectedValues;

  Set<T> get selectedValues => Set<T>.unmodifiable(_selectedValues);

  T? get selectedValue =>
      _selectedValues.isEmpty ? null : _selectedValues.first;

  bool get canSelectMore {
    if (mode == MetroSelectionMode.single) {
      return true;
    }
    return maxSelectionCount == null ||
        _selectedValues.length < maxSelectionCount!;
  }

  bool isSelected(T value) => _selectedValues.contains(value);

  bool select(T value) {
    if (mode == MetroSelectionMode.single) {
      if (_selectedValues.length == 1 && _selectedValues.contains(value)) {
        return false;
      }
      _selectedValues = LinkedHashSet<T>()..add(value);
      notifyListeners();
      return true;
    }
    if (_selectedValues.contains(value) || !canSelectMore) {
      return false;
    }
    _selectedValues.add(value);
    notifyListeners();
    return true;
  }

  bool deselect(T value) {
    if (!_selectedValues.contains(value)) {
      return false;
    }
    if (!allowEmptySelection && _selectedValues.length == 1) {
      return false;
    }
    _selectedValues.remove(value);
    notifyListeners();
    return true;
  }

  bool toggle(T value) {
    return isSelected(value) ? deselect(value) : select(value);
  }

  bool clear() {
    if (_selectedValues.isEmpty || !allowEmptySelection) {
      return false;
    }
    _selectedValues.clear();
    notifyListeners();
    return true;
  }

  bool replace(Iterable<T> values) {
    final next = LinkedHashSet<T>.of(values);
    _validateSelection(next);
    if (!allowEmptySelection && next.isEmpty && _selectedValues.isNotEmpty) {
      return false;
    }
    if (setEquals(_selectedValues, next)) {
      return false;
    }
    _selectedValues = next;
    notifyListeners();
    return true;
  }

  bool selectAll(Iterable<T> values) {
    if (mode == MetroSelectionMode.single) {
      final iterator = values.iterator;
      return iterator.moveNext() ? select(iterator.current) : false;
    }
    final next = LinkedHashSet<T>.of(_selectedValues);
    for (final value in values) {
      if (maxSelectionCount != null && next.length >= maxSelectionCount!) {
        break;
      }
      next.add(value);
    }
    if (setEquals(_selectedValues, next)) {
      return false;
    }
    _selectedValues = next;
    notifyListeners();
    return true;
  }

  void _validateSelection(Set<T> values) {
    if (mode == MetroSelectionMode.single && values.length > 1) {
      throw ArgumentError.value(
        values,
        'selectedValues',
        'Single selection accepts at most one value.',
      );
    }
    if (maxSelectionCount != null && values.length > maxSelectionCount!) {
      throw ArgumentError.value(
        values,
        'selectedValues',
        'Contains more values than maxSelectionCount.',
      );
    }
  }
}

/// Provides a selection controller to descendant Metro controls.
class MetroSelectionGroup<T> extends StatefulWidget {
  const MetroSelectionGroup({
    required this.child,
    this.controller,
    this.mode = MetroSelectionMode.single,
    this.initialSelectedValues = const [],
    this.allowEmptySelection = true,
    this.maxSelectionCount,
    this.onChanged,
    super.key,
  });

  final Widget child;
  final MetroSelectionController<T>? controller;
  final MetroSelectionMode mode;
  final Iterable<T> initialSelectedValues;
  final bool allowEmptySelection;
  final int? maxSelectionCount;
  final ValueChanged<Set<T>>? onChanged;

  static MetroSelectionController<S>? maybeOf<S>(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_MetroSelectionScope<S>>()
        ?.controller;
  }

  static MetroSelectionController<S> of<S>(BuildContext context) {
    final controller = maybeOf<S>(context);
    if (controller == null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('No MetroSelectionGroup<$S> found.'),
        ErrorDescription(
          'A Metro selection control requested a group controller, but no '
          'matching MetroSelectionGroup<$S> exists above it.',
        ),
        ErrorHint(
          'Wrap the controls in MetroSelectionGroup<$S> or pass an explicit '
          'MetroSelectionController<$S>.',
        ),
      ]);
    }
    return controller;
  }

  @override
  State<MetroSelectionGroup<T>> createState() => _MetroSelectionGroupState<T>();
}

class _MetroSelectionGroupState<T> extends State<MetroSelectionGroup<T>> {
  MetroSelectionController<T>? _ownedController;

  MetroSelectionController<T> get _controller =>
      widget.controller ?? _ownedController!;

  @override
  void initState() {
    super.initState();
    _ownedController = widget.controller == null ? _createController() : null;
    _controller.addListener(_handleChanged);
  }

  MetroSelectionController<T> _createController({Iterable<T>? values}) {
    return MetroSelectionController<T>(
      allowEmptySelection: widget.allowEmptySelection,
      maxSelectionCount: widget.maxSelectionCount,
      mode: widget.mode,
      selectedValues: values ?? widget.initialSelectedValues,
    );
  }

  @override
  void didUpdateWidget(MetroSelectionGroup<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final externalControllerChanged = oldWidget.controller != widget.controller;
    final internalConfigurationChanged =
        widget.controller == null &&
        oldWidget.controller == null &&
        (oldWidget.mode != widget.mode ||
            oldWidget.allowEmptySelection != widget.allowEmptySelection ||
            oldWidget.maxSelectionCount != widget.maxSelectionCount);
    if (!externalControllerChanged && !internalConfigurationChanged) {
      return;
    }

    final previousValues = _controller.selectedValues;
    _controller.removeListener(_handleChanged);
    _ownedController?.dispose();
    _ownedController = null;
    if (widget.controller == null) {
      final values = widget.mode == MetroSelectionMode.single
          ? previousValues.take(1)
          : widget.maxSelectionCount == null
          ? previousValues
          : previousValues.take(widget.maxSelectionCount!);
      _ownedController = _createController(values: values);
    }
    _controller.addListener(_handleChanged);
  }

  void _handleChanged() {
    widget.onChanged?.call(_controller.selectedValues);
  }

  @override
  Widget build(BuildContext context) {
    return _MetroSelectionScope<T>(
      controller: _controller,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_handleChanged);
    _ownedController?.dispose();
    super.dispose();
  }
}

class _MetroSelectionScope<T> extends InheritedWidget {
  const _MetroSelectionScope({required this.controller, required super.child});

  final MetroSelectionController<T> controller;

  @override
  bool updateShouldNotify(_MetroSelectionScope<T> oldWidget) {
    return controller != oldWidget.controller;
  }
}
