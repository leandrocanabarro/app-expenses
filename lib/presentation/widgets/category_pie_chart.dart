import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/currency_format.dart';
import '../providers/expense_providers.dart';
import '../providers/category_providers.dart';

class CategoryPieChart extends ConsumerWidget {
  const CategoryPieChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Gastos por Categoria',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: expensesAsync.when(
                data: (expenses) => categoriesAsync.when(
                  data: (categories) => _buildPieChart(context, expenses, categories),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Text('Erro ao carregar categorias: $error'),
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Text('Erro ao carregar gastos: $error'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(BuildContext context, List expenses, List categories) {
    if (expenses.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum gasto registrado',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // Group expenses by category
    final Map<String, double> categoryExpenses = {};
    double totalExpenses = 0;

    // Add "Sem categoria" for expenses without category
    categoryExpenses['Sem categoria'] = 0.0;

    // Initialize categories with 0 values
    for (final category in categories) {
      categoryExpenses[category.name] = 0.0;
    }

    // Sum expenses by category
    for (final expense in expenses) {
      totalExpenses += expense.value;
      if (expense.categoryId != null) {
        final category = categories.firstWhere(
          (cat) => cat.id == expense.categoryId,
          orElse: () => null,
        );
        if (category != null) {
          categoryExpenses[category.name] = categoryExpenses[category.name]! + expense.value;
        } else {
          categoryExpenses['Sem categoria'] = categoryExpenses['Sem categoria']! + expense.value;
        }
      } else {
        categoryExpenses['Sem categoria'] = categoryExpenses['Sem categoria']! + expense.value;
      }
    }

    // Remove categories with 0 expenses
    categoryExpenses.removeWhere((key, value) => value == 0.0);

    if (categoryExpenses.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum dado disponível',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // Create pie chart sections
    final List<PieChartSectionData> sections = [];
    final List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
    ];

    int colorIndex = 0;
    for (final entry in categoryExpenses.entries) {
      final percentage = (entry.value / totalExpenses) * 100;
      sections.add(
        PieChartSectionData(
          color: colors[colorIndex % colors.length],
          value: entry.value,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      colorIndex++;
    }

    return Row(
      children: [
        // Pie Chart
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        // Legend
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: categoryExpenses.entries.map((entry) {
              final colorIndex = categoryExpenses.keys.toList().indexOf(entry.key);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: colors[colorIndex % colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            CurrencyFormat.format(entry.value),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}