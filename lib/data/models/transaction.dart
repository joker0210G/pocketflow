import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class Transaction {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final String? note;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final bool isIncome;

  Transaction({
    required this.id,
    required this.amount,
    required this.category,
    this.note,
    required this.date,
    required this.isIncome,
  });

  Transaction copyWith({
    String? id,
    double? amount,
    String? category,
    String? note,
    DateTime? date,
    bool? isIncome,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      note: note ?? this.note,
      date: date ?? this.date,
      isIncome: isIncome ?? this.isIncome,
    );
  }
}
