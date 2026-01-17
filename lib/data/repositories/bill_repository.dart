import 'package:hive_flutter/hive_flutter.dart';
import '../models/bill.dart';
import '../../core/constants.dart';

class BillRepository {
  Future<Box<Bill>> _openBox() async {
    return await Hive.openBox<Bill>(AppConstants.billsBox);
  }

  Future<List<Bill>> getBills() async {
    final box = await _openBox();
    return box.values.toList();
  }

  Future<void> addBill(Bill bill) async {
    final box = await _openBox();
    await box.put(bill.id, bill);
  }

  Future<void> deleteBill(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }

  Future<void> clearAll() async {
    final box = await _openBox();
    await box.clear();
  }
}
