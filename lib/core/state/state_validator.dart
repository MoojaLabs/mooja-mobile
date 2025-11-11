import '../services/storage_service.dart';
import '../di/service_locator.dart';

/// Validates and recovers from corrupted or inconsistent app state
class StateValidator {
  static final StorageService _storage = sl<StorageService>();

  /// Check if the current app state is valid
  static Future<bool> isValid() async {
    try {
      // Check for inconsistent state - org users should have tokens
      final hasToken = await _storage.hasAuthToken();
      final pendingData = await _storage.readPendingOrgData();
      final hasPendingApp = pendingData?.applicationId;

      // If user has pending app but also has token, that's inconsistent
      if (hasPendingApp != null && hasToken) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Recover from corrupted state by resetting to safe defaults
  static Future<void> recover() async {
    try {
      // Clear any corrupted org data
      await _storage.clearPendingOrgData();
    } catch (e) {
      // If recovery fails, clear everything
      await _storage.clear();
    }
  }

  /// Get current state summary for debugging
  static Future<Map<String, dynamic>> getStateSummary() async {
    try {
      final pendingData = await _storage.readPendingOrgData();
      return {
        'country': await _storage.readSelectedCountryCode(),
        'hasAuthToken': await _storage.hasAuthToken(),
        'pendingOrgData': pendingData?.toJson(),
        'pendingOrgComplete': pendingData?.isComplete,
        'pendingOrgReadyForSubmission': pendingData?.isReadyForSubmission,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Validate state before critical operations
  static Future<bool> validateBeforeNavigation() async {
    try {
      // Check if state is valid
      if (!await isValid()) {
        await recover();
        return false;
      }

      return true;
    } catch (e) {
      await recover();
      return false;
    }
  }
}
