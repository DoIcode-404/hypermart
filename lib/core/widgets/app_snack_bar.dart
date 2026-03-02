/// AppSnackBar — branded floating snackbar with icon, label and type variants.
library;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Types
// ─────────────────────────────────────────────────────────────────────────────

enum SnackBarType { success, error, wishlistAdd, wishlistRemove, info }

// ─────────────────────────────────────────────────────────────────────────────
// AppSnackBar
// ─────────────────────────────────────────────────────────────────────────────

abstract final class AppSnackBar {
  /// Show a branded floating snackbar.
  ///
  /// [type] controls the icon and accent colour.
  /// [action] is an optional label + callback shown on the trailing end.
  static void show(
    BuildContext context,
    String message, {
    SnackBarType type = SnackBarType.success,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 2),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: _SnackBarContent(
          message: message,
          type: type,
          actionLabel: actionLabel,
          onAction: onAction,
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Sits just above the curved bottom nav (68 nav + 12 min padding + 16 outer = 96).
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 96),
        duration: duration,
        // Remove the default padding so our widget controls all spacing.
        padding: EdgeInsets.zero,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private content widget
// ─────────────────────────────────────────────────────────────────────────────

class _SnackBarContent extends StatelessWidget {
  const _SnackBarContent({
    required this.message,
    required this.type,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final SnackBarType type;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final cfg = _SnackConfig.of(type);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Coloured accent bar ───────────────────────────────────────
          Container(
            width: 5,
            height: 56,
            decoration: BoxDecoration(
              color: cfg.accentColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // ── Icon ─────────────────────────────────────────────────────
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: cfg.accentColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(cfg.icon, color: cfg.accentColor, size: 18),
          ),

          const SizedBox(width: 12),

          // ── Message ───────────────────────────────────────────────────
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // ── Optional action ───────────────────────────────────────────
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onAction,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  actionLabel!,
                  style: TextStyle(
                    color: cfg.accentColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ] else
            const SizedBox(width: 16),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Config per type
// ─────────────────────────────────────────────────────────────────────────────

class _SnackConfig {
  const _SnackConfig({required this.icon, required this.accentColor});

  final IconData icon;
  final Color accentColor;

  static _SnackConfig of(SnackBarType type) => switch (type) {
    SnackBarType.success => const _SnackConfig(
      icon: Icons.check_circle_rounded,
      accentColor: Color(0xFF22C55E), // green
    ),
    SnackBarType.error => const _SnackConfig(
      icon: Icons.cancel_rounded,
      accentColor: AppColors.error, // red
    ),
    SnackBarType.wishlistAdd => const _SnackConfig(
      icon: Icons.favorite_rounded,
      accentColor: Color(0xFFEC4899), // pink
    ),
    SnackBarType.wishlistRemove => const _SnackConfig(
      icon: Icons.heart_broken_rounded,
      accentColor: Color(0xFF9CA3AF), // grey
    ),
    SnackBarType.info => const _SnackConfig(
      icon: Icons.info_rounded,
      accentColor: Color(0xFF3B82F6), // blue
    ),
  };
}
