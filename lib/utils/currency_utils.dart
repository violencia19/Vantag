import 'package:intl/intl.dart';
import 'dart:math';
import 'package:flutter/services.dart';

/// Premium Türkçe Para Formatı Utilities
/// - Sınırsız tutar desteği (milyarlara kadar)
/// - Akıllı nokta/virgül dönüşümü
/// - Kullanıcı dostu format

// ============================================
// PARSE FONKSİYONLARI
// ============================================

/// Herhangi bir formattaki tutar string'ini double'a çevir
/// Desteklenen formatlar:
/// - Türkçe: "1.234.567,89" veya "1.234.567"
/// - İngilizce: "1,234,567.89" veya "1234567.89"
/// - Karışık: "1234567" veya "1.234567" veya "1,234,567"
double? parseAmount(String? text) {
  if (text == null || text.trim().isEmpty) return null;

  String normalized = text.trim();

  // Tüm boşlukları kaldır
  normalized = normalized.replaceAll(' ', '');

  // TL, ₺ gibi sembolleri kaldır
  normalized = normalized.replaceAll(
    RegExp(r'[TL₺\$€]', caseSensitive: false),
    '',
  );

  // Eğer hem nokta hem virgül varsa, hangisinin ondalık olduğunu belirle
  final hasComma = normalized.contains(',');
  final hasDot = normalized.contains('.');

  if (hasComma && hasDot) {
    // Son ayracı bul - o ondalık
    final lastComma = normalized.lastIndexOf(',');
    final lastDot = normalized.lastIndexOf('.');

    if (lastComma > lastDot) {
      // Türkçe format: 1.234.567,89
      normalized = normalized.replaceAll('.', '').replaceAll(',', '.');
    } else {
      // İngilizce format: 1,234,567.89
      normalized = normalized.replaceAll(',', '');
    }
  } else if (hasComma) {
    // Sadece virgül var
    final commaCount = ','.allMatches(normalized).length;
    final lastCommaIndex = normalized.lastIndexOf(',');
    final afterComma = normalized.substring(lastCommaIndex + 1);

    if (commaCount == 1 && afterComma.length <= 2) {
      // Ondalık virgül: 1234,50
      normalized = normalized.replaceAll(',', '.');
    } else {
      // Binlik virgül (İngilizce): 1,234,567
      normalized = normalized.replaceAll(',', '');
    }
  } else if (hasDot) {
    // Sadece nokta var
    final dotCount = '.'.allMatches(normalized).length;
    final lastDotIndex = normalized.lastIndexOf('.');
    final afterDot = normalized.substring(lastDotIndex + 1);

    if (dotCount == 1 && afterDot.length <= 2) {
      // Ondalık nokta: 1234.50 - olduğu gibi bırak
    } else {
      // Binlik nokta (Türkçe): 1.234.567
      normalized = normalized.replaceAll('.', '');
    }
  }

  // Sayı olmayan karakterleri kaldır (nokta hariç)
  normalized = normalized.replaceAll(RegExp(r'[^\d.]'), '');

  // Birden fazla nokta varsa sadece ilkini tut
  final dotCount = '.'.allMatches(normalized).length;
  if (dotCount > 1) {
    final firstDot = normalized.indexOf('.');
    normalized =
        normalized.substring(0, firstDot + 1) +
        normalized.substring(firstDot + 1).replaceAll('.', '');
  }

  return double.tryParse(normalized);
}

/// Türkçe formatlı metni double'a çevir (legacy uyumluluk)
/// "1.234,50" → 1234.50
double? parseTurkishCurrency(String text) => parseAmount(text);

// ============================================
// FORMAT FONKSİYONLARI
// ============================================

/// Double'ı Türkçe para formatına çevir
/// 1234567.89 → "1.234.567,89"
/// Yuvarlama yapmaz, sadece truncate eder
String formatTurkishCurrency(
  double value, {
  int decimalDigits = 2,
  bool showDecimals = true,
}) {
  if (value.isNaN || value.isInfinite) return '0';

  final isNegative = value < 0;
  final absValue = value.abs();

  // Tam sayı mı kontrol et
  final isWholeNumber = absValue == absValue.truncateToDouble();

  String result;
  if (!showDecimals || (isWholeNumber && decimalDigits == 0)) {
    // Tam sayı formatı
    result = _formatInteger(absValue.truncate());
  } else {
    // Ondalıklı format - yuvarlama yapmadan truncate et
    final multiplier = pow(10, decimalDigits);
    final truncated = (absValue * multiplier).truncate() / multiplier;
    final parts = truncated.toString().split('.');
    final integerPart = int.parse(parts[0]);
    final decimalPart = parts.length > 1
        ? parts[1].padRight(decimalDigits, '0').substring(0, decimalDigits)
        : '0'.padRight(decimalDigits, '0');

    result = '${_formatInteger(integerPart)},$decimalPart';
  }

  return isNegative ? '-$result' : result;
}

/// Kompakt format (K, M, B)
/// 1234567 → "1,23M"
/// Yuvarlama yapmaz, sadece truncate eder
String formatCompact(double value) {
  if (value.isNaN || value.isInfinite) return '0';

  final absValue = value.abs();
  final isNegative = value < 0;
  String result;

  if (absValue >= 1000000000) {
    // Milyar için: 2 ondalık basamak
    final multiplier = 100;
    final truncated =
        ((absValue / 1000000000) * multiplier).truncate() / multiplier;
    final parts = truncated.toString().split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1
        ? parts[1].padRight(2, '0').substring(0, 2)
        : '00';
    result = '$integerPart,${decimalPart}B';
  } else if (absValue >= 1000000) {
    // Milyon için: 2 ondalık basamak
    final multiplier = 100;
    final truncated =
        ((absValue / 1000000) * multiplier).truncate() / multiplier;
    final parts = truncated.toString().split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1
        ? parts[1].padRight(2, '0').substring(0, 2)
        : '00';
    result = '$integerPart,${decimalPart}M';
  } else if (absValue >= 1000) {
    // Bin için: 1 ondalık basamak
    final multiplier = 10;
    final truncated = ((absValue / 1000) * multiplier).truncate() / multiplier;
    final parts = truncated.toString().split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '0';
    result = '$integerPart,${decimalPart}K';
  } else {
    result = absValue.truncate().toString();
  }

  return isNegative ? '-$result' : result;
}

/// Kısa para formatı (tam sayı, ondalık yok)
/// 1234567.89 → "1.234.567 TL"
/// Yuvarlama yapmaz, sadece truncate eder
String formatCurrencyShort(double value, {bool showSymbol = true}) {
  final formatted = formatTurkishCurrency(
    value.truncateToDouble(),
    decimalDigits: 0,
    showDecimals: false,
  );
  return showSymbol ? '$formatted TL' : formatted;
}

/// Tam para formatı
/// 1234567.89 → "1.234.567,89 TL"
String formatCurrencyFull(double value, {bool showSymbol = true}) {
  final formatted = formatTurkishCurrency(value);
  return showSymbol ? '$formatted TL' : formatted;
}

/// Integer'ı binlik ayraçlı string'e çevir
String _formatInteger(int value) {
  if (value == 0) return '0';

  final isNegative = value < 0;
  final absValue = value.abs();
  final str = absValue.toString();
  final buffer = StringBuffer();
  final length = str.length;

  for (int i = 0; i < length; i++) {
    if (i > 0 && (length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(str[i]);
  }

  return isNegative ? '-${buffer.toString()}' : buffer.toString();
}

// ============================================
// INPUT FORMATTER
// ============================================

/// Premium Türkçe para girişi formatter
/// - Sınırsız tutar (12 digit'e kadar = trilyonlar)
/// - Akıllı cursor pozisyonu
/// - Otomatik binlik ayraç
class PremiumCurrencyFormatter extends TextInputFormatter {
  PremiumCurrencyFormatter({
    this.maxIntegerDigits = 12, // Trilyonlara kadar
    this.maxDecimalDigits = 2,
    this.allowDecimals = true,
  });

  final int maxIntegerDigits;
  final int maxDecimalDigits;
  final bool allowDecimals;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String text = newValue.text;

    // Nokta ve virgülü normalize et
    // Kullanıcı her ikisini de girebilir, virgüle çevir
    text = text.replaceAll('.', ',');

    // Sadece rakam ve virgül
    text = text.replaceAll(RegExp(r'[^\d,]'), '');

    // Ondalık işleme
    if (text.contains(',')) {
      if (!allowDecimals) {
        // Ondalık izin verilmiyorsa virgülü kaldır
        text = text.replaceAll(',', '');
      } else {
        // Birden fazla virgül varsa sadece ilkini tut
        final firstComma = text.indexOf(',');
        text =
            text.substring(0, firstComma + 1) +
            text.substring(firstComma + 1).replaceAll(',', '');

        // Ondalık kısmı sınırla
        final parts = text.split(',');
        final intPart = parts[0];
        var decPart = parts.length > 1 ? parts[1] : '';

        if (decPart.length > maxDecimalDigits) {
          decPart = decPart.substring(0, maxDecimalDigits);
        }

        // Integer limit kontrolü
        final cleanInt = intPart.replaceAll(RegExp(r'[^\d]'), '');
        if (cleanInt.length > maxIntegerDigits) {
          return oldValue;
        }

        text = '$intPart,$decPart';
      }
    } else {
      // Integer limit kontrolü
      final cleanInt = text.replaceAll(RegExp(r'[^\d]'), '');
      if (cleanInt.length > maxIntegerDigits) {
        return oldValue;
      }
    }

    // Binlik ayraç ekle
    text = _addThousandSeparators(text);

    // Cursor pozisyonu
    final cursorOffset = _calculateCursor(oldValue, newValue, text);

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: cursorOffset),
    );
  }

  String _addThousandSeparators(String text) {
    if (text.isEmpty) return text;

    String intPart;
    String decPart = '';

    if (text.contains(',')) {
      final parts = text.split(',');
      intPart = parts[0].replaceAll('.', '');
      decPart = ',${parts[1]}';
    } else {
      intPart = text.replaceAll('.', '');
    }

    // Başındaki sıfırları kaldır
    if (intPart.length > 1) {
      intPart = intPart.replaceFirst(RegExp(r'^0+'), '');
      if (intPart.isEmpty) intPart = '0';
    }

    // Binlik ayraç
    final buffer = StringBuffer();
    final len = intPart.length;
    for (int i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(intPart[i]);
    }

    return buffer.toString() + decPart;
  }

  int _calculateCursor(
    TextEditingValue oldValue,
    TextEditingValue newValue,
    String formattedText,
  ) {
    // Basit yaklaşım: ekleme/silmeye göre cursor ayarla
    final oldLen = oldValue.text.length;
    final newLen = newValue.text.length;
    final formattedLen = formattedText.length;

    if (newLen > oldLen) {
      // Ekleme
      final diff = formattedLen - oldLen;
      return (oldValue.selection.baseOffset + diff).clamp(0, formattedLen);
    } else {
      // Silme
      return (newValue.selection.baseOffset).clamp(0, formattedLen);
    }
  }
}

// ============================================
// LEGACY UYUMLULUK
// ============================================

class TurkishCurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    // 1. Binlik noktalarını temizle, her şeyi saf sayıya çek
    String cleanText = newValue.text.replaceAll('.', '');

    // 2. Noktayı virgüle çevir (Kullanıcı hangisine basarsa bassın kuruşa geçsin)
    cleanText = cleanText.replaceAll(',', '.');

    // 3. Birden fazla virgül/nokta koyulmasını engelle
    List<String> parts = cleanText.split('.');
    if (parts.length > 2) return oldValue;

    String beforeDecimal = parts[0].replaceAll(RegExp(r'[^0-9]'), '');
    String? afterDecimal = parts.length > 1 ? parts[1] : null;

    // KURUŞ SINIRI: Maksimum 2 hane (555 yazarsa 55'te durur)
    if (afterDecimal != null && afterDecimal.length > 2) {
      afterDecimal = afterDecimal.substring(0, 2);
    }

    if (beforeDecimal.isEmpty) return newValue;

    // 4. Binlik ayırıcıyı (nokta) ekle
    final formatter = NumberFormat('#,###', 'tr_TR');
    // int.parse hata vermesin diye kontrol (çok büyük sayılar için)
    int? parsedBefore = int.tryParse(beforeDecimal);
    if (parsedBefore == null) return oldValue;

    String formattedBefore = formatter
        .format(parsedBefore)
        .replaceAll(',', '.');

    // 5. Sonucu birleştir (Virgül ile kuruşu ayır)
    String finalString =
        formattedBefore + (afterDecimal != null ? ',$afterDecimal' : '');

    return TextEditingValue(
      text: finalString,
      selection: TextSelection.collapsed(offset: finalString.length),
    );
  }
}

/// Simülasyon zamanı için iki bloklu sonuç
/// UI'da yan yana iki kutucuk göstermek için kullanılır
class SimulationTimeDisplay {
  final String value1;
  final String unit1;
  final String value2;
  final String unit2;
  final bool isYearMode; // true = Yıl+Gün, false = Saat+Gün

  const SimulationTimeDisplay({
    required this.value1,
    required this.unit1,
    required this.value2,
    required this.unit2,
    required this.isYearMode,
  });
}

/// Saatleri iki ayrı birime çevirir (yan yana gösterim için)
/// workHoursPerDay: Kullanıcının günlük çalışma saati (varsayılan 8)
/// workDaysPerWeek: Kullanıcının haftalık çalışma günü (varsayılan 5)
///
/// < 1 yıllık çalışma: Sol blok = Toplam SAAT, Sağ blok = Toplam İŞ GÜNÜ
/// >= 1 yıllık çalışma: Sol blok = Toplam YIL, Sağ blok = Toplam İŞ GÜNÜ
SimulationTimeDisplay getSimulationTimeDisplay(
  double totalHours, {
  double workHoursPerDay = 8,
  int workDaysPerWeek = 5,
}) {
  // Yıllık çalışma saati: haftalık iş günü * 52 hafta * günlük saat
  final double hoursPerYear = workDaysPerWeek * 52 * workHoursPerDay;

  if (totalHours <= 0) {
    return const SimulationTimeDisplay(
      value1: '0',
      unit1: 'Saat',
      value2: '0',
      unit2: 'Gün',
      isYearMode: false,
    );
  }

  if (totalHours >= hoursPerYear) {
    // 1 yıl ve üstü: Yıl + İş Günü (toplam değerler)
    final totalYears = totalHours / hoursPerYear;
    final totalWorkDays = totalHours / workHoursPerDay;

    return SimulationTimeDisplay(
      value1: totalYears.toStringAsFixed(1),
      unit1: 'Yıl',
      value2: formatTurkishCurrency(
        totalWorkDays,
        decimalDigits: 0,
        showDecimals: false,
      ),
      unit2: 'Gün',
      isYearMode: true,
    );
  } else {
    // 1 yılın altı: Saat + İş Günü (toplam değerler)
    final totalWorkDays = totalHours / workHoursPerDay;

    return SimulationTimeDisplay(
      value1: formatTurkishCurrency(totalHours, decimalDigits: 1),
      unit1: 'Saat',
      value2: totalWorkDays.toStringAsFixed(1),
      unit2: 'Gün',
      isYearMode: false,
    );
  }
}
