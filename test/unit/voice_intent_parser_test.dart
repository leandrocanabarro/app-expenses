import 'package:flutter_test/flutter_test.dart';
import 'package:app_expenses/data/services/voice_intent_parser.dart';

void main() {
  group('VoiceIntentParser', () {
    test('should parse create category intent', () {
      const testCases = [
        'criar categoria alimentação',
        'nova categoria transporte',
        'CRIAR CATEGORIA Lazer',
      ];

      for (final testCase in testCases) {
        final intent = VoiceIntentParser.parse(testCase);
        expect(intent, isA<CreateCategory>());
        
        final createCategory = intent as CreateCategory;
        expect(createCategory.name, isNotEmpty);
      }
    });

    test('should parse add expense intent with value and description', () {
      const testCases = [
        'adicionar gasto 50 almoço',
        'gastei 25,90 em café',
        'lançar gasto 100,50 supermercado',
      ];

      for (final testCase in testCases) {
        final intent = VoiceIntentParser.parse(testCase);
        expect(intent, isA<AddExpense>());
        
        final addExpense = intent as AddExpense;
        expect(addExpense.value, greaterThan(0));
        expect(addExpense.description, isNotEmpty);
      }
    });

    test('should parse expense with currency symbols', () {
      const testCases = [
        'adicionar gasto R\$ 50,90 jantar',
        'gastei R\$ 25 em lanche',
        'lançar gasto 15 reais café',
      ];

      for (final testCase in testCases) {
        final intent = VoiceIntentParser.parse(testCase);
        expect(intent, isA<AddExpense>());
        
        final addExpense = intent as AddExpense;
        expect(addExpense.value, greaterThan(0));
      }
    });

    test('should parse expense with category', () {
      const text = 'adicionar gasto 50 almoço na categoria alimentação';
      final intent = VoiceIntentParser.parse(text);
      
      expect(intent, isA<AddExpense>());
      final addExpense = intent as AddExpense;
      expect(addExpense.value, equals(50));
      expect(addExpense.description, equals('almoço'));
      expect(addExpense.categoryName, equals('alimentação'));
    });

    test('should return Unknown for unrecognized commands', () {
      const testCases = [
        'como está o tempo hoje',
        'toque uma música',
        'qual é o meu saldo',
        '',
        '   ',
      ];

      for (final testCase in testCases) {
        final intent = VoiceIntentParser.parse(testCase);
        expect(intent, isA<Unknown>());
      }
    });

    test('should handle different number formats', () {
      const testCases = [
        ('50', 50.0),
        ('50,90', 50.90),
        ('50.90', 50.90),
        ('1.000,50', 1000.50),
        ('1000', 1000.0),
      ];

      for (final (input, expected) in testCases) {
        final intent = VoiceIntentParser.parse('adicionar gasto $input teste');
        expect(intent, isA<AddExpense>());
        
        final addExpense = intent as AddExpense;
        expect(addExpense.value, closeTo(expected, 0.01));
      }
    });
  });
}