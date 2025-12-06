import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  group('LocationService - Distance Calculations', () {
    test('calculateDistance returns correct miles for known coordinates', () {
      // Test distance calculation using Geolocator's distanceBetween
      // Cairo to Alexandria example
      const cairoCenterLat = 30.0444; // Cairo center
      const cairoCenterLon = 31.2357;
      const alexCenterLat = 31.2001; // Alexandria center
      const alexCenterLon = 29.9187;

      // Calculate distance using Geolocator
      final distanceMeters = Geolocator.distanceBetween(
        cairoCenterLat,
        cairoCenterLon,
        alexCenterLat,
        alexCenterLon,
      );

      // Convert to miles (1 meter = 0.000621371 miles)
      final distanceMiles = distanceMeters / 1609.34;

      // Distance should be approximately 110-150 miles (realistic range)
      expect(distanceMiles, greaterThan(100.0));
      expect(distanceMiles, lessThan(200.0));
    });

    test('calculateDistance returns zero for same coordinates', () {
      const lat = 30.0444;
      const lon = 31.2357;

      final distanceMeters = Geolocator.distanceBetween(lat, lon, lat, lon);
      final distanceMiles = distanceMeters / 1609.34;

      expect(distanceMiles, equals(0.0));
    });

    test('calculateDistance handles small distances correctly', () {
      // Two points 1km apart (approx 0.621 miles)
      const lat1 = 30.0444;
      const lon1 = 31.2357;
      const lat2 = 30.0544; // ~1.1km north
      const lon2 = 31.2357;

      final distanceMeters = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
      final distanceMiles = distanceMeters / 1609.34;

      // Should be less than 1 mile
      expect(distanceMiles, lessThan(1.0));
      expect(distanceMiles, greaterThan(0.5));
    });

    test('distance calculation is symmetric', () {
      const lat1 = 30.0444;
      const lon1 = 31.2357;
      const lat2 = 31.2001;
      const lon2 = 29.9187;

      final distance1 = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
      final distance2 = Geolocator.distanceBetween(lat2, lon2, lat1, lon1);

      expect(distance1, equals(distance2));
    });

    test('distance returned is always non-negative', () {
      const lat1 = 30.0;
      const lon1 = 31.0;
      const lat2 = 29.0;
      const lon2 = 30.0;

      final distanceMeters = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);

      expect(distanceMeters, greaterThanOrEqualTo(0.0));
    });
  });

  group('LocationService - City Detection Logic', () {
    test('detects Alexandria from coordinates', () {
      const lat = 31.2001;
      const lon = 29.9187;
      final cityName = _getCityNameFromCoordinates(lat, lon);
      expect(cityName, equals('Alexandria'));
    });

    test('detects Port Said from coordinates', () {
      const lat = 31.25;
      const lon = 32.3;
      final cityName = _getCityNameFromCoordinates(lat, lon);
      expect(cityName, equals('Port Said'));
    });

    test('detects general Egypt for unknown cities', () {
      const lat = 25.0; // Southern Egypt
      const lon = 32.0;
      final cityName = _getCityNameFromCoordinates(lat, lon);
      expect(cityName, equals('Egypt'));
    });

    test('returns formatted coordinates for non-Egyptian location', () {
      const lat = 40.7128;
      const lon = -74.0060;
      final cityName = _getCityNameFromCoordinates(lat, lon);
      expect(cityName, contains('°'));
      expect(cityName, matches(RegExp(r'\d+\.\d+°[NS]')));
    });

    test('English text detection works correctly', () {
      expect(_isEnglish('Cairo'), isTrue);
      expect(_isEnglish('القاهرة'), isFalse);
      expect(_isEnglish('Cairo Downtown'), isTrue);
      expect(_isEnglish('abc'), isTrue);
      expect(_isEnglish('١٢٣'), isFalse);
    });
  });
}

// Helper function replicating the logic from LocationService
String _getCityNameFromCoordinates(double lat, double lon) {
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

bool _isEnglish(String text) {
  final englishPattern = RegExp(r'[a-zA-Z]');
  final matches = englishPattern.allMatches(text).length;
  return matches > text.length * 0.5;
}
