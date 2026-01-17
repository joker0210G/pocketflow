import 'dart:convert';
import 'dart:io' show File;
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants.dart';
import '../models/app_settings.dart';
import '../models/bill.dart';
import '../models/transaction.dart';
import '../models/transaction_category.dart';

class BackupService {
  /// Create XFile based on platform:
  /// - Web: In-memory (XFile.fromData) to avoid file system strictness.
  /// - Mobile/Desktop: Physical file (XFile(path)) to ensure correct filename in Share Sheet.
  Future<XFile> _createXFile(
      String filename, String content, String mimeType) async {
    final bytes = Uint8List.fromList(utf8.encode(content));

    if (kIsWeb) {
      return XFile.fromData(
        bytes,
        mimeType: mimeType,
        name: filename,
      );
    } else {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$filename');
      await file.writeAsBytes(bytes);
      return XFile(file.path, name: filename, mimeType: mimeType);
    }
  }

  Future<XFile> createBackupFile() async {
    final transactionBox =
        await Hive.openBox<Transaction>(AppConstants.transactionBox);
    final billBox = await Hive.openBox<Bill>(AppConstants.billsBox);
    final categoryBox =
        await Hive.openBox<TransactionCategory>(AppConstants.categoriesBox);
    final settingsBox =
        await Hive.openBox<AppSettings>(AppConstants.settingsBox);

    final backupData = {
      'version': 1, // Schema version
      'timestamp': DateTime.now().toIso8601String(),
      'transactions': transactionBox.values.map((e) => e.toJson()).toList(),
      'bills': billBox.values.map((e) => e.toJson()).toList(),
      'categories': categoryBox.values.map((e) => e.toJson()).toList(),
      'settings': settingsBox.get(AppConstants.settingsKey)?.toJson(),
    };

    final jsonString = jsonEncode(backupData);
    final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
    final filename = 'pocketflow_backup_$timestamp.json';

    return _createXFile(filename, jsonString, 'application/json');
  }

  Future<bool> importBackup() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true, // Crucial for Web to get bytes
      );

      if (result != null && result.files.single.bytes != null) {
        // Web: Use bytes directly
        final jsonString = utf8.decode(result.files.single.bytes!);
        return await _processBackupData(jsonString);
      } else if (result != null && result.files.single.path != null) {
        // Mobile/Desktop: Use path via XFile to avoid dart:io direct usage if possible,
        // or just use XFile(path).readAsString() which works everywhere dart:io is available.
        // Since we removed dart:io import, we MUST use XFile to read.
        final file = XFile(result.files.single.path!);
        final jsonString = await file.readAsString();
        return await _processBackupData(jsonString);
      }
      return false; // User cancelled or no file data found
    } catch (e) {
      if (e is FormatException) {
        rethrow;
      }
      throw Exception('Import failed: ${e.toString()}');
    }
  }

  Future<bool> _processBackupData(String jsonString) async {
    final Map<String, dynamic> data = jsonDecode(jsonString);

    // 1. Validation Phase (In-Memory)

    // Check for essential keys
    if (!data.containsKey('transactions') || !data.containsKey('settings')) {
      throw const FormatException(
          'Missing required data sections (transactions or settings)');
    }

    // 1. Validate Transactions
    final List<Transaction> newTransactions = [];
    final transactionsList = data['transactions'] as List;
    for (var i = 0; i < transactionsList.length; i++) {
      try {
        newTransactions.add(Transaction.fromJson(transactionsList[i]));
      } catch (e) {
        throw FormatException(
            'Invalid Transaction at index $i: ${e.toString()}');
      }
    }

    // 2. Validate Bills
    final List<Bill> newBills = [];
    if (data['bills'] != null) {
      final billsList = data['bills'] as List;
      for (var i = 0; i < billsList.length; i++) {
        try {
          newBills.add(Bill.fromJson(billsList[i]));
        } catch (e) {
          throw FormatException('Invalid Bill at index $i: ${e.toString()}');
        }
      }
    }

    // 3. Validate Categories
    final List<TransactionCategory> newCategories = [];
    if (data['categories'] != null) {
      final categoriesList = data['categories'] as List;
      for (var i = 0; i < categoriesList.length; i++) {
        try {
          newCategories.add(TransactionCategory.fromJson(categoriesList[i]));
        } catch (e) {
          throw FormatException(
              'Invalid Category at index $i: ${e.toString()}');
        }
      }
    }

    // 4. Validate Settings
    final AppSettings? newSettings;
    if (data['settings'] != null) {
      try {
        newSettings = AppSettings.fromJson(data['settings']);
      } catch (e) {
        throw FormatException('Invalid Settings: ${e.toString()}');
      }
    } else {
      newSettings = null;
    }

    // 2. Destructive Phase (Write to Hive)

    // Open Boxes
    final transactionBox =
        await Hive.openBox<Transaction>(AppConstants.transactionBox);
    final billBox = await Hive.openBox<Bill>(AppConstants.billsBox);
    final categoryBox =
        await Hive.openBox<TransactionCategory>(AppConstants.categoriesBox);
    final settingsBox =
        await Hive.openBox<AppSettings>(AppConstants.settingsBox);

    // Clear existing data only after validation succeeds
    await transactionBox.clear();
    await billBox.clear();
    await categoryBox.clear();
    await settingsBox.clear();

    // Repopulate
    for (var t in newTransactions) {
      await transactionBox.put(t.id, t);
    }
    for (var b in newBills) {
      await billBox.put(b.id, b);
    }
    for (var c in newCategories) {
      await categoryBox.put(c.id, c);
    }
    if (newSettings != null) {
      await settingsBox.put(AppConstants.settingsKey, newSettings);
    }

    return true;
  }

  Future<XFile> createReportFile() async {
    final transactionBox =
        await Hive.openBox<Transaction>(AppConstants.transactionBox);
    final transactions = transactionBox.values.toList();

    // Sort logic
    transactions.sort((a, b) => b.date.compareTo(a.date));

    List<List<dynamic>> rows = [
      ['Date', 'Time', 'Type', 'Category', 'Amount', 'Note', 'ID'], // Header
    ];

    for (var t in transactions) {
      rows.add([
        t.date.toIso8601String().split('T')[0],
        '${t.date.hour}:${t.date.minute}',
        t.isIncome ? 'Income' : 'Expense',
        t.category,
        t.amount,
        t.note ?? '',
        t.id,
      ]);
    }

    String csvData = const ListToCsvConverter().convert(rows);
    final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
    final filename = 'pocketflow_report_$timestamp.csv';

    return _createXFile(filename, csvData, 'text/csv');
  }
}
