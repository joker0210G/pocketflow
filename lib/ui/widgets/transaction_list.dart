import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions.dart';
import '../../logic/providers.dart';
import '../../data/models/transaction.dart';

class TransactionList extends ConsumerWidget {
  final bool useSliver;
  const TransactionList({super.key, this.useSliver = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionListProvider);

    if (transactions.isEmpty) {
      final emptyContent = Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No transactions yet',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ],
          ),
        ),
      );

      if (useSliver) {
        return SliverFillRemaining(child: emptyContent);
      }
      return emptyContent;
    }

    if (useSliver) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) =>
              _buildTransactionItem(context, ref, transactions[index]),
          childCount: transactions.length,
        ),
      );
    }

    return ListView.builder(
      itemCount: transactions.length,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemBuilder: (context, index) =>
          _buildTransactionItem(context, ref, transactions[index]),
    );
  }

  Widget _buildTransactionItem(
      BuildContext context, WidgetRef ref, Transaction transaction) {
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
              transaction.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: transaction.isIncome ? Colors.green : Colors.red,
            ),
          ),
          title: Text(transaction.category,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (transaction.note != null && transaction.note!.isNotEmpty)
                Text(
                  transaction.note!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                ),
              Text(
                '${transaction.date.formattedDate} • ${transaction.date.formattedTime}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
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
  }
}
