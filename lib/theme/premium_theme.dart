import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Premium Fintech Design System
/// Inspired by Revolut, N26, Nubank
class PremiumTheme {
  PremiumTheme._();

  // ============================================
  // COLORS
  // ============================================
  static const Color background = Color(0xFF0D0D12);
  static const Color surface = Color(0xFF1A1A24);
  static const Color surfaceLight = Color(0xFF252532);
  static const Color cardBorder = Color(0xFF2A2A3A);

  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF8B83FF);
  static const Color secondary = Color(0xFF4ECDC4);

  static const Color success = Color(0xFF00D9A5);
  static const Color successGlow = Color(0x4000D9A5);
  static const Color warning = Color(0xFFFFB800);
  static const Color warningGlow = Color(0x40FFB800);
  static const Color error = Color(0xFFFF4757);
  static const Color errorGlow = Color(0x40FF4757);

  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFF8E8E9A);
  static const Color textTertiary = Color(0xFF5A5A6A);

  // ============================================
  // GRADIENTS
  // ============================================
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00D9A5), Color(0xFF00B894)],
  );

  static const LinearGradient errorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF4757), Color(0xFFFF6B81)],
  );

  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFB800), Color(0xFFFF9500)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x0DFFFFFF),
      Color(0x05FFFFFF),
    ],
  );

  // ============================================
  // GLASSMORPHISM VALUES
  // ============================================
  static const double glassBlur = 10.0;
  static const double glassBorderWidth = 0.5;
  static const Color glassBorderColor = Color(0x20FFFFFF);
  static const Color glassBackground = Color(0x08FFFFFF);

  // ============================================
  // ANIMATION DURATIONS
  // ============================================
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration counting = Duration(milliseconds: 800);

  // ============================================
  // ANIMATION CURVES
  // ============================================
  static const Curve defaultCurve = Curves.easeOutCubic;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeInOutCubic;
}

/// Glassmorphic Card Widget
class PremiumGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? glowColor;
  final double glowIntensity;
  final VoidCallback? onTap;

  const PremiumGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.glowColor,
    this.glowIntensity = 0.3,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: glowColor != null
            ? [
                BoxShadow(
                  color: glowColor!.withValues(alpha: glowIntensity),
                  blurRadius: 20,
                  spreadRadius: -5,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: PremiumTheme.glassBlur,
            sigmaY: PremiumTheme.glassBlur,
          ),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: padding ?? const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: PremiumTheme.cardGradient,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: PremiumTheme.glassBorderColor,
                  width: PremiumTheme.glassBorderWidth,
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated Counting Number Widget
class CountingNumber extends StatefulWidget {
  final double value;
  final TextStyle? style;
  final String prefix;
  final String suffix;
  final int decimals;
  final Duration duration;
  final bool useGrouping;

  const CountingNumber({
    super.key,
    required this.value,
    this.style,
    this.prefix = '',
    this.suffix = '',
    this.decimals = 0,
    this.duration = const Duration(milliseconds: 800),
    this.useGrouping = true,
  });

  @override
  State<CountingNumber> createState() => _CountingNumberState();
}

class _CountingNumberState extends State<CountingNumber>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _setupAnimation();
    _controller.forward();
  }

  void _setupAnimation() {
    _animation = Tween<double>(
      begin: _previousValue,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void didUpdateWidget(CountingNumber oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
      _setupAnimation();
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatNumber(double value) {
    if (widget.useGrouping) {
      final parts = value.toStringAsFixed(widget.decimals).split('.');
      final intPart = parts[0].replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]}.',
      );
      if (parts.length > 1 && widget.decimals > 0) {
        return '$intPart,${parts[1]}';
      }
      return intPart;
    }
    return value.toStringAsFixed(widget.decimals);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          '${widget.prefix}${_formatNumber(_animation.value)}${widget.suffix}',
          style: widget.style,
        );
      },
    );
  }
}

/// Premium Gradient Button
class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final double height;
  final double borderRadius;
  final bool isLoading;
  final IconData? icon;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.gradient,
    this.height = 56,
    this.borderRadius = 16,
    this.isLoading = false,
    this.icon,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null ? _onTapDown : null,
      onTapUp: widget.onPressed != null ? _onTapUp : null,
      onTapCancel: widget.onPressed != null ? _onTapCancel : null,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              height: widget.height,
              decoration: BoxDecoration(
                gradient: widget.gradient ?? PremiumTheme.primaryGradient,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: PremiumTheme.primary.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: widget.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null) ...[
                            PhosphorIcon(
                              widget.icon!,
                              color: Colors.white,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                          ],
                          Text(
                            widget.text,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Premium Icon Container with Glow
class GlowingIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double containerSize;

  const GlowingIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 24,
    this.containerSize = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 12,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Center(
        child: PhosphorIcon(
          icon,
          color: color,
          size: size,
        ),
      ),
    );
  }
}

/// Pressable Widget with Scale Animation
class PremiumPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;

  const PremiumPressable({
    super.key,
    required this.child,
    this.onTap,
    this.scaleFactor = 0.97,
  });

  @override
  State<PremiumPressable> createState() => _PremiumPressableState();
}

class _PremiumPressableState extends State<PremiumPressable>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: widget.scaleFactor).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: _animation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// Shimmer Loading Effect
class PremiumShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const PremiumShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: PremiumTheme.surfaceLight,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Premium Stat Card (for income/expense display)
class PremiumStatCard extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final bool isPositive;

  const PremiumStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.isPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumGlassCard(
      glowColor: color,
      glowIntensity: 0.2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GlowingIcon(
                icon: icon,
                color: color,
                size: 20,
                containerSize: 40,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: PremiumTheme.textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CountingNumber(
                value: value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                  color: PremiumTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
                useGrouping: true,
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'TL',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: PremiumTheme.textTertiary,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Phosphor Icons Mapping (Lucide → Phosphor Duotone)
class PremiumIcons {
  PremiumIcons._();

  // Navigation
  static PhosphorIconData get home => PhosphorIconsDuotone.house;
  static PhosphorIconData get chart => PhosphorIconsDuotone.chartBar;
  static PhosphorIconData get trophy => PhosphorIconsDuotone.trophy;
  static PhosphorIconData get user => PhosphorIconsDuotone.user;
  static PhosphorIconData get plus => PhosphorIconsDuotone.plus;
  static PhosphorIconData get plusCircle => PhosphorIconsDuotone.plusCircle;

  // Finance
  static PhosphorIconData get wallet => PhosphorIconsDuotone.wallet;
  static PhosphorIconData get money => PhosphorIconsDuotone.money;
  static PhosphorIconData get creditCard => PhosphorIconsDuotone.creditCard;
  static PhosphorIconData get bank => PhosphorIconsDuotone.bank;
  static PhosphorIconData get piggyBank => PhosphorIconsDuotone.piggyBank;
  static PhosphorIconData get coins => PhosphorIconsDuotone.coins;
  static PhosphorIconData get currencyDollar => PhosphorIconsDuotone.currencyDollar;
  static PhosphorIconData get trendUp => PhosphorIconsDuotone.trendUp;
  static PhosphorIconData get trendDown => PhosphorIconsDuotone.trendDown;
  static PhosphorIconData get receipt => PhosphorIconsDuotone.receipt;

  // Actions
  static PhosphorIconData get check => PhosphorIconsDuotone.check;
  static PhosphorIconData get checkCircle => PhosphorIconsDuotone.checkCircle;
  static PhosphorIconData get x => PhosphorIconsDuotone.x;
  static PhosphorIconData get xCircle => PhosphorIconsDuotone.xCircle;
  static PhosphorIconData get edit => PhosphorIconsDuotone.pencilSimple;
  static PhosphorIconData get delete => PhosphorIconsDuotone.trash;
  static PhosphorIconData get settings => PhosphorIconsDuotone.gear;
  static PhosphorIconData get share => PhosphorIconsDuotone.shareNetwork;
  static PhosphorIconData get download => PhosphorIconsDuotone.downloadSimple;
  static PhosphorIconData get refresh => PhosphorIconsDuotone.arrowClockwise;

  // Time & Calendar
  static PhosphorIconData get calendar => PhosphorIconsDuotone.calendar;
  static PhosphorIconData get calendarCheck => PhosphorIconsDuotone.calendarCheck;
  static PhosphorIconData get clock => PhosphorIconsDuotone.clock;
  static PhosphorIconData get timer => PhosphorIconsDuotone.timer;
  static PhosphorIconData get hourglass => PhosphorIconsDuotone.hourglass;

  // Categories
  static PhosphorIconData get food => PhosphorIconsDuotone.forkKnife;
  static PhosphorIconData get shopping => PhosphorIconsDuotone.shoppingCart;
  static PhosphorIconData get transport => PhosphorIconsDuotone.car;
  static PhosphorIconData get entertainment => PhosphorIconsDuotone.gameController;
  static PhosphorIconData get health => PhosphorIconsDuotone.heartbeat;
  static PhosphorIconData get education => PhosphorIconsDuotone.graduationCap;
  static PhosphorIconData get home_ => PhosphorIconsDuotone.house;
  static PhosphorIconData get utilities => PhosphorIconsDuotone.lightning;
  static PhosphorIconData get subscription => PhosphorIconsDuotone.repeat;
  static PhosphorIconData get gift => PhosphorIconsDuotone.gift;
  static PhosphorIconData get travel => PhosphorIconsDuotone.airplane;
  static PhosphorIconData get coffee => PhosphorIconsDuotone.coffee;

  // Misc
  static PhosphorIconData get fire => PhosphorIconsDuotone.flame;
  static PhosphorIconData get lightning => PhosphorIconsDuotone.lightning;
  static PhosphorIconData get star => PhosphorIconsDuotone.star;
  static PhosphorIconData get heart => PhosphorIconsDuotone.heart;
  static PhosphorIconData get bell => PhosphorIconsDuotone.bell;
  static PhosphorIconData get info => PhosphorIconsDuotone.info;
  static PhosphorIconData get warning => PhosphorIconsDuotone.warning;
  static PhosphorIconData get question => PhosphorIconsDuotone.question;
  static PhosphorIconData get link => PhosphorIconsDuotone.link;
  static PhosphorIconData get lock => PhosphorIconsDuotone.lock;
  static PhosphorIconData get unlock => PhosphorIconsDuotone.lockOpen;
  static PhosphorIconData get eye => PhosphorIconsDuotone.eye;
  static PhosphorIconData get eyeOff => PhosphorIconsDuotone.eyeSlash;
  static PhosphorIconData get camera => PhosphorIconsDuotone.camera;
  static PhosphorIconData get image => PhosphorIconsDuotone.image;
  static PhosphorIconData get sparkle => PhosphorIconsDuotone.sparkle;
  static PhosphorIconData get confetti => PhosphorIconsDuotone.confetti;
  static PhosphorIconData get target => PhosphorIconsDuotone.target;
  static PhosphorIconData get rocket => PhosphorIconsDuotone.rocket;
  static PhosphorIconData get crown => PhosphorIconsDuotone.crown;
  static PhosphorIconData get shield => PhosphorIconsDuotone.shield;
  static PhosphorIconData get arrowLeft => PhosphorIconsDuotone.arrowLeft;
  static PhosphorIconData get arrowRight => PhosphorIconsDuotone.arrowRight;
  static PhosphorIconData get chevronDown => PhosphorIconsDuotone.caretDown;
  static PhosphorIconData get chevronUp => PhosphorIconsDuotone.caretUp;
  static PhosphorIconData get chevronLeft => PhosphorIconsDuotone.caretLeft;
  static PhosphorIconData get chevronRight => PhosphorIconsDuotone.caretRight;
  static PhosphorIconData get menu => PhosphorIconsDuotone.list;
  static PhosphorIconData get more => PhosphorIconsDuotone.dotsThree;
  static PhosphorIconData get search => PhosphorIconsDuotone.magnifyingGlass;
  static PhosphorIconData get filter => PhosphorIconsDuotone.funnel;
  static PhosphorIconData get sort => PhosphorIconsDuotone.sortAscending;
  static PhosphorIconData get google => PhosphorIconsDuotone.googleLogo;
  static PhosphorIconData get globe => PhosphorIconsDuotone.globe;
  static PhosphorIconData get language => PhosphorIconsDuotone.translate;
  static PhosphorIconData get moon => PhosphorIconsDuotone.moon;
  static PhosphorIconData get sun => PhosphorIconsDuotone.sun;
  static PhosphorIconData get chatBubble => PhosphorIconsDuotone.chatCircle;
  static PhosphorIconData get help => PhosphorIconsDuotone.lifebuoy;
  static PhosphorIconData get signOut => PhosphorIconsDuotone.signOut;
  static PhosphorIconData get briefcase => PhosphorIconsDuotone.briefcase;
  static PhosphorIconData get building => PhosphorIconsDuotone.buildings;
  static PhosphorIconData get handCoins => PhosphorIconsDuotone.handCoins;
  static PhosphorIconData get chartLine => PhosphorIconsDuotone.chartLine;
  static PhosphorIconData get medal => PhosphorIconsDuotone.medal;
  static PhosphorIconData get partyPopper => PhosphorIconsDuotone.confetti;
}
