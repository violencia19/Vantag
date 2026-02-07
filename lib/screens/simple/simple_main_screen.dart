import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../../theme/theme.dart';
import '../../widgets/add_expense_sheet.dart';
import '../../services/services.dart';
import '../../providers/providers.dart';
import '../lock_screen.dart';
import 'simple_transactions_screen.dart';
import 'simple_statistics_screen.dart';
import 'simple_settings_screen.dart';

/// Simple Mode - Main Screen with 3-tab navigation
class SimpleMainScreen extends StatefulWidget {
  const SimpleMainScreen({super.key});

  @override
  State<SimpleMainScreen> createState() => _SimpleMainScreenState();
}

class _SimpleMainScreenState extends State<SimpleMainScreen>
    with WidgetsBindingObserver {
  int _currentIndex = 0;

  // Lock state
  bool _isLocked = false;
  bool _checkingLock = true;
  bool _wasInBackground = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLockStatus();

    // Status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF1A1A2E),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _wasInBackground = true;
      // Clean up simulation expenses when app goes to background
      _cleanupSimulations();
    } else if (state == AppLifecycleState.resumed && _wasInBackground) {
      _wasInBackground = false;
      _checkLockOnResume();
      // Refresh theme for time-based automatic mode
      context.read<ThemeProvider>().refreshTheme();
    } else if (state == AppLifecycleState.detached) {
      // Clean up simulation expenses when app is closing
      _cleanupSimulations();
    }
  }

  /// Clean up simulation expenses - they shouldn't persist
  Future<void> _cleanupSimulations() async {
    try {
      await ExpenseHistoryService().clearSimulations();
      // Refresh provider to reflect changes
      if (mounted) {
        context.read<FinanceProvider>().refresh();
      }
    } catch (e) {
      debugPrint('[SimpleMode Cleanup] Error clearing simulations: $e');
    }
  }

  Future<void> _checkLockStatus() async {
    final lockEnabled = await LockService.isLockEnabled();
    final hasPinSet = await LockService.hasPinSet();

    if (mounted) {
      setState(() {
        _isLocked = lockEnabled && hasPinSet;
        _checkingLock = false;
      });
    }
  }

  Future<void> _checkLockOnResume() async {
    final lockEnabled = await LockService.isLockEnabled();
    final hasPinSet = await LockService.hasPinSet();

    if (lockEnabled && hasPinSet && mounted) {
      setState(() => _isLocked = true);
    }
  }

  void _onUnlocked() {
    setState(() => _isLocked = false);
  }

  void _onNavTap(int index) {
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
  }

  void _showAddExpenseSheet() {
    showAddExpenseSheet(
      context,
      onExpenseAdded: () {
        HapticFeedback.mediumImpact();
        // Navigate to transactions tab
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Show loading while checking lock status
    if (_checkingLock) {
      return Scaffold(
        backgroundColor: context.vantColors.background,
        body: const SizedBox.shrink(),
      );
    }

    // Show lock screen if locked
    if (_isLocked) {
      return LockScreen(onUnlocked: _onUnlocked);
    }

    return Scaffold(
      backgroundColor: context.vantColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          SimpleTransactionsScreen(),
          SimpleStatisticsScreen(),
          SimpleSettingsScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(l10n),
      floatingActionButton: _buildFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNavBar(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: context.vantColors.surface,
        border: Border(
          top: BorderSide(color: context.vantColors.cardBorder, width: 1),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Transactions Tab
              _buildNavItem(
                icon: CupertinoIcons.list_bullet,
                iconOutline: CupertinoIcons.list_bullet,
                label: l10n.simpleTransactions,
                index: 0,
              ),

              // Spacer for FAB
              const SizedBox(width: 64),

              // Statistics Tab
              _buildNavItem(
                icon: CupertinoIcons.chart_pie_fill,
                iconOutline: CupertinoIcons.chart_pie,
                label: l10n.simpleStatistics,
                index: 1,
              ),

              // Settings Tab
              _buildNavItem(
                icon: CupertinoIcons.gear_solid,
                iconOutline: CupertinoIcons.gear,
                label: l10n.simpleSettings,
                index: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData iconOutline,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _onNavTap(index),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? icon : iconOutline,
                size: 24,
                color: isSelected
                    ? context.vantColors.primary
                    : context.vantColors.textTertiary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? context.vantColors.primary
                      : context.vantColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFab() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [context.vantColors.primary, context.vantColors.secondary],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: context.vantColors.primary.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showAddExpenseSheet,
          borderRadius: BorderRadius.circular(28),
          child: Icon(
            CupertinoIcons.plus,
            size: 28,
            color: context.vantColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
