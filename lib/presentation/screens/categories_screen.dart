import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/category_providers.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final addCategoryState = ref.watch(addCategoryControllerProvider);

    ref.listen(addCategoryControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (category) {
          if (category != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Categoria "${category.name}" criada com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );
            ref.read(addCategoryControllerProvider.notifier).reset();
          }
        },
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao criar categoria: $error'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias'),
      ),
      body: categoriesAsync.when(
        data: (categories) => categories.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.category, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Nenhuma categoria encontrada',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Toque no botão + para criar uma categoria',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.category),
                      ),
                      title: Text(category.name),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteDialog(context, category.name),
                      ),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erro ao carregar categorias:\n$error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(categoriesProvider),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context, ref),
        child: addCategoryState.isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.add),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova Categoria'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nome da categoria',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (value) => _addCategory(context, ref, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => _addCategory(context, ref, controller.text.trim()),
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  void _addCategory(BuildContext context, WidgetRef ref, String name) {
    if (name.isNotEmpty) {
      ref.read(addCategoryControllerProvider.notifier).addCategory(name);
      Navigator.pop(context);
    }
  }

  void _showDeleteDialog(BuildContext context, String categoryName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Categoria'),
        content: Text('Tem certeza que deseja excluir a categoria "$categoryName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              // TODO: Implement category deletion
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exclusão de categoria em desenvolvimento')),
              );
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}