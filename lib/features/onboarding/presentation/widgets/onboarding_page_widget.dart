/// Single onboarding page — illustration image + title + subtitle.
library;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/onboarding_page_data.dart';

class OnboardingPageWidget extends StatelessWidget {
  const OnboardingPageWidget({required this.data, super.key});

  final OnboardingPageData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),

          // ── Illustration ─────────────────────────────────────────
          Expanded(
            flex: 9,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.scaffoldBg,
                borderRadius: BorderRadius.circular(24),
              ),
              // padding: const EdgeInsets.all(20),
              child: Image.asset(data.image, fit: BoxFit.contain),
            ),
          ),

          const SizedBox(height: 32),

          // ── Title ────────────────────────────────────────────────
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineLarge,
          ),
          const SizedBox(height: 14),

          // ── Subtitle ─────────────────────────────────────────────
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge,
          ),

          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
