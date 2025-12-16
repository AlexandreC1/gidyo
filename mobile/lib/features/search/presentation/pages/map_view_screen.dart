import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/guide_entity.dart';
import '../providers/search_providers.dart';
import '../widgets/guide_card.dart';

class MapViewScreen extends ConsumerStatefulWidget {
  const MapViewScreen({super.key});

  @override
  ConsumerState<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends ConsumerState<MapViewScreen> {
  GoogleMapController? _mapController;
  GuideEntity? _selectedGuide;
  final Set<Marker> _markers = {};

  // Default location: Port-au-Prince, Haiti
  static const _defaultLocation = LatLng(18.5944, -72.3074);

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider);

    return searchResults.when(
      data: (guides) {
        // Update markers when guides change
        _updateMarkers(guides);

        return Stack(
          children: [
            // Google Map
            GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: _defaultLocation,
                zoom: 12,
              ),
              markers: _markers,
              onMapCreated: (controller) {
                _mapController = controller;
                _fitMarkersInView(guides);
              },
              onCameraMove: (position) {
                // Optional: Re-search when map moves
                // _onMapMove(position);
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
            ),

            // Selected Guide Card
            if (_selectedGuide != null)
              Positioned(
                bottom: AppDimensions.paddingL,
                left: AppDimensions.paddingM,
                right: AppDimensions.paddingM,
                child: _GuideInfoCard(
                  guide: _selectedGuide!,
                  onClose: () {
                    setState(() {
                      _selectedGuide = null;
                    });
                  },
                  onViewProfile: () {
                    // Navigate to guide profile
                  },
                ),
              ),

            // Loading Indicator
            if (guides.isEmpty)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.error,
            ),
            const SizedBox(height: AppDimensions.paddingL),
            Text(
              'Error loading map',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppDimensions.paddingM),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(searchResultsProvider);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateMarkers(List<GuideEntity> guides) {
    _markers.clear();

    for (final guide in guides) {
      if (guide.latitude != null && guide.longitude != null) {
        _markers.add(
          Marker(
            markerId: MarkerId(guide.id),
            position: LatLng(guide.latitude!, guide.longitude!),
            infoWindow: InfoWindow(
              title: guide.fullName,
              snippet: guide.services.isNotEmpty
                  ? '\$${guide.services.first.price.toInt()}/day'
                  : null,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              guide.isVerified
                  ? BitmapDescriptor.hueGreen
                  : BitmapDescriptor.hueRed,
            ),
            onTap: () {
              setState(() {
                _selectedGuide = guide;
              });
              _animateToGuide(guide);
            },
          ),
        );
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _fitMarkersInView(List<GuideEntity> guides) {
    if (guides.isEmpty || _mapController == null) return;

    final validGuides = guides.where((g) => g.latitude != null && g.longitude != null).toList();

    if (validGuides.isEmpty) return;

    if (validGuides.length == 1) {
      // Center on single guide
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(validGuides.first.latitude!, validGuides.first.longitude!),
        ),
      );
      return;
    }

    // Calculate bounds
    double minLat = validGuides.first.latitude!;
    double maxLat = validGuides.first.latitude!;
    double minLng = validGuides.first.longitude!;
    double maxLng = validGuides.first.longitude!;

    for (final guide in validGuides) {
      if (guide.latitude! < minLat) minLat = guide.latitude!;
      if (guide.latitude! > maxLat) maxLat = guide.latitude!;
      if (guide.longitude! < minLng) minLng = guide.longitude!;
      if (guide.longitude! > maxLng) maxLng = guide.longitude!;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50),
    );
  }

  void _animateToGuide(GuideEntity guide) {
    if (_mapController == null) return;
    if (guide.latitude == null || guide.longitude == null) return;

    _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(guide.latitude!, guide.longitude!),
        15,
      ),
    );
  }

  // Optional: Re-search when map moves
  void _onMapMove(CameraPosition position) {
    // You can implement logic to update search params based on map position
    // and trigger a new search when the user moves the map
  }
}

class _GuideInfoCard extends StatelessWidget {
  final GuideEntity guide;
  final VoidCallback onClose;
  final VoidCallback onViewProfile;

  const _GuideInfoCard({
    required this.guide,
    required this.onClose,
    required this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mini Guide Card
            GuideCard(
              guide: guide,
              isCompact: true,
              onTap: onViewProfile,
            ),

            const SizedBox(height: AppDimensions.paddingM),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onClose,
                    child: const Text('Close'),
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingM),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onViewProfile,
                    child: const Text('View Profile'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
