import 'package:geolocator/geolocator.dart';

/// Result wrapper for location queries providing user-friendly status information
class LocationResult {
  final Position? position;
  final bool isSuccess;
  final String? userFriendlyMessage;
  final bool permissionDeniedForever;

  const LocationResult({
    this.position,
    required this.isSuccess,
    this.userFriendlyMessage,
    this.permissionDeniedForever = false,
  });
}

/// Service handling device GPS positioning, permission lifecycles, and distance calculations.
class LocationService {
  /// Default fallback coordinate (01968 Senftenberg, Germany)
  /// Used if permission is denied so the user can still preview partner listings.
  static const double defaultLatitude = 51.5195;
  static const double defaultLongitude = 14.0048;

  /// Requests location access and fetches the current device coordinates.
  ///
  /// Handles disabled location services, runtime permission denials, and
  /// permanent denials with descriptive, user-friendly feedback.
  Future<LocationResult> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Verify if device GPS/location service is toggled on
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const LocationResult(
        isSuccess: false,
        userFriendlyMessage:
            'Location services are disabled on your device. Please enable GPS in system settings.',
      );
    }

    // 2. Inspect current application permission status
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Prompt user for permission with system dialog
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return const LocationResult(
          isSuccess: false,
          userFriendlyMessage:
              'Location permission was declined. Partner distances are currently estimated from the city center.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return const LocationResult(
        isSuccess: false,
        permissionDeniedForever: true,
        userFriendlyMessage:
            'Location access is permanently blocked. Enable it in App Settings to see real-time walking distances.',
      );
    }

    // 3. Acquire current high-accuracy coordinates
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );
      return LocationResult(
        position: position,
        isSuccess: true,
      );
    } catch (e) {
      // Fallback: try last known position if current fix timed out
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        return LocationResult(
          position: lastKnown,
          isSuccess: true,
        );
      }
      return LocationResult(
        isSuccess: false,
        userFriendlyMessage: 'Could not acquire GPS fix: ${e.toString()}',
      );
    }
  }

  /// Calculates geodesic distance between two coordinates in kilometers.
  double calculateDistanceInKm({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    final distanceInMeters = Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
    return distanceInMeters / 1000.0;
  }
}
