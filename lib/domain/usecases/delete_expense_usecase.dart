import '../repositories/expense_repository.dart';

class DeleteExpenseUseCase {
  final ExpenseRepository repository;

  const DeleteExpenseUseCase(this.repository);

  Future<void> call(int id) async {
    if (id <= 0) {
      throw ArgumentError('Invalid expense ID');
    }

    await repository.delete(id);
  }
}