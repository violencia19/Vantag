import 'dart:math';

enum DurationCategory {
  short,      // 1-8 saat
  medium,     // 1-7 gün
  long,       // 7+ gün
  simulation  // 100.000 TL ve üzeri (Özel kategori)
}

enum DecisionType {
  yes,      // Aldım
  no,       // Vazgeçtim
  thinking, // Düşünüyorum
}

class MessagesService {
  final _random = Random();
  final List<String> _recentMessages = [];
  static const _maxRecentMessages = 5;

  // ============================================
  // SÜREYE VE TUTARA GÖRE MESAJLAR
  // ============================================

  static const _shortDurationMessages = [
    'Birkaç saatlik emeğin, bir anlık heves için mi?',
    'Bu kadar kısa sürede kazandığın parayı harcamak kolay, kazanmak zor.',
    'Sabah işe gittin, öğlene kalmadan bu para gidecek.',
    'Bir kahve molası kadar sürede kazandın, bir tıkla gidecek.',
    'Yarım günlük mesai, tam günlük pişmanlık olmasın.',
    'Bu ürün için çalıştığın saatleri düşün.',
    'Küçük görünüyor ama toplamda büyük fark yaratıyor.',
    'Şimdi değil dersen, yarın da olur.',
  ];

  static const _mediumDurationMessages = [
    'Bir haftalık emeğin bu ürüne değer mi?',
    'Bu parayı biriktirmek günler aldı, harcamak saniyeler alacak.',
    'Bir haftanı buna yatırıyor olsaydın kabul eder miydin?',
    'Günlerce emek, anlık bir karar.',
    'Hafta sonu tatili mi, bu ürün mü?',
    'Bu kadar gün boyunca ne için çalıştığını hatırla.',
    'Pazartesiden cumaya kadar bunun için mi çalıştın?',
    'Haftalık bütçeni tek seferde harcamak mantıklı mı?',
  ];

  static const _longDurationMessages = [
    'Haftalarca çalışman gerekiyor bunun için. Gerçekten değer mi?',
    'Bu parayı biriktirmek aylar alabilir.',
    'Uzun vadeli hedeflerinden birini erteliyor olabilirsin.',
    'Bu ürün için harcayacağın zaman, tatil planlarını etkiler mi?',
    'Bu yatırım mı, harcama mı?',
    'Gelecekteki sen bu kararı nasıl değerlendirir?',
    'Bu kadar uzun süre çalışmak, kalıcı bir şey için olmalı.',
    'Ay sonunda bu karara nasıl bakacaksın?',
  ];

  // YENİ: Simülasyon seviyesi için karar ekranı mesajları (100k+ TL)
  static const _simulationDurationMessages = [
    'Bu rakam artık bir harcama değil, ciddi bir yatırım kararı.',
    'Böyle büyük bir tutar için duygularınla değil, vizyonunla karar ver.',
    'Bu tutarın karşılığı olan zamanı hesaplamak bile güç.',
    'Hayallerini süsleyen o büyük adım bu olabilir mi?',
    'Bu kadar büyük bir rakamı yönetmek, sabır ve strateji ister.',
    'Cüzdanını değil, geleceğini etkileyecek bir noktadasın.',
    'Büyük rakamlar, büyük sorumluluklar getirir. Hazır mısın?',
    'Bu tutar senin için sadece bir sayı mı, yoksa bir dönüm noktası mı?',
  ];

  // ============================================
  // KARARA GÖRE MESAJLAR
  // ============================================

  static const _yesMessages = [
    'Kaydettim. Umarım değer.',
    'Bakalım pişman olacak mısın.',
    'Tamam, senin paran.',
    'Aldın aldın, hayırlı olsun.',
    'Keyfin bilir.',
    'Peki, kayıtlara geçti.',
    'İhtiyaçsa sorun yok.',
    'Bazen harcamak da gerekir.',
  ];

  static const _noMessages = [
    'Güzel karar. Bu parayı kurtardın.',
    'Zor olanı seçtin, gelecekte teşekkür edeceksin.',
    'İrade kazandı.',
    'Akıllıca. Bu para sana lazım olacak.',
    'Vazgeçmek de bir kazanım.',
    'Heves geçti, para kaldı.',
    'Kendine yatırım yaptın aslında.',
    'Zor karar, doğru karar.',
  ];

  static const _thinkingMessages = [
    'Düşünmek bedava, harcamak değil.',
    'Acele etmemek akıllıca.',
    'Bir gece uyu, yarın tekrar bak.',
    '24 saat bekle, hala istiyorsan gel.',
    'Tereddüt ediyorsan muhtemelen gerekli değil.',
    'Zaman en iyi danışman.',
    'Acil değilse, acele etme.',
    'Emin değilsen, cevap muhtemelen hayır.',
  ];

  // ============================================
  // MESAJ SEÇME MANTIĞI
  // ============================================

  /// Süreye VE Tutara göre kategori belirle
  DurationCategory _getDurationCategory(double hours, double amount) {
    if (amount >= 100000) {
      return DurationCategory.simulation;
    }
    if (hours <= 8) {
      return DurationCategory.short;
    } else if (hours <= 7 * 8) {
      return DurationCategory.medium;
    } else {
      return DurationCategory.long;
    }
  }

  /// Kategoriye göre mesaj listesi getir
  List<String> _getMessagesForDuration(DurationCategory category) {
    return switch (category) {
      DurationCategory.short => _shortDurationMessages,
      DurationCategory.medium => _mediumDurationMessages,
      DurationCategory.long => _longDurationMessages,
      DurationCategory.simulation => _simulationDurationMessages,
    };
  }

  List<String> _getMessagesForDecision(DecisionType decision) {
    return switch (decision) {
      DecisionType.yes => _yesMessages,
      DecisionType.no => _noMessages,
      DecisionType.thinking => _thinkingMessages,
    };
  }

  String _selectRandomMessage(List<String> messages) {
    final availableMessages = messages
        .where((m) => !_recentMessages.contains(m))
        .toList();

    final sourceList = availableMessages.isEmpty ? messages : availableMessages;
    final message = sourceList[_random.nextInt(sourceList.length)];

    _recentMessages.add(message);
    if (_recentMessages.length > _maxRecentMessages) {
      _recentMessages.removeAt(0);
    }

    return message;
  }

  /// Hesaplama sonucu gösterilirken hem saate hem tutara bakarak mesaj döndür
  String getCalculationMessage(double hours, double amount) {
    final category = _getDurationCategory(hours, amount);
    final messages = _getMessagesForDuration(category);
    return _selectRandomMessage(messages);
  }

  String getMessageForDecision(DecisionType decision) {
    final messages = _getMessagesForDecision(decision);
    return _selectRandomMessage(messages);
  }

  void clearRecentMessages() {
    _recentMessages.clear();
  }
}