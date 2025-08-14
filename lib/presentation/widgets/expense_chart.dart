import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/expense_providers.dart';

class ExpenseChart extends ConsumerWidget {
  const ExpenseChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Gastos dos Últimos 6 Meses',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: expensesAsync.when(
                data: (expenses) => _buildChart(expenses),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Text('Erro ao carregar dados: $error'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(List expenses) {
    if (expenses.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum dado disponível',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // Group expenses by month
    final Map<String, double> monthlyExpenses = {};
    final now = DateTime.now();
    
    // Initialize last 6 months with 0 values
    for (int i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthKey = DateFormat('MMM').format(date);
      monthlyExpenses[monthKey] = 0.0;
    }

    // Sum expenses by month
    for (final expense in expenses) {
      final expenseDate = expense.date as DateTime;
      final monthKey = DateFormat('MMM').format(expenseDate);
      if (monthlyExpenses.containsKey(monthKey)) {
        monthlyExpenses[monthKey] = monthlyExpenses[monthKey]! + expense.value;
      }
    }

    final spots = monthlyExpenses.entries
        .toList()
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.value))
        .toList();

    final maxY = monthlyExpenses.values.isEmpty 
        ? 100.0 
        : monthlyExpenses.values.reduce((a, b) => a > b ? a : b) * 1.1;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: maxY / 5,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade300,
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey.shade300,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (double value, TitleMeta meta) {
                final index = value.toInt();
                if (index < 0 || index >= monthlyExpenses.length) {
                  return const Text('');
                }
                final monthKey = monthlyExpenses.keys.elementAt(index);
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    monthKey,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: maxY / 5,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  'R\$ ${value.toInt()}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                );
              },
              reservedSize: 60,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade300),
        ),
        minX: 0,
        maxX: (monthlyExpenses.length - 1).toDouble(),
        minY: 0,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                Colors.red.shade400,
                Colors.red.shade600,
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.red.shade100.withOpacity(0.3),
                  Colors.red.shade200.withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}