import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/currency_format.dart';
import '../../domain/entities/expense.dart';
import '../providers/category_providers.dart';
import '../providers/expense_providers.dart';
import '../screens/edit_expense_screen.dart';

class ExpenseList extends ConsumerWidget {
  final List<Expense> expenses;

  const ExpenseList({super.key, required this.expenses});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (expenses.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Nenhum gasto encontrado',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Adicione um gasto ou ajuste os filtros',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return ExpenseCard(expense: expense);
      },
    );
  }
}

class ExpenseCard extends ConsumerWidget {
  final Expense expense;

  const ExpenseCard({super.key, required this.expense});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.red.shade100,
          child: const Icon(Icons.shopping_bag, color: Colors.red),
        ),
        title: Text(
          expense.description,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            categoriesAsync.when(
              data: (categories) {
                final category = categories
                    .cast<dynamic>()
                    .firstWhere((cat) => cat?.id == expense.categoryId, orElse: () => null);
                return Text(category?.name ?? 'Sem categoria');
              },
              loading: () => const Text('Carregando...'),
              error: (_, __) => const Text('Sem categoria'),
            ),
            Text(
              DateFormat('dd/MM/yyyy', 'pt_BR').format(expense.date),
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyFormat.format(expense.value),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.red,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                  onPressed: () => _navigateToEdit(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () => _showDeleteDialog(context, ref),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Gasto'),
        content: const Text('Tem certeza que deseja excluir este gasto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              if (expense.id != null) {
                ref.read(deleteExpenseControllerProvider.notifier).deleteExpense(expense.id!);
              }
              Navigator.pop(context);
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _navigateToEdit(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditExpenseScreen(expense: expense),
      ),
    );
  }
}