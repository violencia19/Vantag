import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vantag/l10n/app_localizations.dart';

enum DurationCategory {
  short, // 1-8 hours
  medium, // 1-7 days
  long, // 7+ days
  simulation, // 100.000 TL+ (Special category)
}

enum DecisionType {
  yes, // Bought
  no, // Passed
  thinking, // Thinking
}

class MessagesService {
  final _random = Random();
  final List<int> _recentMessageIndices = [];
  static const _maxRecentMessages = 5;

  // ============================================
  // MESSAGE SELECTION LOGIC
  // ============================================

  /// Determine category based on duration AND amount
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

  /// Get messages list for duration category
  List<String> _getMessagesForDuration(
    BuildContext context,
    DurationCategory category,
  ) {
    final l10n = AppLocalizations.of(context);
    return switch (category) {
      DurationCategory.short => [
        l10n.msgShort1,
        l10n.msgShort2,
        l10n.msgShort3,
        l10n.msgShort4,
        l10n.msgShort5,
        l10n.msgShort6,
        l10n.msgShort7,
        l10n.msgShort8,
      ],
      DurationCategory.medium => [
        l10n.msgMedium1,
        l10n.msgMedium2,
        l10n.msgMedium3,
        l10n.msgMedium4,
        l10n.msgMedium5,
        l10n.msgMedium6,
        l10n.msgMedium7,
        l10n.msgMedium8,
      ],
      DurationCategory.long => [
        l10n.msgLong1,
        l10n.msgLong2,
        l10n.msgLong3,
        l10n.msgLong4,
        l10n.msgLong5,
        l10n.msgLong6,
        l10n.msgLong7,
        l10n.msgLong8,
      ],
      DurationCategory.simulation => [
        l10n.msgSim1,
        l10n.msgSim2,
        l10n.msgSim3,
        l10n.msgSim4,
        l10n.msgSim5,
        l10n.msgSim6,
        l10n.msgSim7,
        l10n.msgSim8,
      ],
    };
  }

  List<String> _getMessagesForDecision(
    BuildContext context,
    DecisionType decision,
  ) {
    final l10n = AppLocalizations.of(context);
    return switch (decision) {
      DecisionType.yes => [
        l10n.msgYes1,
        l10n.msgYes2,
        l10n.msgYes3,
        l10n.msgYes4,
        l10n.msgYes5,
        l10n.msgYes6,
        l10n.msgYes7,
        l10n.msgYes8,
      ],
      DecisionType.no => [
        l10n.msgNo1,
        l10n.msgNo2,
        l10n.msgNo3,
        l10n.msgNo4,
        l10n.msgNo5,
        l10n.msgNo6,
        l10n.msgNo7,
        l10n.msgNo8,
      ],
      DecisionType.thinking => [
        l10n.msgThink1,
        l10n.msgThink2,
        l10n.msgThink3,
        l10n.msgThink4,
        l10n.msgThink5,
        l10n.msgThink6,
        l10n.msgThink7,
        l10n.msgThink8,
      ],
    };
  }

  String _selectRandomMessage(List<String> messages) {
    // Create available indices (0-7) excluding recent ones
    final availableIndices = List.generate(
      messages.length,
      (i) => i,
    ).where((i) => !_recentMessageIndices.contains(i)).toList();

    final sourceIndices = availableIndices.isEmpty
        ? List.generate(messages.length, (i) => i)
        : availableIndices;

    final selectedIndex = sourceIndices[_random.nextInt(sourceIndices.length)];

    _recentMessageIndices.add(selectedIndex);
    if (_recentMessageIndices.length > _maxRecentMessages) {
      _recentMessageIndices.removeAt(0);
    }

    return messages[selectedIndex];
  }

  /// Return message based on hours and amount when showing calculation result
  String getCalculationMessage(
    BuildContext context,
    double hours,
    double amount,
  ) {
    final category = _getDurationCategory(hours, amount);
    final messages = _getMessagesForDuration(context, category);
    return _selectRandomMessage(messages);
  }

  String getMessageForDecision(BuildContext context, DecisionType decision) {
    final messages = _getMessagesForDecision(context, decision);
    return _selectRandomMessage(messages);
  }

  void clearRecentMessages() {
    _recentMessageIndices.clear();
  }
}
