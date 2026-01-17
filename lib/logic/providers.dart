import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/transaction.dart';
import '../data/repositories/transaction_repository.dart';

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
