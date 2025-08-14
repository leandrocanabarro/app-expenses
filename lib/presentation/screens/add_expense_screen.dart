import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/category_providers.dart';
import '../providers/expense_providers.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  int? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _valueController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final addExpenseState = ref.watch(addExpenseControllerProvider);

    ref.listen(addExpenseControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (expense) {
          if (expense != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Gasto adicionado com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );
            context.pop();
          }
        },
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao adicionar gasto: $error'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Gasto'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Value field
              TextFormField(
                controller: _valueController,
                decoration: const InputDecoration(
                  labelText: 'Valor',
                  prefixText: 'R\$ ',
                  border: OutlineInputBorder(),
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
                  onPressed: addExpenseState.isLoading ? null : _saveExpense,
                  child: addExpenseState.isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Salvar Gasto'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      final value = double.parse(_valueController.text.replaceAll(',', '.'));
      final description = _descriptionController.text.trim();
      
      ref.read(addExpenseControllerProvider.notifier).addExpense(
        value: value,
        description: description,
        categoryId: _selectedCategoryId,
        date: _selectedDate,
      );
    }
  }
}