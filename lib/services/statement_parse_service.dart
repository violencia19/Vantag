import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:csv/csv.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

/// A single parsed transaction from bank statement
class ParsedTransaction {
  final DateTime date;
  final String description;
  final double amount;
  final String category;
  final String? merchant;
  final bool isExpense; // true = expense, false = income

  ParsedTransaction({
    required this.date,
    required this.description,
    required this.amount,
    required this.category,
    this.merchant,
    this.isExpense = true,
  });

  factory ParsedTransaction.fromJson(Map<String, dynamic> json) {
    return ParsedTransaction(
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      description: json['description'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      category: _mapCategory(json['category']),
      merchant: json['merchant'],
      isExpense: json['isExpense'] ?? true,
    );
  }

  static String _mapCategory(String? category) {
    const mapping = {
      'food': 'Yiyecek',
      'transport': 'Ulaşım',
      'entertainment': 'Eğlence',
      'shopping': 'Alışveriş',
      'health': 'Sağlık',
      'bills': 'Faturalar',
      'education': 'Eğitim',
      'subscription': 'Abonelik',
      'other': 'Diğer',
    };
    return mapping[category?.toLowerCase()] ?? 'Diğer';
  }
}

/// Result of parsing a bank statement
class StatementParseResult {
  final List<ParsedTransaction> transactions;
  final int totalFound;
  final int successfullyParsed;
  final String? error;
  final String? bankName;

  StatementParseResult({
    required this.transactions,
    required this.totalFound,
    required this.successfullyParsed,
    this.error,
    this.bankName,
  });

  bool get hasError => error != null;
  bool get isEmpty => transactions.isEmpty;
}

/// Service for parsing bank statements (PDF/CSV) using AI
class StatementParseService {
  static final StatementParseService _instance = StatementParseService._();
  factory StatementParseService() => _instance;
  StatementParseService._();

  /// Parse a bank statement file (PDF or CSV)
  Future<StatementParseResult> parseFile(File file) async {
    final extension = file.path.toLowerCase().split('.').last;

    String rawText;

    try {
      if (extension == 'pdf') {
        rawText = await _extractTextFromPDF(file);
      } else if (extension == 'csv') {
        rawText = await _extractTextFromCSV(file);
      } else {
        return StatementParseResult(
          transactions: [],
          totalFound: 0,
          successfullyParsed: 0,
          error: 'Desteklenmeyen dosya formatı: $extension',
        );
      }

      if (rawText.trim().isEmpty) {
        return StatementParseResult(
          transactions: [],
          totalFound: 0,
          successfullyParsed: 0,
          error: 'Dosyadan metin çıkarılamadı',
        );
      }

      // Parse with AI
      return await _parseWithAI(rawText);
    } catch (e) {
      debugPrint('[StatementParse] Error: $e');
      return StatementParseResult(
        transactions: [],
        totalFound: 0,
        successfullyParsed: 0,
        error: 'Dosya işlenirken hata: $e',
      );
    }
  }

  /// Extract text from PDF using Syncfusion
  Future<String> _extractTextFromPDF(File file) async {
    final bytes = await file.readAsBytes();
    final document = PdfDocument(inputBytes: bytes);

    final StringBuffer textBuffer = StringBuffer();

    // Extract text from all pages
    for (int i = 0; i < document.pages.count; i++) {
      final text = PdfTextExtractor(
        document,
      ).extractText(startPageIndex: i, endPageIndex: i);
      textBuffer.writeln(text);
    }

    document.dispose();

    return textBuffer.toString();
  }

  /// Extract text from CSV
  Future<String> _extractTextFromCSV(File file) async {
    final csvString = await file.readAsString();
    final rows = const CsvToListConverter(
      eol: '\n',
      shouldParseNumbers: false,
    ).convert(csvString);

    // Convert CSV to readable text format for AI
    final buffer = StringBuffer();
    for (final row in rows) {
      buffer.writeln(row.join(' | '));
    }

    return buffer.toString();
  }

  /// Parse extracted text using GPT-4o-mini
  Future<StatementParseResult> _parseWithAI(String rawText) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      return StatementParseResult(
        transactions: [],
        totalFound: 0,
        successfullyParsed: 0,
        error: 'OpenAI API key not configured',
      );
    }

    // Truncate text if too long (GPT-4o-mini context limit)
    String textToSend = rawText;
    if (rawText.length > 15000) {
      textToSend = rawText.substring(0, 15000);
    }

    final prompt =
        '''You are a bank statement parser. Extract ALL expense transactions from this bank statement text.

BANK STATEMENT TEXT:
"""
$textToSend
"""

INSTRUCTIONS:
1. Find all expense/debit transactions (money going OUT)
2. Skip income/credit transactions (money coming IN)
3. Extract: date, description, amount, category, merchant name if identifiable
4. Use these categories: food, transport, entertainment, shopping, health, bills, education, subscription, other
5. For Turkish banks: amounts might use comma as decimal separator (1.234,56 = 1234.56)
6. Detect the bank name if possible

Return ONLY valid JSON array:
{
  "bank": "Bank name or null",
  "transactions": [
    {
      "date": "2024-01-15",
      "description": "MIGROS MARKET",
      "amount": 150.50,
      "category": "shopping",
      "merchant": "Migros",
      "isExpense": true
    }
  ]
}

If no transactions found, return: {"bank": null, "transactions": []}''';

    try {
      final response = await http
          .post(
            Uri.parse('https://api.openai.com/v1/chat/completions'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: jsonEncode({
              'model': 'gpt-4o-mini',
              'messages': [
                {'role': 'user', 'content': prompt},
              ],
              'temperature': 0,
              'max_tokens': 4000,
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode != 200) {
        debugPrint('[StatementParse] API error: ${response.statusCode}');
        debugPrint('[StatementParse] Body: ${response.body}');
        return StatementParseResult(
          transactions: [],
          totalFound: 0,
          successfullyParsed: 0,
          error: 'AI API hatası: ${response.statusCode}',
        );
      }

      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'] as String;

      // Extract JSON from response (handle markdown code blocks)
      String jsonStr = content.trim();
      if (jsonStr.contains('```')) {
        final jsonMatch = RegExp(
          r'```(?:json)?\s*([\s\S]*?)```',
        ).firstMatch(jsonStr);
        if (jsonMatch != null) {
          jsonStr = jsonMatch.group(1)!.trim();
        }
      }

      final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;
      final transactionsJson = parsed['transactions'] as List<dynamic>? ?? [];
      final bankName = parsed['bank'] as String?;

      final transactions = <ParsedTransaction>[];
      for (final t in transactionsJson) {
        try {
          transactions.add(
            ParsedTransaction.fromJson(t as Map<String, dynamic>),
          );
        } catch (e) {
          debugPrint('[StatementParse] Failed to parse transaction: $e');
        }
      }

      return StatementParseResult(
        transactions: transactions,
        totalFound: transactionsJson.length,
        successfullyParsed: transactions.length,
        bankName: bankName,
      );
    } catch (e) {
      debugPrint('[StatementParse] AI parse error: $e');
      return StatementParseResult(
        transactions: [],
        totalFound: 0,
        successfullyParsed: 0,
        error: 'AI parse hatası: $e',
      );
    }
  }

  /// Parse plain text (for manual paste)
  Future<StatementParseResult> parseText(String text) async {
    if (text.trim().isEmpty) {
      return StatementParseResult(
        transactions: [],
        totalFound: 0,
        successfullyParsed: 0,
        error: 'Metin boş',
      );
    }

    return await _parseWithAI(text);
  }
}
