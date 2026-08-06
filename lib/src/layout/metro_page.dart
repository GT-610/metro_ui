import 'package:flutter/widgets.dart';

import '../theme/metro_spacing.dart';
import '../theme/metro_theme.dart';

/// A Metro page surface with generous whitespace and an optional large title.
class MetroPage extends StatelessWidget {
  const MetroPage({
    required this.child,
    this.title,
    this.leading,
    this.actions = const <Widget>[],
    this.padding = const EdgeInsets.all(MetroSpacing.lg),
    this.scrollable = true,
    this.safeArea = true,
    this.bottomBar,
    super.key,
  });

  final Widget child;
  final Widget? title;
  final Widget? leading;
  final List<Widget> actions;
  final EdgeInsetsGeometry padding;
  final bool scrollable;
  final bool safeArea;
  final Widget? bottomBar;

  @override
  Widget build(BuildContext context) {
    final theme = MetroTheme.of(context);
    Widget contents = Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null || title != null || actions.isNotEmpty) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (leading != null) ...[
                  leading!,
                  if (title != null) const SizedBox(width: 20),
                ],
                if (title != null)
                  Expanded(
                    child: DefaultTextStyle.merge(
                      style: theme.typography.hero,
                      child: title!,
                    ),
                  )
                else
                  const Spacer(),
                if (actions.isNotEmpty) ...[
                  const SizedBox(width: MetroSpacing.md),
                  Wrap(spacing: MetroSpacing.xs, children: actions),
                ],
              ],
            ),
            const SizedBox(height: MetroSpacing.lg),
          ],
          if (scrollable)
            Expanded(child: SingleChildScrollView(child: child))
          else
            Expanded(child: child),
        ],
      ),
    );
    if (safeArea) {
      contents = SafeArea(bottom: bottomBar == null, child: contents);
    }
    if (bottomBar != null) {
      Widget bar = bottomBar!;
      if (safeArea) {
        bar = SafeArea(top: false, child: bar);
      }
      contents = Column(
        children: [
          Expanded(child: contents),
          bar,
        ],
      );
    }
    return ColoredBox(color: theme.colors.background, child: contents);
  }
}
