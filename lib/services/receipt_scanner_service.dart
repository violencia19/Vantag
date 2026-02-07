import 'dart:io';
import 'package:flutter/foundation.dart';
// TEMPORARILY DISABLED for iOS Simulator - ML Kit doesn't support arm64 simulator
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'analytics_service.dart';

/// Result from scanning a receipt
class ScanResult {
  final double? amount;
  final String? merchant;
  final DateTime? date;
  final String? currency;

  const ScanResult({this.amount, this.merchant, this.date, this.currency});

  bool get hasAmount => amount != null && amount! > 0;

  @override
  String toString() =>
      'ScanResult(amount: $amount, merchant: $merchant, date: $date, currency: $currency)';
}

class ReceiptScannerService {
  // ML Kit disabled until arm64 simulator support is restored.
  // Set to true when google_mlkit_text_recognition is re-enabled in pubspec.
  static const bool _mlKitEnabled = false;

  // final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final _imagePicker = ImagePicker();

  /// Whether OCR scanning is currently available
  bool get isAvailable => _mlKitEnabled;

  Future<File?> pickImage({required bool fromCamera}) async {
    final XFile? image = await _imagePicker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) return null;
    return File(image.path);
  }

  /// Scan receipt and extract amount, merchant, and currency.
  /// Returns empty ScanResult when ML Kit is disabled — callers should
  /// check [isAvailable] before invoking and show appropriate UI.
  Future<ScanResult> scanReceipt() async {
    AnalyticsService().logReceiptScanned();

    if (!_mlKitEnabled) {
      debugPrint('[ReceiptScanner] ML Kit disabled — returning empty result');
      return const ScanResult();
    }

    final imageFile = await pickImage(fromCamera: true);
    if (imageFile == null) {
      return const ScanResult();
    }
    return extractFromReceipt(imageFile);
  }

  /// Extract data from receipt image.
  /// Returns empty ScanResult when ML Kit is disabled.
  Future<ScanResult> extractFromReceipt(File imageFile) async {
    if (!_mlKitEnabled) {
      debugPrint('[ReceiptScanner] ML Kit disabled — returning empty result');
      return const ScanResult();
    }

    // TODO: Re-enable when ML Kit arm64 simulator support is restored:
    // final inputImage = InputImage.fromFile(imageFile);
    // final recognizedText = await _textRecognizer.processImage(inputImage);
    // final fullText = recognizedText.text;
    // final lines = fullText.split('\n');
    // final currency = _detectCurrency(fullText);
    // final merchant = _extractMerchant(lines);
    // final amount = _extractTotal(lines);
    // return ScanResult(amount: amount, merchant: merchant, currency: currency);

    return const ScanResult();
  }

  /// Legacy method for backwards compatibility
  Future<double?> extractTotalFromReceipt(File imageFile) async {
    final result = await extractFromReceipt(imageFile);
    return result.amount;
  }

  void dispose() {
    // Re-enable when ML Kit is restored:
    // _textRecognizer.close();
  }
}
