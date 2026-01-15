/// Confidence level of voice parsing result
enum VoiceConfidence {
  /// High confidence - can auto-save
  high,

  /// Medium confidence - show with edit option
  medium,

  /// Low confidence - require user confirmation
  low,
}

/// Source of the parsing result
enum VoiceParseSource {
  /// Parsed using regex patterns (fast, free)
  regex,

  /// Parsed using GPT-4o (smart, API cost)
  gpt,

  /// Direct input (not from voice)
  direct,
}

/// Result of voice input parsing
class VoiceParseResult {
  /// Parsed amount (null if not detected)
  final double? amount;

  /// Detected category
  final String? category;

  /// Description/note for the expense
  final String description;

  /// Confidence level of the parsing
  final VoiceConfidence confidence;

  /// Source of parsing (regex or GPT)
  final VoiceParseSource source;

  /// Original voice text
  final String originalText;

  /// Suggested display name (for merchant learning)
  final String? merchantName;

  /// Date for the expense (null = today)
  final DateTime? date;

  const VoiceParseResult({
    this.amount,
    this.category,
    required this.description,
    required this.confidence,
    required this.source,
    required this.originalText,
    this.merchantName,
    this.date,
  });

  /// True if result has enough data to create an expense
  bool get isValid => amount != null && amount! > 0;

  /// True if can be auto-saved without confirmation
  bool get canAutoSave => isValid && confidence == VoiceConfidence.high;

  /// True if needs user confirmation before saving
  bool get needsConfirmation => !isValid || confidence == VoiceConfidence.low;

  /// Create from GPT JSON response
  factory VoiceParseResult.fromGptJson(
    Map<String, dynamic> json,
    String originalText,
  ) {
    final confidenceStr = json['confidence'] as String? ?? 'low';
    final confidence = switch (confidenceStr.toLowerCase()) {
      'high' => VoiceConfidence.high,
      'medium' => VoiceConfidence.medium,
      _ => VoiceConfidence.low,
    };

    return VoiceParseResult(
      amount: (json['amount'] as num?)?.toDouble(),
      category: json['category'] as String?,
      description: json['description'] as String? ?? originalText,
      confidence: confidence,
      source: VoiceParseSource.gpt,
      originalText: originalText,
      merchantName: json['merchant'] as String?,
    );
  }

  /// Create from regex parsing
  factory VoiceParseResult.fromRegex({
    required double? amount,
    required String? category,
    required String description,
    required String originalText,
    String? merchantName,
  }) {
    // Determine confidence based on what was detected
    VoiceConfidence confidence;
    if (amount != null && category != null) {
      confidence = VoiceConfidence.high;
    } else if (amount != null) {
      confidence = VoiceConfidence.medium;
    } else {
      confidence = VoiceConfidence.low;
    }

    return VoiceParseResult(
      amount: amount,
      category: category,
      description: description,
      confidence: confidence,
      source: VoiceParseSource.regex,
      originalText: originalText,
      merchantName: merchantName,
    );
  }

  /// Create a failed parse result
  factory VoiceParseResult.failed(String originalText) {
    return VoiceParseResult(
      description: originalText,
      confidence: VoiceConfidence.low,
      source: VoiceParseSource.regex,
      originalText: originalText,
    );
  }

  /// Copy with modifications
  VoiceParseResult copyWith({
    double? amount,
    String? category,
    String? description,
    VoiceConfidence? confidence,
    VoiceParseSource? source,
    String? originalText,
    String? merchantName,
    DateTime? date,
  }) {
    return VoiceParseResult(
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      confidence: confidence ?? this.confidence,
      source: source ?? this.source,
      originalText: originalText ?? this.originalText,
      merchantName: merchantName ?? this.merchantName,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'category': category,
      'description': description,
      'confidence': confidence.name,
      'source': source.name,
      'originalText': originalText,
      'merchantName': merchantName,
      'date': date?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'VoiceParseResult(amount: $amount, category: $category, '
        'description: $description, confidence: $confidence, source: $source)';
  }
}
