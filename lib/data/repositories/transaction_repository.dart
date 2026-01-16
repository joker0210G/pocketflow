import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants.dart';
import '../models/transaction.dart';

class TransactionRepository {
  Box<Transaction>? _box;

  Future<Box<Transaction>> _getBox() async {
    if (_box != null && _box!.isOpen) {
      return _box!;
    }
    _box = await Hive.openBox<Transaction>(AppConstants.transactionBox);
    return _box!;
  }

  Future<void> addTransaction(Transaction transaction) async {
    final box = await _getBox();
    await box.put(transaction.id, transaction);
  }

  Future<void> deleteTransaction(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }

  Future<List<Transaction>> getTransactions() async {
    final box = await _getBox();
    return box.values.toList();
  }
}
