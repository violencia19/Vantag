import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

/// Result from scanning a receipt
class ScanResult {
  final double? amount;
  final String? merchant;
  final DateTime? date;
  final String? currency;

  const ScanResult({
    this.amount,
    this.merchant,
    this.date,
    this.currency,
  });

  bool get hasAmount => amount != null && amount! > 0;

  @override
  String toString() =>
      'ScanResult(amount: $amount, merchant: $merchant, date: $date, currency: $currency)';
}

class ReceiptScannerService {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final _imagePicker = ImagePicker();

  // Total keywords in multiple languages
  static const _totalKeywords = [
    // Turkish
    'toplam', 'tutar', 'genel toplam', 'ödenecek', 'ara toplam',
    'nakit', 'kart', 'ödenen', 'net tutar',
    // English
    'total', 'amount', 'sum', 'grand total', 'subtotal', 'balance due',
    'amount due', 'payment', 'net amount',
    // German (common in EU)
    'summe', 'gesamt', 'betrag', 'gesamtbetrag', 'endbetrag',
    // French (common in EU)
    'total', 'montant', 'somme', 'à payer',
    // Spanish
    'total', 'importe', 'suma',
  ];

  Future<File?> pickImage({required bool fromCamera}) async {
    final XFile? image = await _imagePicker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) return null;
    return File(image.path);
  }

  /// Scan receipt and extract amount, merchant, and currency
  Future<ScanResult> scanReceipt() async {
    final imageFile = await pickImage(fromCamera: true);
    if (imageFile == null) {
      return const ScanResult();
    }
    return extractFromReceipt(imageFile);
  }

  /// Extract data from receipt image
  Future<ScanResult> extractFromReceipt(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final recognizedText = await _textRecognizer.processImage(inputImage);

    final fullText = recognizedText.text;
    final lines = fullText.split('\n');

    // Detect currency from receipt
    final currency = _detectCurrency(fullText);

    // Extract merchant (usually first non-empty line or line with store name)
    final merchant = _extractMerchant(lines);

    // Extract total amount
    final amount = _extractTotal(lines);

    debugPrint('[ReceiptScanner] Extracted: amount=$amount, currency=$currency, merchant=$merchant');

    return ScanResult(
      amount: amount,
      merchant: merchant,
      currency: currency,
    );
  }

  /// Legacy method for backwards compatibility
  Future<double?> extractTotalFromReceipt(File imageFile) async {
    final result = await extractFromReceipt(imageFile);
    return result.amount;
  }

  /// Detect currency from receipt text
  String? _detectCurrency(String fullText) {
    final text = fullText.toUpperCase();

    // Check for currency symbols and codes
    // Order matters - check specific symbols first
    if (text.contains('₺') || RegExp(r'\bTL\b').hasMatch(text) || text.contains('TRY')) {
      return 'TRY';
    }
    if (text.contains('€') || RegExp(r'\bEUR\b').hasMatch(text)) {
      return 'EUR';
    }
    if (text.contains('£') || RegExp(r'\bGBP\b').hasMatch(text)) {
      return 'GBP';
    }
    if (text.contains('\$') || RegExp(r'\bUSD\b').hasMatch(text)) {
      return 'USD';
    }

    return null; // Default to user's selected currency
  }

  /// Extract merchant name (usually first meaningful line)
  String? _extractMerchant(List<String> lines) {
    for (final line in lines.take(5)) {
      final cleaned = line.trim();
      // Skip empty lines, lines with only numbers, or very short lines
      if (cleaned.isEmpty || cleaned.length < 3) continue;
      if (RegExp(r'^[\d\s\-\.\,\/]+$').hasMatch(cleaned)) continue;
      // Skip lines that look like addresses or dates
      if (RegExp(r'\d{2}[\/\-\.]\d{2}[\/\-\.]\d{2,4}').hasMatch(cleaned)) continue;
      if (cleaned.toLowerCase().contains('tel:') ||
          cleaned.toLowerCase().contains('fax:')) continue;

      // Found a potential merchant name
      return cleaned;
    }
    return null;
  }

  /// Extract total amount from receipt lines
  double? _extractTotal(List<String> lines) {
    double? foundAmount;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].toLowerCase();

      // Check for total keywords
      for (final keyword in _totalKeywords) {
        if (line.contains(keyword)) {
          // Extract from same line
          final amount = _extractAmount(lines[i]);
          if (amount != null && amount > 0) {
            if (foundAmount == null || amount > foundAmount) {
              foundAmount = amount;
            }
          }

          // Also check next line
          if (i + 1 < lines.length) {
            final nextAmount = _extractAmount(lines[i + 1]);
            if (nextAmount != null && nextAmount > 0) {
              if (foundAmount == null || nextAmount > foundAmount) {
                foundAmount = nextAmount;
              }
            }
          }
        }
      }
    }

    // If no keyword found, find the largest amount as fallback
    if (foundAmount == null) {
      for (final line in lines) {
        final amount = _extractAmount(line);
        if (amount != null && amount > 0) {
          if (foundAmount == null || amount > foundAmount) {
            foundAmount = amount;
          }
        }
      }
    }

    return foundAmount;
  }

  /// Extract amount from text
  double? _extractAmount(String text) {
    // Remove currency symbols
    String cleaned = text.replaceAll(RegExp(r'[₺$€£]'), ' ');
    cleaned = cleaned.replaceAll(
      RegExp(r'\b(TL|TRY|USD|EUR|GBP)\b', caseSensitive: false),
      ' ',
    );

    // Patterns for different number formats
    final patterns = [
      // Turkish format: 1.234,56
      RegExp(r'(\d{1,3}(?:\.\d{3})*,\d{2})'),
      // US/UK format: 1,234.56
      RegExp(r'(\d{1,3}(?:,\d{3})*\.\d{2})'),
      // Simple decimal with comma: 123,45
      RegExp(r'(\d+,\d{2})'),
      // Simple decimal with dot: 123.45
      RegExp(r'(\d+\.\d{2})'),
      // Integer
      RegExp(r'(\d+)'),
    ];

    for (final pattern in patterns) {
      final matches = pattern.allMatches(cleaned);
      for (final match in matches) {
        final numStr = match.group(1)!;
        final parsed = _parseAmount(numStr);
        if (parsed != null && parsed > 0) {
          return parsed;
        }
      }
    }

    return null;
  }

  /// Parse amount string handling different formats
  double? _parseAmount(String text) {
    try {
      String cleaned = text.trim();

      // Handle formats with both separators
      if (cleaned.contains(',') && cleaned.contains('.')) {
        if (cleaned.lastIndexOf(',') > cleaned.lastIndexOf('.')) {
          // Turkish format: 1.234,56 -> 1234.56
          cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
        } else {
          // US/UK format: 1,234.56 -> 1234.56
          cleaned = cleaned.replaceAll(',', '');
        }
      } else if (cleaned.contains(',')) {
        // Only comma - could be Turkish decimal or US thousands
        final parts = cleaned.split(',');
        if (parts.length == 2 && parts[1].length == 2) {
          // Likely Turkish decimal: 123,45 -> 123.45
          cleaned = cleaned.replaceAll(',', '.');
        } else {
          // Likely US thousands: 1,234 -> 1234
          cleaned = cleaned.replaceAll(',', '');
        }
      }

      return double.tryParse(cleaned);
    } catch (e) {
      return null;
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}
