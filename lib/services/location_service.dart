import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_android/geolocator_android.dart';
import 'package:geolocator_apple/geolocator_apple.dart';
import 'package:geolocator_web/geolocator_web.dart';

/// handling location permissions and calculating distances
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Position? _currentPosition;
  bool _isLocationEnabled = false;

  /// Get the current position of the device,Returns null if location services are disabled or permissions are denied
  Future<Position?> getCurrentPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _isLocationEnabled = false;
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _isLocationEnabled = false;
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _isLocationEnabled = false;
        return null;
      }

      
      LocationSettings locationSettings = _getLocationSettings();

      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
      _isLocationEnabled = true;
      return _currentPosition;
    } catch (e) {
      debugPrint('Error getting location: $e');
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
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1609.34; // Convert meters to miles
  }

  /// Calculate distance from current position to a restaurant
  double? getDistanceToRestaurant(double restaurantLat, double restaurantLon) {
    if (_currentPosition == null) {
      return null;
    }
    return calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      restaurantLat,
      restaurantLon,
    );
  }

  bool get isLocationEnabled => _isLocationEnabled;

  Position? get currentPosition => _currentPosition;

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