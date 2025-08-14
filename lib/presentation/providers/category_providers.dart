import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/database_service.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/usecases/add_category_usecase.dart';
import '../../domain/usecases/update_category_usecase.dart';
import '../../domain/usecases/delete_category_usecase.dart';
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

final updateCategoryUseCaseProvider = Provider<UpdateCategoryUsecase>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return UpdateCategoryUsecase(repository);
});

final deleteCategoryUseCaseProvider = Provider<DeleteCategoryUsecase>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return DeleteCategoryUsecase(repository);
});

// Categories state provider
final categoriesProvider = FutureProvider<List<Category>>((ref) {
  final useCase = ref.watch(getCategoriesUseCaseProvider);
  return useCase.call();
});

// Category by ID provider
final categoryByIdProvider = FutureProvider.family<Category?, int>((ref, id) async {
  final repository = ref.watch(categoryRepositoryProvider);
  return await repository.findById(id);
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

// Update category controller
final updateCategoryControllerProvider = StateNotifierProvider<UpdateCategoryController, AsyncValue<void>>((ref) {
  final useCase = ref.watch(updateCategoryUseCaseProvider);
  return UpdateCategoryController(useCase, ref);
});

class UpdateCategoryController extends StateNotifier<AsyncValue<void>> {
  final UpdateCategoryUsecase _useCase;
  final Ref _ref;

  UpdateCategoryController(this._useCase, this._ref) : super(const AsyncValue.data(null));

  Future<void> updateCategory(Category category) async {
    state = const AsyncValue.loading();
    try {
      await _useCase.call(category);
      state = const AsyncValue.data(null);
      
      // Refresh categories list
      _ref.invalidate(categoriesProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Delete category controller
final deleteCategoryControllerProvider = StateNotifierProvider<DeleteCategoryController, AsyncValue<void>>((ref) {
  final useCase = ref.watch(deleteCategoryUseCaseProvider);
  return DeleteCategoryController(useCase, ref);
});

class DeleteCategoryController extends StateNotifier<AsyncValue<void>> {
  final DeleteCategoryUsecase _useCase;
  final Ref _ref;

  DeleteCategoryController(this._useCase, this._ref) : super(const AsyncValue.data(null));

  Future<void> deleteCategory(int id) async {
    state = const AsyncValue.loading();
    try {
      await _useCase.call(id);
      state = const AsyncValue.data(null);
      
      // Refresh categories list
      _ref.invalidate(categoriesProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}