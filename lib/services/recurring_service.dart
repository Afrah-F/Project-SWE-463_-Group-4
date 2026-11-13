import 'package:uuid/uuid.dart';

import '../models/expense.dart';
import '../utils/formatters.dart';

/// Copies every expense marked "repeat every month" into each month that has
/// no copy yet, up to and including the current month.
class RecurringService {
  static const Uuid _uuid = Uuid();

  /// Returns only the NEW expenses that should be added.
  static List<Expense> generateDue(List<Expense> all, DateTime now) {
    final created = <Expense>[];
    final currentMonth = DateTime(now.year, now.month);

    for (final origin in all.where((e) => e.isRecurring && e.recurringSourceId == null)) {
      var month = DateTime(origin.date.year, origin.date.month + 1);
      var guard = 0; // never create more than 10 years of catch-up copies
      while (!month.isAfter(currentMonth) && guard < 120) {
        final exists = all.any((e) =>
            e.recurringSourceId == origin.id && isSameMonth(e.date, month));
        if (!exists) {
          final day = origin.date.day.clamp(1, daysInMonth(month.year, month.month));
          created.add(Expense(
            id: _uuid.v4(),
            userId: origin.userId,
            amount: origin.amount,
            categoryId: origin.categoryId,
            date: DateTime(month.year, month.month, day),
            note: origin.note,
            isRecurring: false,
            recurringSourceId: origin.id,
          ));
        }
        month = DateTime(month.year, month.month + 1);
        guard++;
      }
    }
    return created;
  }
}
