@Tags(['golden'])
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_ui/metro_ui.dart';

import 'preview_support.dart';

void main() {
  setUpAll(loadPreviewFonts);

  for (final brightness in previewBrightnesses) {
    testWidgets('controls preview in ${brightness.name} theme', (tester) async {
      final theme = previewTheme(brightness);
      final boundaryKey = await pumpPreview(
        tester,
        brightness: brightness,
        child: _ControlsPreview(theme: theme),
      );
      await expectPreview(
        tester,
        boundaryKey,
        'preview_controls_${brightness.name}',
      );
    });
  }
}

class _ControlsPreview extends StatelessWidget {
  const _ControlsPreview({required this.theme});

  final MetroThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Metro controls', style: theme.typography.header),
        const SizedBox(height: MetroSpacing.xl),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: PreviewColumn(
                  spread: true,
                  children: [
                    _buttonsSection(),
                    _selectionSection(),
                    _slidersSection(),
                  ],
                ),
              ),
              const SizedBox(width: MetroSpacing.xxl),
              Expanded(
                child: PreviewColumn(
                  spread: true,
                  children: [
                    _textEntrySection(),
                    _numberAndSearchSection(),
                    _progressSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buttonsSection() {
    return PreviewSection(
      title: 'Buttons',
      description: 'Variant, state, and the compact icon form.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: MetroSpacing.sm,
            runSpacing: MetroSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              MetroButton(onPressed: () {}, child: const Text('STANDARD')),
              MetroButton.accent(onPressed: () {}, child: const Text('ACCENT')),
              const MetroButton(onPressed: null, child: Text('DISABLED')),
            ],
          ),
          const SizedBox(height: MetroSpacing.md),
          Row(
            children: [
              MetroIconButton(
                icon: const Text('+'),
                semanticLabel: 'Add',
                onPressed: () {},
              ),
              const SizedBox(width: MetroSpacing.sm),
              MetroIconButton(
                icon: const Text('*'),
                semanticLabel: 'Favorite',
                variant: MetroButtonVariant.accent,
                onPressed: () {},
              ),
              const SizedBox(width: MetroSpacing.md),
              MetroBackButton(onPressed: () {}),
              const SizedBox(width: MetroSpacing.xs),
              const MetroBackButton(hideWhenDisabled: false, onPressed: null),
            ],
          ),
        ],
      ),
    );
  }

  Widget _selectionSection() {
    return PreviewSection(
      title: 'Selection',
      description: 'Boolean, tri-state, exclusive, and immediate settings.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: MetroSpacing.lg,
            runSpacing: MetroSpacing.md,
            children: [
              MetroCheckBox(
                value: true,
                onChanged: (_) {},
                label: const Text('Checked'),
              ),
              MetroCheckBox(
                value: null,
                tristate: true,
                onChanged: (_) {},
                label: const Text('Mixed'),
              ),
              const MetroCheckBox(
                value: false,
                onChanged: null,
                label: Text('Unavailable'),
              ),
            ],
          ),
          const SizedBox(height: MetroSpacing.md),
          Wrap(
            spacing: MetroSpacing.lg,
            runSpacing: MetroSpacing.md,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              MetroRadioButton<int>(
                value: 1,
                groupValue: 1,
                onChanged: (_) {},
                label: const Text('Selected'),
              ),
              MetroRadioButton<int>(
                value: 2,
                groupValue: 1,
                onChanged: (_) {},
                label: const Text('Unselected'),
              ),
              MetroToggleSwitch(
                value: true,
                onChanged: (_) {},
                label: const Text('Enabled'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _slidersSection() {
    return const PreviewSection(
      title: 'Sliders',
      description: 'Continuous and two-thumb range input.',
      child: Column(
        children: [
          MetroSlider(value: 0.4, onChanged: _ignoreDouble),
          SizedBox(height: MetroSpacing.lg),
          MetroRangeSlider(
            values: MetroRangeValues(0.25, 0.7),
            onChanged: _ignoreRange,
          ),
          SizedBox(height: MetroSpacing.lg),
          MetroSlider(
            value: 0.6,
            divisions: 5,
            tickPlacement: MetroSliderTickPlacement.both,
            onChanged: _ignoreDouble,
          ),
        ],
      ),
    );
  }

  Widget _textEntrySection() {
    return PreviewSection(
      title: 'Text entry',
      description: 'One shared entry-box surface across input families.',
      child: Column(
        children: [
          const MetroTextField(
            label: Text('Account'),
            placeholder: 'name@example.com',
          ),
          const SizedBox(height: MetroSpacing.md),
          MetroTextFormField(
            label: const Text('Password'),
            placeholder: 'Eight characters minimum',
            validator: (value) =>
                (value?.length ?? 0) < 8 ? 'Password is too short' : null,
          ),
          const SizedBox(height: MetroSpacing.md),
          const MetroComboBox<String>(
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
        ],
      ),
    );
  }

  Widget _numberAndSearchSection() {
    return const PreviewSection(
      title: 'Number and search',
      description: 'Stepping input and local suggestions.',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: MetroNumberBox<int>(
                  value: 12,
                  min: 0,
                  max: 99,
                  onChanged: _ignoreInt,
                  semanticLabel: 'Quantity',
                ),
              ),
              SizedBox(width: MetroSpacing.sm),
              Expanded(
                child: MetroNumberBox<double>(
                  value: 0.75,
                  min: 0,
                  max: 1,
                  onChanged: _ignoreDoubleOrNull,
                  semanticLabel: 'Opacity',
                ),
              ),
            ],
          ),
          SizedBox(height: MetroSpacing.md),
          MetroSearchBox<String>(
            placeholder: 'Search controls',
            semanticLabel: 'Search the controls preview',
            items: [
              MetroSearchBoxItem(
                value: 'tiles',
                queryText: 'Tiles',
                child: Text('Tiles'),
              ),
            ],
            onSubmitted: _ignoreQuery,
          ),
        ],
      ),
    );
  }

  Widget _progressSection() {
    return const PreviewSection(
      title: 'Progress',
      description: 'Linear and circular, determinate.',
      child: Row(
        children: [
          Expanded(child: MetroProgressBar(value: 0.64)),
          SizedBox(width: MetroSpacing.lg),
          MetroProgressRing(value: 0.68, semanticLabel: '68 percent'),
          SizedBox(width: MetroSpacing.md),
          MetroProgressRing(value: 0.25, semanticLabel: '25 percent'),
        ],
      ),
    );
  }
}

void _ignoreString(String? value) {}

void _ignoreDouble(double value) {}

void _ignoreRange(MetroRangeValues values) {}

void _ignoreQuery(String query) {}

void _ignoreInt(int? value) {}

void _ignoreDoubleOrNull(double? value) {}
