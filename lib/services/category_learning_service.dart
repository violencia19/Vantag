import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/store_categories.dart';

/// Kullanıcının manuel kategori seçimlerini öğrenen ve hatırlayan servis
/// Öncelik: Kullanıcının öğrettiği > Built-in sözlük
class CategoryLearningService {
  static const _keyLearnedCategories = 'learned_categories';

  /// Kullanıcının öğrettiği kategoriler (description -> category)
  static Map<String, String> _learnedCategories = {};
  static bool _isInitialized = false;

  /// Servisi başlat ve önceki öğrenmeleri yükle
  static Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyLearnedCategories);

    if (json != null && json.isNotEmpty) {
      try {
        final decoded = jsonDecode(json) as Map<String, dynamic>;
        _learnedCategories = decoded.map((k, v) => MapEntry(k, v.toString()));
      } catch (e) {
        _learnedCategories = {};
      }
    }

    _isInitialized = true;
  }

  /// Kullanıcının manuel seçimini öğren ve kaydet
  /// [description]: Kullanıcının girdiği açıklama
  /// [category]: Kullanıcının seçtiği kategori
  static Future<void> learn(String description, String category) async {
    if (description.trim().isEmpty || category.isEmpty) return;

    // Açıklamadan anahtar kelimeler çıkar
    final keywords = _extractKeywords(description);

    for (final keyword in keywords) {
      _learnedCategories[keyword] = category;
    }

    // Tam açıklamayı da kaydet
    _learnedCategories[description.toLowerCase().trim()] = category;

    await _save();
  }

  /// Verilen açıklamadan kategori tahmini yap
  /// Önce kullanıcı tercihlerine, sonra built-in sözlüğe bakar
  static String? predictCategory(String description) {
    if (description.trim().isEmpty) return null;

    final searchText = description.toLowerCase().trim();

    // 1. Önce kullanıcının tam eşleşmelerine bak
    if (_learnedCategories.containsKey(searchText)) {
      return _learnedCategories[searchText];
    }

    // 2. Kullanıcının öğrendiği kelimelerde partial match
    for (final entry in _learnedCategories.entries) {
      if (searchText.contains(entry.key) || entry.key.contains(searchText)) {
        return entry.value;
      }
    }

    // 3. Kelime bazlı arama (öğrenilmiş)
    final words = searchText.split(RegExp(r'\s+'));
    for (final word in words) {
      if (word.length < 2) continue;
      if (_learnedCategories.containsKey(word)) {
        return _learnedCategories[word];
      }
    }

    // 4. Built-in sözlüğe bak
    final builtInCategory = StoreCategories.findCategory(description);
    if (builtInCategory != null) {
      return builtInCategory;
    }

    return null;
  }

  /// Açıklamadan anahtar kelimeler çıkar
  static List<String> _extractKeywords(String description) {
    final text = description.toLowerCase().trim();
    final words = text.split(RegExp(r'\s+'));

    // En az 3 karakterli kelimeleri al
    return words
        .where((w) => w.length >= 3)
        .map((w) => w.replaceAll(RegExp(r'[^\w\sğüşıöçĞÜŞİÖÇ]'), ''))
        .where((w) => w.isNotEmpty)
        .toList();
  }

  /// Öğrenilen kategorileri SharedPreferences'a kaydet
  static Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLearnedCategories, jsonEncode(_learnedCategories));
  }

  /// Tüm öğrenmeleri sıfırla (debug için)
  static Future<void> reset() async {
    _learnedCategories.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLearnedCategories);
  }

  /// Debug: Öğrenilmiş kategori sayısı
  static int get learnedCount => _learnedCategories.length;

  /// Debug: Tüm öğrenilmiş kategorileri göster
  static Map<String, String> get learnedCategories => Map.unmodifiable(_learnedCategories);
}
