import '../entities/category.dart';
import '../repositories/category_repository.dart';

class AddCategoryUseCase {
  final CategoryRepository repository;

  const AddCategoryUseCase(this.repository);

  Future<int> call(String name) async {
    if (name.trim().isEmpty) {
      throw ArgumentError('Category name cannot be empty');
    }

    final trimmedName = name.trim();
    final existing = await repository.findByName(trimmedName);
    if (existing != null) {
      throw ArgumentError('Category with name "$trimmedName" already exists');
    }

    final category = Category(name: trimmedName);
    return await repository.add(category);
  }
}