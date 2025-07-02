import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/location_service.dart';

class LocalizationProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  String _countryCode = 'TN'; // Default to Tunisia
  bool _isDetectingLocation = false;

  static const String _languageKey = 'language_code';
  static const String _countryKey = 'country_code';

  Locale get locale => _locale;
  Locale get currentLocale => _locale;
  String get languageCode => _locale.languageCode;
  String get countryCode => _countryCode;
  bool get isDetectingLocation => _isDetectingLocation;

  // Map language codes to display codes
  String get displayLanguageCode {
    switch (_locale.languageCode) {
      case 'en':
        return 'En';
      case 'fr':
        return 'Fr';
      case 'ar':
        return 'Ar';
      case 'es':
        return 'Es';
      case 'de':
        return 'De';
      case 'it':
        return 'It';
      default:
        return 'En';
    }
  }

  LocalizationProvider() {
    _loadSavedSettings();
  }

  Future<void> _loadSavedSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageKey);
    final savedCountry = prefs.getString(_countryKey);

    if (savedLanguage != null) {
      _locale = Locale(savedLanguage);
    }

    if (savedCountry != null) {
      _countryCode = savedCountry;
    } else {
      // If no saved country, try to auto-detect from GPS (non-blocking)
      // Don't await this - let it run in background
      _autoDetectCountry();
    }

    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, locale.languageCode);

    notifyListeners();
  }

  Future<void> setCountryCode(String code) async {
    if (_countryCode == code) return;

    _countryCode = code;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_countryKey, code);

    notifyListeners();
  }

  /// Auto-detect country from GPS location
  Future<void> _autoDetectCountry() async {
    if (_isDetectingLocation) {
      return; // Prevent multiple simultaneous detections
    }

    _isDetectingLocation = true;
    notifyListeners();

    try {
      debugPrint('Auto-detecting country from GPS...');

      // Try to get current position (pass a dummy context)
      final position = await LocationService.getCurrentPositionWithoutContext();
      if (position != null) {
        final detectedCountry = await LocationService.getCountryFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (detectedCountry != null) {
          debugPrint('Auto-detected country: $detectedCountry');
          await setCountryCode(detectedCountry);
        } else {
          debugPrint('Could not determine country from coordinates');
        }
      } else {
        debugPrint('Could not get GPS position');
      }
    } catch (e) {
      debugPrint('Error auto-detecting country: $e');
    } finally {
      _isDetectingLocation = false;
      notifyListeners();
    }
  }

  /// Manually trigger country detection (for refresh button)
  Future<void> detectCountryFromGPS() async {
    await _autoDetectCountry();
  }
}
