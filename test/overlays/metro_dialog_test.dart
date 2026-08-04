import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_ui/metro_ui.dart';

void main() {
  testWidgets('dialog captures Metro theme and returns a result', (
    tester,
  ) async {
    String? result;
    await tester.pumpWidget(
      _overlayTestApp(
        child: Builder(
          builder: (context) {
            return Center(
              child: MetroButton(
                onPressed: () async {
                  result = await showMetroDialog<String>(
                    context: context,
                    builder: (dialogContext) {
                      return MetroDialog(
                        semanticLabel: 'Save changes dialog',
                        title: const Text('Save changes?'),
                        content: const Text('Your work will be preserved.'),
                        actions: [
                          MetroButton.accent(
                            onPressed: () {
                              Navigator.of(dialogContext).pop('saved');
                            },
                            child: const Text('SAVE'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('OPEN'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('OPEN'));
    await tester.pumpAndSettle();
    expect(find.text('Save changes?'), findsOneWidget);
    expect(find.bySemanticsLabel('Save changes dialog'), findsOneWidget);

    await tester.tap(find.text('SAVE'));
    await tester.pumpAndSettle();
    expect(result, 'saved');
    expect(find.text('Save changes?'), findsNothing);
  });

  testWidgets('escape dismisses the dialog', (tester) async {
    await tester.pumpWidget(
      _overlayTestApp(
        child: Builder(
          builder: (context) {
            return MetroButton(
              onPressed: () {
                showMetroDialog<void>(
                  context: context,
                  builder: (_) =>
                      const MetroDialog(title: Text('Keyboard dismissal')),
                );
              },
              child: const Text('OPEN'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('OPEN'));
    await tester.pumpAndSettle();
    expect(find.text('Keyboard dismissal'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Keyboard dismissal'), findsNothing);
  });

  testWidgets('local dialog theme is captured across the navigator', (
    tester,
  ) async {
    const customColor = Color(0xFF123456);
    await tester.pumpWidget(
      _overlayTestApp(
        child: MetroDialogTheme(
          data: const MetroDialogThemeData(backgroundColor: customColor),
          child: Builder(
            builder: (context) {
              return MetroButton(
                onPressed: () {
                  showMetroDialog<void>(
                    context: context,
                    builder: (_) => const MetroDialog(title: Text('Themed')),
                  );
                },
                child: const Text('OPEN'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('OPEN'));
    await tester.pumpAndSettle();
    final box = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(MetroDialog),
        matching: find.byType(DecoratedBox),
      ),
    );
    expect((box.decoration as BoxDecoration).color, customColor);
  });
}

Widget _overlayTestApp({required Widget child}) {
  return WidgetsApp(
    color: const Color(0xFF000000),
    onGenerateRoute: (_) => PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondaryAnimation) {
        return MetroTheme(data: MetroThemeData.light(), child: child);
      },
    ),
  );
}
