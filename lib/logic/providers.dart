import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/transaction.dart';
import '../data/models/bill.dart';
import '../data/models/transaction_category.dart';
import '../data/repositories/transaction_repository.dart';
import '../data/repositories/bill_repository.dart';
import '../data/repositories/category_repository.dart';

// Repository Provider
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

// Transaction List Provider
final transactionListProvider =
    StateNotifierProvider<TransactionNotifier, List<Transaction>>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return TransactionNotifier(repository);
});

class TransactionNotifier extends StateNotifier<List<Transaction>> {
  final TransactionRepository _repository;

  TransactionNotifier(this._repository) : super([]) {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    final transactions = await _repository.getTransactions();
    // Sort by date descending (newest first)
    transactions.sort((a, b) => b.date.compareTo(a.date));
    state = transactions;
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _repository.addTransaction(transaction);
    await loadTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    await _repository.deleteTransaction(id);
    await loadTransactions();
  }

  Future<void> clearAllTransactions() async {
    await _repository.clearAll();
    await loadTransactions();
  }
}

// Derived Providers
final balanceProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionListProvider);
  return transactions.fold(0, (previousValue, element) {
    if (element.isIncome) {
      return previousValue + element.amount;
    } else {
      return previousValue - element.amount;
    }
  });
});

final incomeProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionListProvider);
  return transactions
      .where((t) => t.isIncome)
      .fold(0, (prev, t) => prev + t.amount);
});

final expenseProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionListProvider);
  return transactions
      .where((t) => !t.isIncome)
      .fold(0, (prev, t) => prev + t.amount);
});

final recentTransactionsProvider = Provider<List<Transaction>>((ref) {
  final transactions = ref.watch(transactionListProvider);
  return transactions.take(5).toList();
});

// Bill Repository Provider
final billRepositoryProvider = Provider<BillRepository>((ref) {
  return BillRepository();
});

// Bill List Provider
final billListProvider = StateNotifierProvider<BillNotifier, List<Bill>>((ref) {
  final repository = ref.watch(billRepositoryProvider);
  return BillNotifier(repository);
});

class BillNotifier extends StateNotifier<List<Bill>> {
  final BillRepository _repository;

  BillNotifier(this._repository) : super([]) {
    loadBills();
  }

  Future<void> loadBills() async {
    final bills = await _repository.getBills();
    state = bills;
  }

  Future<void> addBill(Bill bill) async {
    await _repository.addBill(bill);
    await loadBills();
  }

  Future<void> deleteBill(String id) async {
    await _repository.deleteBill(id);
    await loadBills();
  }
}

// Category Repository Provider
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository();
});

// Category List Provider
final categoryListProvider =
    StateNotifierProvider<CategoryNotifier, List<TransactionCategory>>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return CategoryNotifier(repository);
});

class CategoryNotifier extends StateNotifier<List<TransactionCategory>> {
  final CategoryRepository _repository;

  CategoryNotifier(this._repository) : super([]) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    final categories = await _repository.getCategories();
    if (categories.isEmpty) {
      await _seedDefaultCategories();
    } else {
      state = categories;
    }
  }

  Future<void> _seedDefaultCategories() async {
    final defaults = [
      TransactionCategory(name: 'Food', isIncome: false, isDefault: true),
      TransactionCategory(name: 'Travel', isIncome: false, isDefault: true),
      TransactionCategory(
          name: 'Entertainment', isIncome: false, isDefault: true),
      TransactionCategory(name: 'Shopping', isIncome: false, isDefault: true),
      TransactionCategory(
          name: 'Pocket Money', isIncome: true, isDefault: true),
      TransactionCategory(name: 'Gift', isIncome: true, isDefault: true),
      TransactionCategory(name: 'Other', isIncome: false, isDefault: true),
    ];

    for (var cat in defaults) {
      await _repository.addCategory(cat);
    }
    state = await _repository.getCategories();
  }

  Future<void> addCategory(TransactionCategory category) async {
    await _repository.addCategory(category);
    await loadCategories();
  }

  Future<void> deleteCategory(String id) async {
    await _repository.deleteCategory(id);
    await loadCategories();
  }
}
