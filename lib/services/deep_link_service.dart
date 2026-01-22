import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import 'voice_parser_service.dart';

/// Callback for when an expense should be added
typedef OnAddExpense = Future<void> Function(Expense expense);

/// Callback for navigation
typedef OnNavigate = void Function(String route);

/// Callback to get the current hourly rate
typedef GetHourlyRate = double Function();

/// Service for handling deep links (vantag:// scheme)
/// Supports Siri Shortcuts, Google Assistant, and direct links
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._();
  factory DeepLinkService() => _instance;
  DeepLinkService._();

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  OnAddExpense? _onAddExpense;
  OnNavigate? _onNavigate;
  GetHourlyRate? _getHourlyRate;
  GlobalKey<NavigatorState>? _navigatorKey;

  /// Flag to auto-start voice input when app opens from deep link
  bool _shouldAutoStartVoice = false;
  bool get shouldAutoStartVoice => _shouldAutoStartVoice;
  void consumeAutoStartFlag() => _shouldAutoStartVoice = false;

  /// Simple initialization with navigator key (from main.dart)
  void init(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
    _initLinks();
  }

  /// Set callbacks after initialization (can be called from a widget with provider access)
  void setCallbacks({
    OnAddExpense? onAddExpense,
    OnNavigate? onNavigate,
    GetHourlyRate? getHourlyRate,
  }) {
    if (onAddExpense != null) _onAddExpense = onAddExpense;
    if (onNavigate != null) _onNavigate = onNavigate;
    if (getHourlyRate != null) _getHourlyRate = getHourlyRate;
  }

  /// Full initialization with callbacks
  Future<void> initWithCallbacks({
    required GlobalKey<NavigatorState> navigatorKey,
    required OnAddExpense onAddExpense,
    OnNavigate? onNavigate,
    GetHourlyRate? getHourlyRate,
  }) async {
    _navigatorKey = navigatorKey;
    _onAddExpense = onAddExpense;
    _onNavigate = onNavigate;
    _getHourlyRate = getHourlyRate;
    await _initLinks();
  }

  /// Initialize link listening
  Future<void> _initLinks() async {

    // Handle initial link (app opened via link)
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(initialLink);
      }
    } catch (e) {
      debugPrint('[DeepLink] Error getting initial link: $e');
    }

    // Listen for links while app is running
    _linkSubscription = _appLinks.uriLinkStream.listen(
      _handleDeepLink,
      onError: (e) => debugPrint('[DeepLink] Stream error: $e'),
    );
  }

  /// Dispose of resources
  void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
  }

  /// Handle incoming deep link
  void _handleDeepLink(Uri uri) {
    debugPrint('[DeepLink] Received: $uri');

    // Validate scheme
    if (uri.scheme != 'vantag') {
      debugPrint('[DeepLink] Invalid scheme: ${uri.scheme}');
      return;
    }

    // Route based on host/path
    switch (uri.host) {
      case 'add-expense':
      case 'add':
        _handleAddExpense(uri);
        break;

      case 'quick-add':
        _handleQuickAdd(uri);
        break;

      case 'summary':
      case 'report':
        _handleNavigate('report');
        break;

      case 'subscriptions':
        _handleNavigate('subscriptions');
        break;

      case 'profile':
        _handleNavigate('profile');
        break;

      case 'pursuits':
      case 'dreams':
        _handleNavigate('pursuits');
        break;

      case 'settings':
        _handleNavigate('settings');
        break;

      case 'achievements':
      case 'badges':
        _handleNavigate('achievements');
        break;

      case 'paywall':
      case 'premium':
      case 'pro':
        _handleNavigate('paywall');
        break;

      case 'habit-calculator':
      case 'calculator':
        _handleNavigate('habit-calculator');
        break;

      case 'share':
        _handleShare(uri);
        break;

      default:
        debugPrint('[DeepLink] Unknown route: ${uri.host}');
    }
  }

  /// Handle add-expense deep link
  /// URL format: vantag://add-expense?amount=50&category=food&description=kahve
  void _handleAddExpense(Uri uri) async {
    final params = uri.queryParameters;

    // Parse amount
    final amountStr = params['amount'];
    double? amount;
    if (amountStr != null) {
      amount = double.tryParse(amountStr.replaceAll(',', '.'));
    }

    // Parse category
    final category = params['category'] ?? params['cat'];
    final mappedCategory = VoiceParserService.mapToAppCategory(category);

    // Get description
    final description = params['description'] ??
                        params['desc'] ??
                        params['note'] ??
                        '';

    // If we have enough data, add directly
    if (amount != null && amount > 0) {
      await _addExpenseDirectly(
        amount: amount,
        category: mappedCategory,
        description: description,
      );
    } else {
      // Not enough data, navigate to expense screen
      _handleNavigate('expense');
    }
  }

  /// Handle quick-add with voice text or open voice screen
  /// URL format: vantag://quick-add?text=50 lira kahve
  /// OR vantag://quick-add (opens voice screen with auto-start)
  void _handleQuickAdd(Uri uri) async {
    final text = uri.queryParameters['text'] ?? uri.queryParameters['q'];

    if (text == null || text.isEmpty) {
      // No text provided - set flag and open voice input screen
      _shouldAutoStartVoice = true;
      _navigateToVoiceInput();
      return;
    }

    // Parse voice text
    final parser = VoiceParserService();
    final result = await parser.parse(text);

    if (result.canAutoSave && result.amount != null) {
      await _addExpenseDirectly(
        amount: result.amount!,
        category: VoiceParserService.mapToAppCategory(result.category),
        description: result.description,
      );
    } else {
      // Show confirmation needed
      _showConfirmationDialog(result);
    }
  }

  /// Navigate to voice input screen
  void _navigateToVoiceInput() {
    final context = _navigatorKey?.currentContext;
    if (context == null) return;

    Navigator.of(context).pushNamed('/voice-input');
  }

  /// Add expense directly and show feedback
  Future<void> _addExpenseDirectly({
    required double amount,
    required String category,
    required String? description,
  }) async {
    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Calculate work time using actual hourly rate from user profile
    final hourlyRate = _getHourlyRate?.call() ?? 50.0; // Fallback to 50 TL/hr if not set
    final hoursRequired = hourlyRate > 0 ? amount / hourlyRate : 0.0;
    final daysRequired = hoursRequired / 8.0;

    final expense = Expense(
      amount: amount,
      category: category,
      subCategory: description?.isNotEmpty == true ? description : null,
      date: DateTime.now(),
      hoursRequired: hoursRequired,
      daysRequired: daysRequired,
      decision: ExpenseDecision.yes,
    );

    if (_onAddExpense != null) {
      await _onAddExpense!(expense);

      // Show success feedback
      _showSuccessNotification(expense);
    }
  }

  /// Show success notification
  void _showSuccessNotification(Expense expense) {
    final context = _navigatorKey?.currentContext;
    if (context == null || !context.mounted) return;

    // Haptic success
    HapticFeedback.lightImpact();

    final displayText = expense.subCategory ?? expense.category;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${expense.amount.toStringAsFixed(0)}₺ $displayText eklendi',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2ECC71),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Geri Al',
          textColor: Colors.white,
          onPressed: () {
            // TODO: Implement undo
          },
        ),
      ),
    );
  }

  /// Show confirmation dialog for low-confidence results
  void _showConfirmationDialog(VoiceParseResult result) {
    final context = _navigatorKey?.currentContext;
    if (context == null || !context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Harcamayı Onayla',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"${result.originalText}"',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            if (result.amount != null)
              _buildDetailRow('Tutar', '${result.amount!.toStringAsFixed(0)}₺'),
            _buildDetailRow(
              'Kategori',
              VoiceParserService.getCategoryDisplayName(result.category),
            ),
            _buildDetailRow('Açıklama', result.description),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'İptal',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (result.amount != null) {
                _addExpenseDirectly(
                  amount: result.amount!,
                  category: VoiceParserService.mapToAppCategory(result.category),
                  description: result.description,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
            ),
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Handle navigation to a screen
  void _handleNavigate(String route) {
    if (_onNavigate != null) {
      _onNavigate!(route);
    }
  }

  /// Generate deep link URL
  static Uri generateAddExpenseLink({
    double? amount,
    String? category,
    String? description,
  }) {
    final params = <String, String>{};
    if (amount != null) params['amount'] = amount.toString();
    if (category != null) params['category'] = category;
    if (description != null) params['description'] = description;

    return Uri(
      scheme: 'vantag',
      host: 'add-expense',
      queryParameters: params.isEmpty ? null : params,
    );
  }

  /// Generate quick-add link with voice text
  static Uri generateQuickAddLink(String text) {
    return Uri(
      scheme: 'vantag',
      host: 'quick-add',
      queryParameters: {'text': text},
    );
  }

  /// Generate pursuit deep link
  static Uri generatePursuitLink(String pursuitId) {
    return Uri(
      scheme: 'vantag',
      host: 'pursuits',
      queryParameters: {'id': pursuitId},
    );
  }

  /// Generate share link for achievements
  static Uri generateShareAchievementLink(String achievementId) {
    return Uri(
      scheme: 'vantag',
      host: 'share',
      queryParameters: {'type': 'achievement', 'id': achievementId},
    );
  }

  /// Generate share link for savings milestone
  static Uri generateShareSavingsLink(double amount) {
    return Uri(
      scheme: 'vantag',
      host: 'share',
      queryParameters: {'type': 'savings', 'amount': amount.toString()},
    );
  }

  /// Handle share deep link (from shared content)
  void _handleShare(Uri uri) {
    final type = uri.queryParameters['type'];
    final id = uri.queryParameters['id'];

    debugPrint('[DeepLink] Share: type=$type, id=$id');

    // Navigate to appropriate screen based on share type
    switch (type) {
      case 'achievement':
        _handleNavigate('achievements');
        break;
      case 'savings':
      case 'progress':
        _handleNavigate('pursuits');
        break;
      default:
        _handleNavigate('home');
    }
  }

  /// Get all supported URL schemes for documentation
  static Map<String, String> getSupportedSchemes() {
    return {
      'vantag://add-expense?amount=50&category=food&description=kahve': 'Add expense with details',
      'vantag://quick-add?text=50 lira kahve': 'Quick add with voice text',
      'vantag://quick-add': 'Open voice input screen',
      'vantag://summary': 'Open reports/summary screen',
      'vantag://subscriptions': 'Open subscriptions screen',
      'vantag://pursuits': 'Open dreams/pursuits screen',
      'vantag://achievements': 'Open achievements screen',
      'vantag://settings': 'Open settings screen',
      'vantag://profile': 'Open profile screen',
      'vantag://paywall': 'Open premium paywall',
      'vantag://habit-calculator': 'Open habit calculator',
    };
  }
}
