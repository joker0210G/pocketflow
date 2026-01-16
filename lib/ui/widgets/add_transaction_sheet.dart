import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../logic/providers.dart';
import '../../data/models/transaction.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  ConsumerState<AddTransactionSheet> createState() =>
      _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  // final _noteController = TextEditingController(); // Optional note for future use
  bool _isIncome = false;
  String _selectedCategory = 'Food';

  final List<String> _expenseCategories = [
    'Food',
    'Travel',
    'Entertainment',
    'Shopping',
    'Other'
  ];
  final List<String> _incomeCategories = ['Pocket Money', 'Gift', 'Other'];

  @override
  void dispose() {
    _amountController.dispose();
    // _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text);
      if (amount == null) return;

      final transaction = Transaction(
        id: const Uuid().v4(),
        amount: amount,
        category: _selectedCategory,
        date: DateTime.now(),
        isIncome: _isIncome,
      );

      ref.read(transactionListProvider.notifier).addTransaction(transaction);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = _isIncome ? _incomeCategories : _expenseCategories;
    // Reset category if not in the new list (simple logic)
    if (!categories.contains(_selectedCategory)) {
      _selectedCategory = categories.first;
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'New Transaction',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Expense / Income'),
                Switch(
                  value: _isIncome,
                  onChanged: (value) {
                    setState(() {
                      _isIncome = value;
                    });
                  },
                  activeTrackColor: Colors
                      .green, // Fixed: Use activeTrackColor instead of deprecated activeColor
                ),
              ],
            ),
            TextFormField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '₹ ',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Invalid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text('Category'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: categories.map((category) {
                return ChoiceChip(
                  label: Text(category),
                  selected: _selectedCategory == category,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submit,
              child: const Text('Add Transaction'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
