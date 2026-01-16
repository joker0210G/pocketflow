import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions.dart';
import '../../logic/providers.dart';

class TransactionList extends ConsumerWidget {
  const TransactionList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionListProvider);

    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No transactions yet',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: transactions.length,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return Dismissible(
          key: Key(transaction.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) {
            ref
                .read(transactionListProvider.notifier)
                .deleteTransaction(transaction.id);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Transaction deleted')),
            );
          },
          child: Card(
            elevation: 1,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: transaction.isIncome
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                child: Icon(
                  transaction.isIncome
                      ? Icons.arrow_downward
                      : Icons.arrow_upward,
                  color: transaction.isIncome ? Colors.green : Colors.red,
                ),
              ),
              title: Text(transaction.category,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                  '${transaction.date.formattedDate} • ${transaction.date.formattedTime}'),
              trailing: Text(
                '${transaction.isIncome ? '+' : '-'}${transaction.amount.toCurrency}',
                style: TextStyle(
                  color: transaction.isIncome ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
