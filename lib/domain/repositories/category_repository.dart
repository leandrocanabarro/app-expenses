import '../entities/category.dart';

abstract class CategoryRepository {
  Future<int> add(Category category);
  Future<List<Category>> list();
  Future<Category?> findById(int id);
  Future<Category?> findByName(String name);
}