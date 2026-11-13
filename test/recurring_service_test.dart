import 'package:flutter_test/flutter_test.dart';
import 'package:mizania/models/expense.dart';
import 'package:mizania/services/recurring_service.dart';

void main() {
  Expense rent(DateTime d) => Expense(
        id: 'r1',
        userId: 'u1',
        amount: 1500,
        categoryId: 'housing',
        date: d,
        isRecurring: true,
      );

  test('creates one copy for every missing month up to the current month', () {
    final due = RecurringService.generateDue(
      [rent(DateTime(2026, 8, 31))],
      DateTime(2026, 10, 15),
    );
    expect(due.length, 2);
    expect(due.map((e) => e.date.month).toSet(), {9, 10});
    expect(due.every((e) => e.recurringSourceId == 'r1' && !e.isRecurring), isTrue);
    // September has 30 days, so day 31 is clamped to 30.
    expect(due.firstWhere((e) => e.date.month == 9).date.day, 30);
  });

  test('does not duplicate a copy that already exists', () {
    final origin = rent(DateTime(2026, 9, 1));
    final copy = Expense(
      id: 'c1',
      userId: 'u1',
      amount: 1500,
      categoryId: 'housing',
      date: DateTime(2026, 10, 1),
      recurringSourceId: 'r1',
    );
    expect(RecurringService.generateDue([origin, copy], DateTime(2026, 10, 20)), isEmpty);
  });

  test('creates nothing when the expense was logged this month', () {
    expect(
      RecurringService.generateDue([rent(DateTime(2026, 10, 3))], DateTime(2026, 10, 20)),
      isEmpty,
    );
  });
}
