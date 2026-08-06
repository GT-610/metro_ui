import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_ui/metro_ui.dart';

import '../test_utils.dart';

void main() {
  testWidgets('controls keep an English fallback without a delegate', (
    tester,
  ) async {
    late MetroLocalizations localizations;
    await tester.pumpWidget(
      metroTestApp(
        child: Builder(
          builder: (context) {
            localizations = MetroLocalizations.of(context);
            return const SizedBox();
          },
        ),
      ),
    );

    expect(localizations, isA<MetroLocalizationsEn>());
    expect(localizations.selectDateTitle, 'SELECT DATE');
  });

  testWidgets('Chinese delegate localizes picker defaults', (tester) async {
    await tester.pumpWidget(
      _localizedTestApp(
        locale: const Locale('zh', 'CN'),
        child: MetroDatePicker(selected: null, onChanged: (_) {}),
      ),
    );

    expect(find.text('年'), findsOneWidget);
    expect(find.text('月'), findsOneWidget);
    expect(find.text('日'), findsOneWidget);
    expect(find.bySemanticsLabel('日期选择器'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('日期选择器'));
    await tester.pumpAndSettle();
    expect(find.text('选择日期'), findsOneWidget);
    expect(find.text('完成'), findsOneWidget);
    expect(find.text('取消'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
  });

  testWidgets('Chinese time picker uses localized day periods', (tester) async {
    await tester.pumpWidget(
      _localizedTestApp(
        locale: const Locale('zh'),
        child: MetroTimePicker(
          selected: const MetroTime(hour: 14, minute: 30),
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.text('下午'), findsOneWidget);
    expect(find.bySemanticsLabel('时间选择器，2，30，下午'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('时间选择器，2，30，下午'));
    await tester.pumpAndSettle();
    expect(find.text('选择时间'), findsOneWidget);
    expect(find.text('上午'), findsWidgets);
    expect(find.text('下午'), findsWidgets);
  });

  testWidgets('data grid localizes controlled sort semantics', (tester) async {
    MetroDataGridSort? sort;
    await tester.pumpWidget(
      _localizedTestApp(
        locale: const Locale('zh'),
        child: StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              width: 280,
              child: MetroDataGrid<String>(
                columns: [
                  MetroDataGridColumn<String>(
                    key: 'name',
                    label: const Text('名称'),
                    semanticLabel: '按名称排序',
                    sortable: true,
                    cellBuilder: (context, row, index) => Text(row),
                  ),
                ],
                onSortChanged: (next) => setState(() => sort = next),
                rows: const ['项目'],
                sort: sort,
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.bySemanticsLabel('按名称排序'));
    await tester.pump();
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('按名称排序'))
          .getSemanticsData()
          .value,
      '升序',
    );
  });

  testWidgets('toggle places its selected thumb at the logical end', (
    tester,
  ) async {
    Future<double> thumbX(TextDirection direction) async {
      await tester.pumpWidget(
        metroTestApp(
          child: Center(
            child: Directionality(
              textDirection: direction,
              child: MetroToggleSwitch(value: true, onChanged: (_) {}),
            ),
          ),
        ),
      );
      return tester
          .getCenter(
            find.descendant(
              of: find.byType(AnimatedPositionedDirectional),
              matching: find.byType(ColoredBox),
            ),
          )
          .dx;
    }

    final ltrX = await thumbX(TextDirection.ltr);
    final rtlX = await thumbX(TextDirection.rtl);
    expect(ltrX, greaterThan(rtlX));
  });

  testWidgets(
    'data grid keeps its first logical column on the RTL start edge',
    (tester) async {
      await tester.pumpWidget(
        metroTestApp(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: SizedBox(
              width: 240,
              child: MetroDataGrid<String>(
                columns: [
                  MetroDataGridColumn<String>(
                    key: 'first',
                    label: const Text('FIRST'),
                    width: 120,
                    cellBuilder: (context, row, index) => Text(row),
                  ),
                  MetroDataGridColumn<String>(
                    key: 'second',
                    label: const Text('SECOND'),
                    width: 120,
                    cellBuilder: (context, row, index) => Text(row),
                  ),
                ],
                rows: const ['value'],
              ),
            ),
          ),
        ),
      );

      expect(
        tester.getCenter(find.text('FIRST')).dx,
        greaterThan(tester.getCenter(find.text('SECOND')).dx),
      );
    },
  );
}

Widget _localizedTestApp({required Locale locale, required Widget child}) {
  return WidgetsApp(
    color: const Color(0xFF000000),
    locale: locale,
    localizationsDelegates: const [MetroLocalizations.delegate],
    onGenerateRoute: (_) => PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondaryAnimation) {
        return MediaQuery(
          data: const MediaQueryData(size: Size(800, 600)),
          child: MetroTheme(
            data: MetroThemeData.light(),
            child: Center(child: child),
          ),
        );
      },
    ),
    supportedLocales: MetroLocalizations.supportedLocales,
  );
}
