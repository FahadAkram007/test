import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/partner.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';
import '../widgets/partner_card.dart';

/// Screen displaying partner merchants, distance-based radius filtering,
/// live GPS positioning, and opening hour statuses.
class PartnersScreen extends StatefulWidget {
  const PartnersScreen({super.key});

  @override
  State<PartnersScreen> createState() => _PartnersScreenState();
}

class _PartnersScreenState extends State<PartnersScreen> {
  final LocationService _locationService = LocationService();
  final TextEditingController _searchController = TextEditingController();

  Position? _userPosition;
  bool _isLoadingLocation = true;
  String? _locationStatusMessage;
  bool _hasRealGpsFix = false;

  // Filter state
  double _maxDistanceKm = 5.0; // Default 5 km radius
  bool _filterByRadius = true;
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Food & Dining',
    'Fitness',
    'Coffee & Cafe',
    'Education & Tech',
    'Commute',
  ];

  @override
  void initState() {
    super.initState();
    _initUserLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initUserLocation({bool promptSettingsIfBlocked = false}) async {
    setState(() {
      _isLoadingLocation = true;
      _locationStatusMessage = null;
    });

    final result = await _locationService.getCurrentLocation();

    if (!mounted) return;

    if (result.isSuccess && result.position != null) {
      setState(() {
        _userPosition = result.position;
        _isLoadingLocation = false;
        _hasRealGpsFix = true;
        _locationStatusMessage = null;
      });
    } else {
      // Use fallback default coordinate so user can still test distance sorting/filtering
      final fallbackPosition = Position(
        latitude: LocationService.defaultLatitude,
        longitude: LocationService.defaultLongitude,
        timestamp: DateTime.now(),
        accuracy: 100,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );

      setState(() {
        _userPosition = fallbackPosition;
        _isLoadingLocation = false;
        _hasRealGpsFix = false;
        _locationStatusMessage = result.userFriendlyMessage ??
            'Using default downtown coordinates for distance preview.';
      });

      if (promptSettingsIfBlocked && result.permissionDeniedForever) {
        await Geolocator.openAppSettings();
      }
    }
  }

  /// Calculates distances and applies radius, category, and search filters,
  /// then sorts strictly by nearest first.
  List<PartnerModel> get _filteredAndSortedPartners {
    final userLat = _userPosition?.latitude ?? LocationService.defaultLatitude;
    final userLng = _userPosition?.longitude ?? LocationService.defaultLongitude;

    // 1. Calculate distance for every partner from user position
    final partnersWithDistance = PartnerModel.samplePartners.map((p) {
      final distance = _locationService.calculateDistanceInKm(
        startLatitude: userLat,
        startLongitude: userLng,
        endLatitude: p.latitude,
        endLongitude: p.longitude,
      );
      return p.copyWithDistance(distance);
    }).toList();

    // 2. Filter by distance radius, category, and search text
    final query = _searchController.text.toLowerCase().trim();

    final filtered = partnersWithDistance.where((p) {
      // Radius filter
      if (_filterByRadius && p.distanceInKm != null && p.distanceInKm! > _maxDistanceKm) {
        return false;
      }

      // Category filter
      if (_selectedCategory != 'All' && p.category != _selectedCategory) {
        return false;
      }

      // Text search query
      if (query.isNotEmpty) {
        final matchesName = p.name.toLowerCase().contains(query);
        final matchesAddress = p.address.toLowerCase().contains(query);
        final matchesCat = p.category.toLowerCase().contains(query);
        if (!matchesName && !matchesAddress && !matchesCat) return false;
      }

      return true;
    }).toList();

    // 3. Sort by distance, nearest first
    filtered.sort((a, b) {
      final distA = a.distanceInKm ?? double.infinity;
      final distB = b.distanceInKm ?? double.infinity;
      return distA.compareTo(distB);
    });

    return filtered;
  }

  void _showLocationPermissionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_on_rounded,
                    color: Theme.of(ctx).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Why Location is Needed',
                    style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'PerkFlow uses your GPS location exclusively to display restaurants, cafes, and gym partners near your current location and calculate real walking/driving distances. Your location is never tracked or stored on our servers.',
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _initUserLocation(promptSettingsIfBlocked: true);
                    },
                    child: const Text('Allow Access'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final partners = _filteredAndSortedPartners;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Partner Locations'),
        actions: [
          IconButton(
            tooltip: 'GPS Accuracy & Permissions',
            icon: _isLoadingLocation
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: cs.primary,
                    ),
                  )
                : Icon(
                    _hasRealGpsFix ? Icons.my_location_rounded : Icons.location_searching_rounded,
                    color: _hasRealGpsFix ? cs.primary : cs.onSurfaceVariant,
                  ),
            onPressed: _isLoadingLocation ? null : () => _initUserLocation(),
          ),
          IconButton(
            tooltip: 'Location Info',
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => _showLocationPermissionSheet(context),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fallback / Permission Notice Banner if GPS is simulated or blocked
                  if (_locationStatusMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppTheme.warning.withValues(alpha: 0.1),
                        borderRadius: AppRadius.smRadius,
                        border: Border.all(
                          color: AppTheme.warning.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: AppTheme.warning, size: 20),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              _locationStatusMessage!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurface,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => _showLocationPermissionSheet(context),
                            child: const Text('Enable GPS'),
                          ),
                        ],
                      ),
                    ),

                  // 1. Distance Radius Filter Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.radar_rounded, color: cs.primary, size: 20),
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(
                                    'Distance Radius',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    _filterByRadius
                                        ? '< ${_maxDistanceKm.toStringAsFixed(1)} km'
                                        : 'Any Distance',
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: cs.primary,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Switch.adaptive(
                                    value: _filterByRadius,
                                    onChanged: (val) {
                                      setState(() => _filterByRadius = val);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (_filterByRadius) ...[
                            Slider(
                              value: _maxDistanceKm,
                              min: 0.5,
                              max: 10.0,
                              divisions: 19,
                              label: '${_maxDistanceKm.toStringAsFixed(1)} km',
                              onChanged: (val) {
                                setState(() => _maxDistanceKm = val);
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '0.5 km (Walking)',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                    fontSize: 11,
                                  ),
                                ),
                                Text(
                                  '10.0 km (Metro/Drive)',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // 2. Search Field
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search partners, cuisines or addresses...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // 3. Category Chips
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.xs),
                      itemBuilder: (context, i) {
                        final cat = _categories[i];
                        final isSelected = cat == _selectedCategory;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedCategory = cat);
                            }
                          },
                          labelStyle: TextStyle(
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? cs.onPrimary : cs.onSurface,
                          ),
                          selectedColor: cs.primary,
                          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: AppRadius.fullRadius),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // 4. Results Header with sorting indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Nearby Partner Venues',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.sort_rounded, size: 14, color: cs.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            'Nearest First (${partners.length})',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 5. Partners List
          if (partners.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.location_off_rounded, size: 48, color: cs.outline),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'No partners within ${_maxDistanceKm.toStringAsFixed(1)} km',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        'Try expanding the distance slider or choosing another category.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      FilledButton.tonal(
                        onPressed: () {
                          setState(() {
                            _maxDistanceKm = 10.0;
                            _selectedCategory = 'All';
                            _searchController.clear();
                          });
                        },
                        child: const Text('Reset Radius & Filters'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final partner = partners[index];
                    return PartnerCard(
                      partner: partner,
                      index: index,
                    );
                  },
                  childCount: partners.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.xxxl),
          ),
        ],
      ),
    );
  }
}
