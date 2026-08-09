import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_ui/metro_ui.dart';

import '../test_utils.dart';

void main() {
  testWidgets('text field shows placeholder and accepts input', (tester) async {
    var value = '';
    await tester.pumpWidget(
      metroTestApp(
        child: Center(
          child: SizedBox(
            width: 280,
            child: MetroTextField(
              label: const Text('Name'),
              placeholder: 'Type a name',
              onChanged: (next) => value = next,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Type a name'), findsOneWidget);
    await tester.tap(find.byType(EditableText));
    await tester.enterText(find.byType(EditableText), 'Metro');
    await tester.pump();

    expect(value, 'Metro');
    expect(find.text('Type a name'), findsNothing);
  });

  testWidgets('external controller remains authoritative', (tester) async {
    final controller = TextEditingController(text: 'Initial');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      metroTestApp(
        child: Center(
          child: SizedBox(
            width: 280,
            child: MetroTextField(controller: controller),
          ),
        ),
      ),
    );

    controller.text = 'Updated';
    await tester.pump();
    expect(find.text('Updated'), findsOneWidget);
  });

  testWidgets('disabled text field exposes disabled semantics', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      metroTestApp(
        child: const Center(
          child: SizedBox(
            width: 280,
            child: MetroTextField(
              enabled: false,
              semanticLabel: 'Account name',
            ),
          ),
        ),
      ),
    );

    final node = tester.getSemantics(find.byType(MetroTextField));
    expect(
      node,
      containsMetroSemantics(
        isTextField: true,
        hasEnabledState: true,
        isEnabled: false,
      ),
    );
    semantics.dispose();
  });

  testWidgets('dark theme text input keeps the Windows 8 light editing well', (
    tester,
  ) async {
    await tester.pumpWidget(
      metroTestApp(
        theme: MetroThemeData.dark(),
        child: const Center(
          child: SizedBox(width: 280, child: MetroTextField()),
        ),
      ),
    );

    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(MetroTextField),
        matching: find.byType(Container),
      ),
    );
    final editable = tester.widget<EditableText>(find.byType(EditableText));
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, const Color(0xCCFFFFFF));
    expect(decoration.border!.top.color, const Color(0x00000000));
    expect(editable.style.color, const Color(0xFF000000));
  });

  testWidgets('validation feedback colors the field and updates semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final theme = MetroThemeData.light();
    await tester.pumpWidget(
      metroTestApp(
        theme: theme,
        child: const Center(
          child: SizedBox(
            width: 280,
            child: MetroTextField(
              semanticLabel: 'User name',
              supportingText: Text('This value is unavailable'),
              validationState: MetroTextFieldValidationState.error,
            ),
          ),
        ),
      ),
    );

    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(MetroTextField),
        matching: find.byType(Container),
      ),
    );
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.border!.top.color, theme.colors.error);
    expect(find.text('This value is unavailable'), findsOneWidget);
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('User name'))
          .getSemanticsData()
          .validationResult,
      SemanticsValidationResult.invalid,
    );
    semantics.dispose();
  });

  testWidgets('local text field theme sits below widget style', (tester) async {
    const localColor = Color(0xFF123456);
    const widgetColor = Color(0xFF654321);
    await tester.pumpWidget(
      metroTestApp(
        child: const Center(
          child: MetroTextFieldTheme(
            data: MetroTextFieldThemeData(
              style: MetroTextFieldStyle(
                borderColor: WidgetStatePropertyAll(localColor),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  key: Key('local'),
                  width: 280,
                  child: MetroTextField(),
                ),
                SizedBox(
                  key: Key('widget'),
                  width: 280,
                  child: MetroTextField(
                    style: MetroTextFieldStyle(
                      borderColor: WidgetStatePropertyAll(widgetColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final localContainer = tester.widget<Container>(
      find.descendant(
        of: find.byKey(const Key('local')),
        matching: find.byType(Container),
      ),
    );
    final localDecoration = localContainer.decoration! as BoxDecoration;
    expect(localDecoration.border!.top.color, localColor);

    final widgetContainer = tester.widget<Container>(
      find.descendant(
        of: find.byKey(const Key('widget')),
        matching: find.byType(Container),
      ),
    );
    final widgetDecoration = widgetContainer.decoration! as BoxDecoration;
    expect(widgetDecoration.border!.top.color, widgetColor);
  });

  testWidgets('password constructor applies secure input defaults', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      metroTestApp(
        child: const Center(
          child: SizedBox(width: 280, child: MetroTextField.password()),
        ),
      ),
    );

    final editable = tester.widget<EditableText>(find.byType(EditableText));
    expect(editable.obscureText, isTrue);
    expect(editable.autocorrect, isFalse);
    expect(editable.enableSuggestions, isFalse);
    expect(editable.keyboardType, TextInputType.visiblePassword);
    expect(editable.autofillHints, contains(AutofillHints.password));
    expect(
      tester.getSemantics(find.byType(MetroTextField)),
      containsMetroSemantics(isObscured: true),
    );
    semantics.dispose();
  });

  testWidgets('form field validates, shows success, and resets', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    var resetCount = 0;
    await tester.pumpWidget(
      metroTestApp(
        child: Form(
          key: formKey,
          child: Center(
            child: SizedBox(
              width: 280,
              child: MetroTextFormField(
                controller: controller,
                onReset: () => resetCount++,
                showSuccessWhenValid: true,
                successText: const Text('Looks good'),
                validator: (value) => (value?.length ?? 0) < 4
                    ? 'Use at least four characters'
                    : null,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(EditableText), 'bad');
    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Use at least four characters'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), 'Metro');
    expect(formKey.currentState!.validate(), isTrue);
    await tester.pump();
    expect(find.text('Looks good'), findsOneWidget);

    formKey.currentState!.reset();
    await tester.pump();
    expect(controller.text, isEmpty);
    expect(resetCount, 1);
    expect(find.text('Looks good'), findsNothing);
  });
}
