import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Alt kategori öneri ve geçmiş yönetimi servisi
class SubCategoryService {
  static const _keyPrefix = 'recent_subcategories_';
  static const _maxRecentCount = 5;

  /// Ana kategoriye göre sabit öneriler
  static const Map<String, List<String>> fixedSuggestions = {
    'Yiyecek': ['Market', 'Kafe', 'Restoran'],
    'Giyim': ['Ayakkabı', 'Bot', 'Kaban'],
    'Ulaşım': ['Benzin', 'Taksi', 'Akbil'],
    'Elektronik': ['Telefon', 'Bilgisayar', 'Aksesuar'],
    'Eğlence': ['Sinema', 'Oyun', 'Konser'],
    'Sağlık': ['İlaç', 'Muayene', 'Vitamin'],
    'Eğitim': ['Kitap', 'Kurs', 'Yazılım'],
    'Faturalar': ['Elektrik', 'Su', 'İnternet'],
    'Diğer': ['Hediye', 'Abonelik', 'Bakım'],
  };

  /// Alt kategori metnini normalize et
  /// - trim
  /// - İlk harf büyük, geri kalan küçük
  /// - Türkçe karakterleri koru
  static String normalize(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return '';

    // İlk harfi büyük, gerisini küçük yap (Türkçe uyumlu)
    return _toTitleCase(trimmed);
  }

  /// Türkçe uyumlu title case
  static String _toTitleCase(String text) {
    if (text.isEmpty) return text;

    // Türkçe karakter haritası
    const lowerToUpper = {
      'a': 'A', 'b': 'B', 'c': 'C', 'ç': 'Ç', 'd': 'D', 'e': 'E',
      'f': 'F', 'g': 'G', 'ğ': 'Ğ', 'h': 'H', 'ı': 'I', 'i': 'İ',
      'j': 'J', 'k': 'K', 'l': 'L', 'm': 'M', 'n': 'N', 'o': 'O',
      'ö': 'Ö', 'p': 'P', 'r': 'R', 's': 'S', 'ş': 'Ş', 't': 'T',
      'u': 'U', 'ü': 'Ü', 'v': 'V', 'y': 'Y', 'z': 'Z',
    };

    const upperToLower = {
      'A': 'a', 'B': 'b', 'C': 'c', 'Ç': 'ç', 'D': 'd', 'E': 'e',
      'F': 'f', 'G': 'g', 'Ğ': 'ğ', 'H': 'h', 'I': 'ı', 'İ': 'i',
      'J': 'j', 'K': 'k', 'L': 'l', 'M': 'm', 'N': 'n', 'O': 'o',
      'Ö': 'ö', 'P': 'p', 'R': 'r', 'S': 's', 'Ş': 'ş', 'T': 't',
      'U': 'u', 'Ü': 'ü', 'V': 'v', 'Y': 'y', 'Z': 'z',
    };

    final buffer = StringBuffer();
    bool isFirst = true;

    for (final char in text.split('')) {
      if (isFirst) {
        // İlk harfi büyük yap
        buffer.write(lowerToUpper[char] ?? char.toUpperCase());
        isFirst = false;
      } else {
        // Diğer harfleri küçük yap
        buffer.write(upperToLower[char] ?? char.toLowerCase());
      }
    }

    return buffer.toString();
  }

  /// İki alt kategori aynı mı kontrol et (case-insensitive, normalize edilmiş)
  static bool isSame(String a, String b) {
    return normalize(a).toLowerCase() == normalize(b).toLowerCase();
  }

  /// Ana kategori için son kullanılan alt kategorileri getir
  Future<List<String>> getRecentSubCategories(String mainCategory) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix${_sanitizeKey(mainCategory)}';
    final json = prefs.getString(key);

    if (json == null) return [];

    try {
      final list = jsonDecode(json) as List;
      return list.cast<String>();
    } catch (e) {
      return [];
    }
  }

  /// Ana kategori için yeni alt kategori ekle (en son kullanılana taşı)
  Future<void> addRecentSubCategory(String mainCategory, String subCategory) async {
    final normalized = normalize(subCategory);
    if (normalized.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix${_sanitizeKey(mainCategory)}';

    // Mevcut listeyi al
    final current = await getRecentSubCategories(mainCategory);

    // Aynı olanı çıkar (case-insensitive)
    current.removeWhere((s) => isSame(s, normalized));

    // Başa ekle
    current.insert(0, normalized);

    // Maksimum 5 tut
    final trimmed = current.take(_maxRecentCount).toList();

    // Kaydet
    await prefs.setString(key, jsonEncode(trimmed));
  }

  /// Ana kategori için tüm önerileri getir (son kullanılanlar + sabit)
  Future<SubCategorySuggestions> getSuggestions(String mainCategory) async {
    final recent = await getRecentSubCategories(mainCategory);
    final fixed = fixedSuggestions[mainCategory] ?? [];

    // Sabit önerilerden son kullanılanlarda olmayanları filtrele
    final filteredFixed = fixed
        .where((f) => !recent.any((r) => isSame(r, f)))
        .toList();

    return SubCategorySuggestions(
      recent: recent,
      fixed: filteredFixed,
    );
  }

  /// Key'i sanitize et (SharedPreferences için güvenli)
  String _sanitizeKey(String category) {
    return category
        .replaceAll(' ', '_')
        .replaceAll('ı', 'i')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c')
        .replaceAll('İ', 'I')
        .replaceAll('Ğ', 'G')
        .replaceAll('Ü', 'U')
        .replaceAll('Ş', 'S')
        .replaceAll('Ö', 'O')
        .replaceAll('Ç', 'C')
        .toLowerCase();
  }
}

/// Alt kategori önerileri
class SubCategorySuggestions {
  final List<String> recent; // Son kullanılanlar (outline stil)
  final List<String> fixed;  // Sabit öneriler (normal stil)

  const SubCategorySuggestions({
    required this.recent,
    required this.fixed,
  });

  bool get isEmpty => recent.isEmpty && fixed.isEmpty;
  bool get hasRecent => recent.isNotEmpty;
  bool get hasFixed => fixed.isNotEmpty;
}
