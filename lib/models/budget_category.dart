class BudgetCategory {
  final String id;
  final String userId;
  final String name;
  final double monthlyLimit;
  final String iconKey;
  final int colorValue;

  /// Set only for the six seeded categories so their names can be shown in
  /// the current app language. It becomes null once the user renames one.
  final String? nameKey;

  const BudgetCategory({
    required this.id,
    required this.userId,
    required this.name,
    required this.monthlyLimit,
    required this.iconKey,
    required this.colorValue,
    this.nameKey,
  });

  BudgetCategory copyWith({
    String? name,
    double? monthlyLimit,
    String? iconKey,
    int? colorValue,
    bool clearNameKey = false,
  }) {
    return BudgetCategory(
      id: id,
      userId: userId,
      name: name ?? this.name,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      iconKey: iconKey ?? this.iconKey,
      colorValue: colorValue ?? this.colorValue,
      nameKey: clearNameKey ? null : nameKey,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'name': name,
        'monthlyLimit': monthlyLimit,
        'iconKey': iconKey,
        'colorValue': colorValue,
        'nameKey': nameKey,
      };

  factory BudgetCategory.fromJson(Map<String, dynamic> json) => BudgetCategory(
        id: json['id'] as String,
        userId: json['userId'] as String,
        name: json['name'] as String,
        monthlyLimit: (json['monthlyLimit'] as num).toDouble(),
        iconKey: json['iconKey'] as String,
        colorValue: json['colorValue'] as int,
        nameKey: json['nameKey'] as String?,
      );
}
