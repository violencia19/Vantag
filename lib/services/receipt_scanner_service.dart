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
  // TEMPORARILY DISABLED for iOS Simulator
  // final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final _imagePicker = ImagePicker();

  Future<File?> pickImage({required bool fromCamera}) async {
    final XFile? image = await _imagePicker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) return null;
    return File(image.path);
  }

  /// Scan receipt and extract amount, merchant, and currency
  /// TEMPORARILY DISABLED - Returns empty result for simulator testing
  Future<ScanResult> scanReceipt() async {
    // Track receipt scanner usage
    AnalyticsService().logReceiptScanned();

    // TEMPORARILY DISABLED for iOS Simulator
    debugPrint('[ReceiptScanner] ML Kit temporarily disabled for simulator testing');
    return const ScanResult();

    /* ORIGINAL CODE - Re-enable when ML Kit is restored:
    final imageFile = await pickImage(fromCamera: true);
    if (imageFile == null) {
      return const ScanResult();
    }
    return extractFromReceipt(imageFile);
    */
  }

  /// Extract data from receipt image
  /// TEMPORARILY DISABLED - Returns empty result for simulator testing
  Future<ScanResult> extractFromReceipt(File imageFile) async {
    // TEMPORARILY DISABLED for iOS Simulator
    debugPrint('[ReceiptScanner] ML Kit temporarily disabled for simulator testing');
    return const ScanResult();

    /* ORIGINAL CODE - Re-enable when ML Kit is restored:
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

    debugPrint(
      '[ReceiptScanner] Extracted: amount=$amount, currency=$currency, merchant=$merchant',
    );

    return ScanResult(amount: amount, merchant: merchant, currency: currency);
    */
  }

  /// Legacy method for backwards compatibility
  Future<double?> extractTotalFromReceipt(File imageFile) async {
    final result = await extractFromReceipt(imageFile);
    return result.amount;
  }

  void dispose() {
    // TEMPORARILY DISABLED for iOS Simulator
    // _textRecognizer.close();
  }
}
