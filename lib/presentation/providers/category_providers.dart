import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/database_service.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/usecases/add_category_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';

// Database service provider
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

// Repository provider
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return CategoryRepositoryImpl(databaseService);
});

// Use cases providers
final addCategoryUseCaseProvider = Provider<AddCategoryUseCase>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return AddCategoryUseCase(repository);
});

final getCategoriesUseCaseProvider = Provider<GetCategoriesUseCase>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return GetCategoriesUseCase(repository);
});

// Categories state provider
final categoriesProvider = FutureProvider<List<Category>>((ref) {
  final useCase = ref.watch(getCategoriesUseCaseProvider);
  return useCase.call();
});

// Category addition controller
final addCategoryControllerProvider = StateNotifierProvider<AddCategoryController, AsyncValue<Category?>>((ref) {
  final useCase = ref.watch(addCategoryUseCaseProvider);
  return AddCategoryController(useCase, ref);
});

class AddCategoryController extends StateNotifier<AsyncValue<Category?>> {
  final AddCategoryUseCase _useCase;
  final Ref _ref;

  AddCategoryController(this._useCase, this._ref) : super(const AsyncValue.data(null));

  Future<void> addCategory(String name) async {
    state = const AsyncValue.loading();
    try {
      final id = await _useCase.call(name);
      final category = Category(id: id, name: name);
      state = AsyncValue.data(category);
      
      // Refresh categories list
      _ref.invalidate(categoriesProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}