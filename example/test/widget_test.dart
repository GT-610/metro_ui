import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_ui/metro_ui.dart';
import 'package:metro_ui_example/gallery/gallery_navigation.dart';
import 'package:metro_ui_example/main.dart';

void main() {
  testWidgets('gallery searches the catalog and changes appearance', (
    tester,
  ) async {
    await tester.pumpWidget(const MetroGalleryApp());

    expect(find.text('Metro UI'), findsWidgets);
    expect(find.text('Modern UI for Flutter'), findsOneWidget);
    expect(find.text('BROWSE BY CATEGORY'), findsOneWidget);
    final catalogSearch = find.byType(EditableText);
    expect(catalogSearch, findsOneWidget);
    expect(find.bySemanticsLabel('Use dark theme'), findsOneWidget);

    await tester.enterText(catalogSearch, 'MetroDatePicker');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Inputs & pickers'), findsWidgets);
    expect(find.text('MetroNumberBox'), findsOneWidget);
    expect(find.text('SEARCH RESULT'), findsOneWidget);
    await tester.tap(find.text('JUMP TO DEMO'));
    await tester.pump();
    expect(find.text('Date and time').hitTestable(), findsOneWidget);

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

    await tester.tapAt(const Offset(400, 300), buttons: kSecondaryMouseButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 367));

    await tester.tap(find.bySemanticsLabel('About Metro UI'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Metro UI for Flutter'), findsOneWidget);

    await tester.tap(find.text('CLOSE'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Metro UI for Flutter'), findsNothing);

    await tester.tap(find.bySemanticsLabel('Open settings flyout'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Experience'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Close settings'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Experience'), findsNothing);
  });

  testWidgets('gallery demonstrates selection and directional navigation', (
    tester,
  ) async {
    await tester.pumpWidget(const MetroGalleryApp());

    await Scrollable.ensureVisible(
      tester.element(find.text('OPEN THE COMPLETE PLAYGROUND')),
      alignment: 0.5,
    );
    await tester.pump();
    await tester.tap(find.text('OPEN THE COMPLETE PLAYGROUND'));
    await tester.pump();
    expect(find.text('All controls'), findsWidgets);

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
      tester.element(find.text('Semantic zoom')),
      alignment: 0.35,
    );
    await tester.pump();
    await Scrollable.ensureVisible(
      tester.element(find.text('TILE')),
      alignment: 0.6,
    );
    await tester.pump();
    await tester.tap(find.text('TILE'));
    await tester.pump();
    expect(find.text('Last action: Semantic zoom item Tile'), findsOneWidget);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.minus);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 334));
    await tester.pump();
    expect(
      find.bySemanticsLabel('NAVIGATION, 3 component examples').hitTestable(),
      findsOneWidget,
    );
    await tester.tap(find.bySemanticsLabel('NAVIGATION, 3 component examples'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 334));
    await tester.pump();
    expect(find.text('Last action: Semantic zoom NAVIGATION'), findsOneWidget);
    expect(find.text('PIVOT').hitTestable(), findsOneWidget);

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

  testWidgets('wide gallery keeps persistent catalog navigation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MetroGalleryApp());

    expect(find.byType(GalleryNavigation), findsOneWidget);
    expect(find.text('METRO GALLERY'), findsOneWidget);

    await tester.tap(find.text('Data display'));
    await tester.pump();

    expect(find.text('Data display'), findsWidgets);
    expect(find.text('Data grid'), findsOneWidget);
    expect(find.text('MetroDataGrid'), findsOneWidget);
  });
}
