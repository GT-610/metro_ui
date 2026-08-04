import 'package:flutter/widgets.dart';

WidgetStateProperty<T?>? lerpStateProperty<T>(
  WidgetStateProperty<T?>? a,
  WidgetStateProperty<T?>? b,
  double t,
  T? Function(T? a, T? b, double t) lerp,
) {
  if (a == null && b == null) {
    return null;
  }
  return WidgetStateProperty.resolveWith(
    (states) => lerp(a?.resolve(states), b?.resolve(states), t),
  );
}

T? lerpDiscrete<T>(T? a, T? b, double t) => t < 0.5 ? a : b;

double? lerpDouble(double? a, double? b, double t) {
  if (a == null && b == null) {
    return null;
  }
  return (a ?? b)! + ((b ?? a)! - (a ?? b)!) * t;
}
