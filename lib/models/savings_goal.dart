class SavingsGoal {
  final String id;
  final String userId;
  final String name;
  final double targetAmount;
  final double savedAmount;

  const SavingsGoal({
    required this.id,
    required this.userId,
    required this.name,
    required this.targetAmount,
    this.savedAmount = 0,
  });

  /// 0.0 to 1.0, safe when the target is zero.
  double get progress =>
      targetAmount <= 0 ? 0 : (savedAmount / targetAmount).clamp(0.0, 1.0);

  double get remaining =>
      (targetAmount - savedAmount) < 0 ? 0 : targetAmount - savedAmount;

  SavingsGoal copyWith({String? name, double? targetAmount, double? savedAmount}) {
    return SavingsGoal(
      id: id,
      userId: userId,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'name': name,
        'targetAmount': targetAmount,
        'savedAmount': savedAmount,
      };

  factory SavingsGoal.fromJson(Map<String, dynamic> json) => SavingsGoal(
        id: json['id'] as String,
        userId: json['userId'] as String,
        name: json['name'] as String,
        targetAmount: (json['targetAmount'] as num).toDouble(),
        savedAmount: (json['savedAmount'] as num).toDouble(),
      );
}
