import '../../domain/entities/expense.dart';

class ExpenseModel extends Expense {
  const ExpenseModel({
    super.id,
    required super.value,
    required super.description,
    super.categoryId,
    required super.date,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as int?,
      value: map['value'] as double,
      description: map['description'] as String,
      categoryId: map['category_id'] as int?,
      date: DateTime.parse(map['date'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'value': value,
      'description': description,
      'category_id': categoryId,
      'date': date.toIso8601String(),
    };
  }

  factory ExpenseModel.fromEntity(Expense expense) {
    return ExpenseModel(
      id: expense.id,
      value: expense.value,
      description: expense.description,
      categoryId: expense.categoryId,
      date: expense.date,
    );
  }

  Expense toEntity() {
    return Expense(
      id: id,
      value: value,
      description: description,
      categoryId: categoryId,
      date: date,
    );
  }
}