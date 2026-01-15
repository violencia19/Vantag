import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import '../utils/global_merchants.dart';

/// Source of the merchant match
enum MatchSource {
  /// Matched from global merchant database
  global,

  /// Matched from user's learned merchants
  userLearned,

  /// Matched using fuzzy string matching
  fuzzyMatch,

  /// Matched from crowdsourced data (future)
  crowdsourced,
}

/// Represents a matched merchant result
class MerchantMatch {
  final String pattern;
  final String category;
  final String displayName;
  final double confidence;
  final MatchSource source;

  MerchantMatch({
    required this.pattern,
    required this.category,
    required this.displayName,
    required this.confidence,
    required this.source,
  });

  /// True if confidence is high enough for automatic matching
  bool get isAutoMatch => confidence >= 0.85;

  /// True if match is a suggestion (medium confidence)
  bool get isSuggestion => confidence >= 0.70 && confidence < 0.85;

  @override
  String toString() =>
      'MerchantMatch(pattern: $pattern, category: $category, confidence: $confidence, source: $source)';
}

/// A merchant learned from user input
class LearnedMerchant {
  final String pattern;
  final String category;
  final String displayName;
  final DateTime createdAt;
  int usageCount;

  LearnedMerchant({
    required this.pattern,
    required this.category,
    required this.displayName,
    required this.createdAt,
    this.usageCount = 1,
  });

  factory LearnedMerchant.fromMap(Map<String, dynamic> map) {
    return LearnedMerchant(
      pattern: map['pattern'] as String,
      category: map['category'] as String,
      displayName: map['displayName'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      usageCount: map['usageCount'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pattern': pattern,
      'category': category,
      'displayName': displayName,
      'createdAt': Timestamp.fromDate(createdAt),
      'usageCount': usageCount,
    };
  }
}

/// Service for learning and matching merchants from transaction descriptions
class MerchantLearningService {
  static final MerchantLearningService _instance = MerchantLearningService._();
  factory MerchantLearningService() => _instance;
  MerchantLearningService._();

  /// Local cache of learned merchants - avoid Firestore on every lookup
  final Map<String, LearnedMerchant> _localCache = {};
  bool _cacheLoaded = false;
  String? _loadedUserId;

  /// Load merchant cache from Firestore at app startup
  Future<void> loadCache(String userId) async {
    // Skip if already loaded for this user
    if (_cacheLoaded && _loadedUserId == userId) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('learned_merchants')
          .get();

      _localCache.clear();
      for (final doc in snapshot.docs) {
        final merchant = LearnedMerchant.fromMap(doc.data());
        _localCache[merchant.pattern] = merchant;
      }

      _cacheLoaded = true;
      _loadedUserId = userId;
    } catch (e) {
      // Continue with empty cache on error
      _cacheLoaded = true;
      _loadedUserId = userId;
    }
  }

  /// Clear cache (on logout)
  void clearCache() {
    _localCache.clear();
    _cacheLoaded = false;
    _loadedUserId = null;
  }

  /// Normalize text for matching - clean bank noise from descriptions
  String normalize(String text) {
    return text
        .toUpperCase()
        // Turkish characters to ASCII for matching
        .replaceAll('İ', 'I')
        .replaceAll('Ş', 'S')
        .replaceAll('Ğ', 'G')
        .replaceAll('Ü', 'U')
        .replaceAll('Ö', 'O')
        .replaceAll('Ç', 'C')
        .replaceAll('I', 'I') // Turkish dotless I
        // Clean bank terminology
        .replaceAll(RegExp(r'POS\s*'), '')
        .replaceAll(RegExp(r'SATIS\s*'), '')
        .replaceAll(RegExp(r'KK\s*'), '')
        .replaceAll(RegExp(r'KREDI KARTI\s*'), '')
        .replaceAll(RegExp(r'HARCAMA\s*'), '')
        .replaceAll(RegExp(r'ISLEM\s*'), '')
        .replaceAll(RegExp(r'ODEME\s*'), '')
        .replaceAll(RegExp(r'INTERNET\s*'), '')
        .replaceAll(RegExp(r'MOBIL\s*'), '')
        .replaceAll(RegExp(r'ONLINE\s*'), '')
        .replaceAll(RegExp(r'FATURA\s*'), '')
        .replaceAll(RegExp(r'OTOMATIK\s*'), '')
        // Clean dates, times, receipt numbers
        .replaceAll(RegExp(r'\d{2}[/.-]\d{2}[/.-]\d{2,4}'), '')
        .replaceAll(RegExp(r'\d{2}:\d{2}'), '')
        .replaceAll(RegExp(r'#\d+'), '')
        .replaceAll(RegExp(r'REF[:\s]*\w+'), '')
        .replaceAll(RegExp(r'FIS[:\s]*\d+'), '')
        // Clean special characters
        .replaceAll(RegExp(r'[^A-Z0-9\s&]'), '')
        // Multiple spaces to single
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Main search function - find merchant from raw description
  Future<MerchantMatch?> findMerchant(String rawDescription) async {
    final normalized = normalize(rawDescription);

    if (normalized.isEmpty) return null;

    // 1. First check EXACT MATCH in local cache (user learned)
    for (final entry in _localCache.entries) {
      if (normalized.contains(entry.key) || entry.key.contains(normalized)) {
        return MerchantMatch(
          pattern: entry.key,
          category: entry.value.category,
          displayName: entry.value.displayName,
          confidence: 1.0,
          source: MatchSource.userLearned,
        );
      }
    }

    // 2. Check global merchants database
    final globalCategory = GlobalMerchants.getCategory(normalized);
    if (globalCategory != null) {
      final merchantName = GlobalMerchants.getMerchantName(normalized)!;
      return MerchantMatch(
        pattern: merchantName,
        category: globalCategory,
        displayName: GlobalMerchants.getDisplayName(merchantName),
        confidence: 1.0,
        source: MatchSource.global,
      );
    }

    // 3. FUZZY MATCH - find similar in local cache
    MerchantMatch? bestFuzzyMatch;
    int bestScore = 0;

    for (final entry in _localCache.entries) {
      // Use fuzzywuzzy ratio for similarity
      final score = ratio(entry.key, normalized);
      if (score > bestScore && score >= 70) {
        bestScore = score;
        bestFuzzyMatch = MerchantMatch(
          pattern: entry.key,
          category: entry.value.category,
          displayName: entry.value.displayName,
          confidence: score / 100.0,
          source: MatchSource.fuzzyMatch,
        );
      }
    }

    // Return fuzzy match if found
    // 0.85+ = auto match, 0.70-0.85 = suggestion
    if (bestFuzzyMatch != null) {
      return bestFuzzyMatch;
    }

    // 4. No match found
    return null;
  }

  /// Learn a new merchant from user input
  Future<void> learnMerchant({
    required String userId,
    required String rawDescription,
    required String category,
    required String displayName,
  }) async {
    final pattern = normalize(rawDescription);

    // Don't save very short patterns (false positive prevention)
    if (pattern.length < 4) return;

    final learned = LearnedMerchant(
      pattern: pattern,
      category: category,
      displayName: displayName,
      createdAt: DateTime.now(),
      usageCount: 1,
    );

    try {
      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('learned_merchants')
          .doc(pattern.hashCode.abs().toString())
          .set(learned.toMap(), SetOptions(merge: true));

      // Update local cache
      _localCache[pattern] = learned;
    } catch (e) {
      // Still update local cache even if Firestore fails
      _localCache[pattern] = learned;
    }
  }

  /// Increment usage count for a pattern (for confidence scoring)
  Future<void> incrementUsage(String userId, String pattern) async {
    if (!_localCache.containsKey(pattern)) return;

    _localCache[pattern]!.usageCount++;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('learned_merchants')
          .doc(pattern.hashCode.abs().toString())
          .update({'usageCount': FieldValue.increment(1)});
    } catch (e) {
      // Ignore Firestore errors for usage increment
    }
  }

  /// Delete a learned merchant
  Future<void> deleteMerchant(String userId, String pattern) async {
    _localCache.remove(pattern);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('learned_merchants')
          .doc(pattern.hashCode.abs().toString())
          .delete();
    } catch (e) {
      // Ignore errors
    }
  }

  /// Get all learned merchants for display
  List<LearnedMerchant> getAllLearnedMerchants() {
    return _localCache.values.toList()
      ..sort((a, b) => b.usageCount.compareTo(a.usageCount));
  }

  /// Check if cache is loaded
  bool get isCacheLoaded => _cacheLoaded;

  /// Get count of learned merchants
  int get learnedMerchantCount => _localCache.length;
}
