/// Location permission screen — asks user to enable location access.
/// Matches the "Enable Location" design with map preview, description,
/// and Allow / Not Now actions.
library;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/delivery_location.dart';
import '../providers/location_providers.dart';

class LocationPermissionScreen extends ConsumerStatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  ConsumerState<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState
    extends ConsumerState<LocationPermissionScreen> {
  bool _isRequesting = false;

  Future<void> _requestPermission() async {
    setState(() => _isRequesting = true);
    final controller = ref.read(locationControllerProvider.notifier);
    final granted = await controller.requestPermission();
    if (!mounted) return;
    setState(() => _isRequesting = false);

    if (granted) {
      // Permission granted → go to map picker with GPS location.
      context.goNamed(RouteNames.confirmLocation, extra: true);
    } else {
      // Show a message but still allow them to proceed.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permission denied. You can still pick a location on the map.',
            ),
          ),
        );
      }
    }
  }

  void _skipPermission() {
    // Go to map picker without GPS — will center on Kathmandu default.
    context.goNamed(RouteNames.confirmLocation, extra: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Location Access',
          style: AppTextStyles.headlineMedium.copyWith(fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 24),

                      // ── Map preview ────────────────────────────
                      _buildMapPreview(),

                      const SizedBox(height: 28),

                      // ── Title ──────────────────────────────────
                      Text(
                        'Enable Location',
                        style: AppTextStyles.headlineLarge.copyWith(
                          fontSize: 26,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      // ── Description ────────────────────────────
                      Text(
                        'To ensure fast delivery and accurate tracking of your '
                        'orders, HyperMart needs access to your location. This '
                        'helps us find the nearest store to you.',
                        style: AppTextStyles.bodyLarge,
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // ── CTA buttons ──────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isRequesting ? null : _requestPermission,
                  icon:
                      _isRequesting
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.textWhite,
                            ),
                          )
                          : const Icon(
                            Icons.near_me,
                            color: AppColors.textWhite,
                          ),
                  label: Text(
                    'Allow Location Access',
                    style: AppTextStyles.buttonLarge,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: _skipPermission,
                child: Text(
                  'Not Now',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'You can change your location preferences anytime in the app settings.',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                  letterSpacing: 0,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Static map preview showing Kathmandu area with rounded corners
  /// and an orange pin icon overlapping bottom-right.
  Widget _buildMapPreview() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Map tile preview.
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 280,
            width: double.infinity,
            child: IgnorePointer(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: const LatLng(
                    DeliveryLocation.defaultLat,
                    DeliveryLocation.defaultLng,
                  ),
                  initialZoom: 11,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.hypermart',
                  ),
                ],
              ),
            ),
          ),
        ),

        // Orange pin icon — overlapping bottom-right.
        Positioned(
          bottom: -20,
          right: 16,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.location_on,
              color: AppColors.textWhite,
              size: 30,
            ),
          ),
        ),
      ],
    );
  }
}
