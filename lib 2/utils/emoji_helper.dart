// Smart emoji helper for pursuits/dreams
// Returns context-aware emojis based on pursuit name keywords

/// Get a smart default emoji based on the pursuit name
/// This provides more specific emojis than category-based defaults
String getDefaultPursuitEmoji(String pursuitName) {
  final name = pursuitName.toLowerCase().trim();

  // Tech devices
  if (name.contains('iphone') ||
      name.contains('telefon') ||
      name.contains('phone') ||
      name.contains('samsung') ||
      name.contains('pixel')) {
    return '📱';
  }

  if (name.contains('macbook') ||
      name.contains('laptop') ||
      name.contains('bilgisayar') ||
      name.contains('computer') ||
      name.contains('notebook') ||
      name.contains('pc')) {
    return '💻';
  }

  if (name.contains('airpods') ||
      name.contains('kulaklık') ||
      name.contains('headphone') ||
      name.contains('earbuds') ||
      name.contains('earphone')) {
    return '🎧';
  }

  if (name.contains('saat') ||
      name.contains('watch') ||
      name.contains('apple watch') ||
      name.contains('smartwatch')) {
    return '⌚';
  }

  if (name.contains('playstation') ||
      name.contains('ps5') ||
      name.contains('ps4') ||
      name.contains('xbox') ||
      name.contains('gaming') ||
      name.contains('nintendo') ||
      name.contains('switch') ||
      name.contains('konsol')) {
    return '🎮';
  }

  if (name.contains('ipad') || name.contains('tablet')) {
    return '📱';
  }

  if (name.contains('kamera') ||
      name.contains('camera') ||
      name.contains('gopro') ||
      name.contains('fotoğraf')) {
    return '📷';
  }

  if (name.contains('tv') ||
      name.contains('televizyon') ||
      name.contains('television')) {
    return '📺';
  }

  // Vehicles
  if (name.contains('araba') ||
      name.contains('car') ||
      name.contains('tesla') ||
      name.contains('bmw') ||
      name.contains('mercedes') ||
      name.contains('audi') ||
      name.contains('otomobil')) {
    return '🚗';
  }

  if (name.contains('motorsiklet') ||
      name.contains('motorcycle') ||
      name.contains('motor') ||
      name.contains('scooter') ||
      name.contains('vespa')) {
    return '🏍️';
  }

  if (name.contains('bisiklet') ||
      name.contains('bike') ||
      name.contains('bicycle')) {
    return '🚴';
  }

  // Home
  if (name.contains('ev') ||
      name.contains('house') ||
      name.contains('home') ||
      name.contains('apartment') ||
      name.contains('daire') ||
      name.contains('konut')) {
    return '🏠';
  }

  if (name.contains('mobilya') ||
      name.contains('furniture') ||
      name.contains('koltuk') ||
      name.contains('sofa') ||
      name.contains('kanepe') ||
      name.contains('yatak') ||
      name.contains('bed')) {
    return '🛋️';
  }

  // Travel
  if (name.contains('tatil') ||
      name.contains('vacation') ||
      name.contains('holiday') ||
      name.contains('travel') ||
      name.contains('seyahat') ||
      name.contains('gezi') ||
      name.contains('trip')) {
    return '✈️';
  }

  if (name.contains('otel') ||
      name.contains('hotel') ||
      name.contains('resort')) {
    return '🏨';
  }

  // Education
  if (name.contains('kurs') ||
      name.contains('course') ||
      name.contains('education') ||
      name.contains('eğitim') ||
      name.contains('bootcamp') ||
      name.contains('sertifika') ||
      name.contains('certificate')) {
    return '🎓';
  }

  if (name.contains('kitap') ||
      name.contains('book') ||
      name.contains('kindle') ||
      name.contains('e-reader')) {
    return '📚';
  }

  // Health & Fitness
  if (name.contains('spor') ||
      name.contains('gym') ||
      name.contains('fitness') ||
      name.contains('workout') ||
      name.contains('egzersiz')) {
    return '💪';
  }

  if (name.contains('koşu') ||
      name.contains('running') ||
      name.contains('maraton') ||
      name.contains('marathon')) {
    return '🏃';
  }

  // Life events
  if (name.contains('düğün') ||
      name.contains('wedding') ||
      name.contains('evlilik') ||
      name.contains('nişan') ||
      name.contains('engagement')) {
    return '💒';
  }

  if (name.contains('bebek') ||
      name.contains('baby') ||
      name.contains('çocuk') ||
      name.contains('child')) {
    return '👶';
  }

  // Fashion
  if (name.contains('çanta') ||
      name.contains('bag') ||
      name.contains('purse') ||
      name.contains('handbag')) {
    return '👜';
  }

  if (name.contains('ayakkabı') ||
      name.contains('shoe') ||
      name.contains('sneaker') ||
      name.contains('bot') ||
      name.contains('boot')) {
    return '👟';
  }

  if (name.contains('gözlük') ||
      name.contains('glasses') ||
      name.contains('sunglasses') ||
      name.contains('güneş gözlüğü')) {
    return '🕶️';
  }

  // Other
  if (name.contains('hediye') ||
      name.contains('gift') ||
      name.contains('present')) {
    return '🎁';
  }

  if (name.contains('yatırım') ||
      name.contains('investment') ||
      name.contains('hisse') ||
      name.contains('stock') ||
      name.contains('kripto') ||
      name.contains('crypto')) {
    return '📈';
  }

  if (name.contains('acil') ||
      name.contains('emergency') ||
      name.contains('güvence') ||
      name.contains('fon') ||
      name.contains('fund')) {
    return '🏦';
  }

  // Default - target/goal emoji
  return '🎯';
}

/// Check if name matches any known keyword pattern
bool hasSmartEmoji(String pursuitName) {
  final emoji = getDefaultPursuitEmoji(pursuitName);
  return emoji != '🎯'; // Returns true if we found a specific match
}
