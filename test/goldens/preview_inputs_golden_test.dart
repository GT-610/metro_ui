@Tags(['golden'])
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_ui/metro_ui.dart';

import 'preview_support.dart';

void main() {
  setUpAll(loadPreviewFonts);

  for (final brightness in previewBrightnesses) {
    testWidgets('inputs preview in ${brightness.name} theme', (tester) async {
      final theme = previewTheme(brightness);
      final boundaryKey = await pumpPreview(
        tester,
        brightness: brightness,
        child: _InputsPreview(theme: theme),
      );
      await expectPreview(
        tester,
        boundaryKey,
        'preview_inputs_${brightness.name}',
      );
    });
  }
}

class _InputsPreview extends StatelessWidget {
  const _InputsPreview({required this.theme});

  final MetroThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Metro inputs and pickers', style: theme.typography.header),
        const SizedBox(height: MetroSpacing.xl),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _leftColumn()),
              const SizedBox(width: MetroSpacing.xxl),
              Expanded(child: _middleColumn()),
              const SizedBox(width: MetroSpacing.xxl),
              Expanded(child: _rightColumn()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _leftColumn() {
    return PreviewColumn(
      children: [_textEntrySection(), _comboBoxSection(), _validationSection()],
    );
  }

  Widget _middleColumn() {
    return PreviewColumn(children: [_searchSection(), _numberSection()]);
  }

  Widget _rightColumn() {
    return PreviewColumn(children: [_pickersSection(), _sliderSection()]);
  }

  Widget _textEntrySection() {
    return const PreviewSection(
      title: 'Text entry',
      description: 'The shared 28 pixel entry box.',
      child: Column(
        children: [
          MetroTextField(
            label: Text('Account'),
            placeholder: 'name@example.com',
          ),
          SizedBox(height: MetroSpacing.md),
          MetroTextField(
            label: Text('Password'),
            placeholder: 'Enter a password',
          ),
        ],
      ),
    );
  }

  Widget _comboBoxSection() {
    return const PreviewSection(
      title: 'Combo box',
      description: 'Single choice from a compact popup list.',
      child: Column(
        children: [
          MetroComboBox<String>(
            value: 'metro',
            items: [
              MetroComboBoxItem(value: 'metro', child: Text('Metro selection')),
              MetroComboBoxItem(
                value: 'modern',
                child: Text('Modern selection'),
              ),
            ],
            onChanged: _ignoreString,
          ),
          SizedBox(height: MetroSpacing.md),
          MetroComboBox<String>(
            disabledPlaceholder: Text('Unavailable'),
            items: [
              MetroComboBoxItem(value: 'disabled', child: Text('Disabled')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _validationSection() {
    return PreviewSection(
      title: 'Validation',
      description: 'Supporting text and a field-level error.',
      child: MetroTextFormField(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        initialValue: 'ab',
        label: const Text('Display name'),
        supportingText: const Text('Four characters or more'),
        validator: (value) =>
            (value?.length ?? 0) < 4 ? 'Use four characters or more' : null,
      ),
    );
  }

  Widget _searchSection() {
    return const PreviewSection(
      title: 'Search',
      description: 'Suggestions filter as the query changes.',
      child: Column(
        children: [
          MetroSearchBox<String>(
            placeholder: 'Search controls',
            semanticLabel: 'Search the controls preview',
            items: [
              MetroSearchBoxItem(
                value: 'tiles',
                queryText: 'Tiles',
                child: Text('Tiles'),
              ),
              MetroSearchBoxItem(
                value: 'flyout',
                queryText: 'Flyout',
                child: Text('Flyout'),
              ),
            ],
            onSubmitted: _ignoreQuery,
          ),
          SizedBox(height: MetroSpacing.md),
          MetroSearchBox<String>(
            placeholder: 'Unavailable',
            enabled: false,
            items: [],
          ),
        ],
      ),
    );
  }

  Widget _numberSection() {
    return const PreviewSection(
      title: 'Number box',
      description: 'Stepping, clamping, and decimal places.',
      child: Column(
        children: [
          MetroNumberBox<int>(
            value: 12,
            min: 0,
            max: 99,
            onChanged: _ignoreInt,
            semanticLabel: 'Quantity',
          ),
          SizedBox(height: MetroSpacing.md),
          MetroNumberBox<double>(
            value: 0.75,
            min: 0,
            max: 1,
            onChanged: _ignoreDoubleOrNull,
            semanticLabel: 'Opacity',
          ),
          SizedBox(height: MetroSpacing.md),
          MetroNumberBox<int>(
            value: null,
            placeholder: 'Empty',
            onChanged: _ignoreInt,
            semanticLabel: 'Optional quantity',
          ),
        ],
      ),
    );
  }

  Widget _pickersSection() {
    return PreviewSection(
      title: 'Date and time',
      description: 'Segmented fields, one entry box per part.',
      child: Column(
        children: [
          MetroDatePicker(
            selected: DateTime(2026, 11, 17),
            onChanged: (_) {},
            semanticLabel: 'Target date',
          ),
          const SizedBox(height: MetroSpacing.md),
          MetroDatePicker(
            selected: null,
            onChanged: (_) {},
            semanticLabel: 'Unset date',
          ),
          const SizedBox(height: MetroSpacing.md),
          MetroTimePicker(
            selected: const MetroTime(hour: 9, minute: 30),
            onChanged: (_) {},
            semanticLabel: 'Target time',
          ),
          const SizedBox(height: MetroSpacing.md),
          MetroTimePicker(
            selected: const MetroTime(hour: 17, minute: 0),
            hourFormat: MetroHourFormat.twentyFourHour,
            onChanged: (_) {},
            semanticLabel: 'End time',
          ),
        ],
      ),
    );
  }

  Widget _sliderSection() {
    return const PreviewSection(
      title: 'Sliders',
      description: 'Continuous and two-thumb range input.',
      child: Column(
        children: [
          MetroSlider(value: 0.4, onChanged: _ignoreValue),
          SizedBox(height: MetroSpacing.md),
          MetroRangeSlider(
            values: MetroRangeValues(0.25, 0.7),
            onChanged: _ignoreRange,
          ),
          SizedBox(height: MetroSpacing.md),
          MetroSlider(
            value: 0.6,
            divisions: 5,
            tickPlacement: MetroSliderTickPlacement.both,
            onChanged: _ignoreValue,
          ),
        ],
      ),
    );
  }
}

void _ignoreQuery(String query) {}

void _ignoreString(String? value) {}

void _ignoreValue(double value) {}

void _ignoreRange(MetroRangeValues values) {}

void _ignoreInt(int? value) {}

void _ignoreDoubleOrNull(double? value) {}
