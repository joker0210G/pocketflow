import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants.dart';
import '../models/transaction_category.dart';

class CategoryRepository {
  Future<Box<TransactionCategory>> _openBox() async {
    return await Hive.openBox<TransactionCategory>(AppConstants.categoriesBox);
  }

  Future<List<TransactionCategory>> getCategories() async {
    final box = await _openBox();
    return box.values.toList();
  }

  Future<void> addCategory(TransactionCategory category) async {
    final box = await _openBox();
    await box.put(category.id, category);
  }

  Future<void> deleteCategory(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }
}
