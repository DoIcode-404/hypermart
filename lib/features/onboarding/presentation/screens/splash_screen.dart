/// Splash screen — app icon, title, animated progress bar, tagline.
/// Auto-navigates to onboarding after simulated loading completes.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/asset_constants.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;
  late final Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _progressController.forward();

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        context.go(RoutePaths.onboarding);
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 3),

              // ── App icon ───────────────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  AssetConstants.appIcon,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),

              // ── Title ──────────────────────────────────────────────
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'HyperMart ',
                      style: AppTextStyles.headlineLarge.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextSpan(
                      text: '(beta)',
                      style: AppTextStyles.headlineLarge.copyWith(
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              // ── Tagline ────────────────────────────────────────────
              Text(
                'Delivered in minutes',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const Spacer(flex: 4),

              // ── Progress section ───────────────────────────────────
              AnimatedBuilder(
                listenable: _progressAnimation,
                builder: (context, _) {
                  final percent = (_progressAnimation.value * 100).toInt();
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Preparing your store...',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '$percent%',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: _progressAnimation.value,
                          minHeight: 6,
                          backgroundColor: AppColors.progressTrack,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFE8622E),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // ── Bottom tagline ─────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bolt, size: 16, color: AppColors.textTertiary),
                  const SizedBox(width: 6),
                  Text(
                    'HYPER-FAST DELIVERY',
                    style: AppTextStyles.caption.copyWith(
                      letterSpacing: 1.5,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

/// Convenience widget — same as [AnimatedBuilder] but avoids deprecated
/// warning in newer Flutter versions.
class AnimatedBuilder extends AnimatedWidget {
  const AnimatedBuilder({
    required super.listenable,
    required this.builder,
    super.key,
  });

  // ignore: use_super_parameters
  Animation<double> get animation => listenable as Animation<double>;
  final Widget Function(BuildContext context, Widget? child) builder;

  @override
  Widget build(BuildContext context) => builder(context, null);
}
