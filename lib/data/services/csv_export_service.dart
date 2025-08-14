import 'dart:io';
import 'package:intl/intl.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/category.dart';

class CsvExportService {
  static String generateExpensesCsv(List<Expense> expenses, List<Category> categories) {
    final StringBuffer csv = StringBuffer();
    
    // CSV Header
    csv.writeln('Data,Descrição,Valor,Categoria');
    
    // CSV Rows
    for (final expense in expenses) {
      final date = DateFormat('dd/MM/yyyy').format(expense.date);
      final description = _escapeCsvField(expense.description);
      final value = expense.value.toStringAsFixed(2).replaceAll('.', ',');
      
      String categoryName = 'Sem categoria';
      if (expense.categoryId != null) {
        final category = categories.firstWhere(
          (cat) => cat.id == expense.categoryId,
          orElse: () => Category(name: 'Sem categoria'),
        );
        categoryName = category.name;
      }
      
      csv.writeln('$date,$description,$value,${_escapeCsvField(categoryName)}');
    }
    
    return csv.toString();
  }
  
  static String generateCategoriesCsv(List<Category> categories) {
    final StringBuffer csv = StringBuffer();
    
    // CSV Header
    csv.writeln('ID,Nome');
    
    // CSV Rows
    for (final category in categories) {
      csv.writeln('${category.id},${_escapeCsvField(category.name)}');
    }
    
    return csv.toString();
  }
  
  static String _escapeCsvField(String field) {
    // Escape fields that contain commas, quotes, or newlines
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }
  
  static String generateFileName(String prefix) {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd_HH-mm-ss').format(now);
    return '${prefix}_$dateStr.csv';
  }
}