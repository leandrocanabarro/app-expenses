import 'package:flutter/material.dart';
import '../../domain/entities/category.dart';

class CategoryList extends StatelessWidget {
  final List<Category> categories;
  final VoidCallback? onCategoryTap;

  const CategoryList({
    super.key,
    required this.categories,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const Center(
        child: Text('Nenhuma categoria encontrada'),
      );
    }

    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return ListTile(
          leading: const Icon(Icons.category),
          title: Text(category.name),
          onTap: onCategoryTap,
        );
      },
    );
  }
}