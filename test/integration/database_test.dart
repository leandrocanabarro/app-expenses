import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:app_expenses/data/datasources/database_service.dart';
import 'package:app_expenses/data/repositories/category_repository_impl.dart';
import 'package:app_expenses/data/repositories/expense_repository_impl.dart';
import 'package:app_expenses/domain/entities/category.dart';
import 'package:app_expenses/domain/entities/expense.dart';

void main() {
  setUpAll(() {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory for unit testing
    databaseFactory = databaseFactoryFfi;
  });

  group('Database Integration Tests', () {
    late DatabaseService databaseService;
    late CategoryRepositoryImpl categoryRepository;
    late ExpenseRepositoryImpl expenseRepository;

    setUp(() async {
      databaseService = DatabaseService();
      categoryRepository = CategoryRepositoryImpl(databaseService);
      expenseRepository = ExpenseRepositoryImpl(databaseService);
    });

    tearDown(() async {
      await databaseService.close();
    });

    test('should create and retrieve categories', () async {
      // Arrange
      const category = Category(name: 'Test Category');

      // Act
      final id = await categoryRepository.add(category);
      final categories = await categoryRepository.list();
      final foundCategory = await categoryRepository.findById(id);

      // Assert
      expect(id, greaterThan(0));
      expect(categories, isNotEmpty);
      expect(foundCategory, isNotNull);
      expect(foundCategory!.name, equals('Test Category'));
    });

    test('should prevent duplicate category names', () async {
      // Arrange
      const category1 = Category(name: 'Duplicate');
      const category2 = Category(name: 'Duplicate');

      // Act
      await categoryRepository.add(category1);
      
      // Assert
      expect(
        () => categoryRepository.add(category2),
        throwsException,
      );
    });

    test('should create and retrieve expenses', () async {
      // Arrange
      final now = DateTime.now();
      final expense = Expense(
        value: 50.0,
        description: 'Test Expense',
        date: now,
      );

      // Act
      final id = await expenseRepository.add(expense);
      final expenses = await expenseRepository.list();
      final foundExpense = await expenseRepository.findById(id);

      // Assert
      expect(id, greaterThan(0));
      expect(expenses, isNotEmpty);
      expect(foundExpense, isNotNull);
      expect(foundExpense!.value, equals(50.0));
      expect(foundExpense.description, equals('Test Expense'));
    });

    test('should create expense with category reference', () async {
      // Arrange
      const category = Category(name: 'Food');
      final categoryId = await categoryRepository.add(category);
      
      final expense = Expense(
        value: 25.0,
        description: 'Lunch',
        categoryId: categoryId,
        date: DateTime.now(),
      );

      // Act
      final expenseId = await expenseRepository.add(expense);
      final foundExpense = await expenseRepository.findById(expenseId);

      // Assert
      expect(foundExpense, isNotNull);
      expect(foundExpense!.categoryId, equals(categoryId));
    });

    test('should filter expenses by month', () async {
      // Arrange
      final thisMonth = DateTime.now();
      final lastMonth = DateTime(thisMonth.year, thisMonth.month - 1);
      
      final expense1 = Expense(
        value: 50.0,
        description: 'This month',
        date: thisMonth,
      );
      
      final expense2 = Expense(
        value: 30.0,
        description: 'Last month',
        date: lastMonth,
      );

      await expenseRepository.add(expense1);
      await expenseRepository.add(expense2);

      // Act
      final thisMonthExpenses = await expenseRepository.list(month: thisMonth);
      final lastMonthExpenses = await expenseRepository.list(month: lastMonth);

      // Assert
      expect(thisMonthExpenses, hasLength(1));
      expect(lastMonthExpenses, hasLength(1));
      expect(thisMonthExpenses.first.description, equals('This month'));
      expect(lastMonthExpenses.first.description, equals('Last month'));
    });

    test('should delete expenses', () async {
      // Arrange
      final expense = Expense(
        value: 100.0,
        description: 'To be deleted',
        date: DateTime.now(),
      );
      
      final id = await expenseRepository.add(expense);

      // Act
      await expenseRepository.delete(id);
      final foundExpense = await expenseRepository.findById(id);

      // Assert
      expect(foundExpense, isNull);
    });
  });
}