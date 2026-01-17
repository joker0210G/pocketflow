import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocketflow/data/models/transaction.dart';
import 'package:pocketflow/data/repositories/transaction_repository.dart';
import 'package:pocketflow/logic/providers.dart';
import 'package:pocketflow/main.dart';

import 'package:pocketflow/logic/settings_provider.dart';
import 'package:pocketflow/data/models/app_settings.dart';

import 'package:pocketflow/data/models/bill.dart';
import 'package:pocketflow/data/repositories/bill_repository.dart';

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

class MockBillRepository implements BillRepository {
  @override
  Future<List<Bill>> getBills() async => [];

  @override
  Future<void> addBill(Bill bill) async {}

  @override
  Future<void> deleteBill(String id) async {}

  @override
  Future<void> clearAll() async {}

  // ignore: unused_element
  // Future<Box<Bill>> _openBox() async {
  //   throw UnimplementedError();
  // }
}

class MockSettingsNotifier extends SettingsNotifier {
  MockSettingsNotifier() : super(shouldLoad: false) {
    state = const AppSettings();
  }

  @override
  Future<void> updateTheme(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode.toString());
  }
}

void main() {
  testWidgets('PocketFlow Smoke Test - Home Screen Loads',
      (WidgetTester tester) async {
    // Set a realistic screen size to avoid overflow errors
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;

    // Override the repository provider with a mock to avoid Hive initialization
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transactionRepositoryProvider
              .overrideWithValue(MockTransactionRepository()),
          billRepositoryProvider.overrideWithValue(MockBillRepository()),
          settingsProvider.overrideWith((ref) => MockSettingsNotifier()),
        ],
        child: const MainApp(),
      ),
    );

    // Verify app title
    expect(find.text('PocketFlow'), findsOneWidget);

    // Verify Balance Card exists
    expect(find.text('Current Balance'), findsOneWidget);

    // Verify FAB exists (MainScreen -> HomeScreen index 0)
    expect(find.byIcon(Icons.add), findsOneWidget);

    // Clean up
    addTearDown(tester.view.resetPhysicalSize);
  });
}
