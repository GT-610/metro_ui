import 'package:flutter/widgets.dart';

import 'metro_button.dart';

/// An accessible square Metro button for an icon or other compact glyph.
class MetroIconButton extends StatelessWidget {
  const MetroIconButton({
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.variant = MetroButtonVariant.standard,
    this.style,
    this.autofocus = false,
    this.focusNode,
    super.key,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final MetroButtonVariant variant;
  final MetroButtonStyle? style;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final compactStyle = const MetroButtonStyle(
      minimumSize: Size.square(40),
      padding: EdgeInsets.all(8),
    ).merge(style);
    return MetroButton(
      autofocus: autofocus,
      focusNode: focusNode,
      onPressed: onPressed,
      semanticLabel: semanticLabel,
      style: compactStyle,
      variant: variant,
      child: icon,
    );
  }
}
