import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../theme/metro_spacing.dart';
import '../../theme/metro_theme.dart';
import 'metro_dialog_theme.dart';

export 'metro_dialog_theme.dart';

/// Shows a flat Metro dialog without depending on Material widgets.
Future<T?> showMetroDialog<T extends Object?>({
  required BuildContext context,
  required WidgetBuilder builder,
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
  final dialogTheme = const MetroDialogThemeData(
    barrierColor: Color(0x99000000),
  ).merge(theme.dialogTheme).merge(MetroDialogTheme.maybeOf(context));
  final reduceMotion = _reduceMotion(context);
  final slideBegin = Directionality.of(context) == TextDirection.ltr
      ? const Offset(0.08, 0)
      : const Offset(-0.08, 0);

  return showGeneralDialog<T>(
    context: context,
    barrierColor:
        barrierColor ?? dialogTheme.barrierColor ?? const Color(0x99000000),
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel,
    requestFocus: requestFocus ?? true,
    routeSettings: routeSettings,
    transitionDuration: reduceMotion ? Duration.zero : theme.motion.normal,
    useRootNavigator: useRootNavigator,
    pageBuilder: (routeContext, animation, secondaryAnimation) {
      Widget child = Builder(builder: builder);
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
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: theme.motion.navigationCurve,
        reverseCurve: theme.motion.standardCurve,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: slideBegin,
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// A square, typography-led dialog surface for use with [showMetroDialog].
class MetroDialog extends StatelessWidget {
  const MetroDialog({
    this.title,
    this.content,
    this.actions = const <Widget>[],
    this.semanticLabel,
    this.backgroundColor,
    this.borderColor,
    this.padding,
    this.maxWidth,
    super.key,
  });

  final Widget? title;
  final Widget? content;
  final List<Widget> actions;
  final String? semanticLabel;
  final Color? backgroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final theme = MetroTheme.of(context);
    final defaults = MetroDialogThemeData(
      backgroundColor: theme.colors.background,
      borderColor: theme.colors.foreground,
      padding: const EdgeInsets.all(MetroSpacing.lg),
      maxWidth: 560,
      titleStyle: theme.typography.subheader,
      contentStyle: theme.typography.body,
    );
    final widgetOverrides = MetroDialogThemeData(
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      padding: padding,
      maxWidth: maxWidth,
    );
    final effectiveTheme = defaults
        .merge(theme.dialogTheme)
        .merge(MetroDialogTheme.maybeOf(context))
        .merge(widgetOverrides);

    Widget dialog = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: effectiveTheme.maxWidth!),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: effectiveTheme.backgroundColor,
          border: Border.all(color: effectiveTheme.borderColor!, width: 2),
        ),
        child: Padding(
          padding: effectiveTheme.padding!,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) ...[
                DefaultTextStyle.merge(
                  style: effectiveTheme.titleStyle,
                  child: title!,
                ),
                if (content != null || actions.isNotEmpty)
                  const SizedBox(height: MetroSpacing.md),
              ],
              if (content != null)
                Flexible(
                  child: SingleChildScrollView(
                    child: DefaultTextStyle.merge(
                      style: effectiveTheme.contentStyle,
                      child: content!,
                    ),
                  ),
                ),
              if (content != null && actions.isNotEmpty)
                const SizedBox(height: MetroSpacing.lg),
              if (actions.isNotEmpty)
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    runAlignment: WrapAlignment.end,
                    spacing: MetroSpacing.xs,
                    runSpacing: MetroSpacing.xs,
                    children: actions,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    dialog = SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(MetroSpacing.lg),
          child: dialog,
        ),
      ),
    );
    return Semantics(
      explicitChildNodes: true,
      label: semanticLabel,
      namesRoute: true,
      scopesRoute: true,
      child: dialog,
    );
  }
}

bool _reduceMotion(BuildContext context) {
  final mediaQuery = MediaQuery.maybeOf(context);
  return mediaQuery?.disableAnimations == true ||
      mediaQuery?.accessibleNavigation == true;
}
