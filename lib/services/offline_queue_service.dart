import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'connectivity_service.dart';

/// Represents a queued operation for offline sync
class QueuedOperation {
  final String id;
  final String type; // 'expense', 'pursuit', 'subscription', etc.
  final String action; // 'add', 'update', 'delete'
  final Map<String, dynamic> data;
  final DateTime createdAt;
  int retryCount;

  QueuedOperation({
    required this.id,
    required this.type,
    required this.action,
    required this.data,
    required this.createdAt,
    this.retryCount = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'action': action,
        'data': data,
        'createdAt': createdAt.toIso8601String(),
        'retryCount': retryCount,
      };

  factory QueuedOperation.fromJson(Map<String, dynamic> json) {
    return QueuedOperation(
      id: json['id'] as String,
      type: json['type'] as String,
      action: json['action'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map),
      createdAt: DateTime.parse(json['createdAt'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
    );
  }
}

/// Service to manage offline operation queue
class OfflineQueueService extends ChangeNotifier {
  static const _queueKey = 'offline_queue_v1';
  static const _maxRetries = 3;

  final ConnectivityService _connectivityService;
  List<QueuedOperation> _queue = [];
  bool _isSyncing = false;
  StreamSubscription<bool>? _connectivitySubscription;

  OfflineQueueService({ConnectivityService? connectivityService})
      : _connectivityService = connectivityService ?? ConnectivityService();

  List<QueuedOperation> get queue => List.unmodifiable(_queue);
  int get pendingCount => _queue.length;
  bool get hasPending => _queue.isNotEmpty;
  bool get isSyncing => _isSyncing;

  /// Initialize service
  Future<void> initialize() async {
    await _loadQueue();
    await _connectivityService.initialize();

    // Listen for connectivity changes
    _connectivitySubscription =
        _connectivityService.onConnectivityChanged.listen((isConnected) {
      if (isConnected && hasPending) {
        syncQueue();
      }
    });

    // Initial sync attempt if online
    if (_connectivityService.isConnected && hasPending) {
      syncQueue();
    }
  }

  /// Add operation to queue
  Future<void> enqueue({
    required String type,
    required String action,
    required Map<String, dynamic> data,
  }) async {
    final operation = QueuedOperation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      action: action,
      data: data,
      createdAt: DateTime.now(),
    );

    _queue.add(operation);
    await _saveQueue();
    notifyListeners();

    // Try to sync immediately if online
    if (_connectivityService.isConnected) {
      syncQueue();
    }
  }

  /// Remove operation from queue
  Future<void> dequeue(String id) async {
    _queue.removeWhere((op) => op.id == id);
    await _saveQueue();
    notifyListeners();
  }

  /// Sync all pending operations
  Future<void> syncQueue() async {
    if (_isSyncing || _queue.isEmpty) return;

    _isSyncing = true;
    notifyListeners();

    final operationsToProcess = List<QueuedOperation>.from(_queue);
    final failedOperations = <QueuedOperation>[];

    for (final operation in operationsToProcess) {
      try {
        await _processOperation(operation);
        await dequeue(operation.id);
      } catch (e) {
        debugPrint('Failed to sync operation ${operation.id}: $e');
        operation.retryCount++;

        if (operation.retryCount < _maxRetries) {
          failedOperations.add(operation);
        } else {
          // Remove after max retries
          await dequeue(operation.id);
          debugPrint('Removed operation ${operation.id} after $_maxRetries retries');
        }
      }
    }

    // Update queue with failed operations
    _queue = failedOperations;
    await _saveQueue();

    _isSyncing = false;
    notifyListeners();
  }

  /// Process a single operation
  Future<void> _processOperation(QueuedOperation operation) async {
    // This is a placeholder - actual implementation depends on the operation type
    // Each service should register its sync handlers
    debugPrint(
        'Processing ${operation.type}:${operation.action} - ${operation.id}');

    // Simulate network delay for now
    await Future.delayed(const Duration(milliseconds: 100));

    // In a real implementation, you would:
    // 1. Get the appropriate service based on operation.type
    // 2. Call the appropriate method based on operation.action
    // 3. Pass operation.data to the method
  }

  /// Load queue from storage
  Future<void> _loadQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_queueKey);

      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString) as List;
        _queue = jsonList
            .map((item) =>
                QueuedOperation.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading offline queue: $e');
      _queue = [];
    }
  }

  /// Save queue to storage
  Future<void> _saveQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(_queue.map((op) => op.toJson()).toList());
      await prefs.setString(_queueKey, jsonString);
    } catch (e) {
      debugPrint('Error saving offline queue: $e');
    }
  }

  /// Clear all pending operations
  Future<void> clearQueue() async {
    _queue.clear();
    await _saveQueue();
    notifyListeners();
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
