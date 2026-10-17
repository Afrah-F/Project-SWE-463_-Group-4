import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mizania/main.dart';

void main() {
  testWidgets('Mizania welcome screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(const MizaniaApp());

    expect(find.text('MIZANIA'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
  });
}
