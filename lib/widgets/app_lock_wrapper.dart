import 'package:flutter/material.dart';
import '../services/lock_service.dart';
import '../screens/lock_screen.dart';
import '../theme/app_theme.dart';

/// Wrapper widget that shows lock screen when app requires authentication
class AppLockWrapper extends StatefulWidget {
  final Widget child;

  const AppLockWrapper({super.key, required this.child});

  @override
  State<AppLockWrapper> createState() => _AppLockWrapperState();
}

class _AppLockWrapperState extends State<AppLockWrapper>
    with WidgetsBindingObserver {
  bool _isLocked = true;
  bool _checkingLock = true;
  bool _wasInBackground = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLock();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // App going to background - mark for lock check on return
      _wasInBackground = true;
    } else if (state == AppLifecycleState.resumed && _wasInBackground) {
      // App returning from background - check if should lock
      _wasInBackground = false;
      _checkLockOnResume();
    }
  }

  Future<void> _checkLock() async {
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

  @override
  Widget build(BuildContext context) {
    if (_checkingLock) {
      // Show loading while checking lock status
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      );
    }

    if (_isLocked) {
      return LockScreen(onUnlocked: _onUnlocked);
    }

    return widget.child;
  }
}
