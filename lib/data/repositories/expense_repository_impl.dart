import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/database_service.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final DatabaseService databaseService;

  const ExpenseRepositoryImpl(this.databaseService);

  @override
  Future<int> add(Expense expense) async {
    final db = await databaseService.database;
    final model = ExpenseModel.fromEntity(expense);
    return await db.insert('expenses', model.toMap());
  }

  @override
  Future<List<Expense>> list({DateTime? month, int? categoryId}) async {
    final db = await databaseService.database;
    
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (month != null) {
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59, 999);
      
      whereClause += 'date >= ? AND date <= ?';
      whereArgs.addAll([startOfMonth.toIso8601String(), endOfMonth.toIso8601String()]);
    }

    if (categoryId != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'category_id = ?';
      whereArgs.add(categoryId);
    }

    final maps = await db.query(
      'expenses',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'date DESC',
    );

    return maps.map((map) => ExpenseModel.fromMap(map).toEntity()).toList();
  }

  @override
  Future<void> delete(int id) async {
    final db = await databaseService.database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<Expense?> findById(int id) async {
    final db = await databaseService.database;
    final maps = await db.query(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (maps.isEmpty) return null;
    return ExpenseModel.fromMap(maps.first).toEntity();
  }
}