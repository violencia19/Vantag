import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'referral_service.dart';
import 'deep_link_service.dart';

/// Paylaşım servisi - Widget'ları screenshot alıp paylaşır
class ShareService {
  /// Get share text with referral link if available
  static Future<String> getShareTextWithReferral({
    String? customText,
    String defaultText = 'Sen kaç gün çalışıyorsun? 👀',
  }) async {
    String shareLink = 'vantag.app';
    try {
      final referralCode = await ReferralService().getOrCreateReferralCode();
      if (referralCode != null) {
        final referralLink = DeepLinkService.generateReferralLink(referralCode);
        shareLink = referralLink.toString();
      }
    } catch (_) {
      // Use default link if referral fails
    }
    return '${customText ?? defaultText} $shareLink';
  }

  /// Widget'ı image'a çevirip paylaş
  /// [key] - RepaintBoundary'nin GlobalKey'i
  /// [shareText] - Paylaşım metni (opsiyonel, referral link otomatik eklenir)
  static Future<bool> shareWidget(
    GlobalKey key, {
    String? shareText,
  }) async {
    try {
      // Widget'ı image'a çevir
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        return false;
      }

      // 3x scale ile yüksek kaliteli görüntü
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      // PNG'ye çevir
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        return false;
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // Temp dosyaya kaydet
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/vantag_share_$timestamp.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      // Get share text with referral link
      final finalShareText = shareText ?? await getShareTextWithReferral();

      // Paylaş
      await Share.shareXFiles(
        [XFile(filePath)],
        text: finalShareText,
      );

      // Temp dosyayı 5 dakika sonra sil
      Future.delayed(const Duration(minutes: 5), () {
        if (file.existsSync()) {
          try {
            file.deleteSync();
          } catch (_) {
            // Silme hatası görmezden gelinir
          }
        }
      });

      return true;
    } catch (_) {
      return false;
    }
  }

  /// Sadece metin paylaş
  static Future<void> shareText(String text) async {
    await Share.share(text);
  }
}
