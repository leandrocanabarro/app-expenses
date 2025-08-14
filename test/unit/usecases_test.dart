import 'package:flutter_test/flutter_test.dart';
import 'package:app_expenses/domain/usecases/add_expense_usecase.dart';
import 'package:app_expenses/domain/usecases/add_category_usecase.dart';
import 'package:app_expenses/domain/entities/expense.dart';
import 'package:app_expenses/domain/entities/category.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_expenses/domain/repositories/expense_repository.dart';
import 'package:app_expenses/domain/repositories/category_repository.dart';

class MockExpenseRepository extends Mock implements ExpenseRepository {}
class MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  group('AddExpenseUseCase', () {
    late AddExpenseUseCase useCase;
    late MockExpenseRepository mockRepository;

    setUp(() {
      mockRepository = MockExpenseRepository();
      useCase = AddExpenseUseCase(mockRepository);
    });

    test('should add expense successfully', () async {
      // Arrange
      const expectedId = 1;
      when(() => mockRepository.add(any())).thenAnswer((_) async => expectedId);

      // Act
      final result = await useCase.call(
        value: 50.0,
        description: 'Test expense',
        categoryId: 1,
      );

      // Assert
      expect(result, equals(expectedId));
      verify(() => mockRepository.add(any())).called(1);
    });

    test('should throw error for invalid value', () async {
      // Act & Assert
      expect(
        () => useCase.call(value: 0, description: 'Test'),
        throwsA(isA<ArgumentError>()),
      );
      
      expect(
        () => useCase.call(value: -10, description: 'Test'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should throw error for empty description', () async {
      // Act & Assert
      expect(
        () => useCase.call(value: 50, description: ''),
        throwsA(isA<ArgumentError>()),
      );
      
      expect(
        () => useCase.call(value: 50, description: '   '),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('AddCategoryUseCase', () {
    late AddCategoryUseCase useCase;
    late MockCategoryRepository mockRepository;

    setUp(() {
      mockRepository = MockCategoryRepository();
      useCase = AddCategoryUseCase(mockRepository);
    });

    test('should add category successfully', () async {
      // Arrange
      const expectedId = 1;
      when(() => mockRepository.findByName(any())).thenAnswer((_) async => null);
      when(() => mockRepository.add(any())).thenAnswer((_) async => expectedId);

      // Act
      final result = await useCase.call('Test Category');

      // Assert
      expect(result, equals(expectedId));
      verify(() => mockRepository.findByName('Test Category')).called(1);
      verify(() => mockRepository.add(any())).called(1);
    });

    test('should throw error for empty name', () async {
      // Act & Assert
      expect(
        () => useCase.call(''),
        throwsA(isA<ArgumentError>()),
      );
      
      expect(
        () => useCase.call('   '),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should throw error for duplicate name', () async {
      // Arrange
      const existingCategory = Category(id: 1, name: 'Existing');
      when(() => mockRepository.findByName(any())).thenAnswer((_) async => existingCategory);

      // Act & Assert
      expect(
        () => useCase.call('Existing'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}