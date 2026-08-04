import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_ui/metro_ui.dart';
import 'package:metro_ui_example/main.dart';

void main() {
  testWidgets('gallery renders and changes theme', (tester) async {
    await tester.pumpWidget(const MetroGalleryApp());

    expect(find.text('Metro UI'), findsOneWidget);
    expect(find.text('Tiles'), findsOneWidget);
    expect(find.bySemanticsLabel('Use dark theme'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Use Chinese locale'));
    await tester.pump();
    expect(find.bySemanticsLabel('Use English locale'), findsOneWidget);

    await Scrollable.ensureVisible(
      tester.element(find.bySemanticsLabel('Event date')),
      alignment: 0.5,
    );
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('Event date'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('选择日期'), findsOneWidget);
    expect(find.text('完成'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.bySemanticsLabel('Use English locale'));
    await tester.pump();

    await tester.tap(find.bySemanticsLabel('Use dark theme'));
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.bySemanticsLabel('Use light theme'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('About Metro UI'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Metro UI for Flutter'), findsOneWidget);

    await tester.tap(find.text('CLOSE'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Metro UI for Flutter'), findsNothing);

    await tester.tap(find.bySemanticsLabel('Open settings flyout'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Experience'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Close settings'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Experience'), findsNothing);
  });

  testWidgets('gallery demonstrates selection and directional navigation', (
    tester,
  ) async {
    await tester.pumpWidget(const MetroGalleryApp());

    await Scrollable.ensureVisible(
      tester.element(find.text('Mail')),
      alignment: 0.5,
    );
    await tester.pump();
    await tester.tap(
      find.ancestor(of: find.text('Mail'), matching: find.byType(MetroTile)),
    );
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(find.text('Last action: Photos tile'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('12 NEW\nMEMORIES'), findsOneWidget);

    await tester.ensureVisible(find.text('Comfortable'));
    await tester.pump();
    await tester.tap(find.text('Comfortable'));
    await tester.pump();
    expect(find.text('Last action: View mode 1'), findsOneWidget);

    await tester.ensureVisible(find.text('Pictures'));
    await tester.pump();
    await tester.tap(find.text('Pictures'));
    await tester.pump();
    expect(find.text('Last action: 2 library items selected'), findsOneWidget);

    await Scrollable.ensureVisible(
      tester.element(find.bySemanticsLabel('Event date')),
      alignment: 0.5,
    );
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('Event date'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('SELECT DATE'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.bySemanticsLabel('Event time'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('SELECT TIME'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await Scrollable.ensureVisible(
      tester.element(find.bySemanticsLabel('Volume')),
      alignment: 0.5,
    );
    await tester.pump();
    await tester.tapAt(tester.getCenter(find.bySemanticsLabel('Volume')));
    await tester.pump();
    expect(find.text('Last action: Volume 50'), findsOneWidget);

    await Scrollable.ensureVisible(
      tester.element(find.text('Data grid')),
      alignment: 0.35,
    );
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('Sort albums by title'));
    await tester.pump();
    expect(find.text('Last action: Sorted albums ascending'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Discovery, Daft Punk, 2001'));
    await tester.pump();
    expect(find.text('Last action: Selected Discovery'), findsOneWidget);

    await tester.ensureVisible(find.text('OPEN TRANSITION PAGE'));
    await tester.pump();
    await tester.tap(find.text('OPEN TRANSITION PAGE'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Directional motion'), findsOneWidget);
    expect(
      find.textContaining('follows the logical reading direction'),
      findsOneWidget,
    );

    await tester.tap(find.bySemanticsLabel('Close transition page'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 650));
    await tester.pump();
    expect(find.text('Directional motion'), findsNothing);
  });
}
