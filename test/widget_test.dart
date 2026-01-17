import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocketflow/data/models/transaction.dart';
import 'package:pocketflow/data/repositories/transaction_repository.dart';
import 'package:pocketflow/logic/providers.dart';
import 'package:pocketflow/main.dart';

import 'package:pocketflow/logic/settings_provider.dart';

// Manual Mock Repository
class MockTransactionRepository implements TransactionRepository {
  @override
  Future<List<Transaction>> getTransactions() async => [];

  @override
  Future<void> addTransaction(Transaction transaction) async {}

  @override
  Future<void> deleteTransaction(String id) async {}

  @override
  Future<void> clearAll() async {}
}

class MockSettingsNotifier extends SettingsNotifier {
  MockSettingsNotifier() : super(shouldLoad: false) {
    state = ThemeMode.light;
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
  }
}

void main() {
  testWidgets('PocketFlow Smoke Test - Home Screen Loads',
      (WidgetTester tester) async {
    // Override the repository provider with a mock to avoid Hive initialization
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transactionRepositoryProvider
              .overrideWithValue(MockTransactionRepository()),
          settingsProvider.overrideWith((ref) => MockSettingsNotifier()),
        ],
        child: const MainApp(),
      ),
    );

    // Verify app title
    expect(find.text('PocketFlow'), findsOneWidget);

    // Verify Balance Card exists
    expect(find.text('Current Balance'), findsOneWidget);

    // Verify FAB exists
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
