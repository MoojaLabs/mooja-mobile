import 'package:flutter/material.dart';
import '../../../core/themes/theme_exports.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/country_detection_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/user_context_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late final CountryDetectionService _countryDetectionService;
  late final StorageService _storage;
  String _loadingMessage = 'Loading...';

  @override
  void initState() {
    super.initState();
    _countryDetectionService = sl<CountryDetectionService>();
    _storage = sl<StorageService>();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Step 1: Detect country
      setState(() {
        _loadingMessage = 'Detecting your location...';
      });

      final detectedCountry = await _countryDetectionService.detectCountry();

      if (detectedCountry != null) {
        // Save detected country to storage if no country is already set
        final existingCountry = await _storage.readSelectedCountryCode();
        if (existingCountry == null) {
          await _storage.saveSelectedCountryCode(detectedCountry.value);
        }
      }

      // Step 2: Check user state and navigate accordingly
      setState(() {
        _loadingMessage = 'Preparing your feed...';
      });

      await _navigateBasedOnUserState();
    } catch (e) {
      // On any error, fallback to protestor feed
      print('Splash initialization error: $e');
      if (mounted) {
        context.goToHome();
      }
    }
  }

  Future<void> _navigateBasedOnUserState() async {
    final userContext = sl<UserContextService>();
    final storage = sl<StorageService>();

    if (!mounted) return;

    // Simplified navigation logic with direct checks
    final canAccess = await userContext.canAccessOrgFeatures(); // isLoggedIn()

    if (canAccess) {
      // Case 1: Logged in org - go to org dashboard
      context.goToOrganizationFeed();
    } else {
      // Check for pending application directly
      final pendingData = await storage.readPendingOrgData();
      if (pendingData?.applicationId != null) {
        // Case 2: Pending org - go to timeline
        context.go('/verification-timeline');
      } else {
        // Case 3: Everyone else - go to home feed
        context.goToHome();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: 18.pt,
          child: Column(
            children: [
              // App branding area
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App logo/icon placeholder
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: 40.radius,
                          color: ThemeColors.backgroundSecondary(
                            context,
                          ).withValues(alpha: 0.3),
                        ),
                        child: Icon(
                          Icons.favorite,
                          size: 60,
                          color: ThemeColors.textPrimary(context),
                        ),
                      ),

                      32.v,

                      // App name
                      Text(
                        'Mooja',
                        style: AppTypography.h2SemiBold,
                        textAlign: TextAlign.center,
                      ),

                      16.v,

                      // Tagline
                      Text(
                        'Change begins right here.',
                        style: AppTypography.bodyMedium.copyWith(
                          color: ThemeColors.textSecondary(context),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              // Loading indicator and message
              Column(
                children: [
                  const CircularProgressIndicator(),

                  16.v,

                  Text(
                    _loadingMessage,
                    style: AppTypography.bodyMedium.copyWith(
                      color: ThemeColors.textSecondary(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              32.v,
            ],
          ),
        ),
      ),
    );
  }
}
