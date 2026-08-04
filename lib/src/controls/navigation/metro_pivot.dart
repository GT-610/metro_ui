import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/metro_interactive.dart';
import '../../theme/metro_spacing.dart';
import '../../theme/metro_theme.dart';

/// One header/content pair displayed by a [MetroPivot].
@immutable
class MetroPivotItem {
  const MetroPivotItem({required this.header, required this.child});

  final Widget header;
  final Widget child;
}

/// Typography and spacing values used by [MetroPivot].
@immutable
class MetroPivotThemeData {
  const MetroPivotThemeData({
    this.headerStyle,
    this.selectedHeaderStyle,
    double? headerSpacing,
    double? contentSpacing,
  }) : assert(headerSpacing == null || headerSpacing >= 0),
       assert(contentSpacing == null || contentSpacing >= 0),
       _headerSpacing = headerSpacing,
       _contentSpacing = contentSpacing;

  final TextStyle? headerStyle;
  final TextStyle? selectedHeaderStyle;
  final double? _headerSpacing;
  final double? _contentSpacing;

  double get headerSpacing => _headerSpacing ?? MetroSpacing.lg;
  double get contentSpacing => _contentSpacing ?? MetroSpacing.md;

  MetroPivotThemeData copyWith({
    TextStyle? headerStyle,
    TextStyle? selectedHeaderStyle,
    double? headerSpacing,
    double? contentSpacing,
  }) {
    return MetroPivotThemeData(
      headerStyle: headerStyle ?? this.headerStyle,
      selectedHeaderStyle: selectedHeaderStyle ?? this.selectedHeaderStyle,
      headerSpacing: headerSpacing ?? _headerSpacing,
      contentSpacing: contentSpacing ?? _contentSpacing,
    );
  }

  MetroPivotThemeData merge(MetroPivotThemeData? other) {
    if (other == null) return this;
    return MetroPivotThemeData(
      headerStyle: other.headerStyle ?? headerStyle,
      selectedHeaderStyle: other.selectedHeaderStyle ?? selectedHeaderStyle,
      headerSpacing: other._headerSpacing ?? _headerSpacing,
      contentSpacing: other._contentSpacing ?? _contentSpacing,
    );
  }

  static MetroPivotThemeData lerp(
    MetroPivotThemeData a,
    MetroPivotThemeData b,
    double t,
  ) {
    return MetroPivotThemeData(
      headerStyle: TextStyle.lerp(a.headerStyle, b.headerStyle, t),
      selectedHeaderStyle: TextStyle.lerp(
        a.selectedHeaderStyle,
        b.selectedHeaderStyle,
        t,
      ),
      headerSpacing: a.headerSpacing + (b.headerSpacing - a.headerSpacing) * t,
      contentSpacing:
          a.contentSpacing + (b.contentSpacing - a.contentSpacing) * t,
    );
  }
}

/// Overrides Pivot typography and spacing for a subtree.
class MetroPivotTheme extends InheritedTheme {
  const MetroPivotTheme({required this.data, required super.child, super.key});

  final MetroPivotThemeData data;

  static MetroPivotThemeData? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MetroPivotTheme>()?.data;
  }

  static MetroPivotThemeData of(BuildContext context) {
    return maybeOf(context) ?? const MetroPivotThemeData();
  }

  @override
  bool updateShouldNotify(MetroPivotTheme oldWidget) => data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) {
    return MetroPivotTheme(data: data, child: child);
  }
}

/// Horizontal, swipeable navigation modeled after the Windows 8 Pivot.
class MetroPivot extends StatefulWidget {
  const MetroPivot({
    required this.items,
    this.index,
    this.initialIndex = 0,
    this.onChanged,
    this.swipeEnabled = true,
    this.autofocus = false,
    super.key,
  }) : assert(items.length > 0),
       assert(initialIndex >= 0 && initialIndex < items.length),
       assert(index == null || (index >= 0 && index < items.length));

  final List<MetroPivotItem> items;
  final int? index;
  final int initialIndex;
  final ValueChanged<int>? onChanged;
  final bool swipeEnabled;
  final bool autofocus;

  @override
  State<MetroPivot> createState() => _MetroPivotState();
}

class _MetroPivotState extends State<MetroPivot> {
  late int _index = widget.index ?? widget.initialIndex;
  late final PageController _pageController = PageController(
    initialPage: _index,
  );

  int get _effectiveIndex => widget.index ?? _index;

  @override
  void didUpdateWidget(MetroPivot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index != null && widget.index != oldWidget.index) {
      _schedulePageChange(widget.index!);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _select(int index) {
    if (index == _effectiveIndex) {
      return;
    }
    if (widget.index == null) {
      setState(() => _index = index);
    }
    widget.onChanged?.call(index);
    _changePage(index);
  }

  void _schedulePageChange(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _changePage(index);
      }
    });
  }

  void _changePage(int index) {
    if (!_pageController.hasClients || _pageController.page?.round() == index) {
      return;
    }
    final theme = MetroTheme.of(context);
    if (_reduceMotion(context)) {
      _pageController.jumpToPage(index);
    } else {
      _pageController.animateToPage(
        index,
        duration: theme.motion.navigation,
        curve: theme.motion.navigationCurve,
      );
    }
  }

  void _handlePageChanged(int index) {
    if (index == _effectiveIndex) {
      return;
    }
    if (widget.index == null) {
      setState(() => _index = index);
    }
    widget.onChanged?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = MetroTheme.of(context);
    final pivotTheme = theme.pivotTheme.merge(MetroPivotTheme.maybeOf(context));
    final headerStyle =
        pivotTheme.headerStyle ??
        theme.typography.subheader.copyWith(
          color: theme.colors.mutedForeground,
        );
    final selectedHeaderStyle =
        pivotTheme.selectedHeaderStyle ??
        theme.typography.subheader.copyWith(color: theme.colors.foreground);

    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.arrowLeft): _PreviousPivotIntent(),
        SingleActivator(LogicalKeyboardKey.arrowRight): _NextPivotIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _PreviousPivotIntent: CallbackAction<_PreviousPivotIntent>(
            onInvoke: (intent) {
              final direction = Directionality.of(context);
              final delta = direction == TextDirection.ltr ? -1 : 1;
              _select(
                (_effectiveIndex + delta).clamp(0, widget.items.length - 1),
              );
              return null;
            },
          ),
          _NextPivotIntent: CallbackAction<_NextPivotIntent>(
            onInvoke: (intent) {
              final direction = Directionality.of(context);
              final delta = direction == TextDirection.ltr ? 1 : -1;
              _select(
                (_effectiveIndex + delta).clamp(0, widget.items.length - 1),
              );
              return null;
            },
          ),
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var index = 0; index < widget.items.length; index += 1)
                    Padding(
                      padding: EdgeInsetsDirectional.only(
                        end: index == widget.items.length - 1
                            ? 0
                            : pivotTheme.headerSpacing,
                      ),
                      child: MetroInteractive(
                        autofocus: widget.autofocus && index == _effectiveIndex,
                        onPressed: () => _select(index),
                        semanticSelected: index == _effectiveIndex,
                        builder: (context, states) {
                          final selected = index == _effectiveIndex;
                          return AnimatedDefaultTextStyle(
                            duration: _reduceMotion(context)
                                ? Duration.zero
                                : theme.motion.normal,
                            curve: theme.motion.standardCurve,
                            style: selected ? selectedHeaderStyle : headerStyle,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: widget.items[index].header,
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: pivotTheme.contentSpacing),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _handlePageChanged,
                physics: widget.swipeEnabled
                    ? const PageScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                children: [for (final item in widget.items) item.child],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static bool _reduceMotion(BuildContext context) {
    final mediaQuery = MediaQuery.maybeOf(context);
    return mediaQuery?.disableAnimations == true ||
        mediaQuery?.accessibleNavigation == true;
  }
}

class _PreviousPivotIntent extends Intent {
  const _PreviousPivotIntent();
}

class _NextPivotIntent extends Intent {
  const _NextPivotIntent();
}
