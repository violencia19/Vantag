import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'merchant_learning_service.dart';

/// A parsed expense from import
class ParsedExpense {
  final DateTime date;
  final String rawDescription;
  final double amount;
  final MerchantMatch? match;
  String? selectedCategory;
  String? displayName;
  bool rememberMerchant;

  ParsedExpense({
    required this.date,
    required this.rawDescription,
    required this.amount,
    this.match,
    this.selectedCategory,
    this.displayName,
    this.rememberMerchant = true,
  });

  /// True if auto-matched with high confidence
  bool get isAutoMatched => match != null && match!.isAutoMatch;

  /// True if has a suggestion
  bool get hasSuggestion => match != null && match!.isSuggestion;

  /// True if pending review (no match or low confidence)
  bool get isPending => match == null || (!isAutoMatched && !hasSuggestion);

  /// Get the effective category (selected or from match)
  String? get effectiveCategory => selectedCategory ?? match?.category;

  /// Get the effective display name
  String? get effectiveDisplayName => displayName ?? match?.displayName;
}

/// Result of an import operation
class ImportResult {
  /// Expenses that were auto-matched (high confidence)
  final List<ParsedExpense> recognized;

  /// Expenses with suggestions (medium confidence)
  final List<ParsedExpense> suggestions;

  /// Expenses that need manual categorization
  final List<ParsedExpense> pending;

  /// Parsing errors
  final List<String> errors;

  ImportResult({
    required this.recognized,
    required this.suggestions,
    required this.pending,
    this.errors = const [],
  });

  /// Total expenses parsed
  int get totalCount => recognized.length + suggestions.length + pending.length;

  /// Count of items needing review
  int get needsReviewCount => suggestions.length + pending.length;

  /// True if all expenses were auto-matched
  bool get allRecognized => suggestions.isEmpty && pending.isEmpty;
}

/// Service for importing expenses from CSV/bank statements
class ImportService {
  final _merchantService = MerchantLearningService();

  /// Date formats to try when parsing
  static final List<DateFormat> _dateFormats = [
    DateFormat('dd/MM/yyyy'),
    DateFormat('dd.MM.yyyy'),
    DateFormat('yyyy-MM-dd'),
    DateFormat('MM/dd/yyyy'),
    DateFormat('dd-MM-yyyy'),
    DateFormat('d/M/yyyy'),
    DateFormat('d.M.yyyy'),
  ];

  /// Import expenses from a CSV file
  Future<ImportResult> importCSV(File file, String userId) async {
    // Ensure merchant cache is loaded
    await _merchantService.loadCache(userId);

    final List<ParsedExpense> recognized = [];
    final List<ParsedExpense> suggestions = [];
    final List<ParsedExpense> pending = [];
    final List<String> errors = [];

    try {
      // Read and parse CSV
      final csvString = await file.readAsString();
      final rows = const CsvToListConverter(
        eol: '\n',
        shouldParseNumbers: false,
      ).convert(csvString);

      if (rows.isEmpty) {
        errors.add('CSV file is empty');
        return ImportResult(
          recognized: recognized,
          suggestions: suggestions,
          pending: pending,
          errors: errors,
        );
      }

      // Detect column indices from header
      final header = rows.first.map((e) => e.toString().toLowerCase()).toList();
      final columnIndices = _detectColumns(header);

      if (columnIndices == null) {
        errors.add(
          'Could not detect required columns (date, description, amount)',
        );
        return ImportResult(
          recognized: recognized,
          suggestions: suggestions,
          pending: pending,
          errors: errors,
        );
      }

      // Parse data rows (skip header)
      for (var i = 1; i < rows.length; i++) {
        final row = rows[i];

        try {
          // Skip empty rows
          if (row.isEmpty ||
              row.every((cell) => cell.toString().trim().isEmpty)) {
            continue;
          }

          final date = _parseDate(row[columnIndices.dateIndex].toString());
          final description = row[columnIndices.descriptionIndex]
              .toString()
              .trim();
          final amount = _parseAmount(
            row[columnIndices.amountIndex].toString(),
          );

          if (date == null ||
              amount == null ||
              amount <= 0 ||
              description.isEmpty) {
            errors.add('Row ${i + 1}: Invalid data');
            continue;
          }

          // Find merchant match
          final match = await _merchantService.findMerchant(description);

          final expense = ParsedExpense(
            date: date,
            rawDescription: description,
            amount: amount,
            match: match,
          );

          // Categorize by match confidence
          if (match == null) {
            pending.add(expense);
          } else if (match.isAutoMatch) {
            recognized.add(expense);
          } else if (match.isSuggestion) {
            suggestions.add(expense);
          } else {
            pending.add(expense);
          }
        } catch (e) {
          errors.add('Row ${i + 1}: Parse error - $e');
        }
      }
    } catch (e) {
      errors.add('Failed to read file: $e');
    }

    return ImportResult(
      recognized: recognized,
      suggestions: suggestions,
      pending: pending,
      errors: errors,
    );
  }

  /// Detect column indices from header row
  _ColumnIndices? _detectColumns(List<String> header) {
    int? dateIndex;
    int? descriptionIndex;
    int? amountIndex;

    for (var i = 0; i < header.length; i++) {
      final col = header[i].trim();

      // Date column detection
      if (dateIndex == null &&
          (col.contains('tarih') ||
              col.contains('date') ||
              col.contains('islem tarihi') ||
              col == 'gun')) {
        dateIndex = i;
      }

      // Description column detection
      if (descriptionIndex == null &&
          (col.contains('aciklama') ||
              col.contains('description') ||
              col.contains('islem') ||
              col.contains('merchant') ||
              col.contains('detay'))) {
        descriptionIndex = i;
      }

      // Amount column detection
      if (amountIndex == null &&
          (col.contains('tutar') ||
              col.contains('amount') ||
              col.contains('miktar') ||
              col.contains('borc') ||
              col.contains('harcama'))) {
        amountIndex = i;
      }
    }

    // If not detected, use common positions
    dateIndex ??= 0;
    descriptionIndex ??= 1;
    amountIndex ??= 2;

    // Ensure all within bounds
    if (dateIndex >= header.length ||
        descriptionIndex >= header.length ||
        amountIndex >= header.length) {
      return null;
    }

    return _ColumnIndices(
      dateIndex: dateIndex,
      descriptionIndex: descriptionIndex,
      amountIndex: amountIndex,
    );
  }

  /// Parse date from various formats
  DateTime? _parseDate(String value) {
    final cleaned = value.trim();
    if (cleaned.isEmpty) return null;

    for (final format in _dateFormats) {
      try {
        return format.parseStrict(cleaned);
      } catch (_) {
        continue;
      }
    }

    // Try parsing as timestamp
    final timestamp = int.tryParse(cleaned);
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }

    return null;
  }

  /// Parse amount from string
  double? _parseAmount(String value) {
    // Clean the string
    String cleaned = value
        .trim()
        .replaceAll(RegExp(r'[^\d.,\-]'), '') // Remove non-numeric except . , -
        .replaceAll(' ', '');

    if (cleaned.isEmpty) return null;

    // Handle Turkish format (1.234,56) vs US format (1,234.56)
    if (cleaned.contains(',')) {
      // If both . and , exist, determine format
      if (cleaned.contains('.')) {
        // Check which is the decimal separator
        final lastComma = cleaned.lastIndexOf(',');
        final lastDot = cleaned.lastIndexOf('.');

        if (lastComma > lastDot) {
          // Turkish format: 1.234,56
          cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
        } else {
          // US format: 1,234.56
          cleaned = cleaned.replaceAll(',', '');
        }
      } else {
        // Only comma: assume decimal separator (Turkish)
        cleaned = cleaned.replaceAll(',', '.');
      }
    }

    final amount = double.tryParse(cleaned);

    // Return absolute value (expenses are positive)
    return amount?.abs();
  }

  /// Import from plain text (manual paste)
  Future<ImportResult> importText(String text, String userId) async {
    await _merchantService.loadCache(userId);

    final List<ParsedExpense> recognized = [];
    final List<ParsedExpense> suggestions = [];
    final List<ParsedExpense> pending = [];
    final List<String> errors = [];

    final lines = text.split('\n').where((l) => l.trim().isNotEmpty);

    for (final line in lines) {
      // Try to extract amount from line
      final amountMatch = RegExp(r'[\d.,]+').allMatches(line);
      if (amountMatch.isEmpty) continue;

      // Take the largest number as amount
      double? amount;
      for (final m in amountMatch) {
        final parsed = _parseAmount(m.group(0) ?? '');
        if (parsed != null && (amount == null || parsed > amount)) {
          amount = parsed;
        }
      }

      if (amount == null || amount <= 0) continue;

      // Remove amount from description
      final description = line.replaceAll(RegExp(r'[\d.,]+'), '').trim();
      if (description.isEmpty) continue;

      final match = await _merchantService.findMerchant(description);

      final expense = ParsedExpense(
        date: DateTime.now(),
        rawDescription: description,
        amount: amount,
        match: match,
      );

      if (match == null) {
        pending.add(expense);
      } else if (match.isAutoMatch) {
        recognized.add(expense);
      } else if (match.isSuggestion) {
        suggestions.add(expense);
      } else {
        pending.add(expense);
      }
    }

    return ImportResult(
      recognized: recognized,
      suggestions: suggestions,
      pending: pending,
      errors: errors,
    );
  }
}

class _ColumnIndices {
  final int dateIndex;
  final int descriptionIndex;
  final int amountIndex;

  _ColumnIndices({
    required this.dateIndex,
    required this.descriptionIndex,
    required this.amountIndex,
  });
}
