import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

class UpdateExpenseUsecase {
  final ExpenseRepository repository;

  const UpdateExpenseUsecase(this.repository);

  Future<void> call(Expense expense) async {
    if (expense.id == null) {
      throw ArgumentError('Cannot update expense without id');
    }
    return await repository.update(expense);
  }
}