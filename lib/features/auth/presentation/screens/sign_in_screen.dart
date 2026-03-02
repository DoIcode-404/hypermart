/// Sign-in screen — phone number entry + Google OAuth.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/asset_constants.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/phone_auth_state.dart';
import '../../domain/entities/user_entity.dart';
import '../controllers/auth_controller.dart';
import '../providers/auth_providers.dart';
import '../widgets/country_code_picker.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _phoneController = TextEditingController();
  CountryCode _selectedCountry = kCountryCodes.first; // +977 Nepal

  /// Cached display number used when navigating to OTP screen.
  String _pendingDisplayNumber = '';

  /// Whether we already navigated so we don't push twice.
  bool _navigated = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onContinue() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a phone number')),
      );
      return;
    }

    // Build E.164 number: strip spaces, concatenate dial code + digits.
    final e164 = '${_selectedCountry.dialCode}$phone';
    _pendingDisplayNumber = '${_selectedCountry.dialCode} $phone';
    _navigated = false;

    // Fire the verification — navigation happens in ref.listen when
    // Firebase responds with PhoneAuthCodeSent.
    ref.read(phoneAuthControllerProvider.notifier).sendCode(e164);
  }

  @override
  Widget build(BuildContext context) {
    // Listen for phone auth state changes.
    ref.listen<PhoneAuthState>(phoneAuthControllerProvider, (prev, next) {
      if (next is PhoneAuthCodeSent && !_navigated) {
        // Firebase has sent the SMS — now navigate to OTP screen.
        _navigated = true;
        context.pushNamed(
          RouteNames.otpVerification,
          extra: _pendingDisplayNumber,
        );
      } else if (next is PhoneAuthSuccess) {
        // Android auto-verification completed before user left this screen.
        context.goNamed(RouteNames.locationPermission);
      } else if (next is PhoneAuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    // Listen for Google auth state changes.
    ref.listen<AsyncValue<UserEntity?>>(googleAuthControllerProvider, (
      _,
      next,
    ) {
      next.whenOrNull(
        data: (user) {
          if (user != null) {
            context.goNamed(RouteNames.locationPermission);
          }
        },
        error: (err, _) {
          ref.read(googleAuthControllerProvider.notifier).reset();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Google sign-in failed: $err'),
              backgroundColor: AppColors.error,
            ),
          );
        },
      );
    });

    final authState = ref.watch(phoneAuthControllerProvider);
    final isSending = authState is PhoneAuthSending;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Logo ─────────────────────────────────────────
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: AppColors.primarySoft,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Image.asset(
                      AssetConstants.appIcon,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Title ────────────────────────────────────────
                  Text('HyperMart', style: AppTextStyles.headlineLarge),
                  const SizedBox(height: 8),

                  // ── Subtitle ─────────────────────────────────────
                  Text(
                    'Welcome back! Please enter your\ndetails to access your account.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyLarge,
                  ),
                  const SizedBox(height: 28),

                  // ── Phone Number label ───────────────────────────
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Phone Number',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── Country code + phone field ───────────────────
                  Row(
                    children: [
                      CountryCodePicker(
                        selected: _selectedCountry,
                        onChanged: (code) {
                          setState(() => _selectedCountry = code);
                        },
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: '(555) 000-0000',
                              hintStyle: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.textTertiary,
                              ),
                              prefixIcon: Icon(
                                Icons.phone_outlined,
                                color: AppColors.textTertiary,
                                size: 20,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 16,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.dotInactive,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.primary,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Continue button ──────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isSending ? null : _onContinue,
                      child:
                          isSending
                              ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.textWhite,
                                ),
                              )
                              : const Text('Continue'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Or continue with ────────────────────────────
                  Row(
                    children: [
                      const Expanded(child: Divider(endIndent: 12)),
                      Text(
                        'Or continue with',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const Expanded(child: Divider(indent: 12)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Google button ────────────────────────────────
                  Consumer(
                    builder: (context, ref, _) {
                      final googleState = ref.watch(
                        googleAuthControllerProvider,
                      );
                      final isGoogleLoading = googleState is AsyncLoading;
                      return SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed:
                              isGoogleLoading
                                  ? null
                                  : () =>
                                      ref
                                          .read(
                                            googleAuthControllerProvider
                                                .notifier,
                                          )
                                          .signIn(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.dotInactive),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isGoogleLoading)
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.primary,
                                  ),
                                )
                              else
                                Image.asset(
                                  AssetConstants.googleIcon,
                                  width: 22,
                                  height: 22,
                                  errorBuilder:
                                      (_, __, ___) => const Text(
                                        'G',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF4285F4),
                                        ),
                                      ),
                                ),
                              const SizedBox(width: 12),
                              Text(
                                'Continue with Google',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
