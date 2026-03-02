import 'package:apidash/consts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apidash/widgets/editor.dart';
import '../test_consts.dart';

void main() {
  testWidgets('Testing Editor', (tester) async {
    dynamic changedValue;
    await tester.pumpWidget(
      MaterialApp(
        title: 'Editor',
        theme: kThemeDataLight,
        home: Scaffold(
          body: Column(children: [
            Expanded(
              child: TextFieldEditor(
                fieldKey: '2',
                onChanged: (value) {
                  changedValue = value;
                },
              ),
            ),
          ]),
        ),
      ),
    );

    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.byKey(const Key("2")), findsOneWidget);
    expect(find.text(kHintContent), findsOneWidget);
    var txtForm = find.byKey(const Key("2"));
    await tester.enterText(txtForm, 'entering 123 for testing content body');
    await tester.pump();
    await tester.pumpAndSettle();

    await tester.tap(txtForm);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();

    await tester.pump();
    await tester.pumpAndSettle();
    expect(changedValue, 'entering 123 for testing content body  ');
  });
  testWidgets('Testing Editor Dark theme', (tester) async {
    dynamic changedValue;
    await tester.pumpWidget(
      MaterialApp(
        title: 'Editor Dark',
        theme: kThemeDataDark,
        home: Scaffold(
          body: Column(children: [
            Expanded(
              child: TextFieldEditor(
                fieldKey: '2',
                onChanged: (value) {
                  changedValue = value;
                },
                initialValue: 'initial',
              ),
            ),
          ]),
        ),
      ),
    );
    expect(find.text('initial'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.byKey(const Key("2")), findsOneWidget);
    expect(find.text(kHintContent), findsOneWidget);
    var txtForm = find.byKey(const Key("2"));
    await tester.enterText(txtForm, 'entering 123 for testing content body');
    await tester.pump();
    await tester.pumpAndSettle();

    await tester.tap(txtForm);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();

    await tester.pump();
    await tester.pumpAndSettle();
    expect(changedValue, 'entering 123 for testing content body  ');
  });

  testWidgets('TextFieldEditor preserves range selection on text update', (tester) async {
  const initialValue = 'hello world';
  const updatedValue = 'hello world!';

  await tester.pumpWidget(
    MaterialApp(
      theme: kThemeDataLight,
      home: Scaffold(
        body: TextFieldEditor(
          fieldKey: 'testKey',
          initialValue: initialValue,
        ),
      ),
    ),
  );

  // Grab controller via EditableText.
  EditableText editableText = tester.widget<EditableText>(find.byType(EditableText));
  TextEditingController controller = editableText.controller;

  // Set a range selection [2, 7]
  controller.selection = const TextSelection(baseOffset: 2, extentOffset: 7);
  await tester.pump();

  // Update initialValue with same fieldKey (simulates external update)
  await tester.pumpWidget(
    MaterialApp(
      theme: kThemeDataLight,
      home: Scaffold(
        body: TextFieldEditor(
          fieldKey: 'testKey',
          initialValue: updatedValue,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  editableText = tester.widget<EditableText>(find.byType(EditableText));
  controller = editableText.controller;

  expect(controller.text, updatedValue);
  expect(controller.selection.baseOffset, 2);
  expect(controller.selection.extentOffset, 7);
});

testWidgets('TextFieldEditor clamps selection when text shrinks', (tester) async {
  const initialValue = 'hello world';
  const updatedValue = 'hello'; // shorter (len=5)

  await tester.pumpWidget(
    MaterialApp(
      theme: kThemeDataLight,
      home: Scaffold(
        body: TextFieldEditor(
          fieldKey: 'testKey',
          initialValue: initialValue,
        ),
      ),
    ),
  );

  EditableText editableText = tester.widget<EditableText>(find.byType(EditableText));
  TextEditingController controller = editableText.controller;

  // Selection points beyond new text length after shrink
  controller.selection = const TextSelection(baseOffset: 5, extentOffset: 11);
  await tester.pump();

  await tester.pumpWidget(
    MaterialApp(
      theme: kThemeDataLight,
      home: Scaffold(
        body: TextFieldEditor(
          fieldKey: 'testKey',
          initialValue: updatedValue,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  editableText = tester.widget<EditableText>(find.byType(EditableText));
  controller = editableText.controller;

  expect(controller.text, updatedValue);

  // Both offsets must be within [0, updatedValue.length]
  expect(controller.selection.baseOffset, inInclusiveRange(0, updatedValue.length));
  expect(controller.selection.extentOffset, inInclusiveRange(0, updatedValue.length));
}
}
