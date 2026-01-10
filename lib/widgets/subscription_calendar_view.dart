import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../models/models.dart';
import '../theme/theme.dart';

/// Abonelik takvim görünümü
/// Her ayın hangi gününde hangi aboneliklerin yenilendiğini gösterir
class SubscriptionCalendarView extends StatefulWidget {
  final List<Subscription> subscriptions;
  final Function(int day, List<Subscription> subscriptions) onDayTap;

  const SubscriptionCalendarView({
    super.key,
    required this.subscriptions,
    required this.onDayTap,
  });

  @override
  State<SubscriptionCalendarView> createState() => _SubscriptionCalendarViewState();
}

class _SubscriptionCalendarViewState extends State<SubscriptionCalendarView> {
  late DateTime _currentMonth;
  late Map<int, List<Subscription>> _subscriptionsByDay;

  List<String> _getWeekDays(AppLocalizations l10n) => [
    l10n.weekdayMon, l10n.weekdayTue, l10n.weekdayWed, l10n.weekdayThu,
    l10n.weekdayFri, l10n.weekdaySat, l10n.weekdaySun
  ];

  List<String> _getMonthNames(AppLocalizations l10n) => [
    '', l10n.monthJan, l10n.monthFeb, l10n.monthMar, l10n.monthApr,
    l10n.monthMay, l10n.monthJun, l10n.monthJul, l10n.monthAug,
    l10n.monthSep, l10n.monthOct, l10n.monthNov, l10n.monthDec
  ];

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
    _updateSubscriptionsByDay();
  }

  @override
  void didUpdateWidget(SubscriptionCalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.subscriptions != widget.subscriptions) {
      _updateSubscriptionsByDay();
    }
  }

  void _updateSubscriptionsByDay() {
    _subscriptionsByDay = {};
    for (final sub in widget.subscriptions) {
      final renewalDay = sub.getRenewalDayForMonth(
        _currentMonth.year,
        _currentMonth.month,
      );
      _subscriptionsByDay.putIfAbsent(renewalDay, () => []).add(sub);
    }
  }

  void _previousMonth() {
    HapticFeedback.selectionClick();
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
      _updateSubscriptionsByDay();
    });
  }

  void _nextMonth() {
    HapticFeedback.selectionClick();
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
      _updateSubscriptionsByDay();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstDayOfWeek = _currentMonth.weekday; // 1 = Monday
    final weekDays = _getWeekDays(l10n);
    final monthNames = _getMonthNames(l10n);

    return Column(
      children: [
        // Month header and navigation
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _previousMonth,
                icon: const Icon(PhosphorIconsDuotone.caretLeft),
                color: AppColors.textSecondary,
              ),
              Text(
                '${monthNames[_currentMonth.month]} ${_currentMonth.year}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                onPressed: _nextMonth,
                icon: const Icon(PhosphorIconsDuotone.caretRight),
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Weekday headers
        Row(
          children: weekDays.map((day) => Expanded(
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          )).toList(),
        ),
        const SizedBox(height: 12),

        // Calendar grid
        _buildCalendarGrid(daysInMonth, firstDayOfWeek),
      ],
    );
  }

  Widget _buildCalendarGrid(int daysInMonth, int firstDayOfWeek) {
    final now = DateTime.now();
    final isCurrentMonth = _currentMonth.year == now.year && _currentMonth.month == now.month;

    // Toplam hücre sayısı: önceki aydan boşluklar + bu ayın günleri
    final totalCells = firstDayOfWeek - 1 + daysInMonth;
    final rowCount = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rowCount, (rowIndex) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: List.generate(7, (colIndex) {
              final cellIndex = rowIndex * 7 + colIndex;
              final dayNumber = cellIndex - (firstDayOfWeek - 2);

              // Önceki aydan veya sonraki aydan boşluk
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const Expanded(child: SizedBox(height: 56));
              }

              final isToday = isCurrentMonth && dayNumber == now.day;
              final subs = _subscriptionsByDay[dayNumber] ?? [];

              return Expanded(
                child: _buildDayCell(dayNumber, isToday, subs),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildDayCell(int day, bool isToday, List<Subscription> subs) {
    final hasSubscriptions = subs.isNotEmpty;

    return GestureDetector(
      onTap: hasSubscriptions ? () {
        HapticFeedback.lightImpact();
        widget.onDayTap(day, subs);
      } : null,
      child: Container(
        height: 56,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isToday
              ? AppColors.primary.withValues(alpha: 0.2)
              : hasSubscriptions
                  ? AppColors.surface.withValues(alpha: 0.5)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isToday
              ? Border.all(color: AppColors.primary, width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gün numarası
            Text(
              '$day',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isToday || hasSubscriptions ? FontWeight.w600 : FontWeight.w400,
                color: isToday
                    ? AppColors.primary
                    : hasSubscriptions
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
              ),
            ),
            if (hasSubscriptions) ...[
              const SizedBox(height: 4),
              // Abonelik renk noktaları
              _buildSubscriptionDots(subs),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionDots(List<Subscription> subs) {
    // Maksimum 3 nokta göster
    final displaySubs = subs.take(3).toList();
    final hasMore = subs.length > 3;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...displaySubs.map((sub) => Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: sub.color,
            shape: BoxShape.circle,
          ),
        )),
        if (hasMore)
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: AppColors.textTertiary,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '+',
                style: TextStyle(
                  fontSize: 6,
                  color: Colors.white,
                  height: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
