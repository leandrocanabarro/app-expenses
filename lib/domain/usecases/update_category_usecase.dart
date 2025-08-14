import '../entities/category.dart';
import '../repositories/category_repository.dart';

class UpdateCategoryUsecase {
  final CategoryRepository repository;

  const UpdateCategoryUsecase(this.repository);

  Future<void> call(Category category) async {
    if (category.id == null) {
      throw ArgumentError('Cannot update category without id');
    }
    return await repository.update(category);
  }
}