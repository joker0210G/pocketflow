import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';
import 'settings_provider.dart';

final dailyAllowanceProvider = Provider<double>((ref) {
  final settings = ref.watch(settingsProvider);
  final balance = ref.watch(balanceProvider);

  if (balance <= 0) return 0.0;

  DateTime now = DateTime.now();
  int daysRemaining;

  if (settings.isFixedIncome) {
    if (settings.nextPayDate == null) return 0.0;
    daysRemaining = settings.nextPayDate!.difference(now).inDays;
  } else {
    // Flexible logic
    if (settings.termStartDate == null || settings.customTermDays == null) {
      // Default fallback if not set: Rolling 7 days
      daysRemaining = 7;
    } else {
      final endOfTerm =
          settings.termStartDate!.add(Duration(days: settings.customTermDays!));
      daysRemaining = endOfTerm.difference(now).inDays;
    }
  }

  // Handle past-due or final day logic
  if (daysRemaining < 1) daysRemaining = 1;
  // Cap at reasonable max to avoid weird math if date is far future
  if (daysRemaining > 365) daysRemaining = 365;

  // Cap at reasonable max to avoid weird math if date is far future
  if (daysRemaining > 365) daysRemaining = 365;

  // Calculate committed money from bills
  final bills = ref.watch(billListProvider);
  double committedMoney = bills.fold(0, (sum, bill) => sum + bill.amount);

  double spendable = (balance - committedMoney);
  if (spendable < 0) spendable = 0;

  return spendable / daysRemaining;
});

final daysRemainingProvider = Provider<int>((ref) {
  final settings = ref.watch(settingsProvider);

  DateTime now = DateTime.now();
  int daysRemaining;

  if (settings.isFixedIncome) {
    if (settings.nextPayDate == null) return 30; // Default
    daysRemaining = settings.nextPayDate!.difference(now).inDays;
  } else {
    if (settings.termStartDate == null || settings.customTermDays == null) {
      return 7;
    }
    final endOfTerm =
        settings.termStartDate!.add(Duration(days: settings.customTermDays!));
    daysRemaining = endOfTerm.difference(now).inDays;
  }

  return daysRemaining < 0 ? 0 : daysRemaining;
});
