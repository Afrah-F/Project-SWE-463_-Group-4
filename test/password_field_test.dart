import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mizania/widgets/password_field.dart';

void main() {
  testWidgets('each password field has its own eye that shows and hides it',
      (tester) async {
    final a = TextEditingController(text: 'secret-a');
    final b = TextEditingController(text: 'secret-b');
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Column(children: [
          PasswordField(controller: a, label: 'First'),
          PasswordField(controller: b, label: 'Second'),
        ]),
      ),
    ));

    bool obscured(int i) =>
        tester.widget<EditableText>(find.byType(EditableText).at(i)).obscureText;

    expect(find.byIcon(Icons.visibility), findsNWidgets(2));
    expect(obscured(0), isTrue);
    expect(obscured(1), isTrue);

    // Revealing the first field leaves the second one hidden.
    await tester.tap(find.byIcon(Icons.visibility).first);
    await tester.pump();
    expect(obscured(0), isFalse);
    expect(obscured(1), isTrue);

    // The eye toggles back.
    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();
    expect(obscured(0), isTrue);
  });
}
