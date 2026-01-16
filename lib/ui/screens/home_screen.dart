import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_list.dart';
import '../widgets/add_transaction_sheet.dart';
import 'stats_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PocketFlow'),
        actions: [
          IconButton(
            icon: const Icon(Icons.pie_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatsScreen()),
              );
            },
          )
        ],
      ),
      body: const Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: BalanceCard(),
          ),
          Expanded(child: TransactionList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => const AddTransactionSheet());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
