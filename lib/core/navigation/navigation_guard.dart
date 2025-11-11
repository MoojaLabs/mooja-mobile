import '../services/user_context_service.dart';
import '../services/storage_service.dart';
import '../di/service_locator.dart';

/// Prevents invalid navigation combinations that could cause loops or unexpected behavior
class NavigationGuard {
  /// Check if navigation from one route to another is valid
  static Future<bool> canNavigate(String from, String to) async {
    // Prevent redirect loops
    if (from == to) {
      return false;
    }

    return true;
  }

  /// Get a safe fallback route if navigation is invalid
  static Future<String> getSafeRoute() async {
    final userContext = sl<UserContextService>();
    final storage = sl<StorageService>();

    final canAccess = await userContext.canAccessOrgFeatures();
    final pendingData = await storage.readPendingOrgData();

    if (canAccess) {
      // Logged in org - go to org dashboard
      return '/home/organization';
    } else if (pendingData?.applicationId != null) {
      // Pending org - go to timeline
      return '/verification-timeline';
    } else {
      // Everyone else - go to protestor feed
      return '/home/protestor';
    }
  }

  /// Log navigation for debugging
  static void logNavigation(String from, String to, String reason) {
    // no-op in production
  }
}
