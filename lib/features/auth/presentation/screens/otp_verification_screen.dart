/// OTP verification screen — 6-digit code entry with resend timer.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/asset_constants.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/phone_auth_state.dart';
import '../controllers/auth_controller.dart';
import '../widgets/otp_input_field.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({required this.phoneNumber, super.key});

  /// Full phone number including dial code, e.g. "+1 5550001234".
  final String phoneNumber;

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  static const _resendDuration = 45;

  String _otp = '';
  int _secondsRemaining = _resendDuration;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _secondsRemaining = _resendDuration;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  void _resendCode() {
    if (_secondsRemaining > 0) return;
    ref.read(phoneAuthControllerProvider.notifier).resendCode();
    _startTimer();
  }

  void _verify() {
    if (_otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the full code')),
      );
      return;
    }
    ref.read(phoneAuthControllerProvider.notifier).verifyCode(_otp);
  }

  String get _formattedTime {
    final mins = _secondsRemaining ~/ 60;
    final secs = _secondsRemaining % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // ── Listen for auth state changes ─────────────────────────────
    ref.listen<PhoneAuthState>(phoneAuthControllerProvider, (prev, next) {
      if (next is PhoneAuthSuccess) {
        // Successfully verified — navigate to location permission flow.
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

    final authState = ref.watch(phoneAuthControllerProvider);
    final isVerifying = authState is PhoneAuthVerifying;

    return Scaffold(
      appBar: AppBar(title: const Text('Verify Phone')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 32),

                      // ── Icon ─────────────────────────────────────
                      Container(
                        width: 90,
                        height: 90,
                        decoration: const BoxDecoration(
                          color: AppColors.primarySoft,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Image.asset(
                          AssetConstants.appIcon,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Title ────────────────────────────────────
                      Text(
                        'Enter Verification Code',
                        style: AppTextStyles.headlineLarge.copyWith(
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // ── Subtitle ─────────────────────────────────
                      Text(
                        "We've sent a 6-digit code to",
                        style: AppTextStyles.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.phoneNumber,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // ── OTP boxes ────────────────────────────────
                      OtpInputField(
                        length: 6,
                        onCompleted: (code) {
                          _otp = code;
                          // Auto-verify as soon as all 6 digits are entered.
                          _verify();
                        },
                        onChanged: (code) => _otp = code,
                      ),
                      const SizedBox(height: 28),

                      // ── Resend section ───────────────────────────
                      Text(
                        "Didn't receive the code?",
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: _resendCode,
                            child: Text(
                              'Resend Code',
                              style: AppTextStyles.link.copyWith(
                                color:
                                    _secondsRemaining > 0
                                        ? AppColors.textTertiary
                                        : AppColors.primary,
                              ),
                            ),
                          ),
                          if (_secondsRemaining > 0) ...[
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _formattedTime,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── Verify button (pinned to bottom) ────────────────
              Padding(
                padding: const EdgeInsets.only(bottom: 24, top: 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isVerifying ? null : _verify,
                    child:
                        isVerifying
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.textWhite,
                              ),
                            )
                            : const Text('Verify'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
