import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  // Get the current position
  static Future<Position?> getCurrentPosition(BuildContext? context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied
      return null;
    }

    // When we reach here, permissions are granted and we can get the position
    return await Geolocator.getCurrentPosition();
  }

  // Get the current position without requiring BuildContext
  static Future<Position?> getCurrentPositionWithoutContext() async {
    return await getCurrentPosition(null);
  }

  // Get the country code from coordinates
  static Future<String?> getCountryFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isNotEmpty) {
        final countryCode = placemarks.first.isoCountryCode;
        return _mapCountryCodeToSupportedCountry(countryCode);
      }
    } catch (e) {
      debugPrint('Error getting country from coordinates: $e');
    }
    return null;
  }

  // Map any country code to our supported countries
  static String _mapCountryCodeToSupportedCountry(String? countryCode) {
    if (countryCode == null) return 'TN'; // Default to Tunisia

    switch (countryCode) {
      case 'TN':
        return 'TN'; // Tunisia
      case 'US':
        return 'US'; // United States
      case 'FR':
        return 'FR'; // France
      case 'ES':
        return 'ES'; // Spain
      case 'DE':
        return 'DE'; // Germany
      case 'IT':
        return 'IT'; // Italy
      case 'DZ':
        return 'DZ'; // Algeria
      case 'MA':
        return 'MA'; // Morocco
      case 'EG':
        return 'EG'; // Egypt
      case 'SA':
        return 'SA'; // Saudi Arabia
      case 'AE':
        return 'AE'; // United Arab Emirates
      case 'QA':
        return 'QA'; // Qatar
      case 'KW':
        return 'KW'; // Kuwait
      case 'BH':
        return 'BH'; // Bahrain
      case 'OM':
        return 'OM'; // Oman
      case 'JO':
        return 'JO'; // Jordan
      case 'LB':
        return 'LB'; // Lebanon
      case 'GB':
        return 'GB'; // United Kingdom
      case 'CA':
        return 'CA'; // Canada
      case 'AU':
        return 'AU'; // Australia
      case 'JP':
        return 'JP'; // Japan
      case 'KR':
        return 'KR'; // South Korea
      case 'CN':
        return 'CN'; // China
      case 'IN':
        return 'IN'; // India
      case 'BR':
        return 'BR'; // Brazil
      case 'MX':
        return 'MX'; // Mexico
      case 'AR':
        return 'AR'; // Argentina
      default:
        // For any other country, default to Tunisia
        return 'TN';
    }
  }
}
