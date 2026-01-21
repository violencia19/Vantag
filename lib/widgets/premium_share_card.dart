import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../theme/theme.dart';
import '../models/models.dart';
import '../utils/currency_utils.dart';

/// Premium Share Card Format
enum ShareCardFormat {
  story,  // 1080x1920 (9:16) - Instagram/TikTok Story
  square, // 1080x1080 (1:1) - Instagram Post / Twitter
}

/// Premium Share Card Widget
/// Designed for maximum viral potential and app downloads
class PremiumShareCard extends StatefulWidget {
  final double amount;
  final double hoursRequired;
  final String category;
  final DateTime date;
  final String currencySymbol;
  final ShareCardFormat format;
  final ExpenseDecision? decision;

  const PremiumShareCard({
    super.key,
    required this.amount,
    required this.hoursRequired,
    required this.category,
    required this.date,
    this.currencySymbol = '₺',
    this.format = ShareCardFormat.story,
    this.decision,
  });

  @override
  State<PremiumShareCard> createState() => _PremiumShareCardState();
}

class _PremiumShareCardState extends State<PremiumShareCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.4, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Size get _cardSize {
    switch (widget.format) {
      case ShareCardFormat.story:
        return const Size(360, 640); // 9:16 ratio (scaled for preview)
      case ShareCardFormat.square:
        return const Size(360, 360); // 1:1 ratio
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = _cardSize;

    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background gradient
            _buildBackground(),

            // Noise texture overlay
            _buildNoiseOverlay(),

            // Ambient glow orb
            _buildGlowOrb(),

            // Main content
            _buildContent(l10n),

            // Vantag branding
            _buildBranding(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D0B14), // Deep purple-black
            Color(0xFF1A1625), // Mid purple
            Color(0xFF0F0D18), // Dark purple
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildNoiseOverlay() {
    return Opacity(
      opacity: 0.03,
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/noise.png'),
            repeat: ImageRepeat.repeat,
          ),
        ),
      ),
    );
  }

  Widget _buildGlowOrb() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Positioned(
          top: widget.format == ShareCardFormat.story ? 120 : 40,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: _glowAnimation.value * 0.4),
                    AppColors.primary.withValues(alpha: _glowAnimation.value * 0.2),
                    AppColors.primary.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(AppLocalizations l10n) {
    final isStory = widget.format == ShareCardFormat.story;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: isStory ? 60 : 32,
      ),
      child: Column(
        children: [
          if (isStory) const SizedBox(height: 40),

          // Category badge
          _buildCategoryBadge(),

          SizedBox(height: isStory ? 40 : 24),

          // Hero: Hours display
          _buildHeroSection(l10n),

          SizedBox(height: isStory ? 32 : 20),

          // Amount card
          _buildAmountCard(l10n),

          if (isStory) ...[
            const Spacer(),

            // CTA Section
            _buildCTASection(l10n),

            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryBadge() {
    final icon = ExpenseCategory.getIcon(widget.category);
    final color = ExpenseCategory.getColor(widget.category);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Text(
            widget.category,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatDate(widget.date),
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(AppLocalizations l10n) {
    final hours = widget.hoursRequired;
    final displayHours = hours < 1 ? hours * 60 : hours; // Convert to minutes if < 1 hour
    final isMinutes = hours < 1;
    final unit = isMinutes ? 'dk' : 'saat';

    return Column(
      children: [
        // Pre-text
        Text(
          'Bunu almak için',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.7),
            letterSpacing: 0.5,
          ),
        ),

        const SizedBox(height: 12),

        // Hero number with gradient
        ShaderMask(
          shaderCallback: (bounds) {
            return const LinearGradient(
              colors: [
                Color(0xFFFFFFFF),
                Color(0xFFE8E4FF),
                Color(0xFFB8B0FF),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(bounds);
          },
          child: Text(
            isMinutes
                ? displayHours.toStringAsFixed(0)
                : (hours >= 10 ? hours.toStringAsFixed(0) : hours.toStringAsFixed(1)),
            style: TextStyle(
              fontSize: widget.format == ShareCardFormat.story ? 96 : 72,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1,
              letterSpacing: -4,
            ),
          ),
        ),

        const SizedBox(height: 4),

        // Unit badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.3),
                AppColors.primary.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Text(
            unit.toUpperCase(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 3,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Post-text
        Text(
          'çalışman gerekiyor',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.7),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountCard(AppLocalizations l10n) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Amount
              Text(
                '${widget.currencySymbol}${formatTurkishCurrency(widget.amount, decimalDigits: 0)}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(width: 16),

              // Decision indicator (if any)
              if (widget.decision != null) _buildDecisionIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDecisionIndicator() {
    final decision = widget.decision!;
    final (icon, color, label) = switch (decision) {
      ExpenseDecision.yes => (PhosphorIconsFill.checkCircle, AppColors.error, 'Aldım'),
      ExpenseDecision.no => (PhosphorIconsFill.prohibit, AppColors.success, 'Vazgeçtim'),
      ExpenseDecision.thinking => (PhosphorIconsFill.clock, AppColors.warning, 'Düşünüyorum'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTASection(AppLocalizations l10n) {
    return Column(
      children: [
        // Divider with glow
        Container(
          width: 120,
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                AppColors.primary.withValues(alpha: 0.6),
                Colors.transparent,
              ],
            ),
            borderRadius: BorderRadius.circular(1),
          ),
        ),

        const SizedBox(height: 24),

        // CTA text
        Text(
          'Sen kaç saat çalışıyorsun?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),

        const SizedBox(height: 8),

        // Download prompt
        Text(
          'Öğrenmek için Vantag\'ı indir',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildBranding() {
    return Positioned(
      bottom: widget.format == ShareCardFormat.story ? 20 : 16,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Vantag logo placeholder (could be actual logo)
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Center(
              child: Text(
                'V',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'vantag.app',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.5),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
      'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}

/// Animated glow painter for extra premium effect
class GlowPainter extends CustomPainter {
  final double animationValue;
  final Color color;

  GlowPainter({required this.animationValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: animationValue * 0.5),
          color.withValues(alpha: animationValue * 0.2),
          color.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(GlowPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

/// Square format variant for social posts
class PremiumShareCardSquare extends StatelessWidget {
  final double amount;
  final double hoursRequired;
  final String category;
  final DateTime date;
  final String currencySymbol;
  final ExpenseDecision? decision;

  const PremiumShareCardSquare({
    super.key,
    required this.amount,
    required this.hoursRequired,
    required this.category,
    required this.date,
    this.currencySymbol = '₺',
    this.decision,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumShareCard(
      amount: amount,
      hoursRequired: hoursRequired,
      category: category,
      date: date,
      currencySymbol: currencySymbol,
      format: ShareCardFormat.square,
      decision: decision,
    );
  }
}

/// Helper function to show share card preview
void showShareCardPreview(
  BuildContext context, {
  required double amount,
  required double hoursRequired,
  required String category,
  required DateTime date,
  String currencySymbol = '₺',
  ExpenseDecision? decision,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.9),
    builder: (context) => _ShareCardPreviewSheet(
      amount: amount,
      hoursRequired: hoursRequired,
      category: category,
      date: date,
      currencySymbol: currencySymbol,
      decision: decision,
    ),
  );
}

class _ShareCardPreviewSheet extends StatefulWidget {
  final double amount;
  final double hoursRequired;
  final String category;
  final DateTime date;
  final String currencySymbol;
  final ExpenseDecision? decision;

  const _ShareCardPreviewSheet({
    required this.amount,
    required this.hoursRequired,
    required this.category,
    required this.date,
    required this.currencySymbol,
    this.decision,
  });

  @override
  State<_ShareCardPreviewSheet> createState() => _ShareCardPreviewSheetState();
}

class _ShareCardPreviewSheetState extends State<_ShareCardPreviewSheet> {
  ShareCardFormat _selectedFormat = ShareCardFormat.story;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.shareResult,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        PhosphorIconsRegular.x,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Format selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _FormatButton(
                      label: 'Story',
                      icon: PhosphorIconsRegular.deviceMobile,
                      isSelected: _selectedFormat == ShareCardFormat.story,
                      onTap: () => setState(() => _selectedFormat = ShareCardFormat.story),
                    ),
                    const SizedBox(width: 12),
                    _FormatButton(
                      label: 'Post',
                      icon: PhosphorIconsRegular.squareLogo,
                      isSelected: _selectedFormat == ShareCardFormat.square,
                      onTap: () => setState(() => _selectedFormat = ShareCardFormat.square),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Card preview
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: PremiumShareCard(
                      amount: widget.amount,
                      hoursRequired: widget.hoursRequired,
                      category: widget.category,
                      date: widget.date,
                      currencySymbol: widget.currencySymbol,
                      format: _selectedFormat,
                      decision: widget.decision,
                    ),
                  ),
                ),
              ),

              // Share buttons
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: _ShareButton(
                        label: 'Instagram',
                        icon: PhosphorIconsFill.instagramLogo,
                        color: const Color(0xFFE4405F),
                        onTap: () {
                          // TODO: Implement Instagram share
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ShareButton(
                        label: 'Twitter',
                        icon: PhosphorIconsFill.xLogo,
                        color: Colors.white,
                        onTap: () {
                          // TODO: Implement Twitter share
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ShareButton(
                        label: l10n.save,
                        icon: PhosphorIconsFill.downloadSimple,
                        color: AppColors.primary,
                        onTap: () {
                          // TODO: Save to gallery
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FormatButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FormatButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ShareButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
