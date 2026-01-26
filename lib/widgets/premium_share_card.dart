import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../theme/theme.dart';
import '../models/models.dart';
import '../utils/currency_utils.dart';
import '../services/referral_service.dart';
import '../services/deep_link_service.dart';
import '../services/haptic_service.dart';

/// Premium Share Card Format
enum ShareCardFormat {
  story, // 1080x1920 (9:16) - Instagram/TikTok Story
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

  /// Whether to show a watermark (for free users)
  final bool showWatermark;

  const PremiumShareCard({
    super.key,
    required this.amount,
    required this.hoursRequired,
    required this.category,
    required this.date,
    this.currencySymbol = '₺',
    this.format = ShareCardFormat.story,
    this.decision,
    this.showWatermark = false,
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
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
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

            // Watermark for free users
            if (widget.showWatermark) _buildWatermark(),
          ],
        ),
      ),
    );
  }

  Widget _buildWatermark() {
    return Positioned(
      bottom: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              PhosphorIconsDuotone.sparkle,
              size: 14,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 6),
            Text(
              'vantag.app',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.background, // Deep purple-black
            AppColors.cardBackground, // Mid purple
            AppColors.background.withValues(alpha: 0.95), // Dark purple
          ],
          stops: const [0.0, 0.5, 1.0],
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
                    context.appColors.primary.withValues(
                      alpha: _glowAnimation.value * 0.4,
                    ),
                    context.appColors.primary.withValues(
                      alpha: _glowAnimation.value * 0.2,
                    ),
                    context.appColors.primary.withValues(alpha: 0.0),
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
    final displayHours = hours < 1
        ? hours * 60
        : hours; // Convert to minutes if < 1 hour
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
              colors: [Color(0xFFFFFFFF), Color(0xFFE8E4FF), Color(0xFFB8B0FF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(bounds);
          },
          child: Text(
            isMinutes
                ? displayHours.toStringAsFixed(0)
                : (hours >= 10
                      ? hours.toStringAsFixed(0)
                      : hours.toStringAsFixed(1)),
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
                context.appColors.primary.withValues(alpha: 0.3),
                context.appColors.primary.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: context.appColors.primary.withValues(alpha: 0.4),
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
      ExpenseDecision.yes => (
        PhosphorIconsFill.checkCircle,
        context.appColors.error,
        'Aldım',
      ),
      ExpenseDecision.no => (
        PhosphorIconsFill.prohibit,
        context.appColors.success,
        'Vazgeçtim',
      ),
      ExpenseDecision.thinking => (
        PhosphorIconsFill.clock,
        context.appColors.warning,
        'Düşünüyorum',
      ),
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
                context.appColors.primary.withValues(alpha: 0.6),
                Colors.transparent,
              ],
            ),
            borderRadius: BorderRadius.circular(1),
          ),
        ),

        const SizedBox(height: 20),

        // CTA text
        Text(
          'Sen kaç saat çalışıyorsun?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),

        // Bottom spacing to prevent overlap with branding
        const SizedBox(height: 48),
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
              gradient: LinearGradient(
                colors: [
                  context.appColors.primary,
                  context.appColors.primaryLight,
                ],
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
      'Oca',
      'Şub',
      'Mar',
      'Nis',
      'May',
      'Haz',
      'Tem',
      'Ağu',
      'Eyl',
      'Eki',
      'Kas',
      'Ara',
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
    barrierColor: Colors.black.withOpacity(0.85),
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
  final GlobalKey _cardKey = GlobalKey();
  bool _isProcessing = false;

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
            color: context.appColors.background,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
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
                    Semantics(
                      label: l10n.accessibilityCloseSheet,
                      button: true,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        tooltip: l10n.close,
                        icon: const Icon(
                          PhosphorIconsRegular.x,
                          color: Colors.white,
                        ),
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
                      onTap: () => setState(
                        () => _selectedFormat = ShareCardFormat.story,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _FormatButton(
                      label: 'Post',
                      icon: PhosphorIconsRegular.squareLogo,
                      isSelected: _selectedFormat == ShareCardFormat.square,
                      onTap: () => setState(
                        () => _selectedFormat = ShareCardFormat.square,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Card preview
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Center(
                      child: RepaintBoundary(
                        key: _cardKey,
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
                ),
              ),

              // Share buttons - Row 1: Social platforms
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        label: '${l10n.share} Instagram',
                        button: true,
                        child: _ShareButton(
                          label: 'Instagram',
                          icon: PhosphorIconsFill.instagramLogo,
                          color: AppColors.instagram,
                          onTap: () => _shareToInstagram(l10n),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Semantics(
                        label: '${l10n.share} TikTok',
                        button: true,
                        child: _ShareButton(
                          label: 'TikTok',
                          icon: PhosphorIconsFill.tiktokLogo,
                          color: Colors.white,
                          onTap: () => _shareToTikTok(l10n),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Semantics(
                        label: '${l10n.share} WhatsApp',
                        button: true,
                        child: _ShareButton(
                          label: 'WhatsApp',
                          icon: PhosphorIconsFill.whatsappLogo,
                          color: AppColors.whatsapp,
                          onTap: () => _shareToWhatsApp(l10n),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Semantics(
                        label: '${l10n.share} X',
                        button: true,
                        child: _ShareButton(
                          label: 'X',
                          icon: PhosphorIconsFill.xLogo,
                          color: Colors.white,
                          onTap: () => _shareToTwitter(l10n),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Share buttons - Row 2: More options
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        label: l10n.saveToGallery,
                        button: true,
                        child: _ShareButton(
                          label: l10n.saveToGallery,
                          icon: PhosphorIconsFill.downloadSimple,
                          color: context.appColors.primary,
                          onTap: () => _saveToGallery(l10n),
                          isLoading: _isProcessing,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Semantics(
                        label: l10n.otherApps,
                        button: true,
                        child: _ShareButton(
                          label: l10n.otherApps,
                          icon: PhosphorIconsFill.shareNetwork,
                          color: context.appColors.textSecondary,
                          onTap: () => _shareGeneric(l10n),
                        ),
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

  /// Capture card as image and return file path
  Future<String?> _captureCard() async {
    try {
      final boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      if (byteData == null) return null;

      final pngBytes = byteData.buffer.asUint8List();
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/vantag_share_$timestamp.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      return filePath;
    } catch (_) {
      return null;
    }
  }

  /// Get share text with referral link
  Future<String> _getShareText() async {
    String shareText = 'Sen kaç saat çalışıyorsun? 👀 vantag.app';
    try {
      final referralCode = await ReferralService().getOrCreateReferralCode();
      if (referralCode != null) {
        final referralLink = DeepLinkService.generateReferralLink(referralCode);
        shareText = 'Sen kaç saat çalışıyorsun? 👀 $referralLink';
      }
    } catch (_) {
      // Use default text if referral fails
    }
    return shareText;
  }

  /// Share to Instagram Stories
  Future<void> _shareToInstagram(AppLocalizations l10n) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    haptics.light();

    try {
      final filePath = await _captureCard();
      if (filePath == null) {
        _showError(l10n);
        return;
      }

      // Try to open Instagram Stories with image
      // Instagram Stories deep link format
      final instagramUrl = Uri.parse('instagram-stories://share');
      if (await canLaunchUrl(instagramUrl)) {
        // Save to gallery first, then user can share from there
        await ImageGallerySaverPlus.saveFile(filePath);
        await launchUrl(instagramUrl, mode: LaunchMode.externalApplication);
        haptics.success();
        if (mounted) Navigator.pop(context);
      } else {
        // Fallback to generic share
        await _shareGeneric(l10n);
      }
    } catch (_) {
      _showError(l10n);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  /// Share to TikTok
  Future<void> _shareToTikTok(AppLocalizations l10n) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    haptics.light();

    try {
      final filePath = await _captureCard();
      if (filePath == null) {
        _showError(l10n);
        return;
      }

      // TikTok doesn't have a direct share API, save and open app
      final tiktokUrl = Uri.parse('tiktok://');
      if (await canLaunchUrl(tiktokUrl)) {
        await ImageGallerySaverPlus.saveFile(filePath);
        await launchUrl(tiktokUrl, mode: LaunchMode.externalApplication);
        haptics.success();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.savedToGallery),
              backgroundColor: context.appColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        await _shareGeneric(l10n);
      }
    } catch (_) {
      _showError(l10n);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  /// Share to WhatsApp
  Future<void> _shareToWhatsApp(AppLocalizations l10n) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    haptics.light();

    try {
      final filePath = await _captureCard();
      if (filePath == null) {
        _showError(l10n);
        return;
      }

      final shareText = await _getShareText();
      final whatsappUrl = Uri.parse(
        'whatsapp://send?text=${Uri.encodeComponent(shareText)}',
      );

      if (await canLaunchUrl(whatsappUrl)) {
        // Share with image and text
        await Share.shareXFiles([XFile(filePath)], text: shareText);
        haptics.success();
        if (mounted) Navigator.pop(context);
      } else {
        await _shareGeneric(l10n);
      }
    } catch (_) {
      _showError(l10n);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  /// Share to Twitter/X
  Future<void> _shareToTwitter(AppLocalizations l10n) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    haptics.light();

    try {
      final filePath = await _captureCard();
      if (filePath == null) {
        _showError(l10n);
        return;
      }

      final shareText = await _getShareText();

      // Use share_plus to share to Twitter
      await Share.shareXFiles([XFile(filePath)], text: shareText);
      haptics.success();
      if (mounted) Navigator.pop(context);
    } catch (_) {
      _showError(l10n);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  /// Save to gallery
  Future<void> _saveToGallery(AppLocalizations l10n) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    haptics.light();

    try {
      final filePath = await _captureCard();
      if (filePath == null) {
        _showError(l10n);
        return;
      }

      final result = await ImageGallerySaverPlus.saveFile(filePath);

      if (result['isSuccess'] == true) {
        haptics.success();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    PhosphorIconsFill.checkCircle,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(l10n.savedToGallery),
                ],
              ),
              backgroundColor: context.appColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } else {
        _showError(l10n);
      }
    } catch (_) {
      _showError(l10n);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  /// Generic share (system share sheet)
  Future<void> _shareGeneric(AppLocalizations l10n) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    haptics.light();

    try {
      final filePath = await _captureCard();
      if (filePath == null) {
        _showError(l10n);
        return;
      }

      final shareText = await _getShareText();
      await Share.shareXFiles([XFile(filePath)], text: shareText);
      haptics.success();
      if (mounted) Navigator.pop(context);
    } catch (_) {
      _showError(l10n);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showError(AppLocalizations l10n) {
    haptics.error();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.shareError),
          backgroundColor: context.appColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
              ? context.appColors.primary.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? context.appColors.primary
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
              color: isSelected
                  ? context.appColors.primary
                  : Colors.white.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? context.appColors.primary
                    : Colors.white.withValues(alpha: 0.6),
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
  final bool isLoading;

  const _ShareButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Column(
          children: [
            if (isLoading)
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: color),
              )
            else
              Icon(icon, size: 24, color: color),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HABIT SHARE CARD - For Habit Calculator viral sharing
// ═══════════════════════════════════════════════════════════════════════════

/// Premium Habit Share Card Widget
/// Shows yearly work days cost for a habit
class HabitShareCard extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String categoryName;
  final int yearlyDays;
  final double? yearlyAmount;
  final String? frequency;
  final ShareCardFormat format;
  // Additional details for post mode
  final int? monthlyDays;
  final int? monthlyExtraHours;
  final double? monthlyAmount;
  final String? currencySymbol;

  const HabitShareCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.categoryName,
    required this.yearlyDays,
    this.yearlyAmount,
    this.frequency,
    this.format = ShareCardFormat.story,
    this.monthlyDays,
    this.monthlyExtraHours,
    this.monthlyAmount,
    this.currencySymbol,
  });

  @override
  State<HabitShareCard> createState() => _HabitShareCardState();
}

class _HabitShareCardState extends State<HabitShareCard>
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
        return const Size(360, 640);
      case ShareCardFormat.square:
        return const Size(400, 400); // Larger for better content fit
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = _cardSize;

    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background gradient
            _buildBackground(),

            // Noise texture overlay
            _buildNoiseOverlay(),

            // Ambient glow orb (uses habit color)
            _buildGlowOrb(),

            // Main content
            _buildContent(AppLocalizations.of(context)),

            // Vantag branding
            _buildBranding(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.background,
            AppColors.cardBackground,
            AppColors.background.withValues(alpha: 0.95),
          ],
          stops: const [0.0, 0.5, 1.0],
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
                    widget.iconColor.withValues(
                      alpha: _glowAnimation.value * 0.4,
                    ),
                    widget.iconColor.withValues(
                      alpha: _glowAnimation.value * 0.2,
                    ),
                    widget.iconColor.withValues(alpha: 0.0),
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

    if (!isStory) {
      // POST MODE - Compact layout with all details
      return _buildPostContent(l10n);
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: isStory ? 60 : 32,
      ),
      child: Column(
        children: [
          if (isStory) const SizedBox(height: 40),

          // Category icon badge
          _buildCategoryBadge(),

          SizedBox(height: isStory ? 40 : 24),

          // Hero: Days display
          _buildHeroSection(l10n),

          SizedBox(height: isStory ? 32 : 20),

          // Info cards (amount + frequency)
          if (widget.yearlyAmount != null || widget.frequency != null)
            _buildInfoCards(l10n),

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

  /// Post mode content - compact square layout with all details
  Widget _buildPostContent(AppLocalizations l10n) {
    final symbol = widget.currencySymbol ?? '₺';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Category badge (compact)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: widget.iconColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, size: 18, color: widget.iconColor),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  widget.categoryName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Hero number
          ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: [Colors.white, widget.iconColor.withValues(alpha: 0.9)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ).createShader(bounds);
            },
            child: Text(
              widget.yearlyDays.toString(),
              style: const TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1,
                letterSpacing: -3,
              ),
            ),
          ),

          // Work days label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.iconColor.withValues(alpha: 0.3),
                  widget.iconColor.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              l10n.habitShareWorkDays,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),

          const SizedBox(height: 4),

          // "of work per year" text
          Text(
            l10n.habitSharePostText,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // Details grid
          _buildPostDetailsGrid(l10n, symbol),
        ],
      ),
    );
  }

  /// Details grid for post mode
  Widget _buildPostDetailsGrid(AppLocalizations l10n, String symbol) {
    final details = <_DetailItem>[];

    // Monthly work time
    if (widget.monthlyDays != null) {
      final monthlyText =
          widget.monthlyExtraHours != null && widget.monthlyExtraHours! > 0
          ? '${widget.monthlyDays}d ${widget.monthlyExtraHours}h'
          : '${widget.monthlyDays} ${l10n.daysAbbrev}';
      details.add(
        _DetailItem(
          icon: PhosphorIconsDuotone.calendarBlank,
          label: l10n.monthly,
          value: monthlyText,
        ),
      );
    }

    // Yearly amount
    if (widget.yearlyAmount != null) {
      details.add(
        _DetailItem(
          icon: PhosphorIconsDuotone.coins,
          label: l10n.yearly,
          value: '$symbol${_formatAmount(widget.yearlyAmount!)}',
        ),
      );
    }

    // Monthly amount
    if (widget.monthlyAmount != null) {
      details.add(
        _DetailItem(
          icon: PhosphorIconsDuotone.wallet,
          label: l10n.monthly,
          value: '$symbol${_formatAmount(widget.monthlyAmount!)}',
        ),
      );
    }

    // Frequency
    if (widget.frequency != null) {
      details.add(
        _DetailItem(
          icon: PhosphorIconsDuotone.repeat,
          label: l10n.frequency,
          value: widget.frequency!,
        ),
      );
    }

    if (details.isEmpty) return const SizedBox.shrink();

    // Show 2x2 grid or single row depending on count
    if (details.length <= 2) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: details
            .map(
              (d) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _buildDetailChip(d),
              ),
            )
            .toList(),
      );
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 6,
      children: details.take(4).map((d) => _buildDetailChip(d)).toList(),
    );
  }

  Widget _buildDetailChip(_DetailItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, size: 14, color: Colors.white.withValues(alpha: 0.7)),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
              Text(
                item.value,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: widget.iconColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(widget.icon, size: 22, color: widget.iconColor),
          ),
          const SizedBox(width: 12),
          Text(
            widget.categoryName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(AppLocalizations l10n) {
    return Column(
      children: [
        // Pre-text
        Text(
          l10n.habitSharePreText,
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
            return LinearGradient(
              colors: [
                Colors.white,
                widget.iconColor.withValues(alpha: 0.9),
                widget.iconColor,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(bounds);
          },
          child: Text(
            widget.yearlyDays.toString(),
            style: TextStyle(
              fontSize: widget.format == ShareCardFormat.story ? 120 : 88,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1,
              letterSpacing: -4,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Unit badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.iconColor.withValues(alpha: 0.3),
                widget.iconColor.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.iconColor.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Text(
            l10n.habitShareWorkDays,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 4,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Post-text
        Text(
          l10n.habitSharePostText,
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

  Widget _buildInfoCards(AppLocalizations l10n) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
              if (widget.yearlyAmount != null) ...[
                Icon(
                  PhosphorIconsDuotone.coins,
                  size: 18,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 8),
                Text(
                  '₺${_formatAmount(widget.yearlyAmount!)}${l10n.habitSharePerYear}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
              if (widget.yearlyAmount != null && widget.frequency != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                ),
              if (widget.frequency != null) ...[
                Icon(
                  PhosphorIconsDuotone.calendarBlank,
                  size: 18,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.frequency!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
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
                widget.iconColor.withValues(alpha: 0.6),
                Colors.transparent,
              ],
            ),
            borderRadius: BorderRadius.circular(1),
          ),
        ),

        const SizedBox(height: 20),

        // CTA text
        Text(
          l10n.habitShareCTA,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),

        // Bottom spacing to prevent overlap with branding
        const SizedBox(height: 48),
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
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.appColors.primary,
                  context.appColors.primaryLight,
                ],
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

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }
}

/// Helper class for detail items in post mode
class _DetailItem {
  final IconData icon;
  final String label;
  final String value;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}

/// Helper function to show habit share card preview
void showHabitShareCardPreview(
  BuildContext context, {
  required IconData icon,
  required Color iconColor,
  required String categoryName,
  required int yearlyDays,
  double? yearlyAmount,
  String? frequency,
  int? monthlyDays,
  int? monthlyExtraHours,
  double? monthlyAmount,
  String? currencySymbol,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.85),
    builder: (context) => _HabitShareCardPreviewSheet(
      icon: icon,
      iconColor: iconColor,
      categoryName: categoryName,
      yearlyDays: yearlyDays,
      yearlyAmount: yearlyAmount,
      frequency: frequency,
      monthlyDays: monthlyDays,
      monthlyExtraHours: monthlyExtraHours,
      monthlyAmount: monthlyAmount,
      currencySymbol: currencySymbol,
    ),
  );
}

class _HabitShareCardPreviewSheet extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String categoryName;
  final int yearlyDays;
  final double? yearlyAmount;
  final String? frequency;
  final int? monthlyDays;
  final int? monthlyExtraHours;
  final double? monthlyAmount;
  final String? currencySymbol;

  const _HabitShareCardPreviewSheet({
    required this.icon,
    required this.iconColor,
    required this.categoryName,
    required this.yearlyDays,
    this.yearlyAmount,
    this.frequency,
    this.monthlyDays,
    this.monthlyExtraHours,
    this.monthlyAmount,
    this.currencySymbol,
  });

  @override
  State<_HabitShareCardPreviewSheet> createState() =>
      _HabitShareCardPreviewSheetState();
}

class _HabitShareCardPreviewSheetState
    extends State<_HabitShareCardPreviewSheet> {
  ShareCardFormat _selectedFormat = ShareCardFormat.story;
  bool _showAmount = true;
  bool _showFrequency = true;
  final GlobalKey _cardKey = GlobalKey();
  bool _isSharing = false;

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
            color: context.appColors.background,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
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
                    Semantics(
                      label: l10n.accessibilityCloseSheet,
                      button: true,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        tooltip: l10n.close,
                        icon: const Icon(
                          PhosphorIconsRegular.x,
                          color: Colors.white,
                        ),
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
                      onTap: () => setState(
                        () => _selectedFormat = ShareCardFormat.story,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _FormatButton(
                      label: 'Post',
                      icon: PhosphorIconsRegular.squareLogo,
                      isSelected: _selectedFormat == ShareCardFormat.square,
                      onTap: () => setState(
                        () => _selectedFormat = ShareCardFormat.square,
                      ),
                    ),
                  ],
                ),
              ),

              // Toggle options
              if (widget.yearlyAmount != null || widget.frequency != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      if (widget.yearlyAmount != null)
                        _ToggleChip(
                          label: l10n.amount,
                          isSelected: _showAmount,
                          onTap: () =>
                              setState(() => _showAmount = !_showAmount),
                        ),
                      if (widget.yearlyAmount != null &&
                          widget.frequency != null)
                        const SizedBox(width: 8),
                      if (widget.frequency != null)
                        _ToggleChip(
                          label: l10n.frequency,
                          isSelected: _showFrequency,
                          onTap: () =>
                              setState(() => _showFrequency = !_showFrequency),
                        ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Card preview
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Center(
                      child: RepaintBoundary(
                        key: _cardKey,
                        child: HabitShareCard(
                          icon: widget.icon,
                          iconColor: widget.iconColor,
                          categoryName: widget.categoryName,
                          yearlyDays: widget.yearlyDays,
                          yearlyAmount: _showAmount
                              ? widget.yearlyAmount
                              : null,
                          frequency: _showFrequency ? widget.frequency : null,
                          format: _selectedFormat,
                          monthlyDays: widget.monthlyDays,
                          monthlyExtraHours: widget.monthlyExtraHours,
                          monthlyAmount: widget.monthlyAmount,
                          currencySymbol: widget.currencySymbol,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Share button
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.premiumCyan],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _isSharing ? null : _shareCard,
                      icon: _isSharing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(PhosphorIconsFill.shareFat, size: 22),
                      label: Text(
                        _isSharing ? l10n.sharing : l10n.share,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _shareCard() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    try {
      // Import share service dynamically to avoid circular deps
      final boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        setState(() => _isSharing = false);
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      if (byteData == null) {
        setState(() => _isSharing = false);
        return;
      }

      final pngBytes = byteData.buffer.asUint8List();
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/vantag_habit_$timestamp.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      // Get referral link for sharing
      final l10n = AppLocalizations.of(context);
      String shareText = l10n.habitShareText;
      try {
        final referralCode = await ReferralService().getOrCreateReferralCode();
        if (referralCode != null) {
          final referralLink = DeepLinkService.generateReferralLink(
            referralCode,
          );
          shareText = l10n.habitShareTextWithLink(referralLink.toString());
        }
      } catch (_) {
        // Use default text if referral fails
      }

      await Share.shareXFiles([XFile(filePath)], text: shareText);

      // Cleanup after 5 minutes
      Future.delayed(const Duration(minutes: 5), () {
        if (file.existsSync()) {
          try {
            file.deleteSync();
          } catch (_) {}
        }
      });

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).shareError),
            backgroundColor: context.appColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? context.appColors.primary.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? context.appColors.primary
                : Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected
                  ? PhosphorIconsFill.checkCircle
                  : PhosphorIconsRegular.circle,
              size: 16,
              color: isSelected
                  ? context.appColors.primary
                  : Colors.white.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? context.appColors.primary
                    : Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
