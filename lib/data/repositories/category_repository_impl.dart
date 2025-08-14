import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/database_service.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final DatabaseService databaseService;

  const CategoryRepositoryImpl(this.databaseService);

  @override
  Future<int> add(Category category) async {
    final db = await databaseService.database;
    final model = CategoryModel.fromEntity(category);
    return await db.insert('categories', model.toMap());
  }

  @override
  Future<List<Category>> list() async {
    final db = await databaseService.database;
    final maps = await db.query('categories', orderBy: 'name');
    return maps.map((map) => CategoryModel.fromMap(map).toEntity()).toList();
  }

  @override
  Future<Category?> findById(int id) async {
    final db = await databaseService.database;
    final maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (maps.isEmpty) return null;
    return CategoryModel.fromMap(maps.first).toEntity();
  }

  @override
  Future<Category?> findByName(String name) async {
    final db = await databaseService.database;
    final maps = await db.query(
      'categories',
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );
    
    if (maps.isEmpty) return null;
    return CategoryModel.fromMap(maps.first).toEntity();
  }
}