import 'package:flutter/widgets.dart';
import 'package:metro_ui/metro_ui.dart';

Widget pickerTestApp({
  required Widget child,
  Locale locale = const Locale('en', 'US'),
  MetroThemeData? theme,
  MediaQueryData mediaQueryData = const MediaQueryData(size: Size(800, 600)),
}) {
  return WidgetsApp(
    color: const Color(0xFF000000),
    locale: locale,
    onGenerateRoute: (_) => PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondaryAnimation) {
        return MediaQuery(
          data: mediaQueryData,
          child: MetroTheme(
            data: theme ?? MetroThemeData.light(),
            child: Center(child: child),
          ),
        );
      },
    ),
  );
}
