import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions.dart';
import '../../logic/providers.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionListProvider);
    final expenses = transactions.where((t) => !t.isIncome).toList();

    if (expenses.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Expenses Analysis')),
        body: const Center(child: Text('No expenses to analyze yet')),
      );
    }

    // Group by category
    final Map<String, double> categoryTotals = {};
    for (var t in expenses) {
      categoryTotals[t.category] = (categoryTotals[t.category] ?? 0) + t.amount;
    }

    final totalExpense =
        categoryTotals.values.fold(0.0, (sum, item) => sum + item);

    return Scaffold(
      appBar: AppBar(title: const Text('Expenses Analysis')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: categoryTotals.entries.map((entry) {
                    final percentage = (entry.value / totalExpense) * 100;
                    final isSmall = percentage < 5;
                    return PieChartSectionData(
                      color: _getColor(entry.key),
                      value: entry.value,
                      title: isSmall ? '' : '${percentage.toStringAsFixed(1)}%',
                      radius: 100,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Total Expenses: ${totalExpense.toCurrency}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...categoryTotals.entries.map((e) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getColor(e.key),
                    radius: 8,
                  ),
                  title: Text(e.key),
                  trailing: Text(e.value.toCurrency),
                )),
          ],
        ),
      ),
    );
  }

  Color _getColor(String category) {
    // Simple consistent colors for specific categories
    switch (category) {
      case 'Food':
        return Colors.orange;
      case 'Travel':
        return Colors.blue;
      case 'Entertainment':
        return Colors.purple;
      case 'Shopping':
        return Colors.pink;
      case 'Other':
        return Colors.grey;
      default:
        return Colors.teal;
    }
  }
}
