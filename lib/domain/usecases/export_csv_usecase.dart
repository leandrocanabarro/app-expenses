import '../../data/services/csv_export_service.dart';
import '../entities/expense.dart';
import '../entities/category.dart';
import '../repositories/expense_repository.dart';
import '../repositories/category_repository.dart';

class ExportCsvUsecase {
  final ExpenseRepository expenseRepository;
  final CategoryRepository categoryRepository;

  const ExportCsvUsecase(this.expenseRepository, this.categoryRepository);

  Future<String> exportExpenses({DateTime? month, int? categoryId}) async {
    final expenses = await expenseRepository.list(month: month, categoryId: categoryId);
    final categories = await categoryRepository.list();
    
    return CsvExportService.generateExpensesCsv(expenses, categories);
  }
  
  Future<String> exportCategories() async {
    final categories = await categoryRepository.list();
    return CsvExportService.generateCategoriesCsv(categories);
  }
  
  String generateExpensesFileName() {
    return CsvExportService.generateFileName('gastos');
  }
  
  String generateCategoriesFileName() {
    return CsvExportService.generateFileName('categorias');
  }
}