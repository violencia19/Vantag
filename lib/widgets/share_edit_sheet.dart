import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../theme/theme.dart';
import 'share_card_widget.dart';

/// Share card edit bottom sheet
class ShareEditSheet extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String categoryName;
  final int yearlyDays;
  final double yearlyAmount;
  final String frequency;
  final void Function(bool showAmount, bool showFrequency) onShare;

  const ShareEditSheet({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.categoryName,
    required this.yearlyDays,
    required this.yearlyAmount,
    required this.frequency,
    required this.onShare,
  });

  @override
  State<ShareEditSheet> createState() => _ShareEditSheetState();
}

class _ShareEditSheetState extends State<ShareEditSheet> {
  bool showAmount = false;
  bool showFrequency = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: context.appColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.appColors.cardBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.editYourCard,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.appColors.textPrimary,
              ),
            ),
          ),

          // Card preview (live updates)
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: ShareCardWidget(
                  icon: widget.icon,
                  iconColor: widget.iconColor,
                  categoryName: widget.categoryName,
                  yearlyDays: widget.yearlyDays,
                  yearlyAmount: showAmount ? widget.yearlyAmount : null,
                  frequency: showFrequency ? widget.frequency : null,
                ),
              ),
            ),
          ),

          // Toggle options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // Duration - always on, cannot be changed
                _buildToggleRow(
                  PhosphorIconsDuotone.timer,
                  l10n.shareCardDuration(widget.yearlyDays),
                  true,
                  null,
                  locked: true,
                ),

                // Amount
                _buildToggleRow(
                  PhosphorIconsDuotone.coins,
                  l10n.shareCardAmountLabel(
                    _formatCurrency(widget.yearlyAmount),
                  ),
                  showAmount,
                  (val) {
                    HapticFeedback.selectionClick();
                    setState(() => showAmount = val);
                  },
                ),

                // Frequency
                _buildToggleRow(
                  PhosphorIconsDuotone.calendarBlank,
                  l10n.shareCardFrequency(widget.frequency),
                  showFrequency,
                  (val) {
                    HapticFeedback.selectionClick();
                    setState(() => showFrequency = val);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Share button
          Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _handleShare,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(PhosphorIconsFill.shareFat, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      l10n.share,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(
    IconData icon,
    String label,
    bool value,
    void Function(bool)? onChanged, {
    bool locked = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: context.appColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: context.appColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: context.appColors.textPrimary, fontSize: 16),
              ),
            ),
            if (locked)
              const Icon(
                PhosphorIconsDuotone.lock,
                color: Color(0x60FFFFFF),
                size: 20,
              )
            else
              Switch(
                value: value,
                onChanged: onChanged,
                activeTrackColor: context.appColors.primary,
                inactiveThumbColor: Colors.white54,
                inactiveTrackColor: context.appColors.surfaceLight,
              ),
          ],
        ),
      ),
    );
  }

  void _handleShare() {
    HapticFeedback.mediumImpact();
    Navigator.pop(context);
    widget.onShare(showAmount, showFrequency);
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }
}
