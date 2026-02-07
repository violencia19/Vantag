/// AI kişilik modu - hitap tarzını belirler
/// Task 63: AI Personality Modes
enum PersonalityMode {
  /// Resmi hitap - "Siz" kullanımı, profesyonel ton
  professional,

  /// Samimi hitap - "Sen" kullanımı, arkadaşça ton
  friendly,

  /// Koç modu - Motive edici, hedef odaklı
  coach,

  /// Sert modu - Doğrudan, dürtüsel harcamalara karşı sert uyarılar
  strict,

  /// Mizahi mod - Espirili, hafif ton
  humorous,
}

extension PersonalityModeExtension on PersonalityMode {
  String get displayName {
    switch (this) {
      case PersonalityMode.professional:
        return 'Profesyonel';
      case PersonalityMode.friendly:
        return 'Arkadaşça';
      case PersonalityMode.coach:
        return 'Koç';
      case PersonalityMode.strict:
        return 'Sert';
      case PersonalityMode.humorous:
        return 'Mizahi';
    }
  }

  String get displayNameEn {
    switch (this) {
      case PersonalityMode.professional:
        return 'Professional';
      case PersonalityMode.friendly:
        return 'Friendly';
      case PersonalityMode.coach:
        return 'Coach';
      case PersonalityMode.strict:
        return 'Strict';
      case PersonalityMode.humorous:
        return 'Humorous';
    }
  }

  String get description {
    switch (this) {
      case PersonalityMode.professional:
        return 'Resmi ve profesyonel ton';
      case PersonalityMode.friendly:
        return 'Samimi ve arkadaşça yaklaşım';
      case PersonalityMode.coach:
        return 'Motive edici ve hedef odaklı';
      case PersonalityMode.strict:
        return 'Dürtüsel harcamalara karşı sert';
      case PersonalityMode.humorous:
        return 'Espirili ve eğlenceli';
    }
  }

  String get emoji {
    switch (this) {
      case PersonalityMode.professional:
        return '👔';
      case PersonalityMode.friendly:
        return '😊';
      case PersonalityMode.coach:
        return '💪';
      case PersonalityMode.strict:
        return '🚨';
      case PersonalityMode.humorous:
        return '😄';
    }
  }

  /// System prompt modifier for this personality
  String get systemPromptModifier {
    switch (this) {
      case PersonalityMode.professional:
        return '''
Resmi bir ton kullan. Kullanıcıya "siz" diye hitap et.
Profesyonel ve saygılı ol. Gereksiz espri yapma.
''';
      case PersonalityMode.friendly:
        return '''
Samimi bir ton kullan. Kullanıcıya "sen" diye hitap et.
Arkadaş gibi konuş ama saygıyı koru.
''';
      case PersonalityMode.coach:
        return '''
Motive edici bir ton kullan. Kullanıcıyı cesaretlendir.
Hedeflerine odaklan. "Yapabilirsin!" gibi ifadeler kullan.
Başarıları kutla, zorlukları fırsata çevir.
''';
      case PersonalityMode.strict:
        return '''
Doğrudan ve sert ol. Gereksiz harcamaları eleştir.
"Bu gerçekten gerekli mi?" gibi sorular sor.
Dürtüsel harcamaları engellemek için uyar.
''';
      case PersonalityMode.humorous:
        return '''
Espirili ve eğlenceli ol. Uygun yerlerde hafif şakalar yap.
Ama ciddi konularda dengeli kal. Para konusunu
eğlenceli hale getir ama önemini küçümseme.
''';
    }
  }
}
