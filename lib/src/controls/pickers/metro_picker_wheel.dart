import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../theme/metro_theme.dart';
import 'metro_picker_style.dart';

class MetroPickerWheel extends StatefulWidget {
  const MetroPickerWheel({
    required this.items,
    required this.selectedIndex,
    required this.onSelectedIndexChanged,
    required this.semanticLabel,
    this.autofocus = false,
    super.key,
  });

  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onSelectedIndexChanged;
  final String semanticLabel;
  final bool autofocus;

  @override
  State<MetroPickerWheel> createState() => _MetroPickerWheelState();
}

class _MetroPickerWheelState extends State<MetroPickerWheel> {
  late final FixedExtentScrollController _controller =
      FixedExtentScrollController(initialItem: widget.selectedIndex);
  bool _focused = false;

  @override
  void didUpdateWidget(MetroPickerWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex ||
        widget.items.length != oldWidget.items.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted &&
            _controller.hasClients &&
            _controller.selectedItem != widget.selectedIndex) {
          _controller.jumpToItem(widget.selectedIndex);
        }
      });
    }
  }

  void _move(int delta) {
    final next = (widget.selectedIndex + delta).clamp(
      0,
      widget.items.length - 1,
    );
    if (next == widget.selectedIndex) {
      return;
    }
    final reduceMotion = _reduceMotion(context);
    if (reduceMotion) {
      _controller.jumpToItem(next);
    } else {
      _controller.animateToItem(
        next,
        duration: MetroTheme.of(context).motion.normal,
        curve: MetroTheme.of(context).motion.standardCurve,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.items.isNotEmpty);
    assert(widget.selectedIndex >= 0);
    assert(widget.selectedIndex < widget.items.length);
    final theme = MetroTheme.of(context);
    final pickerTheme = MetroPickerThemeData(
      selectedBackgroundColor: theme.colors.accent,
      selectedForegroundColor: theme.colors.onAccent,
      itemTextStyle: theme.typography.body,
      itemExtent: 44,
      visibleItemCount: 5,
      popupWidth: 520,
    ).merge(theme.pickerTheme).merge(MetroPickerTheme.maybeOf(context));
    final itemExtent = pickerTheme.itemExtent!;
    final visibleItemCount = pickerTheme.visibleItemCount!;
    final selectedColor = pickerTheme.selectedBackgroundColor!;
    final selectedForeground = pickerTheme.selectedForegroundColor!;
    final itemStyle = pickerTheme.itemTextStyle!;
    final increase = widget.selectedIndex < widget.items.length - 1
        ? widget.items[widget.selectedIndex + 1]
        : null;
    final decrease = widget.selectedIndex > 0
        ? widget.items[widget.selectedIndex - 1]
        : null;

    return Semantics(
      label: widget.semanticLabel,
      value: widget.items[widget.selectedIndex],
      increasedValue: increase,
      decreasedValue: decrease,
      slider: true,
      onIncrease: increase == null ? null : () => _move(1),
      onDecrease: decrease == null ? null : () => _move(-1),
      child: FocusableActionDetector(
        autofocus: widget.autofocus,
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.arrowUp): _MovePickerIntent(-1),
          SingleActivator(LogicalKeyboardKey.arrowDown): _MovePickerIntent(1),
          SingleActivator(LogicalKeyboardKey.pageUp): _MovePickerIntent(-5),
          SingleActivator(LogicalKeyboardKey.pageDown): _MovePickerIntent(5),
        },
        actions: <Type, Action<Intent>>{
          _MovePickerIntent: CallbackAction<_MovePickerIntent>(
            onInvoke: (intent) {
              _move(intent.delta);
              return null;
            },
          ),
        },
        onShowFocusHighlight: (focused) {
          if (_focused != focused) {
            setState(() => _focused = focused);
          }
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: _focused ? theme.colors.focus : theme.colors.border,
              width: _focused ? 2 : 1,
            ),
          ),
          child: SizedBox(
            height: itemExtent * visibleItemCount,
            child: ExcludeSemantics(
              child: ListWheelScrollView.useDelegate(
                controller: _controller,
                diameterRatio: 100,
                itemExtent: itemExtent,
                onSelectedItemChanged: widget.onSelectedIndexChanged,
                overAndUnderCenterOpacity: 0.58,
                perspective: 0.001,
                physics: const FixedExtentScrollPhysics(),
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: widget.items.length,
                  builder: (context, index) {
                    final selected = index == widget.selectedIndex;
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _move(index - widget.selectedIndex),
                      child: AnimatedContainer(
                        alignment: Alignment.center,
                        color: selected ? selectedColor : null,
                        duration: _reduceMotion(context)
                            ? Duration.zero
                            : theme.motion.fast,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          widget.items[index],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: itemStyle.copyWith(
                            color: selected
                                ? selectedForeground
                                : theme.colors.foreground,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static bool _reduceMotion(BuildContext context) {
    final media = MediaQuery.maybeOf(context);
    return media?.disableAnimations == true ||
        media?.accessibleNavigation == true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _MovePickerIntent extends Intent {
  const _MovePickerIntent(this.delta);

  final int delta;
}
