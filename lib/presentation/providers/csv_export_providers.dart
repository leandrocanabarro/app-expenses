import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/export_csv_usecase.dart';
import 'expense_providers.dart';
import 'category_providers.dart';

final exportCsvUsecaseProvider = Provider<ExportCsvUsecase>((ref) {
  final expenseRepository = ref.watch(expenseRepositoryProvider);
  final categoryRepository = ref.watch(categoryRepositoryProvider);
  return ExportCsvUsecase(expenseRepository, categoryRepository);
});

final csvExportControllerProvider = StateNotifierProvider<CsvExportController, AsyncValue<String?>>((ref) {
  final useCase = ref.watch(exportCsvUsecaseProvider);
  return CsvExportController(useCase);
});

class CsvExportController extends StateNotifier<AsyncValue<String?>> {
  final ExportCsvUsecase _useCase;

  CsvExportController(this._useCase) : super(const AsyncValue.data(null));

  Future<void> exportExpenses({DateTime? month, int? categoryId}) async {
    state = const AsyncValue.loading();
    try {
      final csvContent = await _useCase.exportExpenses(month: month, categoryId: categoryId);
      state = AsyncValue.data(csvContent);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> exportCategories() async {
    state = const AsyncValue.loading();
    try {
      final csvContent = await _useCase.exportCategories();
      state = AsyncValue.data(csvContent);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  String getExpensesFileName() {
    return _useCase.generateExpensesFileName();
  }
  
  String getCategoriesFileName() {
    return _useCase.generateCategoriesFileName();
  }
  
  void reset() {
    state = const AsyncValue.data(null);
  }
}