import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../logic/providers.dart';
import '../../data/models/transaction.dart';
import '../../data/models/transaction_category.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  ConsumerState<AddTransactionSheet> createState() =>
      _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isIncome = false;
  String _selectedCategory = 'Food';

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
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
        note: _noteController.text.isEmpty ? null : _noteController.text.trim(),
        date: DateTime.now(),
        isIncome: _isIncome,
      );

      ref.read(transactionListProvider.notifier).addTransaction(transaction);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fetch categories from provider
    final allCategories = ref.watch(categoryListProvider);
    // Filter based on selected type
    final categories =
        allCategories.where((c) => c.isIncome == _isIncome).toList();

    // Reset category if not in the new list (or list empty)
    if (categories.isNotEmpty &&
        !categories.any((c) => c.name == _selectedCategory)) {
      _selectedCategory = categories.first.name;
    } else if (categories.isEmpty) {
      // Fallback text if no categories exist at all
      _selectedCategory = '';
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
            const SizedBox(height: 24),
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Stack(
                children: [
                  // Siding Indicator
                  AnimatedAlign(
                    alignment: _isIncome
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.fastOutSlowIn,
                    child: FractionallySizedBox(
                      widthFactor: 0.5,
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _isIncome ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(21),
                          boxShadow: [
                            BoxShadow(
                              color: (_isIncome ? Colors.green : Colors.red)
                                  .withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Tap targets and Text
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            if (_isIncome) {
                              HapticFeedback.selectionClick();
                              setState(() => _isIncome = false);
                            }
                          },
                          child: Container(
                            alignment: Alignment.center,
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                fontFamily: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.fontFamily,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: !_isIncome
                                    ? Colors.white
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                              ),
                              child: const Text('Expense'),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            if (!_isIncome) {
                              HapticFeedback.selectionClick();
                              setState(() => _isIncome = true);
                            }
                          },
                          child: Container(
                            alignment: Alignment.center,
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                fontFamily: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.fontFamily,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: _isIncome
                                    ? Colors.white
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                              ),
                              child: const Text('Income'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
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
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note (Optional)',
                hintText: 'e.g., Dinner with friends',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit_note),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            const Text('Category'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ...categories.map((category) {
                  return ChoiceChip(
                    label: Text(category.name),
                    selected: _selectedCategory == category.name,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = category.name;
                        });
                      }
                    },
                  );
                }),
                ActionChip(
                  label: const Icon(Icons.add, size: 18),
                  tooltip: 'Add new tag',
                  onPressed: () {
                    _showQuickAddCategoryDialog(context);
                  },
                ),
              ],
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

  void _showQuickAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Tag'),
          content: TextField(
            controller: nameController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Tag Name',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  ref.read(categoryListProvider.notifier).addCategory(
                        TransactionCategory(name: name, isIncome: _isIncome),
                      );
                  // Auto-select the new category
                  setState(() {
                    _selectedCategory = name;
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
