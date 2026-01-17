import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'transaction_category.g.dart';

@HiveType(typeId: 3)
class TransactionCategory {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final bool isIncome; // true for income, false for expense

  @HiveField(3)
  final bool isDefault; // To prevent deleting default categories if needed

  TransactionCategory({
    String? id,
    required this.name,
    required this.isIncome,
    this.isDefault = false,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isIncome': isIncome,
      'isDefault': isDefault,
    };
  }

  factory TransactionCategory.fromJson(Map<String, dynamic> json) {
    return TransactionCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      isIncome: json['isIncome'] as bool,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }
}
