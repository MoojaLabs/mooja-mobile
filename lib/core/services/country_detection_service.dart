import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import '../domain/domain_objects.dart';

/// Proper country detection service using SIM country code
/// Uses platform channels to access SIM country - the only reliable on-device signal
/// Priority: SIM Country > Device Locale > Default
class CountryDetectionService {
  static const MethodChannel _channel = MethodChannel('country_detector');
  static const Duration _cacheExpiry = Duration(hours: 24);
  static const String _defaultCountryCode = 'US'; // Default fallback

  String? _cachedCountryCode;
  DateTime? _cacheTimestamp;

  CountryDetectionService() : _cachedCountryCode = null, _cacheTimestamp = null;

  CountryDetectionService._withCache({
    required String? cachedCountryCode,
    required DateTime? cacheTimestamp,
  }) : _cachedCountryCode = cachedCountryCode,
       _cacheTimestamp = cacheTimestamp;

  /// Detect user's country using SIM country code (proper method)
  /// Returns a Country domain object or default country if detection fails
  Future<Country?> detectCountry() async {
    // Check cache first
    if (_isCacheValid()) {
      print('✅ Using cached country: ${_cachedCountryCode!}');
      return Country(_cachedCountryCode!);
    }

    print('🔍 Starting SIM-based country detection...');

    // 1️⃣ Try SIM country first (most accurate - reflects actual country)
    print('📱 Method 1: Trying SIM country detection...');
    final simCountry = await _getCountryFromSim();
    if (simCountry != null) {
      print('✅ Using SIM country: ${simCountry.value}');
      _cacheResult(simCountry.value);
      return simCountry;
    }
    print('❌ SIM country detection failed');

    // 2️⃣ Fallback to device locale (less accurate but better than nothing)
    print('🌍 Method 2: Trying device locale detection...');
    final localeCountry = _getCountryFromDeviceLocale();
    if (localeCountry != null) {
      print('✅ Using device locale country: ${localeCountry.value}');
      _cacheResult(localeCountry.value);
      return localeCountry;
    }
    print('❌ Device locale detection failed');

    // 3️⃣ Default fallback - return default country if all methods fail
    print(
      '🔄 All detection methods failed, using default: $_defaultCountryCode',
    );
    _cacheResult(_defaultCountryCode);
    return Country(_defaultCountryCode);
  }

  /// Get country from SIM card - Most accurate method
  Future<Country?> _getCountryFromSim() async {
    try {
      // Call native Android/iOS method to get SIM country code
      final simCountryCode = await _channel.invokeMethod<String>(
        'getSimCountry',
      );

      print('SIM country code from platform: $simCountryCode');

      if (simCountryCode != null && simCountryCode.isNotEmpty) {
        final countryCode = simCountryCode.toUpperCase();
        if (_isValidCountryCode(countryCode)) {
          print('Using SIM country: $countryCode');
          return Country(countryCode);
        }
      }
    } catch (e) {
      print('SIM country detection error: $e');
    }

    return null;
  }

  /// Get country from device locale - Fallback method
  Country? _getCountryFromDeviceLocale() {
    try {
      // Use Flutter's window locale as fallback
      final windowLocale = ui.PlatformDispatcher.instance.locale;
      print('Window locale: ${windowLocale.toString()}');

      if (windowLocale.countryCode != null &&
          windowLocale.countryCode!.isNotEmpty) {
        final countryCode = windowLocale.countryCode!.toUpperCase();
        if (_isValidCountryCode(countryCode)) {
          print('Extracted country code from window locale: $countryCode');
          return Country(countryCode);
        }
      }
    } catch (e) {
      print('Device locale detection error: $e');
    }

    return null;
  }

  /// Check if cached country data is still valid
  bool _isCacheValid() {
    if (_cachedCountryCode == null || _cacheTimestamp == null) {
      return false;
    }

    final now = DateTime.now();
    final expiryTime = _cacheTimestamp!.add(_cacheExpiry);
    return now.isBefore(expiryTime);
  }

  /// Cache the detection result
  void _cacheResult(String countryCode) {
    _cachedCountryCode = countryCode;
    _cacheTimestamp = DateTime.now();
    print('💾 Cached country detection result: $countryCode');
  }

  /// Validate if a country code is valid ISO-2 format
  bool _isValidCountryCode(String countryCode) {
    // Basic validation - should be 2 uppercase letters
    if (countryCode.length != 2) return false;

    // Check if it's all uppercase letters
    final regex = RegExp(r'^[A-Z]{2}$');
    return regex.hasMatch(countryCode);
  }

  /// Create a new instance with cached data
  static CountryDetectionService withCache({
    required String? cachedCountryCode,
    required DateTime? cacheTimestamp,
  }) {
    return CountryDetectionService._withCache(
      cachedCountryCode: cachedCountryCode,
      cacheTimestamp: cacheTimestamp,
    );
  }
}
