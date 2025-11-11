import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/pending_org_data.dart';
import 'dart:convert';

/// Secure storage service for tokens and user data
class StorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Auth token methods
  Future<void> saveAuthToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<String?> readAuthToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<void> deleteAuthToken() async {
    await _storage.delete(key: 'auth_token');
  }

  // Refresh token methods
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: 'refresh_token', value: token);
  }

  Future<String?> readRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: 'refresh_token');
  }

  // Clear all auth data
  Future<void> clear() async {
    await _storage.deleteAll();
  }

  // Check if user has valid token
  Future<bool> hasAuthToken() async {
    final token = await readAuthToken();
    return token != null && token.isNotEmpty;
  }

  // ========== App Preferences ==========
  static const String _keySelectedCountry = 'selected_country_code';
  static const String _keyPendingOrgData = 'pending_org_data';

  // Selected country
  Future<void> saveSelectedCountryCode(String countryCode) async {
    await _storage.write(key: _keySelectedCountry, value: countryCode);
  }

  Future<String?> readSelectedCountryCode() async {
    return await _storage.read(key: _keySelectedCountry);
  }

  // ========== Pending Organization Data ==========
  /// Save pending organization verification data (atomic operation)
  Future<void> savePendingOrgData(PendingOrgData data) async {
    await _storage.write(key: _keyPendingOrgData, value: data.toJsonString());
  }

  /// Read pending organization verification data
  Future<PendingOrgData?> readPendingOrgData() async {
    final jsonString = await _storage.read(key: _keyPendingOrgData);
    if (jsonString == null) return null;
    return PendingOrgData.fromJsonString(jsonString);
  }

  /// Clear all pending organization verification data
  Future<void> clearPendingOrgData() async {
    await _storage.delete(key: _keyPendingOrgData);
  }
}
