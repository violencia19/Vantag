import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vantag/l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/pro_provider.dart';
import '../providers/finance_provider.dart';
import '../providers/theme_provider.dart';
import '../services/auth_service.dart';
import '../services/export_service.dart';
import '../services/purchase_service.dart';
import '../services/sound_service.dart';
import '../services/referral_service.dart';
import '../services/deep_link_service.dart';
import '../services/simple_mode_service.dart';
import '../services/lock_service.dart';
import '../theme/theme.dart';
import '../widgets/currency_selector.dart';
import 'paywall_screen.dart';
import 'onboarding_screen.dart';
import 'achievements_screen.dart';
import 'notification_settings_screen.dart';
import 'voice_input_screen.dart';
import 'pin_setup_screen.dart';
import 'import_statement_screen.dart';

/// Settings Screen - Replaces Profile in bottom nav
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isExporting = false;
  bool _isRestoring = false;
  bool _soundEnabled = true;
  bool _simpleModeEnabled = false;

  // Referral system
  String? _referralCode;
  int _referralCount = 0;
  bool _isLoadingReferral = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadReferralData();
  }

  Future<void> _loadSettings() async {
    // Initialize simple mode service
    await simpleModeService.initialize();

    setState(() {
      _soundEnabled = soundService.isEnabled;
      _simpleModeEnabled = simpleModeService.isEnabled;
    });
  }

  Future<void> _loadReferralData() async {
    try {
      final referralService = ReferralService();

      // Get or create referral code
      final code = await referralService.getOrCreateReferralCode();

      // Get referral stats
      final stats = await referralService.getReferralStats();

      if (mounted) {
        setState(() {
          _referralCode = code;
          _referralCount = stats.totalReferrals;
          _isLoadingReferral = false;
        });
      }
    } catch (e) {
      debugPrint('[Settings] Error loading referral data: $e');
      if (mounted) {
        setState(() => _isLoadingReferral = false);
      }
    }
  }

  Future<void> _toggleSound(bool value) async {
    await soundService.setEnabled(value);
    setState(() => _soundEnabled = value);
    HapticFeedback.selectionClick();

    // Play success sound as feedback when enabling
    if (value) {
      soundService.playSuccess();
    }
  }

  Future<void> _toggleSimpleMode(bool value) async {
    await simpleModeService.setEnabled(value);
    setState(() => _simpleModeEnabled = value);
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final proProvider = context.watch<ProProvider>();
    final isPro = proProvider.isPro;

    return Scaffold(
      backgroundColor: context.appColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Semantics(
                  header: true,
                  child: Text(
                    l10n.navSettings,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: context.appColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),

            // Growth Section (Invite Friends)
            SliverToBoxAdapter(child: _buildGrowthSection(l10n)),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // General Section
            SliverToBoxAdapter(
              child: _buildSection(
                title: l10n.settingsGeneral,
                children: [
                  _buildCurrencyTile(l10n),
                  _buildDivider(),
                  _buildLanguageTile(l10n),
                  _buildDivider(),
                  _buildThemeTile(l10n),
                  _buildDivider(),
                  _buildSimpleModeTile(l10n),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Notifications Section
            SliverToBoxAdapter(
              child: _buildSection(
                title: l10n.settingsNotifications,
                children: [
                  _buildRemindersTile(l10n),
                  _buildDivider(),
                  _buildSoundEffectsTile(l10n),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Security Section
            SliverToBoxAdapter(
              child: _buildSecuritySection(l10n),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Pro & Purchases Section
            SliverToBoxAdapter(
              child: _buildSection(
                title: l10n.settingsProPurchases,
                children: [
                  _buildProTile(l10n, isPro),
                  _buildDivider(),
                  _buildRestorePurchasesTile(l10n),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Achievements Section
            SliverToBoxAdapter(
              child: _buildSection(
                title: l10n.navAchievements,
                children: [_buildAchievementsTile(l10n)],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Voice & Shortcuts Section (NEW)
            SliverToBoxAdapter(
              child: _buildVoiceSection(l10n),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Data & Privacy Section
            SliverToBoxAdapter(
              child: _buildSection(
                title: l10n.settingsDataPrivacy,
                children: [
                  _buildGoogleAccountTile(l10n),
                  _buildDivider(),
                  _buildExportTile(l10n, isPro),
                  _buildDivider(),
                  _buildImportStatementTile(l10n, isPro),
                  _buildDivider(),
                  _buildPrivacyPolicyTile(l10n),
                  _buildDivider(),
                  _buildTermsOfServiceTile(l10n),
                  _buildDivider(),
                  _buildDeleteAccountTile(l10n),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // About Section
            SliverToBoxAdapter(
              child: _buildSection(
                title: l10n.settingsAbout,
                children: [
                  _buildVersionTile(l10n),
                  _buildDivider(),
                  _buildContactUsTile(l10n),
                ],
              ),
            ),

            // Bottom padding for nav bar
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthSection(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [context.appColors.primary, context.appColors.secondary],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: context.appColors.primary.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: context.appColors.textPrimary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    PhosphorIconsDuotone.gift,
                    size: 24,
                    color: context.appColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.inviteFriends,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: context.appColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.referralRewardInfo,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.appColors.textPrimary.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Referral code display
            if (_isLoadingReferral)
              Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.appColors.textPrimary.withValues(alpha: 0.9),
                  ),
                ),
              )
            else if (_referralCode != null) ...[
              // Code card
              Semantics(
                button: true,
                label: l10n.codeCopied.replaceAll('!', ''),
                hint: l10n.yourReferralCode,
                child: GestureDetector(
                  onTap: _copyReferralCode,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: context.appColors.textPrimary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: context.appColors.textPrimary.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.yourReferralCode,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: context.appColors.textPrimary.withValues(alpha: 0.9),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _referralCode!,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: context.appColors.textPrimary,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: context.appColors.textPrimary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            PhosphorIconsDuotone.copy,
                            size: 20,
                            color: context.appColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Stats row
              Row(
                children: [
                  // Friends joined count
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: context.appColors.textPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$_referralCount',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: context.appColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n
                                .referralStats(_referralCount)
                                .replaceAll('$_referralCount ', ''),
                            style: TextStyle(
                              fontSize: 11,
                              color: context.appColors.textPrimary.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Share button
                  Expanded(
                    child: Semantics(
                      button: true,
                      label: l10n.shareInviteLink,
                      child: GestureDetector(
                        onTap: _shareApp,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                PhosphorIconsDuotone.shareFat,
                                size: 18,
                                color: context.appColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.shareInviteLink,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: context.appColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _shareApp() {
    final l10n = AppLocalizations.of(context);
    HapticFeedback.mediumImpact();

    // Generate referral link
    final referralLink = _referralCode != null
        ? DeepLinkService.generateReferralLink(_referralCode!).toString()
        : 'https://play.google.com/store/apps/details?id=com.vantag.app';

    Share.share(l10n.shareDefaultMessage(referralLink));
  }

  void _copyReferralCode() {
    if (_referralCode == null) return;

    HapticFeedback.mediumImpact();
    Clipboard.setData(ClipboardData(text: _referralCode!));
    soundService.playSuccess();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(AppLocalizations.of(context).codeCopied),
          ],
        ),
        backgroundColor: context.appColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: context.appColors.textTertiary,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: context.appColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.appColors.cardBorder),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  /// Voice & Shortcuts section with NEW badge
  Widget _buildVoiceSection(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header with NEW badge
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Row(
              children: [
                Text(
                  l10n.voiceAndShortcuts.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: context.appColors.textTertiary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: context.appColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    l10n.newBadge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Semantics(
            button: true,
            label: l10n.voiceInput,
            hint: l10n.voiceInputHint,
            child: Container(
              decoration: BoxDecoration(
                color: context.appColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.appColors.cardBorder),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showVoiceHelpSheet(context, l10n),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color:
                                context.appColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            PhosphorIconsFill.microphone,
                            size: 20,
                            color: context.appColors.primary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.voiceInput,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: context.appColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.voiceInputHint,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.appColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          PhosphorIconsRegular.arrowRight,
                          size: 20,
                          color: context.appColors.textTertiary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show voice help bottom sheet
  void _showVoiceHelpSheet(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      backgroundColor: context.appColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              PhosphorIconsFill.microphone,
              size: 48,
              color: context.appColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.howToUseVoice,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.appColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            // Method 1: Long-press FAB
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.appColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: context.appColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      PhosphorIconsFill.plusCircle,
                      color: context.appColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.longPressFab,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: context.appColors.textPrimary,
                          ),
                        ),
                        Text(
                          l10n.longPressFabHint,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.appColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Method 2: Mic button
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.appColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: context.appColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      PhosphorIconsFill.microphone,
                      color: context.appColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.micButton,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: context.appColors.textPrimary,
                          ),
                        ),
                        Text(
                          l10n.micButtonHint,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.appColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Text(
              l10n.exampleCommands,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: context.appColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildExampleChip(l10n.voiceExample1),
                _buildExampleChip(l10n.voiceExample2),
                _buildExampleChip(l10n.voiceExample3),
              ],
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: Semantics(
                button: true,
                label: l10n.tryNow,
                hint: l10n.voiceInput,
                child: ElevatedButton.icon(
                  icon: const Icon(PhosphorIconsFill.microphone),
                  label: Text(l10n.tryNow),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.appColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const VoiceInputScreen(),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.appColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.appColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: context.appColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Security section with PIN and biometric toggles
  Widget _buildSecuritySection(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              l10n.security.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: context.appColors.textTertiary,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: context.appColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.appColors.cardBorder),
            ),
            child: Column(
              children: [
                // PIN Lock Toggle
                FutureBuilder<bool>(
                  future: LockService.isLockEnabled(),
                  builder: (context, snapshot) {
                    final isEnabled = snapshot.data ?? false;
                    return _buildSecurityTile(
                      icon: PhosphorIconsFill.lock,
                      title: l10n.pinLock,
                      subtitle: l10n.pinLockDescription,
                      value: isEnabled,
                      onChanged: (value) async {
                        if (value) {
                          // Navigate to PIN setup
                          final result = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PinSetupScreen(),
                            ),
                          );
                          if (result == true) {
                            setState(() {});
                          }
                        } else {
                          await LockService.removePin();
                          setState(() {});
                        }
                      },
                    );
                  },
                ),

                // Biometric Toggle (only if PIN is enabled and biometrics available)
                FutureBuilder<List<bool>>(
                  future: Future.wait([
                    LockService.isLockEnabled(),
                    LockService.canUseBiometrics(),
                  ]),
                  builder: (context, snapshot) {
                    final results = snapshot.data ?? [false, false];
                    final pinEnabled = results[0];
                    final canUseBio = results[1];

                    if (!pinEnabled || !canUseBio) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      children: [
                        _buildDivider(),
                        FutureBuilder<bool>(
                          future: LockService.isBiometricEnabled(),
                          builder: (context, bioSnapshot) {
                            return _buildSecurityTile(
                              icon: PhosphorIconsFill.fingerprint,
                              title: l10n.biometricUnlock,
                              subtitle: l10n.biometricDescription,
                              value: bioSnapshot.data ?? false,
                              onChanged: (value) async {
                                if (value) {
                                  // Test biometric before enabling
                                  final success = await LockService
                                      .authenticateWithBiometrics(
                                    l10n.unlockWithBiometric,
                                  );
                                  if (success) {
                                    await LockService.setBiometricEnabled(true);
                                  }
                                } else {
                                  await LockService.setBiometricEnabled(false);
                                }
                                setState(() {});
                              },
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final l10n = AppLocalizations.of(context);
    final toggleState = value ? l10n.accessibilityToggleOn : l10n.accessibilityToggleOff;

    return Semantics(
      toggled: value,
      label: '$title, $toggleState',
      hint: subtitle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: context.appColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: context.appColors.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: context.appColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.appColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeColor: context.appColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    Color? titleColor,
    Widget? trailing,
    bool showArrow = true,
    VoidCallback? onTap,
    String? semanticHint,
  }) {
    return Semantics(
      button: onTap != null,
      label: title,
      hint: semanticHint,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: iconColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: titleColor ?? context.appColors.textPrimary,
                    ),
                  ),
                ),
                if (trailing != null) trailing,
                if (showArrow && trailing == null)
                  Icon(
                    PhosphorIconsDuotone.caretRight,
                    size: 18,
                    color: context.appColors.textTertiary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: context.appColors.cardBorder),
    );
  }

  Widget _buildCurrencyTile(AppLocalizations l10n) {
    final currencyProvider = context.watch<CurrencyProvider>();
    final currency = currencyProvider.currency;

    return _buildListTile(
      icon: PhosphorIconsDuotone.currencyCircleDollar,
      iconColor: AppColors.achievementStreak,
      title: l10n.settingsCurrency,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(currency.flag, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            currency.code,
            style: TextStyle(
              color: context.appColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            PhosphorIconsDuotone.caretRight,
            size: 18,
            color: context.appColors.textTertiary,
          ),
        ],
      ),
      showArrow: false,
      onTap: () => showCurrencySelector(context),
    );
  }

  Widget _buildLanguageTile(AppLocalizations l10n) {
    final localeProvider = context.watch<LocaleProvider>();
    final currentLang = localeProvider.locale?.languageCode ?? 'tr';
    final langName = currentLang == 'tr' ? 'Türkçe' : 'English';

    return _buildListTile(
      icon: PhosphorIconsDuotone.translate,
      iconColor: AppColors.categoryEntertainment,
      title: l10n.settingsLanguage,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            langName,
            style: TextStyle(
              color: context.appColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            PhosphorIconsDuotone.caretRight,
            size: 18,
            color: context.appColors.textTertiary,
          ),
        ],
      ),
      showArrow: false,
      onTap: () => _showLanguageSelector(localeProvider, l10n),
    );
  }

  void _showLanguageSelector(
    LocaleProvider localeProvider,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      backgroundColor: context.appColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              decoration: BoxDecoration(
                color: context.appColors.textTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Text('🇹🇷', style: TextStyle(fontSize: 24)),
              title: const Text('Türkçe'),
              trailing: localeProvider.locale?.languageCode == 'tr'
                  ? Icon(
                      PhosphorIconsDuotone.checkCircle,
                      color: context.appColors.primary,
                    )
                  : null,
              onTap: () {
                localeProvider.setLocale(const Locale('tr'));
                Navigator.pop(context);
                HapticFeedback.selectionClick();
              },
            ),
            ListTile(
              leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
              title: const Text('English'),
              trailing: localeProvider.locale?.languageCode == 'en'
                  ? Icon(
                      PhosphorIconsDuotone.checkCircle,
                      color: context.appColors.primary,
                    )
                  : null,
              onTap: () {
                localeProvider.setLocale(const Locale('en'));
                Navigator.pop(context);
                HapticFeedback.selectionClick();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeTile(AppLocalizations l10n) {
    final themeProvider = context.watch<ThemeProvider>();
    final currentTheme = themeProvider.themeMode;

    String themeName;
    IconData themeIcon;
    switch (currentTheme) {
      case AppThemeMode.dark:
        themeName = l10n.settingsThemeDark;
        themeIcon = PhosphorIconsDuotone.moon;
        break;
      case AppThemeMode.light:
        themeName = l10n.settingsThemeLight;
        themeIcon = PhosphorIconsDuotone.sun;
        break;
      case AppThemeMode.automatic:
        themeName = l10n.settingsThemeAutomatic;
        themeIcon = PhosphorIconsDuotone.clock;
        break;
    }

    return _buildListTile(
      icon: themeIcon,
      iconColor: AppColors.categoryShopping,
      title: l10n.settingsTheme,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            themeName,
            style: TextStyle(
              color: context.appColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            PhosphorIconsDuotone.caretRight,
            size: 18,
            color: context.appColors.textTertiary,
          ),
        ],
      ),
      showArrow: false,
      onTap: () => _showThemeSelector(themeProvider, l10n),
    );
  }

  void _showThemeSelector(ThemeProvider themeProvider, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      backgroundColor: context.appColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              decoration: BoxDecoration(
                color: context.appColors.textTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                l10n.settingsTheme,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: context.appColors.textPrimary,
                ),
              ),
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  PhosphorIconsDuotone.moon,
                  color: context.appColors.textPrimary,
                  size: 20,
                ),
              ),
              title: Text(l10n.settingsThemeDark),
              trailing: themeProvider.themeMode == AppThemeMode.dark
                  ? Icon(
                      PhosphorIconsDuotone.checkCircle,
                      color: context.appColors.primary,
                    )
                  : null,
              onTap: () {
                themeProvider.setThemeMode(AppThemeMode.dark);
                Navigator.pop(context);
                HapticFeedback.selectionClick();
              },
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColorsLight.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  PhosphorIconsDuotone.sun,
                  color: AppColorsLight.textPrimary,
                  size: 20,
                ),
              ),
              title: Text(l10n.settingsThemeLight),
              trailing: themeProvider.themeMode == AppThemeMode.light
                  ? Icon(
                      PhosphorIconsDuotone.checkCircle,
                      color: context.appColors.primary,
                    )
                  : null,
              onTap: () {
                themeProvider.setThemeMode(AppThemeMode.light);
                Navigator.pop(context);
                HapticFeedback.selectionClick();
              },
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.background, AppColorsLight.background],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  PhosphorIconsDuotone.clock,
                  color: context.appColors.textPrimary,
                  size: 20,
                ),
              ),
              title: Text(l10n.settingsThemeAutomatic),
              subtitle: Text(
                '07:00-19:00 ☀️ / 19:00-07:00 🌙',
                style: TextStyle(
                  fontSize: 12,
                  color: context.appColors.textTertiary,
                ),
              ),
              trailing: themeProvider.themeMode == AppThemeMode.automatic
                  ? Icon(
                      PhosphorIconsDuotone.checkCircle,
                      color: context.appColors.primary,
                    )
                  : null,
              onTap: () {
                themeProvider.setThemeMode(AppThemeMode.automatic);
                Navigator.pop(context);
                HapticFeedback.selectionClick();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleModeTile(AppLocalizations l10n) {
    return _buildListTile(
      icon: PhosphorIconsDuotone.leaf,
      iconColor: AppColors.premiumGreen,
      title: l10n.simpleMode,
      trailing: Switch.adaptive(
        value: _simpleModeEnabled,
        onChanged: _toggleSimpleMode,
        activeTrackColor: context.appColors.primary,
      ),
      showArrow: false,
    );
  }

  Widget _buildRemindersTile(AppLocalizations l10n) {
    return _buildListTile(
      icon: PhosphorIconsDuotone.bellRinging,
      iconColor: AppColors.categoryEducation,
      title: l10n.notificationSettings,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()),
        );
      },
    );
  }

  Widget _buildSoundEffectsTile(AppLocalizations l10n) {
    return _buildListTile(
      icon: PhosphorIconsDuotone.speakerHigh,
      iconColor: AppColors.categoryShopping,
      title: l10n.settingsSoundEffects,
      trailing: Switch.adaptive(
        value: _soundEnabled,
        onChanged: _toggleSound,
        activeTrackColor: context.appColors.primary,
      ),
      showArrow: false,
    );
  }

  Widget _buildProTile(AppLocalizations l10n, bool isPro) {
    return _buildListTile(
      icon: PhosphorIconsDuotone.lightning,
      iconColor: isPro
          ? AppColors.medalGold
          : context.appColors.textTertiary,
      title: l10n.settingsVantagPro,
      trailing: isPro
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.medalGold, AppColors.incomeBonus],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'PRO',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: context.appColors.background,
                ),
              ),
            )
          : Icon(
              PhosphorIconsDuotone.caretRight,
              size: 18,
              color: context.appColors.textTertiary,
            ),
      showArrow: false,
      onTap: () {
        if (isPro) {
          HapticFeedback.lightImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.proMemberToast),
              behavior: SnackBarBehavior.floating,
              backgroundColor: context.appColors.success,
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PaywallScreen()),
          );
        }
      },
    );
  }

  Widget _buildRestorePurchasesTile(AppLocalizations l10n) {
    return _buildListTile(
      icon: PhosphorIconsDuotone.arrowCounterClockwise,
      iconColor: AppColors.secondary,
      title: l10n.settingsRestorePurchases,
      trailing: _isRestoring
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : null,
      showArrow: !_isRestoring,
      onTap: _isRestoring ? null : _restorePurchases,
    );
  }

  Widget _buildAchievementsTile(AppLocalizations l10n) {
    return _buildListTile(
      icon: PhosphorIconsDuotone.trophy,
      iconColor: AppColors.medalGold,
      title: l10n.badges,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AchievementsScreen()),
        );
      },
    );
  }

  Future<void> _restorePurchases() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _isRestoring = true);

    try {
      final result = await PurchaseService().restorePurchases();
      final restored = result.isPro ?? false;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              restored ? l10n.settingsRestoreSuccess : l10n.settingsRestoreNone,
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: restored
                ? context.appColors.success
                : context.appColors.surfaceLight,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRestoring = false);
      }
    }
  }

  bool _isLinkingGoogle = false;

  Widget _buildGoogleAccountTile(AppLocalizations l10n) {
    final authService = AuthService();
    final isAnonymous = authService.isAnonymous;
    final isLinkedWithGoogle = authService.isLinkedWithGoogle;
    final user = authService.currentUser;

    if (!isAnonymous && isLinkedWithGoogle) {
      // User is linked with Google - show account info
      return _buildListTile(
        icon: PhosphorIconsDuotone.googleLogo,
        iconColor: AppColors.premiumGreen,
        title: l10n.googleLinked,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (user?.email != null)
              Flexible(
                child: Text(
                  user!.email!,
                  style: TextStyle(
                    color: context.appColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(width: 8),
            Icon(
              PhosphorIconsFill.checkCircle,
              size: 18,
              color: AppColors.premiumGreen,
            ),
          ],
        ),
        showArrow: false,
        semanticHint: user?.email,
      );
    }

    // User is anonymous - show link option
    return StatefulBuilder(
      builder: (context, setLocalState) {
        return _buildListTile(
          icon: PhosphorIconsDuotone.googleLogo,
          iconColor: AppColors.categoryBills,
          title: l10n.googleNotLinked,
          trailing: _isLinkingGoogle
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.appColors.primary,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: context.appColors.warning.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        l10n.dataNotBackedUp,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: context.appColors.warning,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      PhosphorIconsDuotone.caretRight,
                      size: 18,
                      color: context.appColors.textTertiary,
                    ),
                  ],
                ),
          showArrow: false,
          onTap: _isLinkingGoogle ? null : () => _linkGoogleAccount(l10n),
          semanticHint: l10n.dataNotBackedUp,
        );
      },
    );
  }

  Future<void> _linkGoogleAccount(AppLocalizations l10n) async {
    setState(() => _isLinkingGoogle = true);
    HapticFeedback.mediumImpact();

    try {
      final authService = AuthService();
      final result = await authService.signInWithGoogle();

      if (!mounted) return;

      if (result.success) {
        soundService.playSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    result.wasLinked
                        ? l10n.googleLinkedSuccess
                        : l10n.googleLinkedSuccess,
                  ),
                ),
              ],
            ),
            backgroundColor: context.appColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        // Refresh state to show linked status
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(result.errorMessage ?? l10n.googleLinkFailed),
                ),
              ],
            ),
            backgroundColor: context.appColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.googleLinkFailed),
            backgroundColor: context.appColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLinkingGoogle = false);
      }
    }
  }

  Widget _buildExportTile(AppLocalizations l10n, bool isPro) {
    return _buildListTile(
      icon: PhosphorIconsDuotone.fileXls,
      iconColor: AppColors.premiumGreen,
      title: l10n.settingsExportData,
      trailing: _isExporting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : !isPro
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.appColors.primary.withValues(alpha: 0.2),
                    context.appColors.secondary.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'PRO',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: context.appColors.primary,
                ),
              ),
            )
          : null,
      showArrow: !_isExporting && isPro,
      onTap: _isExporting ? null : () => _exportData(isPro),
    );
  }

  Future<void> _exportData(bool isPro) async {
    if (!isPro) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PaywallScreen()),
      );
      return;
    }

    final l10n = AppLocalizations.of(context);
    setState(() => _isExporting = true);

    try {
      final exportService = ExportService();
      // Use Excel (xlsx) export - phones can open this directly
      final file = await exportService.exportToExcel(context);

      if (file != null) {
        // Log file path for debugging
        debugPrint('[Export] File created at: ${file.path}');

        if (!mounted) return;

        // Show dialog with two options: Share or Save to Downloads
        final action = await _showExportOptionsDialog(l10n);

        if (action == 'share') {
          await exportService.shareFile(file);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.exportSuccess),
                backgroundColor: AppColors.premiumGreen,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else if (action == 'save') {
          final result = await exportService.saveToDownloads(file);
          if (mounted) {
            if (result.file != null && result.path != null) {
              // Show success with path
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.exportSuccess,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        result.path!,
                        style: const TextStyle(fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  backgroundColor: AppColors.premiumGreen,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 5),
                ),
              );
            } else {
              // Show error and fallback to share
              debugPrint('[Export] Save failed: ${result.error}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${l10n.exportError}: ${result.error ?? "Unknown"}'),
                  backgroundColor: AppColors.categoryBills,
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: l10n.exportShareOption,
                    textColor: Colors.white,
                    onPressed: () => exportService.shareFile(file),
                  ),
                ),
              );
            }
          }
        }
      } else {
        throw Exception('File creation failed');
      }
    } catch (e) {
      debugPrint('[Export] Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.exportError),
            backgroundColor: AppColors.categoryBills,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  /// Show dialog with export options: Share or Save to Downloads
  Future<String?> _showExportOptionsDialog(AppLocalizations l10n) async {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.appColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              PhosphorIconsDuotone.fileArrowDown,
              color: context.appColors.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.exportComplete,
                style: TextStyle(
                  color: context.appColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          l10n.exportChooseAction,
          style: TextStyle(
            color: context.appColors.textSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          // Save to Downloads button
          TextButton.icon(
            onPressed: () => Navigator.pop(context, 'save'),
            icon: Icon(
              PhosphorIconsDuotone.folderOpen,
              size: 18,
              color: context.appColors.textSecondary,
            ),
            label: Text(
              l10n.exportSaveOption,
              style: TextStyle(color: context.appColors.textSecondary),
            ),
          ),
          // Share button
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, 'share'),
            icon: const Icon(PhosphorIconsDuotone.shareFat, size: 18),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.appColors.primary,
              foregroundColor: Colors.white,
            ),
            label: Text(l10n.exportShareOption),
          ),
        ],
      ),
    );
  }

  Widget _buildImportStatementTile(AppLocalizations l10n, bool isPro) {
    return _buildListTile(
      icon: PhosphorIconsDuotone.fileArrowUp,
      iconColor: AppColors.categoryBills,
      title: l10n.settingsImportStatement,
      trailing: !isPro
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.appColors.primary.withValues(alpha: 0.2),
                    context.appColors.secondary.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'PRO',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: context.appColors.primary,
                ),
              ),
            )
          : null,
      showArrow: isPro,
      onTap: () => _openImportStatement(isPro),
      semanticHint: l10n.settingsImportStatementDesc,
    );
  }

  Future<void> _openImportStatement(bool isPro) async {
    if (!isPro) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PaywallScreen()),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ImportStatementScreen()),
    );
  }

  Widget _buildPrivacyPolicyTile(AppLocalizations l10n) {
    final localeProvider = context.watch<LocaleProvider>();
    final langCode = localeProvider.locale?.languageCode ?? 'tr';
    final privacyUrl = langCode == 'tr'
        ? 'https://violencia19.github.io/Vantag/privacy-tr'
        : 'https://violencia19.github.io/Vantag/privacy-en';

    return _buildListTile(
      icon: PhosphorIconsDuotone.shieldCheck,
      iconColor: AppColors.categoryEntertainment,
      title: l10n.settingsPrivacyPolicy,
      onTap: () => launchUrl(Uri.parse(privacyUrl)),
    );
  }

  Widget _buildTermsOfServiceTile(AppLocalizations l10n) {
    final localeProvider = context.watch<LocaleProvider>();
    final langCode = localeProvider.locale?.languageCode ?? 'tr';
    final termsUrl = langCode == 'tr'
        ? 'https://violencia19.github.io/Vantag/terms-tr'
        : 'https://violencia19.github.io/Vantag/terms-en';

    return _buildListTile(
      icon: PhosphorIconsDuotone.fileText,
      iconColor: AppColors.categoryShopping,
      title: l10n.termsOfService,
      onTap: () => launchUrl(Uri.parse(termsUrl)),
    );
  }

  Widget _buildDeleteAccountTile(AppLocalizations l10n) {
    return _buildListTile(
      icon: PhosphorIconsDuotone.userMinus,
      iconColor: context.appColors.error,
      title: l10n.deleteAccount,
      titleColor: context.appColors.error,
      showArrow: false,
      onTap: () => _deleteAccount(l10n),
    );
  }

  Future<void> _deleteAccount(AppLocalizations l10n) async {
    final confirmWord = l10n.deleteAccountConfirmWord;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      barrierDismissible: false,
      builder: (context) =>
          _DeleteAccountDialog(confirmWord: confirmWord, l10n: l10n),
    );

    if (confirmed == true && mounted) {
      HapticFeedback.heavyImpact();

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.85),
        builder: (context) => Center(
          child: CircularProgressIndicator(color: context.appColors.primary),
        ),
      );

      try {
        final authService = AuthService();
        final result = await authService.deleteAccount();

        if (!result.success) {
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.errorMessage ?? l10n.deleteAccountError),
                backgroundColor: context.appColors.error,
              ),
            );
          }
          return;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        if (mounted) {
          final provider = context.read<FinanceProvider>();
          await provider.resetAllData();
        }

        if (!mounted) return;

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.deleteAccountSuccess),
            backgroundColor: context.appColors.success,
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          (route) => false,
        );
      } catch (e) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.deleteAccountError),
              backgroundColor: context.appColors.error,
            ),
          );
        }
      }
    }
  }

  Widget _buildVersionTile(AppLocalizations l10n) {
    return _buildListTile(
      icon: PhosphorIconsDuotone.info,
      iconColor: AppColors.categoryOther,
      title: l10n.settingsVersion,
      trailing: Text(
        '1.0.0',
        style: TextStyle(
          color: context.appColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      showArrow: false,
    );
  }

  Widget _buildContactUsTile(AppLocalizations l10n) {
    return _buildListTile(
      icon: PhosphorIconsDuotone.envelope,
      iconColor: AppColors.categoryBills,
      title: l10n.settingsContactUs,
      onTap: () => launchUrl(Uri.parse('mailto:support@vantag.app')),
    );
  }
}

/// Delete Account Confirmation Dialog
class _DeleteAccountDialog extends StatefulWidget {
  final String confirmWord;
  final AppLocalizations l10n;

  const _DeleteAccountDialog({required this.confirmWord, required this.l10n});

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _textController = TextEditingController();
  bool _isConfirmed = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_checkConfirmation);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _checkConfirmation() {
    final isConfirmed = _textController.text.trim() == widget.confirmWord;
    if (isConfirmed != _isConfirmed) {
      setState(() => _isConfirmed = isConfirmed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;

    return AlertDialog(
      backgroundColor: context.appColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: context.appColors.error.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              PhosphorIconsDuotone.warning,
              color: context.appColors.error,
              size: 32,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.deleteAccountWarningTitle,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: context.appColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.deleteAccountWarningMessage,
            style: TextStyle(
              fontSize: 14,
              color: context.appColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _textController,
            decoration: InputDecoration(
              hintText: l10n.deleteAccountConfirmPlaceholder,
              hintStyle: TextStyle(
                color: context.appColors.textTertiary,
                fontSize: 14,
              ),
              filled: true,
              fillColor: context.appColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.appColors.cardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.appColors.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: context.appColors.error,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            style: TextStyle(
              color: context.appColors.textPrimary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '"${widget.confirmWord}"',
            style: TextStyle(
              fontSize: 12,
              color: context.appColors.textTertiary,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.cancel,
                    style: TextStyle(
                      color: context.appColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isConfirmed
                      ? () => Navigator.pop(context, true)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.appColors.error,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: context.appColors.error.withValues(
                      alpha: 0.3,
                    ),
                    disabledForegroundColor: context.appColors.textPrimary.withValues(
                      alpha: 0.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.deleteAccountButton,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
