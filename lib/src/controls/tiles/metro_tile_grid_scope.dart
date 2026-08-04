import 'package:flutter/widgets.dart';

class MetroTileGridScope extends InheritedWidget {
  const MetroTileGridScope({
    required this.extent,
    required this.maxWidth,
    required this.spacing,
    required super.child,
    super.key,
  });

  final double extent;
  final double? maxWidth;
  final double spacing;

  static MetroTileGridScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MetroTileGridScope>();
  }

  @override
  bool updateShouldNotify(MetroTileGridScope oldWidget) {
    return extent != oldWidget.extent ||
        maxWidth != oldWidget.maxWidth ||
        spacing != oldWidget.spacing;
  }
}
