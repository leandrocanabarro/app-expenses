import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

class AddExpenseUseCase {
  final ExpenseRepository repository;

  const AddExpenseUseCase(this.repository);

  Future<int> call({
    required double value,
    required String description,
    int? categoryId,
    DateTime? date,
  }) async {
    if (value <= 0) {
      throw ArgumentError('Expense value must be greater than 0');
    }

    if (description.trim().isEmpty) {
      throw ArgumentError('Expense description cannot be empty');
    }

    final expense = Expense(
      value: value,
      description: description.trim(),
      categoryId: categoryId,
      date: date ?? DateTime.now(),
    );

    return await repository.add(expense);
  }
}