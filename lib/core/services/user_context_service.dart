import 'storage_service.dart';
import 'auth_service.dart';

/// Single source of truth for user state across all journeys
/// Prevents cross-journey state pollution and provides consistent user context
class UserContextService {
  final StorageService _storage;
  final AuthService _authService;

  UserContextService(this._storage, this._authService);

  /// Complete organization verification
  Future<void> completeOrgVerification({
    required String token,
    required String refreshToken,
  }) async {
    // Transaction-like behavior: if any step fails, rollback all
    try {
      await _storage.saveAuthToken(token);
      await _storage.saveRefreshToken(refreshToken);
      await _storage.clearPendingOrgData();
    } catch (e) {
      // Rollback on any failure
      await _rollbackOrgVerification();
      rethrow;
    }
  }

  /// Clear all user data (logout)
  Future<void> clearAllUserData() async {
    await _authService.logout();
    // Keep only global preferences
    final country = await _storage.readSelectedCountryCode();
    await _storage.clear(); // This clears everything
    if (country != null) {
      await _storage.saveSelectedCountryCode(country);
    }
  }

  /// Check if user can access organization features
  Future<bool> canAccessOrgFeatures() async {
    return await _authService.isLoggedIn();
  }

  /// Private method to rollback failed org verification
  Future<void> _rollbackOrgVerification() async {
    try {
      await _storage.deleteAuthToken();
      await _storage.deleteRefreshToken();
      // Don't clear user type if it was already set to something else
    } catch (e) {
      // Silent failure on rollback - already in error state
    }
  }
}
