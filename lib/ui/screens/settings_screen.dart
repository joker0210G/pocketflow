import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../logic/settings_provider.dart';
import '../../logic/providers.dart';
import '../../data/services/backup_service.dart';
import 'manage_categories_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _termDaysController;

  @override
  void initState() {
    super.initState();
    _termDaysController = TextEditingController();
  }

  @override
  void dispose() {
    _termDaysController.dispose();
    super.dispose();
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showExportOptions(BuildContext context, XFile file, String title) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '$title Ready',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              subtitle: const Text('Send via email, message, etc.'),
              onTap: () {
                Navigator.pop(context);
                // ignore: deprecated_member_use
                Share.shareXFiles([file], text: 'PocketFlow $title');
              },
            ),
            ListTile(
              leading: const Icon(Icons.save_alt),
              title: const Text('Save to Device'),
              subtitle: const Text('Save file to local storage'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  if (kIsWeb) {
                    // On Web, Share IS Download
                    // ignore: deprecated_member_use
                    await Share.shareXFiles([file]);
                  } else {
                    // Mobile/Desktop: Open File Saver
                    String? outputFile = await FilePicker.platform.saveFile(
                      dialogTitle: 'Save $title',
                      fileName: file.name,
                      allowedExtensions: [file.name.split('.').last],
                      type: FileType.custom,
                    );

                    if (outputFile != null) {
                      await file.saveTo(outputFile);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Saved to $outputFile')),
                        );
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Save cancelled')),
                        );
                      }
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Save failed. Try the "Share" option instead.')),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final themeMode = settings.themeModeEnum;
    final isDarkMode = themeMode == ThemeMode.dark;

    // Pre-fill controllers if not focused
    if (!_termDaysController.selection.isValid) {
      _termDaysController.text = (settings.customTermDays ?? 7).toString();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _buildSectionHeader('Appearance'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Enable dark theme'),
            value: isDarkMode,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).updateTheme(
                    value ? ThemeMode.dark : ThemeMode.light,
                  );
            },
          ),
          const Divider(),
          _buildSectionHeader('In My Pocket'),
          SwitchListTile(
            title:
                Text(settings.isFixedIncome ? 'Fixed Income' : 'Flexible Term'),
            subtitle: Text(settings.isFixedIncome
                ? 'I get paid on a specific date'
                : 'I have a budget for X days'),
            value: settings.isFixedIncome,
            onChanged: (value) {
              final newSettings = settings.copyWith(isFixedIncome: value);
              ref.read(settingsProvider.notifier).updateSettings(newSettings);
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                if (settings.isFixedIncome)
                  ListTile(
                    title: const Text('Next Pay Date'),
                    subtitle: Text(settings.nextPayDate != null
                        ? DateFormat.yMMMd().format(settings.nextPayDate!)
                        : 'Select Date'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: settings.nextPayDate ??
                            DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        ref.read(settingsProvider.notifier).updateSettings(
                            settings.copyWith(nextPayDate: picked));
                      }
                    },
                  )
                else
                  Column(
                    children: [
                      TextField(
                        controller: _termDaysController,
                        decoration: const InputDecoration(
                            labelText: 'Budget Term (Days)',
                            helperText:
                                'How many days should this money last?'),
                        keyboardType: TextInputType.number,
                        onSubmitted: (val) {
                          final days = int.tryParse(val) ?? 7;
                          ref.read(settingsProvider.notifier).updateSettings(
                              settings.copyWith(customTermDays: days));
                        },
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refill / Restart Term'),
                        onPressed: () {
                          // Update start date to NOW
                          ref.read(settingsProvider.notifier).updateSettings(
                              settings.copyWith(termStartDate: DateTime.now()));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Term restarted from today!')),
                          );
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const Divider(),
          _buildSectionHeader('General'),
          ListTile(
            leading: const Icon(Icons.label_outline),
            title: const Text('Manage Categories'),
            subtitle: const Text('Add or remove custom tags'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ManageCategoriesScreen()),
              );
            },
          ),
          const Divider(),
          _buildSectionHeader('Data & Backup'),
          ListTile(
            leading: const Icon(Icons.download, color: Colors.blue),
            title: const Text('Export JSON Backup'),
            subtitle: const Text('Save a full copy of your data'),
            onTap: () async {
              try {
                // Generate file first
                final file = await BackupService().createBackupFile();

                if (context.mounted) {
                  _showExportOptions(context, file, 'Backup');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Export failed: $e')),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload, color: Colors.orange),
            title: const Text('Restore from Backup'),
            subtitle: const Text('Import a JSON backup file'),
            onTap: () async {
              try {
                final success = await BackupService().importBackup();
                if (context.mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Data restored! Please restart the app.')),
                    );
                    ref.invalidate(transactionListProvider);
                    ref.invalidate(billListProvider);
                    ref.invalidate(categoryListProvider);
                    ref.invalidate(settingsProvider);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Restore cancelled')),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Import Failed'),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'The backup file contains invalid data and cannot be restored. No changes were made to your current data.',
                              style: TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 16),
                            const Text('Error Details:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                e
                                    .toString()
                                    .replaceAll('FormatException: ', ''),
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.table_chart, color: Colors.green),
            title: const Text('Export CSV Report'),
            subtitle: const Text('Spreadsheet compatible report'),
            onTap: () async {
              try {
                final file = await BackupService().createReportFile();
                if (context.mounted) {
                  _showExportOptions(context, file, 'CSV Report');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('CSV Export failed: $e')),
                  );
                }
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Clear All Data',
                style: TextStyle(color: Colors.red)),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear Data?'),
                  content: const Text(
                      'This will permanently delete all transactions. Undoing is impossible.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel')),
                    FilledButton(
                      style:
                          FilledButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                ref
                    .read(transactionListProvider.notifier)
                    .clearAllTransactions();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All data cleared')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
