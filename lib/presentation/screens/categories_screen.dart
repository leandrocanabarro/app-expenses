import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/category.dart';
import '../providers/category_providers.dart';
import '../providers/csv_export_providers.dart';

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
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Exportar CSV'),
                onTap: () => _exportCategories(context, ref),
              ),
            ],
          ),
        ],
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
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showEditDialog(context, category),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _showDeleteDialog(context, category.name, category.id!),
                          ),
                        ],
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

  void _showDeleteDialog(BuildContext context, String categoryName, int categoryId) {
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
              ref.read(deleteCategoryControllerProvider.notifier).deleteCategory(categoryId);
              Navigator.pop(context);
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, Category category) {
    final controller = TextEditingController(text: category.name);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Categoria'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nome da categoria',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (value) => _updateCategory(context, ref, category, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => _updateCategory(context, ref, category, controller.text.trim()),
            child: const Text('Atualizar'),
          ),
        ],
      ),
    );
  }

  void _updateCategory(BuildContext context, WidgetRef ref, Category category, String newName) {
    if (newName.isNotEmpty) {
      final updatedCategory = category.copyWith(name: newName);
      ref.read(updateCategoryControllerProvider.notifier).updateCategory(updatedCategory);
      Navigator.pop(context);
    }
  }

  void _exportCategories(BuildContext context, WidgetRef ref) {
    ref.read(csvExportControllerProvider.notifier).exportCategories();

    ref.listen<AsyncValue<String?>>(csvExportControllerProvider, (previous, next) {
      next.when(
        data: (csvContent) {
          if (csvContent != null) {
            _downloadCsv(csvContent, ref.read(csvExportControllerProvider.notifier).getCategoriesFileName());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Categorias exportadas com sucesso!')),
            );
            ref.read(csvExportControllerProvider.notifier).reset();
          }
        },
        loading: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gerando arquivo CSV...')),
          );
        },
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao exportar: $error')),
          );
        },
      );
    });
  }

  void _downloadCsv(String csvContent, String fileName) {
    // Simple approach - just show the CSV content in a dialog for now
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('CSV Exportado: $fileName'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: SingleChildScrollView(
            child: SelectableText(
              csvContent,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}