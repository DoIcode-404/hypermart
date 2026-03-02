/// Confirm delivery location screen — interactive map picker with search,
/// reverse geocoding, and bottom sheet address confirmation.
/// Map is bounded to Nepal only.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/delivery_location.dart';
import '../controllers/location_controller.dart';
import '../providers/location_providers.dart';

class ConfirmLocationScreen extends ConsumerStatefulWidget {
  const ConfirmLocationScreen({this.useGps = false, super.key});

  /// If `true`, attempt to center on GPS position on init.
  final bool useGps;

  @override
  ConsumerState<ConfirmLocationScreen> createState() =>
      _ConfirmLocationScreenState();
}

class _ConfirmLocationScreenState extends ConsumerState<ConfirmLocationScreen> {
  final _mapController = MapController();
  final _searchController = TextEditingController();
  final _additionalInfoController = TextEditingController();
  final _searchFocus = FocusNode();

  Timer? _debounce;
  bool _isGeocodingPin = false;

  /// Current pin location (map center).
  LatLng _pinLocation = const LatLng(
    DeliveryLocation.defaultLat,
    DeliveryLocation.defaultLng,
  );

  /// Current resolved address for the pin.
  DeliveryLocation _currentAddress = DeliveryLocation.kathmandu;

  /// Nepal bounds for constraining the camera.
  static final _nepalBounds = LatLngBounds(
    const LatLng(DeliveryLocation.nepalMinLat, DeliveryLocation.nepalMinLng),
    const LatLng(DeliveryLocation.nepalMaxLat, DeliveryLocation.nepalMaxLng),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initLocation());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _additionalInfoController.dispose();
    _searchFocus.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    final controller = ref.read(locationControllerProvider.notifier);

    if (widget.useGps) {
      final location = await controller.getCurrentLocationWithAddress();
      if (!mounted) return;

      // Clamp to Nepal bounds.
      final lat = location.latitude.clamp(
        DeliveryLocation.nepalMinLat,
        DeliveryLocation.nepalMaxLat,
      );
      final lng = location.longitude.clamp(
        DeliveryLocation.nepalMinLng,
        DeliveryLocation.nepalMaxLng,
      );

      setState(() {
        _pinLocation = LatLng(lat, lng);
        _currentAddress = location.copyWith(latitude: lat, longitude: lng);
      });

      _mapController.move(_pinLocation, 15);
    }
  }

  /// Called when the map stops moving — reverse geocode the center.
  void _onMapPositionChanged(MapCamera camera, bool hasGesture) {
    if (!hasGesture) return;

    final center = camera.center;

    // Clamp to Nepal.
    if (center.latitude < DeliveryLocation.nepalMinLat ||
        center.latitude > DeliveryLocation.nepalMaxLat ||
        center.longitude < DeliveryLocation.nepalMinLng ||
        center.longitude > DeliveryLocation.nepalMaxLng) {
      return;
    }

    setState(() => _pinLocation = center);

    // Debounce reverse geocoding.
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _reverseGeocodePin(center.latitude, center.longitude);
    });
  }

  Future<void> _reverseGeocodePin(double lat, double lng) async {
    if (!mounted) return;
    setState(() => _isGeocodingPin = true);

    final controller = ref.read(locationControllerProvider.notifier);
    final location = await controller.reverseGeocode(lat, lng);

    if (mounted) {
      setState(() {
        _currentAddress = location;
        _isGeocodingPin = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(locationControllerProvider.notifier).searchPlaces(query);
    });
  }

  void _selectSearchResult(DeliveryLocation location) {
    _searchController.clear();
    _searchFocus.unfocus();
    ref.read(locationControllerProvider.notifier).clearSearch();

    final lat = location.latitude.clamp(
      DeliveryLocation.nepalMinLat,
      DeliveryLocation.nepalMaxLat,
    );
    final lng = location.longitude.clamp(
      DeliveryLocation.nepalMinLng,
      DeliveryLocation.nepalMaxLng,
    );

    setState(() {
      _pinLocation = LatLng(lat, lng);
      _currentAddress = location.copyWith(latitude: lat, longitude: lng);
    });

    _mapController.move(_pinLocation, 16);
  }

  Future<void> _confirmLocation() async {
    final finalLocation = _currentAddress.copyWith(
      additionalInfo: _additionalInfoController.text.trim(),
    );

    final controller = ref.read(locationControllerProvider.notifier);
    await controller.confirmLocation(finalLocation);

    if (!mounted) return;

    // Invalidate the saved location provider so home screen picks it up.
    ref.invalidate(savedDeliveryLocationProvider);

    context.goNamed(RouteNames.home);
  }

  void _goToCurrentLocation() async {
    final controller = ref.read(locationControllerProvider.notifier);
    final location = await controller.getCurrentLocationWithAddress();
    if (!mounted) return;

    final lat = location.latitude.clamp(
      DeliveryLocation.nepalMinLat,
      DeliveryLocation.nepalMaxLat,
    );
    final lng = location.longitude.clamp(
      DeliveryLocation.nepalMinLng,
      DeliveryLocation.nepalMaxLng,
    );

    setState(() {
      _pinLocation = LatLng(lat, lng);
      _currentAddress = location.copyWith(latitude: lat, longitude: lng);
    });

    _mapController.move(_pinLocation, 16);
  }

  @override
  Widget build(BuildContext context) {
    final locState = ref.watch(locationControllerProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ── Map ────────────────────────────────────────────
          _buildMap(),

          // ── Center pin (fixed overlay) ─────────────────────
          _buildCenterPin(),

          // ── Top bar (back + title + search) ────────────────
          _buildTopBar(locState),

          // ── Zoom controls ──────────────────────────────────
          _buildZoomControls(),

          // ── Bottom address sheet ───────────────────────────
          _buildBottomSheet(locState),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _pinLocation,
        initialZoom: 13,
        minZoom: 7,
        maxZoom: 18,
        // Constrain camera to Nepal.
        cameraConstraint: CameraConstraint.contain(bounds: _nepalBounds),
        onPositionChanged: _onMapPositionChanged,
        onMapReady: () {},
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.hypermart',
        ),
      ],
    );
  }

  /// Fixed orange pin in the center of the map.
  Widget _buildCenterPin() {
    return Center(
      // Offset the pin slightly up so the tip points to the center.
      child: Padding(
        padding: const EdgeInsets.only(bottom: 48),
        child:
            _isGeocodingPin
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primary,
                  ),
                )
                : const Icon(
                  Icons.location_on,
                  size: 48,
                  color: AppColors.primary,
                ),
      ),
    );
  }

  Widget _buildTopBar(LocationControllerState locState) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        color: AppColors.primary.withValues(alpha: 0.95),
        child: SafeArea(
          bottom: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Title bar ──────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.textWhite,
                      ),
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: Text(
                        'Confirm Delivery Location',
                        style: AppTextStyles.buttonLarge.copyWith(fontSize: 17),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Search bar ─────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search for area, street, or landmark',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.primary,
                      ),
                      suffixIcon:
                          _searchController.text.isNotEmpty
                              ? IconButton(
                                icon: const Icon(Icons.close, size: 20),
                                onPressed: () {
                                  _searchController.clear();
                                  ref
                                      .read(locationControllerProvider.notifier)
                                      .clearSearch();
                                  setState(() {});
                                },
                              )
                              : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),

              // ── Search results dropdown ─────────────
              if (locState.searchResults.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: locState.searchResults.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final result = locState.searchResults[index];
                      return ListTile(
                        dense: true,
                        leading: const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        title: Text(
                          result.areaName,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          result.fullAddress,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textTertiary,
                            letterSpacing: 0,
                          ),
                        ),
                        onTap: () => _selectSearchResult(result),
                      );
                    },
                  ),
                ),

              if (locState.isSearching)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildZoomControls() {
    return Positioned(
      right: 16,
      bottom: 290,
      child: Column(
        children: [
          _zoomButton(Icons.add, () {
            final zoom = _mapController.camera.zoom + 1;
            _mapController.move(
              _mapController.camera.center,
              zoom.clamp(7, 18),
            );
          }),
          const SizedBox(height: 8),
          _zoomButton(Icons.remove, () {
            final zoom = _mapController.camera.zoom - 1;
            _mapController.move(
              _mapController.camera.center,
              zoom.clamp(7, 18),
            );
          }),
        ],
      ),
    );
  }

  Widget _zoomButton(IconData icon, VoidCallback onPressed) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(8),
      color: AppColors.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: AppColors.textPrimary),
        ),
      ),
    );
  }

  Widget _buildBottomSheet(LocationControllerState locState) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Drag handle ──────────────────────────
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // ── Address row ──────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Orange location icon.
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Area name + full address.
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isGeocodingPin
                              ? 'Loading…'
                              : _currentAddress.areaName,
                          style: AppTextStyles.headlineMedium.copyWith(
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isGeocodingPin
                              ? 'Fetching address…'
                              : _currentAddress.fullAddress,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),

                  // "Change" button — scrolls to current GPS.
                  TextButton(
                    onPressed: _goToCurrentLocation,
                    child: Text(
                      'Change',
                      style: AppTextStyles.link.copyWith(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Additional info field ────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.scaffoldBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _additionalInfoController,
                  decoration: InputDecoration(
                    hintText: 'Add house number, floor, or landmark',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    prefixIcon: Icon(
                      Icons.info_outline,
                      color: AppColors.textTertiary.withValues(alpha: 0.6),
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Confirm button ───────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isGeocodingPin ? null : _confirmLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Confirm Location',
                        style: AppTextStyles.buttonLarge,
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward,
                        color: AppColors.textWhite,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
