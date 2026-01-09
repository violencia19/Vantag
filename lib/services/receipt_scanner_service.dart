import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class ReceiptScannerService {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final _imagePicker = ImagePicker();

  Future<File?> pickImage({required bool fromCamera}) async {
    final XFile? image = await _imagePicker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) return null;
    return File(image.path);
  }

  Future<double?> extractTotalFromReceipt(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final recognizedText = await _textRecognizer.processImage(inputImage);

    final text = recognizedText.text.toLowerCase();
    final lines = text.split('\n');

    // Türkçe fişlerde toplam tutarı bulmak için anahtar kelimeler
    final totalKeywords = [
      'toplam',
      'genel toplam',
      'total',
      'tutar',
      'ödenecek',
      'nakit',
      'kart',
      'ödenen',
    ];

    double? foundAmount;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].toLowerCase();

      // Anahtar kelime içeren satırları kontrol et
      for (final keyword in totalKeywords) {
        if (line.contains(keyword)) {
          // Aynı satırda veya sonraki satırda tutar ara
          final amount = _extractAmount(lines[i]);
          if (amount != null && amount > 0) {
            // En büyük tutarı al (genellikle toplam en büyük olur)
            if (foundAmount == null || amount > foundAmount) {
              foundAmount = amount;
            }
          }

          // Sonraki satırda da kontrol et
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

    // Eğer anahtar kelime bulunamadıysa, en büyük sayıyı bul
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

  double? _extractAmount(String text) {
    // Türk lirası formatları: 123,45 veya 123.45 veya 1.234,56
    // Regex ile sayıları bul
    final patterns = [
      // 1.234,56 formatı (Türk formatı)
      RegExp(r'(\d{1,3}(?:\.\d{3})*,\d{2})'),
      // 1,234.56 formatı (Amerikan formatı)
      RegExp(r'(\d{1,3}(?:,\d{3})*\.\d{2})'),
      // 123,45 formatı
      RegExp(r'(\d+,\d{2})'),
      // 123.45 formatı
      RegExp(r'(\d+\.\d{2})'),
      // Sadece tam sayı
      RegExp(r'(\d+)'),
    ];

    for (final pattern in patterns) {
      final matches = pattern.allMatches(text);
      for (final match in matches) {
        final numStr = match.group(1)!;
        final parsed = _parseNumber(numStr);
        if (parsed != null && parsed > 0) {
          return parsed;
        }
      }
    }

    return null;
  }

  double? _parseNumber(String numStr) {
    try {
      // Türk formatı: 1.234,56 -> 1234.56
      if (numStr.contains(',') && numStr.contains('.')) {
        if (numStr.lastIndexOf(',') > numStr.lastIndexOf('.')) {
          // Türk formatı
          numStr = numStr.replaceAll('.', '').replaceAll(',', '.');
        } else {
          // Amerikan formatı
          numStr = numStr.replaceAll(',', '');
        }
      } else if (numStr.contains(',')) {
        // Sadece virgül var - muhtemelen ondalık
        numStr = numStr.replaceAll(',', '.');
      }

      return double.tryParse(numStr);
    } catch (e) {
      return null;
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}
