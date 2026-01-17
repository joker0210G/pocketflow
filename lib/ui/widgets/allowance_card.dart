import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions.dart';
import '../../logic/allowance_provider.dart';

class AllowanceCard extends ConsumerWidget {
  const AllowanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyAllowance = ref.watch(dailyAllowanceProvider);
    final daysRemaining = ref.watch(daysRemainingProvider);

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              "Daily Spendable",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              dailyAllowance.toCurrency,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.onPrimaryContainer),
                const SizedBox(width: 4),
                Text(
                  "$daysRemaining Days Left",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
