/// Onboarding screen — 3-page PageView with dot indicators and CTAs.
/// Page 1-2: "Next →" + "Skip for now" / Page 3: "Get Started" + "Back"
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/asset_constants.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/onboarding_page_data.dart';
import '../widgets/onboarding_dot_indicator.dart';
import '../widgets/onboarding_page_widget.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static final _pages = [
    OnboardingPageData(
      title: 'Browse products fast',
      subtitle:
          'Get your groceries delivered in record\ntime with our optimized routes.',
      image: AssetConstants.onboard1,
    ),
    OnboardingPageData(
      title: 'Save favourites',
      subtitle:
          'Keep track of the products you love most and\nget notified when they go on sale.',
      image: AssetConstants.onboard2,
    ),
    OnboardingPageData(
      title: 'Track orders on map',
      subtitle:
          'Real-time tracking for your deliveries from\nthe store to your doorstep.',
      image: AssetConstants.onboard3,
    ),
  ];

  bool get _isLastPage => _currentPage == _pages.length - 1;

  void _onNext() {
    if (_isLastPage) {
      _onGetStarted();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onBack() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _onSkip() => _onGetStarted();

  void _onGetStarted() {
    // Navigate to sign-in after onboarding; swap to RoutePaths.home
    // once auth / shared-prefs check is in place.
    context.go(RoutePaths.signIn);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      // ── Top-right "Skip for now" for pages 0 & 1, back arrow for page 2
      appBar:
          _isLastPage
              ? AppBar(
                backgroundColor: AppColors.scaffoldBg,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
                  onPressed: _onBack,
                ),
                title: Text(
                  'HyperMart',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
              )
              : AppBar(
                backgroundColor: AppColors.scaffoldBg,
                actions: [
                  TextButton(
                    onPressed: _onSkip,
                    child: Text('Login', style: AppTextStyles.link),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
      body: SafeArea(
        child: Column(
          children: [
            // ── PageView ─────────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder:
                    (context, index) =>
                        OnboardingPageWidget(data: _pages[index]),
              ),
            ),

            // ── Dot indicators ───────────────────────────────────
            OnboardingDotIndicator(
              count: _pages.length,
              currentIndex: _currentPage,
            ),
            const SizedBox(height: 32),

            // ── CTA Button ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                onPressed: _onNext,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isLastPage ? 'Get Started' : 'Next',
                      style: AppTextStyles.buttonLarge,
                    ),
                    if (!_isLastPage) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward,
                        size: 20,
                        color: Colors.white,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Secondary action ────────────────────────────────
            if (_isLastPage)
              TextButton(
                onPressed: _onBack,
                child: Text(
                  'Back',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            else
              TextButton(
                onPressed: _onSkip,
                child: Text('Skip for now', style: AppTextStyles.link),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
