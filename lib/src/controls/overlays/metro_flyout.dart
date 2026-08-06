import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../theme/metro_color_scheme.dart';
import '../../theme/metro_spacing.dart';
import '../../theme/metro_theme.dart';
import 'metro_flyout_theme.dart';

export 'metro_flyout_theme.dart';

/// Logical screen edge used by [showMetroFlyout].
enum MetroFlyoutSide { start, end }

/// Shows a full-height Metro panel from a logical screen edge.
Future<T?> showMetroFlyout<T extends Object?>({
  required BuildContext context,
  required WidgetBuilder builder,
  MetroFlyoutSide side = MetroFlyoutSide.end,
  bool barrierDismissible = false,
  String? barrierLabel,
  Color? barrierColor,
  bool dismissOnEscape = true,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  bool? requestFocus,
}) {
  assert(!barrierDismissible || barrierLabel != null);
  final navigator = Navigator.of(context, rootNavigator: useRootNavigator);
  final themes = InheritedTheme.capture(from: context, to: navigator.context);
  final theme = MetroTheme.of(context);
  final flyoutTheme = const MetroFlyoutThemeData(
    barrierColor: Color(0x66000000),
  ).merge(theme.flyoutTheme).merge(MetroFlyoutTheme.maybeOf(context));
  final reduceMotion = _reduceMotion(context);
  final textDirection = Directionality.of(context);
  final fromRight = switch ((side, textDirection)) {
    (MetroFlyoutSide.end, TextDirection.ltr) ||
    (MetroFlyoutSide.start, TextDirection.rtl) => true,
    _ => false,
  };
  final alignment = side == MetroFlyoutSide.end
      ? AlignmentDirectional.centerEnd
      : AlignmentDirectional.centerStart;
  final slideBegin = Offset(fromRight ? 1 : -1, 0);

  return showGeneralDialog<T>(
    context: context,
    barrierColor:
        barrierColor ?? flyoutTheme.barrierColor ?? const Color(0x66000000),
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel,
    requestFocus: requestFocus ?? true,
    routeSettings: routeSettings,
    transitionDuration: reduceMotion ? Duration.zero : theme.motion.panel,
    useRootNavigator: useRootNavigator,
    pageBuilder: (routeContext, animation, secondaryAnimation) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: theme.motion.standardCurve,
        reverseCurve: theme.motion.standardCurve,
      );
      final panel = SlideTransition(
        key: const ValueKey<String>('metro-flyout-slide'),
        position: Tween<Offset>(
          begin: slideBegin,
          end: Offset.zero,
        ).animate(curved),
        child: Builder(builder: builder),
      );
      Widget child = SafeArea(
        child: Align(alignment: alignment, child: panel),
      );
      if (dismissOnEscape) {
        child = Shortcuts(
          shortcuts: const <ShortcutActivator, Intent>{
            SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
          },
          child: Actions(
            actions: <Type, Action<Intent>>{
              DismissIntent: CallbackAction<DismissIntent>(
                onInvoke: (intent) {
                  Navigator.of(routeContext).maybePop();
                  return null;
                },
              ),
            },
            child: Focus(autofocus: true, skipTraversal: true, child: child),
          ),
        );
      }
      return themes.wrap(child);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) => child,
  );
}

/// Content surface for a Windows 8-style edge flyout.
class MetroFlyout extends StatelessWidget {
  const MetroFlyout({
    required this.child,
    this.title,
    this.leading,
    this.actions = const <Widget>[],
    this.semanticLabel,
    this.backgroundColor,
    this.headerColor,
    this.width,
    this.headerPadding,
    this.contentPadding,
    super.key,
  }) : assert(width == null || width > 0);

  final Widget child;
  final Widget? title;
  final Widget? leading;
  final List<Widget> actions;
  final String? semanticLabel;
  final Color? backgroundColor;
  final Color? headerColor;
  final double? width;
  final EdgeInsetsGeometry? headerPadding;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    final theme = MetroTheme.of(context);
    final defaults = MetroFlyoutThemeData(
      backgroundColor: theme.colors.background,
      headerColor: theme.colors.accent,
      width: 346,
      headerPadding: const EdgeInsets.fromLTRB(40, 32, 40, 16),
      contentPadding: const EdgeInsets.fromLTRB(40, 33, 40, 40),
      titleStyle: theme.typography.subheader.copyWith(
        color: theme.colors.onAccent,
      ),
      contentStyle: theme.typography.body,
    );
    final widgetOverrides = MetroFlyoutThemeData(
      backgroundColor: backgroundColor,
      headerColor: headerColor,
      width: width,
      headerPadding: headerPadding,
      contentPadding: contentPadding,
    );
    final effectiveTheme = defaults
        .merge(theme.flyoutTheme)
        .merge(MetroFlyoutTheme.maybeOf(context))
        .merge(widgetOverrides);
    final effectiveHeaderColor = effectiveTheme.headerColor!;
    final headerForeground = MetroColorScheme.idealForegroundFor(
      effectiveHeaderColor,
    );

    Widget panel = SizedBox(
      width: effectiveTheme.width,
      height: double.infinity,
      child: ColoredBox(
        color: effectiveTheme.backgroundColor!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null || leading != null || actions.isNotEmpty)
              ColoredBox(
                color: effectiveHeaderColor,
                child: Padding(
                  padding: effectiveTheme.headerPadding!,
                  child: IconTheme.merge(
                    data: IconThemeData(color: headerForeground),
                    child: DefaultTextStyle.merge(
                      style: effectiveTheme.titleStyle?.copyWith(
                        color: headerForeground,
                      ),
                      child: Row(
                        children: [
                          if (leading != null) ...[
                            leading!,
                            if (title != null)
                              const SizedBox(width: MetroSpacing.sm),
                          ],
                          if (title != null) Expanded(child: title!),
                          if (title == null) const Spacer(),
                          if (actions.isNotEmpty) ...[
                            const SizedBox(width: MetroSpacing.sm),
                            Wrap(spacing: MetroSpacing.xs, children: actions),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: effectiveTheme.contentPadding!,
                child: DefaultTextStyle.merge(
                  style: effectiveTheme.contentStyle,
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    panel = Semantics(
      explicitChildNodes: true,
      label: semanticLabel,
      namesRoute: true,
      scopesRoute: true,
      child: panel,
    );
    return panel;
  }
}

bool _reduceMotion(BuildContext context) {
  final mediaQuery = MediaQuery.maybeOf(context);
  return mediaQuery?.disableAnimations == true ||
      mediaQuery?.accessibleNavigation == true;
}
