class Expense {
  final int? id;
  final double value;
  final String description;
  final int? categoryId;
  final DateTime date;

  const Expense({
    this.id,
    required this.value,
    required this.description,
    this.categoryId,
    required this.date,
  });

  Expense copyWith({
    int? id,
    double? value,
    String? description,
    int? categoryId,
    DateTime? date,
  }) {
    return Expense(
      id: id ?? this.id,
      value: value ?? this.value,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Expense &&
        other.id == id &&
        other.value == value &&
        other.description == description &&
        other.categoryId == categoryId &&
        other.date == date;
  }

  @override
  int get hashCode => Object.hash(id, value, description, categoryId, date);

  @override
  String toString() {
    return 'Expense(id: $id, value: $value, description: $description, categoryId: $categoryId, date: $date)';
  }
}