import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vantag/l10n/app_localizations.dart';
import 'package:vantag/services/connectivity_service.dart';
import 'package:vantag/services/offline_queue_service.dart';
import 'package:vantag/theme/app_theme.dart';

/// Elegant offline banner that shows when device is not connected
class OfflineBanner extends StatefulWidget {
  final Widget child;

  const OfflineBanner({
    super.key,
    required this.child,
  });

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner>
    with SingleTickerProviderStateMixin {
  final ConnectivityService _connectivityService = ConnectivityService();
  final OfflineQueueService _offlineQueueService = OfflineQueueService();
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;

  bool _isOffline = false;
  bool _showBanner = false;
  int _pendingCount = 0;
  StreamSubscription<bool>? _subscription;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _initConnectivity();
  }

  Future<void> _initConnectivity() async {
    await _connectivityService.initialize();
    await _offlineQueueService.initialize();

    _isOffline = !_connectivityService.isConnected;
    _pendingCount = _offlineQueueService.pendingCount;

    // Listen for queue changes
    _offlineQueueService.addListener(_onQueueChanged);

    if (_isOffline) {
      _showBanner = true;
      _controller.forward();
    }

    _subscription = _connectivityService.onConnectivityChanged.listen((isConnected) {
      if (!isConnected && !_isOffline) {
        // Just went offline
        setState(() {
          _isOffline = true;
          _showBanner = true;
        });
        _controller.forward();
      } else if (isConnected && _isOffline) {
        // Just came back online
        setState(() => _isOffline = false);
        // Show brief "Back online" message then hide
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && !_isOffline && _pendingCount == 0) {
            _controller.reverse().then((_) {
              if (mounted) {
                setState(() => _showBanner = false);
              }
            });
          }
        });
      }
    });

    if (mounted) setState(() {});
  }

  void _onQueueChanged() {
    if (mounted) {
      setState(() {
        _pendingCount = _offlineQueueService.pendingCount;
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _offlineQueueService.removeListener(_onQueueChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showBanner)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _slideAnimation.value * 60),
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: _buildBanner(context),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildBanner(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isBackOnline = !_isOffline;
    final isSyncing = _offlineQueueService.isSyncing;

    // Determine message based on state
    String message;
    if (isBackOnline && isSyncing) {
      message = l10n.syncing;
    } else if (isBackOnline) {
      message = l10n.dataSynced;
    } else if (_pendingCount > 0) {
      message = l10n.pendingSync(_pendingCount);
    } else {
      message = l10n.offlineMessage;
    }

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isBackOnline
                ? [context.appColors.success.withValues(alpha: 0.9), context.appColors.success]
                : [const Color(0xFFFF6B6B), const Color(0xFFEE5A5A)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: (isBackOnline ? context.appColors.success : const Color(0xFFFF6B6B))
                  .withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon with pulse animation
            _PulsingIcon(
              icon: isSyncing ? LucideIcons.refreshCw : (isBackOnline ? LucideIcons.wifi : LucideIcons.wifiOff),
              color: Colors.white,
              isPulsing: !isBackOnline || isSyncing,
            ),
            const SizedBox(width: 12),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isBackOnline ? l10n.backOnline : l10n.noInternet,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Status indicator
            if (!isBackOnline || _pendingCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_pendingCount > 0) ...[
                      Text(
                        '$_pendingCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _pendingCount > 0 ? Colors.amber : Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _pendingCount > 0 ? l10n.pendingLabel : l10n.offline,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Pulsing icon animation for offline state
class _PulsingIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final bool isPulsing;

  const _PulsingIcon({
    required this.icon,
    required this.color,
    this.isPulsing = true,
  });

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isPulsing) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_PulsingIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPulsing && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isPulsing && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isPulsing ? _scaleAnimation.value : 1.0,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.icon,
              color: widget.color,
              size: 20,
            ),
          ),
        );
      },
    );
  }
}

/// Minimal offline indicator (small dot in corner)
class OfflineIndicator extends StatefulWidget {
  const OfflineIndicator({super.key});

  @override
  State<OfflineIndicator> createState() => _OfflineIndicatorState();
}

class _OfflineIndicatorState extends State<OfflineIndicator> {
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _isOffline = false;
  StreamSubscription<bool>? _subscription;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
  }

  Future<void> _initConnectivity() async {
    await _connectivityService.initialize();
    _isOffline = !_connectivityService.isConnected;

    _subscription = _connectivityService.onConnectivityChanged.listen((isConnected) {
      if (mounted) {
        setState(() => _isOffline = !isConnected);
      }
    });

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOffline) return const SizedBox.shrink();

    return Tooltip(
      message: AppLocalizations.of(context).noInternet,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B6B),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(
          LucideIcons.wifiOff,
          color: Colors.white,
          size: 12,
        ),
      ),
    );
  }
}
