import '../repositories/category_repository.dart';

class DeleteCategoryUsecase {
  final CategoryRepository repository;

  const DeleteCategoryUsecase(this.repository);

  Future<void> call(int id) async {
    return await repository.delete(id);
  }
}