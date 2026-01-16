import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions.dart';
import '../../logic/providers.dart';

class BalanceCard extends ConsumerWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(balanceProvider);
    final income = ref.watch(incomeProvider);
    final expense = ref.watch(expenseProvider);

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text('Current Balance',
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(balance.toCurrency,
                style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummary(context, 'Income', income, Colors.green),
                _buildSummary(context, 'Expense', expense, Colors.red),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(
      BuildContext context, String label, double amount, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(amount.toCurrency,
            style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
