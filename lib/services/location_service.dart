import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// handling location permissions and calculating distances
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Position? _currentPosition;
  bool _isLocationEnabled = false;
  String? _currentCityName;
  String? _currentCountryName;

  /// Get the current position of the device,Returns null if location services are disabled or permissions are denied
  Future<Position?> getCurrentPosition() async {
    try {
      debugPrint('📍 LocationService: Checking location services...');

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('❌ LocationService: Location services are disabled');
        _isLocationEnabled = false;
        return null;
      }
      debugPrint('✅ LocationService: Location services are enabled');

      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('📍 LocationService: Current permission status: $permission');

      if (permission == LocationPermission.denied) {
        debugPrint('📍 LocationService: Requesting permission...');
        permission = await Geolocator.requestPermission();
        debugPrint('📍 LocationService: Permission after request: $permission');

        if (permission == LocationPermission.denied) {
          debugPrint('❌ LocationService: Permission denied by user');
          _isLocationEnabled = false;
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('❌ LocationService: Permission permanently denied');
        _isLocationEnabled = false;
        return null;
      }

      debugPrint('📍 LocationService: Getting current position...');
      LocationSettings locationSettings = _getLocationSettings();

      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      _isLocationEnabled = true;
      debugPrint(
        '✅ LocationService: Got position: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}',
      );
      debugPrint('✅ LocationService: Accuracy: ${_currentPosition!.accuracy}m');

      // Get city name from coordinates with English fallback
      await _getCityNameFromCoordinatesAsync(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      return _currentPosition;
    } catch (e) {
      debugPrint('❌ LocationService: Error getting location: $e');
      _isLocationEnabled = false;
      return null;
    }
  }

  LocationSettings _getLocationSettings() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
        forceLocationManager: true,
        intervalDuration: const Duration(seconds: 10),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: 100,
        pauseLocationUpdatesAutomatically: true,
        showBackgroundLocationIndicator: false,
      );
    } else if (kIsWeb) {
      return WebSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
        maximumAge: const Duration(minutes: 5),
      );
    } else {
      return const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );
    }
  }

  /// Calculate distance between two coordinates using Haversine formula
  /// Returns distance in miles
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) /
        1609.34; // Convert meters to miles
  }

  /// Calculate distance from current position to a restaurant
  double? getDistanceToRestaurant(double restaurantLat, double restaurantLon) {
    if (_currentPosition == null) {
      debugPrint(
        '⚠️ LocationService: Cannot calculate distance - no current position',
      );
      return null;
    }

    final distance = calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      restaurantLat,
      restaurantLon,
    );

    debugPrint(
      '📏 LocationService: Distance to restaurant at ($restaurantLat, $restaurantLon): ${distance.toStringAsFixed(2)} mi',
    );
    return distance;
  }

  bool get isLocationEnabled => _isLocationEnabled;

  Position? get currentPosition => _currentPosition;

  String? get currentCityName => _currentCityName;

  String? get currentCountryName => _currentCountryName;

  /// Get English city name from coordinates (fallback for Arabic/failed geocoding)
  String _getCityNameFromCoordinates(double lat, double lon) {
    // Egyptian cities with their coordinate ranges
    // Port Said area
    if (lat >= 31.2 && lat <= 31.3 && lon >= 32.2 && lon <= 32.4) {
      return 'Port Said';
    }
    // Alexandria area
    if (lat >= 31.1 && lat <= 31.3 && lon >= 29.8 && lon <= 30.0) {
      return 'Alexandria';
    }
    // Giza area (including Pyramids)
    if (lat >= 29.9 && lat <= 30.1 && lon >= 31.0 && lon <= 31.3) {
      return 'Giza';
    }
    // New Cairo / 5th Settlement
    if (lat >= 30.0 && lat <= 30.1 && lon >= 31.3 && lon <= 31.5) {
      return 'New Cairo';
    }
    // Heliopolis
    if (lat >= 30.05 && lat <= 30.12 && lon >= 31.25 && lon <= 31.35) {
      return 'Heliopolis';
    }
    // Nasr City
    if (lat >= 30.04 && lat <= 30.08 && lon >= 31.32 && lon <= 31.38) {
      return 'Nasr City';
    }
    // Maadi
    if (lat >= 29.94 && lat <= 29.98 && lon >= 31.23 && lon <= 31.27) {
      return 'Maadi';
    }
    // Downtown Cairo
    if (lat >= 30.03 && lat <= 30.06 && lon >= 31.22 && lon <= 31.26) {
      return 'Downtown Cairo';
    }
    // 6th of October City
    if (lat >= 29.9 && lat <= 30.0 && lon >= 30.9 && lon <= 31.0) {
      return '6th of October';
    }
    // General Cairo area (fallback)
    if (lat >= 29.9 && lat <= 30.2 && lon >= 31.0 && lon <= 31.5) {
      return 'Cairo';
    }
    // Egypt general area
    if (lat >= 22.0 && lat <= 32.0 && lon >= 25.0 && lon <= 35.0) {
      return 'Egypt';
    }

    // Outside Egypt - return coordinates
    return '${lat.toStringAsFixed(2)}°N, ${lon.toStringAsFixed(2)}°E';
  }

  /// Get city name from coordinates using reverse geocoding with English fallback
  Future<void> _getCityNameFromCoordinatesAsync(double lat, double lon) async {
    try {
      debugPrint('🏙️ LocationService: Getting city name for coordinates...');

      // First, set fallback city name based on coordinates (always in English)
      final fallbackCity = _getCityNameFromCoordinates(lat, lon);
      _currentCityName = fallbackCity;
      _currentCountryName = 'Egypt';

      debugPrint('✅ LocationService: Fallback city: $fallbackCity');

      // Try to get more accurate name from geocoding (might be in Arabic)
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          lat,
          lon,
        ).timeout(const Duration(seconds: 3));

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;

          // Get city name from geocoding
          final geocodedCity =
              place.locality ??
              place.subAdministrativeArea ??
              place.administrativeArea;

          // Only use geocoded name if it's in English (has ASCII characters)
          if (geocodedCity != null && _isEnglish(geocodedCity)) {
            _currentCityName = geocodedCity;
            debugPrint('✅ LocationService: Using geocoded name: $geocodedCity');
          } else {
            debugPrint(
              '⚠️ LocationService: Geocoded name not English, using fallback',
            );
          }

          _currentCountryName = place.country ?? 'Egypt';

          // Safe debug print with null checks
          final street = place.street ?? 'N/A';
          final locality = place.locality ?? 'N/A';
          final admin = place.administrativeArea ?? 'N/A';
          debugPrint('   Full address: $street, $locality, $admin');
        }
      } catch (e) {
        debugPrint('⚠️ LocationService: Geocoding timeout/error: $e');
        debugPrint('   Using fallback city name: $fallbackCity');
      }

      debugPrint(
        '✅ LocationService: Final location: $_currentCityName, $_currentCountryName',
      );
    } catch (e, stackTrace) {
      debugPrint('❌ LocationService: Error getting city name: $e');
      debugPrint('   Stack trace: $stackTrace');

      // Even on error, try to set fallback
      _currentCityName = _getCityNameFromCoordinates(lat, lon);
      _currentCountryName = 'Egypt';
    }
  }

  /// Check if string contains primarily English characters
  bool _isEnglish(String text) {
    // Check if string has more ASCII letters than Arabic/other characters
    final englishPattern = RegExp(r'[a-zA-Z]');
    final matches = englishPattern.allMatches(text).length;
    return matches > text.length * 0.5; // More than 50% English letters
  }

  Future<bool> checkLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }
}
