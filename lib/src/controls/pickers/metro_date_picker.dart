import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../foundation/metro_focus_traversal.dart';
import '../../localization/metro_localizations.dart';
import '../../theme/metro_spacing.dart';
import '../../theme/metro_theme.dart';
import '../buttons/metro_button.dart';
import '../overlays/metro_dialog.dart';
import 'metro_picker_field.dart';
import 'metro_picker_style.dart';
import 'metro_picker_wheel.dart';

export 'metro_picker_style.dart';

/// Date segment shown by a Metro date field or picker wheel.
enum MetroDatePickerField { month, day, year }

/// Formats one month, day, or year value in a Metro date picker.
typedef MetroDatePartFormatter =
    String Function(BuildContext context, int value);

/// Returns a practical date-field order for a locale without requiring intl.
List<MetroDatePickerField> metroDatePickerFieldOrderForLocale(Locale? locale) {
  final language = locale?.languageCode.toLowerCase();
  final country = locale?.countryCode?.toUpperCase();
  if (const {'zh', 'ja', 'ko'}.contains(language)) {
    return const [
      MetroDatePickerField.year,
      MetroDatePickerField.month,
      MetroDatePickerField.day,
    ];
  }
  if (language == 'en' && (country == null || country == 'US')) {
    return const [
      MetroDatePickerField.month,
      MetroDatePickerField.day,
      MetroDatePickerField.year,
    ];
  }
  return const [
    MetroDatePickerField.day,
    MetroDatePickerField.month,
    MetroDatePickerField.year,
  ];
}

/// Shows a Metro date dialog and returns the confirmed date.
///
/// The initial date is clamped to the inclusive [firstDate]/[lastDate] range.
/// Dismissing or cancelling the dialog returns null.
Future<DateTime?> showMetroDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  List<MetroDatePickerField>? fieldOrder,
  Map<MetroDatePickerField, int>? fieldFlex,
  bool showMonth = true,
  bool showDay = true,
  bool showYear = true,
  MetroDatePartFormatter? monthFormatter,
  MetroDatePartFormatter? dayFormatter,
  MetroDatePartFormatter? yearFormatter,
  String? title,
  String? monthLabel,
  String? dayLabel,
  String? yearLabel,
  String? confirmLabel,
  String? cancelLabel,
}) {
  final localizations = MetroLocalizations.of(context);
  final first = _dateOnly(firstDate);
  final last = _dateOnly(lastDate);
  assert(!last.isBefore(first));
  assert(showMonth || showDay || showYear);
  if (last.isBefore(first)) {
    throw ArgumentError.value(
      lastDate,
      'lastDate',
      'Must not precede firstDate.',
    );
  }
  if (!showMonth && !showDay && !showYear) {
    throw ArgumentError('At least one date field must be visible.');
  }
  final initial = _clampDate(_dateOnly(initialDate), first, last);
  final order = _normalizedDateFieldOrder(
    fieldOrder ??
        metroDatePickerFieldOrderForLocale(
          Localizations.maybeLocaleOf(context),
        ),
  );
  return showMetroDialog<DateTime>(
    context: context,
    builder: (dialogContext) {
      return _MetroDatePickerDialog(
        cancelLabel: cancelLabel ?? localizations.cancelLabel,
        confirmLabel: confirmLabel ?? localizations.confirmLabel,
        dayFormatter: dayFormatter,
        dayLabel: dayLabel ?? localizations.dayLabel,
        fieldFlex: fieldFlex,
        fieldOrder: order,
        firstDate: first,
        initialDate: initial,
        lastDate: last,
        monthFormatter: monthFormatter,
        monthLabel: monthLabel ?? localizations.monthLabel,
        showDay: showDay,
        showMonth: showMonth,
        showYear: showYear,
        title: title ?? localizations.selectDateTitle,
        yearFormatter: yearFormatter,
        yearLabel: yearLabel ?? localizations.yearLabel,
      );
    },
  );
}

/// A segmented Modern UI date field that opens a three-column picker.
class MetroDatePicker extends StatefulWidget {
  const MetroDatePicker({
    required this.selected,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
    this.currentDate,
    this.fieldOrder,
    this.fieldFlex,
    this.showMonth = true,
    this.showDay = true,
    this.showYear = true,
    this.monthFormatter,
    this.dayFormatter,
    this.yearFormatter,
    this.title,
    this.monthLabel,
    this.dayLabel,
    this.yearLabel,
    this.confirmLabel,
    this.cancelLabel,
    this.onCancel,
    this.style,
    this.autofocus = false,
    this.focusNode,
    this.semanticLabel,
    super.key,
  });

  final DateTime? selected;
  final ValueChanged<DateTime>? onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? currentDate;
  final List<MetroDatePickerField>? fieldOrder;
  final Map<MetroDatePickerField, int>? fieldFlex;
  final bool showMonth;
  final bool showDay;
  final bool showYear;
  final MetroDatePartFormatter? monthFormatter;
  final MetroDatePartFormatter? dayFormatter;
  final MetroDatePartFormatter? yearFormatter;
  final String? title;
  final String? monthLabel;
  final String? dayLabel;
  final String? yearLabel;
  final String? confirmLabel;
  final String? cancelLabel;
  final VoidCallback? onCancel;
  final MetroPickerStyle? style;
  final bool autofocus;
  final FocusNode? focusNode;
  final String? semanticLabel;

  @override
  State<MetroDatePicker> createState() => MetroDatePickerState();
}

/// State exposed so applications can open a keyed [MetroDatePicker].
class MetroDatePickerState extends State<MetroDatePicker> {
  Future<void> open() async {
    if (widget.onChanged == null) {
      return;
    }
    final today = _dateOnly(widget.currentDate ?? DateTime.now());
    final first = _dateOnly(widget.firstDate ?? DateTime(today.year - 100));
    final last = _dateOnly(
      widget.lastDate ?? DateTime(today.year + 25, 12, 31),
    );
    final result = await showMetroDatePicker(
      context: context,
      initialDate: widget.selected ?? _clampDate(today, first, last),
      firstDate: first,
      lastDate: last,
      fieldOrder: widget.fieldOrder,
      fieldFlex: widget.fieldFlex,
      showMonth: widget.showMonth,
      showDay: widget.showDay,
      showYear: widget.showYear,
      monthFormatter: widget.monthFormatter,
      dayFormatter: widget.dayFormatter,
      yearFormatter: widget.yearFormatter,
      title: widget.title,
      monthLabel: widget.monthLabel,
      dayLabel: widget.dayLabel,
      yearLabel: widget.yearLabel,
      confirmLabel: widget.confirmLabel,
      cancelLabel: widget.cancelLabel,
    );
    if (!mounted) {
      return;
    }
    if (result == null) {
      widget.onCancel?.call();
    } else {
      widget.onChanged?.call(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.showMonth || widget.showDay || widget.showYear);
    final localizations = MetroLocalizations.of(context);
    final order = _normalizedDateFieldOrder(
      widget.fieldOrder ??
          metroDatePickerFieldOrderForLocale(
            Localizations.maybeLocaleOf(context),
          ),
    );
    final visibleOrder = order.where(_isFieldVisible).toList();
    final selected = widget.selected;
    final values = <String>[
      for (final field in visibleOrder) _formatField(context, field, selected),
    ];
    final flex = <int>[
      for (final field in visibleOrder)
        math.max(
          1,
          widget.fieldFlex?[field] ??
              (field == MetroDatePickerField.month ? 2 : 1),
        ),
    ];
    final semanticLabel =
        widget.semanticLabel ??
        localizations.datePickerSemanticLabel(
          selected == null ? const [] : values,
        );

    return MetroPickerField(
      autofocus: widget.autofocus,
      flex: flex,
      focusNode: widget.focusNode,
      onPressed: widget.onChanged == null ? null : open,
      semanticLabel: semanticLabel,
      style: widget.style,
      values: values,
    );
  }

  bool _isFieldVisible(MetroDatePickerField field) {
    return switch (field) {
      MetroDatePickerField.month => widget.showMonth,
      MetroDatePickerField.day => widget.showDay,
      MetroDatePickerField.year => widget.showYear,
    };
  }

  String _formatField(
    BuildContext context,
    MetroDatePickerField field,
    DateTime? date,
  ) {
    if (date == null) {
      final localizations = MetroLocalizations.of(context);
      return switch (field) {
        MetroDatePickerField.month =>
          widget.monthLabel ?? localizations.monthLabel,
        MetroDatePickerField.day => widget.dayLabel ?? localizations.dayLabel,
        MetroDatePickerField.year =>
          widget.yearLabel ?? localizations.yearLabel,
      };
    }
    return switch (field) {
      MetroDatePickerField.month =>
        widget.monthFormatter?.call(context, date.month) ??
            _twoDigits(date.month),
      MetroDatePickerField.day =>
        widget.dayFormatter?.call(context, date.day) ?? _twoDigits(date.day),
      MetroDatePickerField.year =>
        widget.yearFormatter?.call(context, date.year) ?? '${date.year}',
    };
  }
}

class _MetroDatePickerDialog extends StatefulWidget {
  const _MetroDatePickerDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.fieldOrder,
    required this.fieldFlex,
    required this.showMonth,
    required this.showDay,
    required this.showYear,
    required this.monthFormatter,
    required this.dayFormatter,
    required this.yearFormatter,
    required this.title,
    required this.monthLabel,
    required this.dayLabel,
    required this.yearLabel,
    required this.confirmLabel,
    required this.cancelLabel,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final List<MetroDatePickerField> fieldOrder;
  final Map<MetroDatePickerField, int>? fieldFlex;
  final bool showMonth;
  final bool showDay;
  final bool showYear;
  final MetroDatePartFormatter? monthFormatter;
  final MetroDatePartFormatter? dayFormatter;
  final MetroDatePartFormatter? yearFormatter;
  final String title;
  final String monthLabel;
  final String dayLabel;
  final String yearLabel;
  final String confirmLabel;
  final String cancelLabel;

  @override
  State<_MetroDatePickerDialog> createState() => _MetroDatePickerDialogState();
}

class _MetroDatePickerDialogState extends State<_MetroDatePickerDialog> {
  late DateTime _date = widget.initialDate;

  List<int> get _years => <int>[
    for (var year = widget.firstDate.year; year <= widget.lastDate.year; year++)
      year,
  ];

  List<int> get _months {
    final firstMonth = _date.year == widget.firstDate.year
        ? widget.firstDate.month
        : 1;
    final lastMonth = _date.year == widget.lastDate.year
        ? widget.lastDate.month
        : 12;
    return <int>[
      for (var month = firstMonth; month <= lastMonth; month++) month,
    ];
  }

  List<int> get _days {
    var firstDay = 1;
    var lastDay = _daysInMonth(_date.year, _date.month);
    if (_date.year == widget.firstDate.year &&
        _date.month == widget.firstDate.month) {
      firstDay = widget.firstDate.day;
    }
    if (_date.year == widget.lastDate.year &&
        _date.month == widget.lastDate.month) {
      lastDay = widget.lastDate.day;
    }
    return <int>[for (var day = firstDay; day <= lastDay; day++) day];
  }

  void _change({int? year, int? month, int? day}) {
    final candidate = DateTime(
      year ?? _date.year,
      month ?? _date.month,
      math.min(
        day ?? _date.day,
        _daysInMonth(year ?? _date.year, month ?? _date.month),
      ),
    );
    setState(
      () => _date = _clampDate(candidate, widget.firstDate, widget.lastDate),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = MetroTheme.of(context);
    final pickerTheme = const MetroPickerThemeData(
      itemExtent: 44,
      visibleItemCount: 5,
      popupWidth: 520,
    ).merge(theme.pickerTheme).merge(MetroPickerTheme.maybeOf(context));
    final visibleFields = widget.fieldOrder.where(_isFieldVisible).toList();
    final wheelHeight = pickerTheme.itemExtent! * pickerTheme.visibleItemCount!;

    return MetroDialog(
      maxWidth: pickerTheme.popupWidth,
      semanticLabel: widget.title,
      title: Text(widget.title),
      content: SizedBox(
        height: wheelHeight,
        child: MetroFocusTraversalGroup(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < visibleFields.length; index += 1) ...[
                if (index != 0) const SizedBox(width: MetroSpacing.xs),
                Expanded(
                  flex: math.max(
                    1,
                    widget.fieldFlex?[visibleFields[index]] ??
                        (visibleFields[index] == MetroDatePickerField.month
                            ? 2
                            : 1),
                  ),
                  child: _wheelFor(
                    context,
                    visibleFields[index],
                    autofocus: index == 0,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        MetroButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.cancelLabel),
        ),
        MetroButton.accent(
          onPressed: () => Navigator.of(context).pop(_date),
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }

  Widget _wheelFor(
    BuildContext context,
    MetroDatePickerField field, {
    required bool autofocus,
  }) {
    return switch (field) {
      MetroDatePickerField.month => MetroPickerWheel(
        autofocus: autofocus,
        items: [
          for (final month in _months)
            widget.monthFormatter?.call(context, month) ?? _twoDigits(month),
        ],
        onSelectedIndexChanged: (index) => _change(month: _months[index]),
        selectedIndex: _months.indexOf(_date.month),
        semanticLabel: widget.monthLabel,
      ),
      MetroDatePickerField.day => MetroPickerWheel(
        autofocus: autofocus,
        items: [
          for (final day in _days)
            widget.dayFormatter?.call(context, day) ?? _twoDigits(day),
        ],
        onSelectedIndexChanged: (index) => _change(day: _days[index]),
        selectedIndex: _days.indexOf(_date.day),
        semanticLabel: widget.dayLabel,
      ),
      MetroDatePickerField.year => MetroPickerWheel(
        autofocus: autofocus,
        items: [
          for (final year in _years)
            widget.yearFormatter?.call(context, year) ?? '$year',
        ],
        onSelectedIndexChanged: (index) => _change(year: _years[index]),
        selectedIndex: _years.indexOf(_date.year),
        semanticLabel: widget.yearLabel,
      ),
    };
  }

  bool _isFieldVisible(MetroDatePickerField field) {
    return switch (field) {
      MetroDatePickerField.month => widget.showMonth,
      MetroDatePickerField.day => widget.showDay,
      MetroDatePickerField.year => widget.showYear,
    };
  }
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

DateTime _clampDate(DateTime date, DateTime first, DateTime last) {
  if (date.isBefore(first)) {
    return first;
  }
  if (date.isAfter(last)) {
    return last;
  }
  return date;
}

int _daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

String _twoDigits(int value) => value.toString().padLeft(2, '0');

List<MetroDatePickerField> _normalizedDateFieldOrder(
  Iterable<MetroDatePickerField> order,
) {
  final result = <MetroDatePickerField>[];
  for (final field in [...order, ...MetroDatePickerField.values]) {
    if (!result.contains(field)) {
      result.add(field);
    }
  }
  return result;
}
