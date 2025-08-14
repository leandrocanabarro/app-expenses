import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    super.id,
    required super.name,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as int?,
      name: map['name'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
    };
  }

  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
    );
  }

  Category toEntity() {
    return Category(
      id: id,
      name: name,
    );
  }
}