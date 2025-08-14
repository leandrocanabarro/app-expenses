import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

class GetExpensesUseCase {
  final ExpenseRepository repository;

  const GetExpensesUseCase(this.repository);

  Future<List<Expense>> call({DateTime? month, int? categoryId}) async {
    return await repository.list(month: month, categoryId: categoryId);
  }
}