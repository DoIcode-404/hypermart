/// App color palette — brand colors, surface, on-surface, semantic colors.
library;

import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Brand ──────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFFE8622E); // Orange CTA / accents
  static const Color primaryLight = Color(0xFFFFF0E9); // Light orange tint
  static const Color primarySoft = Color(0xFFFADDD0); // Peach circle bg

  // ── Neutral ────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1D26); // Headlines / dark text
  static const Color textSecondary = Color(0xFF6B7280); // Body / subtitle gray
  static const Color textTertiary = Color(0xFF9CA3AF); // Hints / captions
  static const Color textWhite = Color(0xFFFFFFFF);

  // ── Surface ────────────────────────────────────────────────────────────
  static const Color scaffoldBg = Color(0xFFFAF8F5); // Warm off-white bg
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF5F0EB); // Card / illustration bg

  // ── Indicator ──────────────────────────────────────────────────────────
  static const Color dotActive = primary;
  static const Color dotInactive = Color(0xFFE8D8D0); // Muted peach dots

  // ── Progress bar ───────────────────────────────────────────────────────
  static const Color progressTrack = Color(0xFFD9D9D9);
  static const Color progressFill = primary;

  // ── Semantic ───────────────────────────────────────────────────────────
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF16A34A);
}
