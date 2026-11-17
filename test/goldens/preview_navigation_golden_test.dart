@Tags(['golden'])
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_ui/metro_ui.dart';

import 'preview_support.dart';

void main() {
  setUpAll(loadPreviewFonts);

  for (final brightness in previewBrightnesses) {
    testWidgets('navigation preview in ${brightness.name} theme', (
      tester,
    ) async {
      final theme = previewTheme(brightness);
      final boundaryKey = await pumpPreview(
        tester,
        brightness: brightness,
        child: _NavigationPreview(theme: theme),
        // The command bar belongs to the page edge, not to the padded body.
        padded: false,
      );
      await expectPreview(
        tester,
        boundaryKey,
        'preview_navigation_${brightness.name}',
      );
    });
  }
}

class _NavigationPreview extends StatelessWidget {
  const _NavigationPreview({required this.theme});

  final MetroThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(previewPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Metro navigation', style: theme.typography.header),
                      const SizedBox(height: MetroSpacing.xl),
                      _pivotSection(),
                      const Spacer(),
                      _flipViewSection(),
                    ],
                  ),
                ),
                const SizedBox(width: MetroSpacing.xl),
                SizedBox(
                  width: 346,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _flyoutSection(),
                      const Spacer(),
                      _dialogSection(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        MetroCommandBar(
          leading: const Text('COMMANDS'),
          commands: [
            MetroCommandButton(
              icon: const Text('+'),
              label: const Text('Add'),
              onPressed: () {},
            ),
            MetroCommandButton(
              icon: const Text('*'),
              label: const Text('Favorite'),
              selected: true,
              onPressed: () {},
            ),
            const MetroCommandButton(
              icon: Text('x'),
              label: Text('Disabled'),
              onPressed: null,
            ),
            MetroCommandButton(
              icon: const Text('-'),
              label: const Text('Remove'),
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _pivotSection() {
    return PreviewSection(
      title: 'Pivot',
      description: 'Horizontal section navigation with a directional swap.',
      child: SizedBox(
        height: 136,
        child: MetroPivot(
          items: const [
            MetroPivotItem(
              header: Text('RECENT'),
              child: Align(
                alignment: AlignmentDirectional.topStart,
                child: Text('Recently used surfaces'),
              ),
            ),
            MetroPivotItem(
              header: Text('FAVORITES'),
              child: Align(
                alignment: AlignmentDirectional.topStart,
                child: Text('Pinned surfaces'),
              ),
            ),
            MetroPivotItem(
              header: Text('SHARED'),
              child: Align(
                alignment: AlignmentDirectional.topStart,
                child: Text('Shared with me'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _flipViewSection() {
    return PreviewSection(
      title: 'Flip view',
      child: SizedBox(
        height: 104,
        child: MetroFlipView(
          showIndicators: true,
          navigationVisibility: MetroFlipViewNavigationVisibility.always,
          items: const [
            MetroFlipViewItem(
              banner: Text('MAIL'),
              child: ColoredBox(
                color: MetroColors.cobalt,
                child: Center(
                  child: Text(
                    '3 unread',
                    style: TextStyle(color: Color(0xFFFFFFFF)),
                  ),
                ),
              ),
            ),
            MetroFlipViewItem(
              banner: Text('PHOTOS'),
              child: ColoredBox(
                color: MetroColors.magenta,
                child: Center(
                  child: Text(
                    '12 new',
                    style: TextStyle(color: Color(0xFFFFFFFF)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _flyoutSection() {
    return PreviewSection(
      title: 'Flyout',
      description: 'Edge-docked settings surface on its own outline.',
      // The panel asks for the full height of its slot, the way an edge-docked
      // flyout does in an application, so the slot has to be bounded.
      child: SizedBox(
        height: 220,
        child: MetroFlyout(
          title: const Text('Settings'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Experience', style: theme.typography.title),
              const SizedBox(height: MetroSpacing.md),
              MetroToggleSwitch(
                value: true,
                onChanged: (_) {},
                label: const Text('Notifications'),
              ),
              const SizedBox(height: MetroSpacing.md),
              MetroCheckBox(
                value: false,
                onChanged: (_) {},
                label: const Text('Sync settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dialogSection() {
    return PreviewSection(
      title: 'Dialog',
      child: MetroDialog(
        title: const Text('Delete item?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          MetroButton(onPressed: () {}, child: const Text('CANCEL')),
          MetroButton.accent(onPressed: () {}, child: const Text('DELETE')),
        ],
      ),
    );
  }
}
