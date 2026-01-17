import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'bill.g.dart';

@HiveType(typeId: 2)
class Bill {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final bool isRecurring; // Default true (e.g. Rent), vs false (One-off debt)

  Bill({
    String? id,
    required this.title,
    required this.amount,
    this.isRecurring = true,
  }) : id = id ?? const Uuid().v4();

  Bill copyWith({
    String? id,
    String? title,
    double? amount,
    bool? isRecurring,
  }) {
    return Bill(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      isRecurring: isRecurring ?? this.isRecurring,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'isRecurring': isRecurring,
    };
  }

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      isRecurring: json['isRecurring'] as bool? ?? true,
    );
  }
}
