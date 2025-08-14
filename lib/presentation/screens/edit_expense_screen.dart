import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/expense.dart';
import '../providers/category_providers.dart';
import '../providers/expense_providers.dart';

class EditExpenseScreen extends ConsumerStatefulWidget {
  final Expense expense;

  const EditExpenseScreen({super.key, required this.expense});

  @override
  ConsumerState<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends ConsumerState<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _valueController;
  late final TextEditingController _descriptionController;
  late int? _selectedCategoryId;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _valueController = TextEditingController(text: widget.expense.value.toString());
    _descriptionController = TextEditingController(text: widget.expense.description);
    _selectedCategoryId = widget.expense.categoryId;
    _selectedDate = widget.expense.date;
  }

  @override
  void dispose() {
    _valueController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final updateExpenseState = ref.watch(updateExpenseControllerProvider);

    ref.listen<AsyncValue<void>>(updateExpenseControllerProvider, (previous, next) {
      next.when(
        data: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gasto atualizado com sucesso!')),
          );
          context.pop();
        },
        loading: () {},
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao atualizar gasto: $error')),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Gasto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Value field
              TextFormField(
                controller: _valueController,
                decoration: const InputDecoration(
                  labelText: 'Valor (R\$)',
                  border: OutlineInputBorder(),
                  prefixText: 'R\$ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um valor';
                  }
                  final doubleValue = double.tryParse(value.replaceAll(',', '.'));
                  if (doubleValue == null || doubleValue <= 0) {
                    return 'Por favor, insira um valor válido maior que zero';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira uma descrição';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Category dropdown
              categoriesAsync.when(
                data: (categories) => DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Categoria (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedCategoryId,
                  items: [
                    const DropdownMenuItem<int>(
                      value: null,
                      child: Text('Sem categoria'),
                    ),
                    ...categories.map((category) => DropdownMenuItem<int>(
                      value: category.id,
                      child: Text(category.name),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Text('Erro ao carregar categorias: $error'),
              ),
              const SizedBox(height: 16),
              
              // Date picker
              ListTile(
                title: const Text('Data'),
                subtitle: Text(_selectedDate.toString().split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                    });
                  }
                },
              ),
              
              const Spacer(),
              
              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: updateExpenseState.isLoading ? null : _updateExpense,
                  child: updateExpenseState.isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Atualizar Gasto'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateExpense() {
    if (_formKey.currentState!.validate()) {
      final value = double.parse(_valueController.text.replaceAll(',', '.'));
      final description = _descriptionController.text.trim();
      
      final updatedExpense = widget.expense.copyWith(
        value: value,
        description: description,
        categoryId: _selectedCategoryId,
        date: _selectedDate,
      );
      
      ref.read(updateExpenseControllerProvider.notifier).updateExpense(updatedExpense);
    }
  }
}