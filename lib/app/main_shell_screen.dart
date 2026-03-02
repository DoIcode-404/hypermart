/// Main bottom-navigation shell — wraps Home, Cart, Orders, Profile.
/// Features a curved floating bottom nav bar with subtle tap animations.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';
import '../features/cart/presentation/providers/cart_providers.dart';

class MainShellScreen extends StatelessWidget {
  const MainShellScreen({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      extendBody: true,
      bottomNavigationBar: _CurvedBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
      ),
    );
  }

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Curved Bottom Nav
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _CurvedBottomNav extends ConsumerWidget {
  const _CurvedBottomNav({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    _NavItemData(Icons.home_outlined, Icons.home, 'Home'),
    _NavItemData(Icons.shopping_cart_outlined, Icons.shopping_cart, 'Cart'),
    _NavItemData(Icons.receipt_long_outlined, Icons.receipt_long, 'Orders'),
    _NavItemData(Icons.person_outline, Icons.person, 'Profile'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final cartCount = ref.watch(cartItemCountProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, math.max(bottomPadding, 12)),
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              return _AnimatedNavItem(
                data: _items[i],
                isSelected: currentIndex == i,
                onTap: () => onTap(i),
                badgeCount: i == 1 ? cartCount : 0,
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _NavItemData {
  const _NavItemData(this.icon, this.activeIcon, this.label);
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedNavItem extends StatefulWidget {
  const _AnimatedNavItem({
    required this.data,
    required this.isSelected,
    required this.onTap,
    this.badgeCount = 0,
  });

  final _NavItemData data;
  final bool isSelected;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  State<_AnimatedNavItem> createState() => _AnimatedNavItemState();
}

class _AnimatedNavItemState extends State<_AnimatedNavItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _slideAnim = Tween<double>(
      begin: 0.0,
      end: -3.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    if (widget.isSelected) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _AnimatedNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _controller.forward(from: 0);
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: SizedBox(
        width: 72,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _slideAnim.value),
              child: Transform.scale(scale: _scaleAnim.value, child: child),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder:
                        (child, anim) =>
                            FadeTransition(opacity: anim, child: child),
                    child: Icon(
                      widget.isSelected
                          ? widget.data.activeIcon
                          : widget.data.icon,
                      key: ValueKey(widget.isSelected),
                      color:
                          widget.isSelected
                              ? AppColors.primary
                              : AppColors.textTertiary,
                      size: 24,
                    ),
                  ),
                  if (widget.badgeCount > 0)
                    Positioned(
                      top: -4,
                      right: -6,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          widget.badgeCount > 99
                              ? '99+'
                              : '${widget.badgeCount}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                  color:
                      widget.isSelected
                          ? AppColors.primary
                          : AppColors.textTertiary,
                ),
                child: Text(widget.data.label),
              ),
              // Active indicator dot.
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                margin: const EdgeInsets.only(top: 4),
                width: widget.isSelected ? 6 : 0,
                height: widget.isSelected ? 6 : 0,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
