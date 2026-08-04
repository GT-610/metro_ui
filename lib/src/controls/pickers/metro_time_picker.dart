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

/// Hour representation used by a Metro time picker.
enum MetroHourFormat { twelveHour, twentyFourHour }

/// Day period used by a twelve-hour Metro time picker.
enum MetroDayPeriod { am, pm }

/// Immutable wall-clock time independent of a calendar date or time zone.
@immutable
class MetroTime {
  const MetroTime({required this.hour, required this.minute})
    : assert(hour >= 0 && hour < 24),
      assert(minute >= 0 && minute < 60);

  factory MetroTime.now() {
    final now = DateTime.now();
    return MetroTime(hour: now.hour, minute: now.minute);
  }

  final int hour;
  final int minute;

  MetroTime copyWith({int? hour, int? minute}) {
    return MetroTime(hour: hour ?? this.hour, minute: minute ?? this.minute);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MetroTime && other.hour == hour && other.minute == minute;
  }

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  String toString() =>
      'MetroTime(${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')})';
}

/// Formats an hour or minute value in a Metro time picker.
typedef MetroTimePartFormatter =
    String Function(BuildContext context, int value);

/// Formats an AM/PM period in a Metro time picker.
typedef MetroDayPeriodFormatter =
    String Function(BuildContext context, MetroDayPeriod period);

/// Shows a Metro time dialog and returns the confirmed wall-clock time.
///
/// Dismissing or cancelling the dialog returns null. The initial minute is
/// normalized to [minuteIncrement].
Future<MetroTime?> showMetroTimePicker({
  required BuildContext context,
  required MetroTime initialTime,
  MetroHourFormat hourFormat = MetroHourFormat.twelveHour,
  int minuteIncrement = 1,
  MetroTimePartFormatter? hourFormatter,
  MetroTimePartFormatter? minuteFormatter,
  MetroDayPeriodFormatter? periodFormatter,
  String? title,
  String? hourLabel,
  String? minuteLabel,
  String? periodLabel,
  String? confirmLabel,
  String? cancelLabel,
  String? anteMeridiemLabel,
  String? postMeridiemLabel,
}) {
  final localizations = MetroLocalizations.of(context);
  assert(minuteIncrement > 0 && minuteIncrement <= 60);
  if (minuteIncrement <= 0 || minuteIncrement > 60) {
    throw ArgumentError.value(
      minuteIncrement,
      'minuteIncrement',
      'Must be between 1 and 60.',
    );
  }
  return showMetroDialog<MetroTime>(
    context: context,
    builder: (dialogContext) {
      return _MetroTimePickerDialog(
        anteMeridiemLabel: anteMeridiemLabel ?? localizations.anteMeridiemLabel,
        cancelLabel: cancelLabel ?? localizations.cancelLabel,
        confirmLabel: confirmLabel ?? localizations.confirmLabel,
        hourFormat: hourFormat,
        hourFormatter: hourFormatter,
        hourLabel: hourLabel ?? localizations.hourLabel,
        initialTime: _normalizeMinute(initialTime, minuteIncrement),
        minuteFormatter: minuteFormatter,
        minuteIncrement: minuteIncrement,
        minuteLabel: minuteLabel ?? localizations.minuteLabel,
        periodFormatter: periodFormatter,
        periodLabel: periodLabel ?? localizations.periodLabel,
        postMeridiemLabel: postMeridiemLabel ?? localizations.postMeridiemLabel,
        title: title ?? localizations.selectTimeTitle,
      );
    },
  );
}

/// A segmented Modern UI time field that opens scrolling time columns.
class MetroTimePicker extends StatefulWidget {
  const MetroTimePicker({
    required this.selected,
    required this.onChanged,
    this.currentTime,
    this.hourFormat = MetroHourFormat.twelveHour,
    this.minuteIncrement = 1,
    this.hourFormatter,
    this.minuteFormatter,
    this.periodFormatter,
    this.title,
    this.hourLabel,
    this.minuteLabel,
    this.periodLabel,
    this.confirmLabel,
    this.cancelLabel,
    this.anteMeridiemLabel,
    this.postMeridiemLabel,
    this.onCancel,
    this.style,
    this.autofocus = false,
    this.focusNode,
    this.semanticLabel,
    super.key,
  }) : assert(minuteIncrement > 0 && minuteIncrement <= 60);

  final MetroTime? selected;
  final ValueChanged<MetroTime>? onChanged;
  final MetroTime? currentTime;
  final MetroHourFormat hourFormat;
  final int minuteIncrement;
  final MetroTimePartFormatter? hourFormatter;
  final MetroTimePartFormatter? minuteFormatter;
  final MetroDayPeriodFormatter? periodFormatter;
  final String? title;
  final String? hourLabel;
  final String? minuteLabel;
  final String? periodLabel;
  final String? confirmLabel;
  final String? cancelLabel;
  final String? anteMeridiemLabel;
  final String? postMeridiemLabel;
  final VoidCallback? onCancel;
  final MetroPickerStyle? style;
  final bool autofocus;
  final FocusNode? focusNode;
  final String? semanticLabel;

  @override
  State<MetroTimePicker> createState() => MetroTimePickerState();
}

/// State exposed so applications can open a keyed [MetroTimePicker].
class MetroTimePickerState extends State<MetroTimePicker> {
  Future<void> open() async {
    if (widget.onChanged == null) {
      return;
    }
    final result = await showMetroTimePicker(
      context: context,
      initialTime: widget.selected ?? widget.currentTime ?? MetroTime.now(),
      hourFormat: widget.hourFormat,
      minuteIncrement: widget.minuteIncrement,
      hourFormatter: widget.hourFormatter,
      minuteFormatter: widget.minuteFormatter,
      periodFormatter: widget.periodFormatter,
      title: widget.title,
      hourLabel: widget.hourLabel,
      minuteLabel: widget.minuteLabel,
      periodLabel: widget.periodLabel,
      confirmLabel: widget.confirmLabel,
      cancelLabel: widget.cancelLabel,
      anteMeridiemLabel: widget.anteMeridiemLabel,
      postMeridiemLabel: widget.postMeridiemLabel,
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
    final localizations = MetroLocalizations.of(context);
    final selected = widget.selected;
    final values = selected == null
        ? <String>[
            widget.hourLabel ?? localizations.hourLabel,
            widget.minuteLabel ?? localizations.minuteLabel,
            if (widget.hourFormat == MetroHourFormat.twelveHour)
              widget.periodLabel ?? localizations.periodLabel,
          ]
        : _formattedValues(context, selected);
    final semanticLabel =
        widget.semanticLabel ??
        localizations.timePickerSemanticLabel(
          selected == null ? const [] : values,
        );
    return MetroPickerField(
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
      onPressed: widget.onChanged == null ? null : open,
      semanticLabel: semanticLabel,
      style: widget.style,
      values: values,
    );
  }

  List<String> _formattedValues(BuildContext context, MetroTime time) {
    final localizations = MetroLocalizations.of(context);
    final minute =
        widget.minuteFormatter?.call(context, time.minute) ??
        _twoDigits(time.minute);
    if (widget.hourFormat == MetroHourFormat.twentyFourHour) {
      final hour =
          widget.hourFormatter?.call(context, time.hour) ??
          _twoDigits(time.hour);
      return [hour, minute];
    }
    final displayHour = _displayHour(time.hour);
    final hour =
        widget.hourFormatter?.call(context, displayHour) ?? '$displayHour';
    final period = time.hour >= 12 ? MetroDayPeriod.pm : MetroDayPeriod.am;
    return [
      hour,
      minute,
      widget.periodFormatter?.call(context, period) ??
          (period == MetroDayPeriod.am
              ? widget.anteMeridiemLabel ?? localizations.anteMeridiemLabel
              : widget.postMeridiemLabel ?? localizations.postMeridiemLabel),
    ];
  }
}

class _MetroTimePickerDialog extends StatefulWidget {
  const _MetroTimePickerDialog({
    required this.anteMeridiemLabel,
    required this.initialTime,
    required this.hourFormat,
    required this.minuteIncrement,
    required this.hourFormatter,
    required this.minuteFormatter,
    required this.periodFormatter,
    required this.title,
    required this.hourLabel,
    required this.minuteLabel,
    required this.periodLabel,
    required this.postMeridiemLabel,
    required this.confirmLabel,
    required this.cancelLabel,
  });

  final String anteMeridiemLabel;
  final MetroTime initialTime;
  final MetroHourFormat hourFormat;
  final int minuteIncrement;
  final MetroTimePartFormatter? hourFormatter;
  final MetroTimePartFormatter? minuteFormatter;
  final MetroDayPeriodFormatter? periodFormatter;
  final String title;
  final String hourLabel;
  final String minuteLabel;
  final String periodLabel;
  final String postMeridiemLabel;
  final String confirmLabel;
  final String cancelLabel;

  @override
  State<_MetroTimePickerDialog> createState() => _MetroTimePickerDialogState();
}

class _MetroTimePickerDialogState extends State<_MetroTimePickerDialog> {
  late MetroTime _time = widget.initialTime;

  List<int> get _hours => widget.hourFormat == MetroHourFormat.twentyFourHour
      ? List<int>.generate(24, (index) => index)
      : List<int>.generate(12, (index) => index + 1);

  List<int> get _minutes => <int>[
    for (var minute = 0; minute < 60; minute += widget.minuteIncrement) minute,
  ];

  MetroDayPeriod get _period =>
      _time.hour >= 12 ? MetroDayPeriod.pm : MetroDayPeriod.am;

  void _setHour(int selectedHour) {
    final hour = widget.hourFormat == MetroHourFormat.twentyFourHour
        ? selectedHour
        : _hourFromDisplay(selectedHour, _period);
    setState(() => _time = _time.copyWith(hour: hour));
  }

  void _setPeriod(MetroDayPeriod period) {
    setState(
      () => _time = _time.copyWith(
        hour: _hourFromDisplay(_displayHour(_time.hour), period),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = MetroTheme.of(context);
    final pickerTheme = const MetroPickerThemeData(
      itemExtent: 44,
      visibleItemCount: 5,
      popupWidth: 440,
    ).merge(theme.pickerTheme).merge(MetroPickerTheme.maybeOf(context));
    final wheelHeight = pickerTheme.itemExtent! * pickerTheme.visibleItemCount!;
    final twelveHour = widget.hourFormat == MetroHourFormat.twelveHour;

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
              Expanded(child: _hourWheel(context)),
              const SizedBox(width: MetroSpacing.xs),
              Expanded(child: _minuteWheel(context)),
              if (twelveHour) ...[
                const SizedBox(width: MetroSpacing.xs),
                Expanded(child: _periodWheel(context)),
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
          onPressed: () => Navigator.of(context).pop(_time),
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }

  Widget _hourWheel(BuildContext context) {
    final selectedHour = widget.hourFormat == MetroHourFormat.twentyFourHour
        ? _time.hour
        : _displayHour(_time.hour);
    return MetroPickerWheel(
      autofocus: true,
      items: [
        for (final hour in _hours)
          widget.hourFormatter?.call(context, hour) ??
              (widget.hourFormat == MetroHourFormat.twentyFourHour
                  ? _twoDigits(hour)
                  : '$hour'),
      ],
      onSelectedIndexChanged: (index) => _setHour(_hours[index]),
      selectedIndex: _hours.indexOf(selectedHour),
      semanticLabel: widget.hourLabel,
    );
  }

  Widget _minuteWheel(BuildContext context) {
    return MetroPickerWheel(
      items: [
        for (final minute in _minutes)
          widget.minuteFormatter?.call(context, minute) ?? _twoDigits(minute),
      ],
      onSelectedIndexChanged: (index) {
        setState(() => _time = _time.copyWith(minute: _minutes[index]));
      },
      selectedIndex: _minutes.indexOf(_time.minute),
      semanticLabel: widget.minuteLabel,
    );
  }

  Widget _periodWheel(BuildContext context) {
    const periods = MetroDayPeriod.values;
    return MetroPickerWheel(
      items: [
        for (final period in periods)
          widget.periodFormatter?.call(context, period) ??
              (period == MetroDayPeriod.am
                  ? widget.anteMeridiemLabel
                  : widget.postMeridiemLabel),
      ],
      onSelectedIndexChanged: (index) => _setPeriod(periods[index]),
      selectedIndex: periods.indexOf(_period),
      semanticLabel: widget.periodLabel,
    );
  }
}

MetroTime _normalizeMinute(MetroTime time, int increment) {
  final minutes = <int>[
    for (var minute = 0; minute < 60; minute += increment) minute,
  ];
  final nearest = minutes.reduce(
    (previous, current) =>
        (current - time.minute).abs() < (previous - time.minute).abs()
        ? current
        : previous,
  );
  return time.copyWith(minute: nearest);
}

int _displayHour(int hour) {
  final value = hour % 12;
  return value == 0 ? 12 : value;
}

int _hourFromDisplay(int hour, MetroDayPeriod period) {
  final base = hour == 12 ? 0 : hour;
  return period == MetroDayPeriod.pm ? base + 12 : base;
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');
