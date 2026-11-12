class Expense {
  final String id;
  final String userId;
  final double amount;
  final String categoryId;
  final DateTime date;
  final String? note;
  final bool isRecurring;

  /// Id of the expense this monthly copy was created from (null for originals).
  final String? recurringSourceId;

  const Expense({
    required this.id,
    required this.userId,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.note,
    this.isRecurring = false,
    this.recurringSourceId,
  });

  Expense copyWith({
    double? amount,
    String? categoryId,
    DateTime? date,
    String? note,
    bool? isRecurring,
    bool clearNote = false,
  }) {
    return Expense(
      id: id,
      userId: userId,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      note: clearNote ? null : (note ?? this.note),
      isRecurring: isRecurring ?? this.isRecurring,
      recurringSourceId: recurringSourceId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'amount': amount,
        'categoryId': categoryId,
        'date': date.toIso8601String(),
        'note': note,
        'isRecurring': isRecurring,
        'recurringSourceId': recurringSourceId,
      };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: json['id'] as String,
        userId: json['userId'] as String,
        amount: (json['amount'] as num).toDouble(),
        categoryId: json['categoryId'] as String,
        date: DateTime.parse(json['date'] as String),
        note: json['note'] as String?,
        isRecurring: json['isRecurring'] as bool? ?? false,
        recurringSourceId: json['recurringSourceId'] as String?,
      );
}
