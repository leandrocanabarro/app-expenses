import '../entities/expense.dart';

abstract class ExpenseRepository {
  Future<int> add(Expense expense);
  Future<List<Expense>> list({DateTime? month, int? categoryId});
  Future<void> delete(int id);
  Future<Expense?> findById(int id);
}