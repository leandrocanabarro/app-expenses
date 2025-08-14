import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/usecases/add_expense_usecase.dart';
import '../../domain/usecases/delete_expense_usecase.dart';
import '../../domain/usecases/get_expenses_usecase.dart';
import 'category_providers.dart';

// Repository provider
final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return ExpenseRepositoryImpl(databaseService);
});

// Use cases providers
final addExpenseUseCaseProvider = Provider<AddExpenseUseCase>((ref) {
  final repository = ref.watch(expenseRepositoryProvider);
  return AddExpenseUseCase(repository);
});

final getExpensesUseCaseProvider = Provider<GetExpensesUseCase>((ref) {
  final repository = ref.watch(expenseRepositoryProvider);
  return GetExpensesUseCase(repository);
});

final deleteExpenseUseCaseProvider = Provider<DeleteExpenseUseCase>((ref) {
  final repository = ref.watch(expenseRepositoryProvider);
  return DeleteExpenseUseCase(repository);
});

// Filters state
final expenseFiltersProvider = StateProvider<ExpenseFilters>((ref) {
  return ExpenseFilters();
});

class ExpenseFilters {
  final DateTime? month;
  final int? categoryId;

  ExpenseFilters({this.month, this.categoryId});

  ExpenseFilters copyWith({
    DateTime? month,
    int? categoryId,
    bool clearMonth = false,
    bool clearCategory = false,
  }) {
    return ExpenseFilters(
      month: clearMonth ? null : (month ?? this.month),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
    );
  }
}

// Expenses state provider with filters
final expensesProvider = FutureProvider<List<Expense>>((ref) {
  final useCase = ref.watch(getExpensesUseCaseProvider);
  final filters = ref.watch(expenseFiltersProvider);
  return useCase.call(month: filters.month, categoryId: filters.categoryId);
});

// Expense addition controller
final addExpenseControllerProvider = StateNotifierProvider<AddExpenseController, AsyncValue<Expense?>>((ref) {
  final useCase = ref.watch(addExpenseUseCaseProvider);
  return AddExpenseController(useCase, ref);
});

class AddExpenseController extends StateNotifier<AsyncValue<Expense?>> {
  final AddExpenseUseCase _useCase;
  final Ref _ref;

  AddExpenseController(this._useCase, this._ref) : super(const AsyncValue.data(null));

  Future<void> addExpense({
    required double value,
    required String description,
    int? categoryId,
    DateTime? date,
  }) async {
    state = const AsyncValue.loading();
    try {
      final id = await _useCase.call(
        value: value,
        description: description,
        categoryId: categoryId,
        date: date,
      );
      
      final expense = Expense(
        id: id,
        value: value,
        description: description,
        categoryId: categoryId,
        date: date ?? DateTime.now(),
      );
      
      state = AsyncValue.data(expense);
      
      // Refresh expenses list
      _ref.invalidate(expensesProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

// Delete expense controller
final deleteExpenseControllerProvider = StateNotifierProvider<DeleteExpenseController, AsyncValue<void>>((ref) {
  final useCase = ref.watch(deleteExpenseUseCaseProvider);
  return DeleteExpenseController(useCase, ref);
});

class DeleteExpenseController extends StateNotifier<AsyncValue<void>> {
  final DeleteExpenseUseCase _useCase;
  final Ref _ref;

  DeleteExpenseController(this._useCase, this._ref) : super(const AsyncValue.data(null));

  Future<void> deleteExpense(int id) async {
    state = const AsyncValue.loading();
    try {
      await _useCase.call(id);
      state = const AsyncValue.data(null);
      
      // Refresh expenses list
      _ref.invalidate(expensesProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}