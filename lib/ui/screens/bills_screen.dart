import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/bill.dart';
import '../../logic/providers.dart';
import '../../core/extensions.dart';

class BillsScreen extends ConsumerWidget {
  const BillsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bills = ref.watch(billListProvider);
    final totalCommitted = bills.fold(0.0, (sum, bill) => sum + bill.amount);

    return Scaffold(
      appBar: AppBar(title: const Text('Committed Money')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            width: double.infinity,
            child: Column(
              children: [
                Text('Total Bills',
                    style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 4),
                Text(
                  totalCommitted.toCurrency,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            child: bills.isEmpty
                ? const Center(child: Text('No bills added yet.'))
                : ListView.builder(
                    itemCount: bills.length,
                    itemBuilder: (context, index) {
                      final bill = bills[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(bill.title[0].toUpperCase()),
                        ),
                        title: Text(bill.title),
                        subtitle:
                            Text(bill.isRecurring ? 'Monthly' : 'One-off'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(bill.amount.toCurrency,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              onPressed: () {
                                ref
                                    .read(billListProvider.notifier)
                                    .deleteBill(bill.id);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBillDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddBillDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    bool isRecurring = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Bill'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                autofocus: true,
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
              CheckboxListTile(
                title: const Text('Recurring (Monthly)'),
                value: isRecurring,
                onChanged: (val) => setState(() => isRecurring = val ?? true),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final title = titleController.text.trim();
                final amount = double.tryParse(amountController.text) ?? 0.0;
                if (title.isNotEmpty && amount > 0) {
                  final bill = Bill(
                      title: title, amount: amount, isRecurring: isRecurring);
                  ref.read(billListProvider.notifier).addBill(bill);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
