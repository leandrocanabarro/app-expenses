import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_expenses/presentation/screens/add_expense_screen.dart';

void main() {
  group('AddExpenseScreen Widget Tests', () {
    testWidgets('should display all form fields', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AddExpenseScreen(),
          ),
        ),
      );

      // Verify form fields are present
      expect(find.byType(TextFormField), findsNWidgets(2)); // Value and description
      expect(find.byType(DropdownButtonFormField), findsOneWidget); // Category
      expect(find.text('Valor'), findsOneWidget);
      expect(find.text('Descrição'), findsOneWidget);
      expect(find.text('Categoria (opcional)'), findsOneWidget);
      expect(find.text('Data'), findsOneWidget);
      expect(find.text('Salvar Gasto'), findsOneWidget);
    });

    testWidgets('should validate required fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AddExpenseScreen(),
          ),
        ),
      );

      // Try to save without filling fields
      await tester.tap(find.text('Salvar Gasto'));
      await tester.pump();

      // Should show validation errors
      expect(find.text('Por favor, insira um valor'), findsOneWidget);
      expect(find.text('Por favor, insira uma descrição'), findsOneWidget);
    });

    testWidgets('should fill form and attempt to save', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AddExpenseScreen(),
          ),
        ),
      );

      // Fill the form
      await tester.enterText(find.byType(TextFormField).first, '50.00');
      await tester.enterText(find.byType(TextFormField).last, 'Test expense');
      
      // Tap save button
      await tester.tap(find.text('Salvar Gasto'));
      await tester.pump();

      // The form should be valid (no validation errors visible)
      expect(find.text('Por favor, insira um valor'), findsNothing);
      expect(find.text('Por favor, insira uma descrição'), findsNothing);
    });

    testWidgets('should validate invalid values', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AddExpenseScreen(),
          ),
        ),
      );

      // Enter invalid value
      await tester.enterText(find.byType(TextFormField).first, '0');
      await tester.enterText(find.byType(TextFormField).last, 'Test');
      
      await tester.tap(find.text('Salvar Gasto'));
      await tester.pump();

      expect(find.text('Por favor, insira um valor válido maior que zero'), findsOneWidget);
    });
  });
}