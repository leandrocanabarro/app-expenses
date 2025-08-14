import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/currency_format.dart';
import '../providers/expense_providers.dart';
import '../providers/voice_provider.dart';
import '../widgets/expense_list.dart';
import '../widgets/voice_mic_button.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize voice service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(voiceStateProvider.notifier).initialize();
    });
  }

  double _calculateMonthTotal(List<dynamic> expenses) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    
    return expenses
        .where((expense) => 
            expense.date.year == currentMonth.year &&
            expense.date.month == currentMonth.month)
        .fold(0.0, (sum, expense) => sum + expense.value);
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expensesProvider);
    final filters = ref.watch(expenseFiltersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Expenses'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Categorias'),
                onTap: () => context.push('/categories'),
              ),
              PopupMenuItem(
                child: const Text('Relatórios'),
                onTap: () => context.push('/report'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Month total card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total do mês:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  expensesAsync.when(
                    data: (expenses) => Text(
                      CurrencyFormat.format(_calculateMonthTotal(expenses)),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (error, _) => Text('Erro: $error'),
                  ),
                ],
              ),
            ),
          ),
          
          // Filters
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showMonthFilter(context),
                    icon: const Icon(Icons.calendar_month),
                    label: Text(filters.month != null 
                        ? DateFormat('MMM yyyy', 'pt_BR').format(filters.month!)
                        : 'Todos os meses'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _showCategoryFilter(context),
                  icon: const Icon(Icons.category),
                  label: const Text('Categoria'),
                ),
              ],
            ),
          ),
          
          // Expenses list
          Expanded(
            child: expensesAsync.when(
              data: (expenses) => ExpenseList(expenses: expenses),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Erro ao carregar gastos:\n$error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(expensesProvider),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          VoiceMicButton(),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () => context.push('/add'),
            heroTag: 'add_expense',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  void _showMonthFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Todos os meses'),
              onTap: () {
                ref.read(expenseFiltersProvider.notifier).state = 
                    ref.read(expenseFiltersProvider).copyWith(clearMonth: true);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Este mês'),
              onTap: () {
                final now = DateTime.now();
                ref.read(expenseFiltersProvider.notifier).state = 
                    ref.read(expenseFiltersProvider).copyWith(month: DateTime(now.year, now.month));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Mês anterior'),
              onTap: () {
                final now = DateTime.now();
                final lastMonth = DateTime(now.year, now.month - 1);
                ref.read(expenseFiltersProvider.notifier).state = 
                    ref.read(expenseFiltersProvider).copyWith(month: lastMonth);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryFilter(BuildContext context) {
    // TODO: Implement category filter
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filtro por categoria em desenvolvimento')),
    );
  }
}