import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/models.dart';
import 'expense_history_service.dart';
import 'pursuit_service.dart';
import 'subscription_service.dart';

/// Backup and restore service for user data
class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  final _expenseService = ExpenseHistoryService();
  final _pursuitService = PursuitService();
  final _subscriptionService = SubscriptionService();

  /// Create a backup of all user data
  Future<Map<String, dynamic>> createBackup() async {
    try {
      // Get all data
      final expenses = await _expenseService.getExpenses();
      final pursuits = await _pursuitService.getAllPursuits();
      final subscriptions = await _subscriptionService.getSubscriptions();

      // Create backup structure
      final backup = {
        'version': 1,
        'createdAt': DateTime.now().toIso8601String(),
        'appVersion': '1.0.3',
        'data': {
          'expenses': expenses.map((e) => e.toJson()).toList(),
          'pursuits': pursuits.map((p) => p.toJson()).toList(),
          'subscriptions': subscriptions.map((s) => s.toJson()).toList(),
        },
      };

      return backup;
    } catch (e) {
      debugPrint('[Backup] Error creating backup: $e');
      rethrow;
    }
  }

  /// Export backup to a file and share
  Future<String?> exportBackup() async {
    try {
      final backup = await createBackup();
      final jsonString = const JsonEncoder.withIndent('  ').convert(backup);

      // Get temp directory
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'vantag_backup_$timestamp.json';
      final filePath = '${tempDir.path}/$fileName';

      // Write to file
      final file = File(filePath);
      await file.writeAsString(jsonString);

      // Share file
      await SharePlus.instance.share(ShareParams(
        files: [XFile(filePath)],
        subject: 'Vantag Backup',
        text: 'Vantag verilerim yedegi',
      ));

      return filePath;
    } catch (e) {
      debugPrint('[Backup] Error exporting backup: $e');
      return null;
    }
  }

  /// Import backup from a file
  Future<BackupResult> importBackup() async {
    try {
      // Pick file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        return BackupResult(success: false, error: 'noFileSelected');
      }

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final backup = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validate backup
      if (backup['version'] == null || backup['data'] == null) {
        return BackupResult(success: false, error: 'invalidBackupFormat');
      }

      return await restoreBackup(backup);
    } catch (e) {
      debugPrint('[Backup] Error importing backup: $e');
      return BackupResult(success: false, error: 'importError');
    }
  }

  /// Restore data from backup
  Future<BackupResult> restoreBackup(Map<String, dynamic> backup) async {
    try {
      final data = backup['data'] as Map<String, dynamic>;
      int expensesRestored = 0;
      int pursuitsRestored = 0;
      int subscriptionsRestored = 0;

      // Restore expenses
      if (data['expenses'] != null) {
        final expenses = (data['expenses'] as List)
            .map((e) => Expense.fromJson(e as Map<String, dynamic>))
            .toList();

        for (final expense in expenses) {
          await _expenseService.addExpense(expense);
          expensesRestored++;
        }
      }

      // Restore pursuits
      if (data['pursuits'] != null) {
        final pursuits = (data['pursuits'] as List)
            .map((p) => Pursuit.fromJson(p as Map<String, dynamic>))
            .toList();

        for (final pursuit in pursuits) {
          await _pursuitService.createPursuit(pursuit);
          pursuitsRestored++;
        }
      }

      // Restore subscriptions
      if (data['subscriptions'] != null) {
        final subscriptions = (data['subscriptions'] as List)
            .map((s) => Subscription.fromJson(s as Map<String, dynamic>))
            .toList();

        for (final subscription in subscriptions) {
          await _subscriptionService.addSubscription(subscription);
          subscriptionsRestored++;
        }
      }

      return BackupResult(
        success: true,
        expensesRestored: expensesRestored,
        pursuitsRestored: pursuitsRestored,
        subscriptionsRestored: subscriptionsRestored,
      );
    } catch (e) {
      debugPrint('[Backup] Error restoring backup: $e');
      return BackupResult(success: false, error: 'restoreError');
    }
  }

  /// Get backup stats
  Future<BackupStats> getBackupStats() async {
    final expenses = await _expenseService.getExpenses();
    final pursuits = await _pursuitService.getAllPursuits();
    final subscriptions = await _subscriptionService.getSubscriptions();

    return BackupStats(
      expenseCount: expenses.length,
      pursuitCount: pursuits.length,
      subscriptionCount: subscriptions.length,
    );
  }
}

/// Result of a backup operation
class BackupResult {
  final bool success;
  final String? error;
  final int expensesRestored;
  final int pursuitsRestored;
  final int subscriptionsRestored;

  BackupResult({
    required this.success,
    this.error,
    this.expensesRestored = 0,
    this.pursuitsRestored = 0,
    this.subscriptionsRestored = 0,
  });
}

/// Stats about data to be backed up
class BackupStats {
  final int expenseCount;
  final int pursuitCount;
  final int subscriptionCount;

  BackupStats({
    required this.expenseCount,
    required this.pursuitCount,
    required this.subscriptionCount,
  });

  int get totalItems => expenseCount + pursuitCount + subscriptionCount;
}

/// Global instance
final backupService = BackupService();
