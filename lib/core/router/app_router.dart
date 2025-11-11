import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../di/service_locator.dart';
import '../services/storage_service.dart';
import '../services/user_context_service.dart';
import '../../features/splash/pages/splash_page.dart';
import '../../features/auth/login_page.dart';
import '../../features/auth/signup_page.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/organization/verification/pages/country_selection_page.dart';
import '../../features/organization/verification/pages/organization_name_page.dart';
import '../../features/organization/verification/pages/social_media_selection_page.dart';
import '../../features/organization/verification/pages/social_username_page.dart';
import '../../features/organization/verification/pages/verification_timeline_page.dart';
import '../../features/organization/verification/pages/status_lookup_page.dart';
import '../../features/organization/verification/pages/code_verification_page.dart';
import '../../features/organization/verification/pages/org_registration_page.dart';
import '../../features/organization/verification/bloc/verification_cubit.dart';
import '../../features/home/widgets/feed_shell.dart';
import '../../features/home/widgets/tab_navigation.dart';
import '../../features/protestor/feed/pages/protestor_feed_page.dart';
import '../../features/organization/dashboard/pages/organization_feed_page.dart';
import '../../features/intro/widgets/org_verification_modal.dart';
import '../../features/intro/widgets/not_eligible_modal.dart';
import '../navigation/navigation_guard.dart';
import '../state/state_validator.dart';

// Route path constants - single source of truth
abstract class AppRoutes {
  // Public routes
  static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const countrySelection = '/country-selection';
  static const organizationName = '/organization-name';
  static const socialMediaSelection = '/social-media-selection';
  static const socialUsername = '/social-username';
  static const verificationTimeline = '/verification-timeline';
  static const statusLookup = '/status-lookup';
  static const codeVerification = '/code-verification';
  static const orgRegistration = '/org-registration';
  static const home = '/home';
  static const protestorFeed = '/home/protestor';
  static const organizationFeed = '/home/organization';
}

// Main router configuration
class AppRouter {
  // Private constructor to prevent instantiation
  AppRouter._();

  static final RouteObserver<ModalRoute<void>> routeObserver =
      RouteObserver<ModalRoute<void>>();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    observers: [routeObserver],
    routes: <RouteBase>[
      // Public routes (no auth required)
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),

      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      GoRoute(
        path: AppRoutes.signup,
        name: 'signup',
        builder: (context, state) => const SignupPage(),
      ),

      GoRoute(
        path: AppRoutes.countrySelection,
        name: 'countrySelection',
        builder: (context, state) {
          final isOrgFlow = state.uri.queryParameters['orgFlow'] == '1';
          return BlocProvider(
            create: (_) => sl<VerificationCubit>(),
            child: CountrySelectionPage(forOrganizationFlow: isOrgFlow),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.organizationName,
        name: 'organizationName',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<VerificationCubit>(),
          child: const OrganizationNamePage(),
        ),
      ),

      GoRoute(
        path: AppRoutes.socialMediaSelection,
        name: 'socialMediaSelection',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<VerificationCubit>(),
          child: const SocialMediaSelectionPage(),
        ),
      ),

      GoRoute(
        path: AppRoutes.socialUsername,
        name: 'socialUsername',
        builder: (context, state) {
          final socialMedia =
              state.uri.queryParameters['socialMedia'] ?? 'Instagram';
          return BlocProvider(
            create: (_) => sl<VerificationCubit>(),
            child: SocialUsernamePage(selectedSocialMedia: socialMedia),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.verificationTimeline,
        name: 'verificationTimeline',
        builder: (context, state) {
          final username = state.uri.queryParameters['username'];
          final initialStatus = state.uri.queryParameters['status'];
          return VerificationTimelinePage(
            username: username,
            initialStatus: initialStatus,
          );
        },
      ),

      GoRoute(
        path: AppRoutes.statusLookup,
        name: 'statusLookup',
        builder: (context, state) => const StatusLookupPage(),
      ),

      GoRoute(
        path: AppRoutes.codeVerification,
        name: 'codeVerification',
        builder: (context, state) => const CodeVerificationPage(),
      ),

      GoRoute(
        path: AppRoutes.orgRegistration,
        name: 'orgRegistration',
        builder: (context, state) {
          final prefilled = state.uri.queryParameters['username'];
          return BlocProvider(
            create: (context) => sl<AuthBloc>(),
            child: OrgRegistrationPage(prefilledUsername: prefilled),
          );
        },
      ),

      // Keeps tab state when switching between tabs
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return FeedShell(
            activeTab: navigationShell.currentIndex == 0
                ? TabType.forYou
                : TabType.forOrganizations,
            onTabChanged: (newTab) async {
              // Validate state before tab changes
              if (!await StateValidator.validateBeforeNavigation()) {
                return;
              }

              // Handle tab changes using UserContextService
              if (newTab == TabType.forYou) {
                // Always allow switching to For You tab
                navigationShell.goBranch(0);
              } else if (newTab == TabType.forOrganizations) {
                // Simplified org access logic with direct checks
                final userContext = sl<UserContextService>();
                final canAccess = await userContext.canAccessOrgFeatures();

                if (canAccess) {
                  // Case 1: Logged in org - allow access
                  navigationShell.goBranch(1);
                } else {
                  // Check for pending application directly
                  final pendingData = await sl<StorageService>()
                      .readPendingOrgData();
                  if (context.mounted) {
                    if (pendingData?.applicationId != null) {
                      // Case 2: Pending org - go to timeline
                      context.go('/verification-timeline');
                    } else {
                      // Case 3: New user - show eligibility modal
                      _showOrgVerificationModalFromFeed(context);
                    }
                  }
                }
              }
            },
            child: navigationShell,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.protestorFeed,
                name: 'protestorFeed',
                builder: (context, state) => const ProtestorFeedPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.organizationFeed,
                name: 'organizationFeed',
                builder: (context, state) => const OrganizationFeedPage(),
              ),
            ],
          ),
        ],
      ),
    ],

    redirect: (BuildContext context, GoRouterState state) async {
      // Validate state before any navigation
      if (!await StateValidator.validateBeforeNavigation()) {
        return await NavigationGuard.getSafeRoute();
      }

      final userContext = sl<UserContextService>();

      // Check if navigation is valid (only if actually navigating somewhere)
      if (state.uri.toString() != state.matchedLocation) {
        final canNavigate = await NavigationGuard.canNavigate(
          state.uri.toString(),
          state.matchedLocation,
        );

        if (!canNavigate) {
          return await NavigationGuard.getSafeRoute();
        }
      } else {}

      // Allow all users to access routes (splash handles routing)
      {
        // Simplified redirect logic with direct checks
        if (state.matchedLocation == AppRoutes.splash) {
          final canAccess = await userContext.canAccessOrgFeatures();
          final pendingData = await sl<StorageService>().readPendingOrgData();

          if (canAccess) {
            // Returning orgs with token should not see splash
            return AppRoutes.organizationFeed;
          } else if (pendingData?.applicationId != null) {
            // Pending orgs should go to timeline, not splash
            return '/verification-timeline';
          } else {
            // Returning protestors should go to feed, not splash
            return AppRoutes.protestorFeed;
          }
        }
      }
      return null;
    },

    // Error page handler
    errorBuilder: (context, state) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Page not found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                state.error?.message ?? 'Unknown error',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.splash),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// Helper function to show org verification modal from feed context
void _showOrgVerificationModalFromFeed(BuildContext context) {
  // Validate state before showing modal
  StateValidator.validateBeforeNavigation().then((isValid) {
    if (!isValid) {
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const OrgVerificationModal(),
    ).then((result) {
      if (!context.mounted) return;
      if (result == 'yes') {
        if (!context.mounted) return;
        context.pushToLogin();
      } else if (result == 'no') {
        if (!context.mounted) return;
        _showNotEligibleModalFromFeed(context);
      }
    });
  });
}

// Helper function to show not eligible modal from feed context
void _showNotEligibleModalFromFeed(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const NotEligibleModal(fromFeed: true),
  );
}

extension NavigationExtensions on BuildContext {
  // Current navigation methods
  void goToSplash() => go(AppRoutes.splash);
  void goToLogin() => go(AppRoutes.login);
  Future<T?> pushToLogin<T>() => GoRouter.of(this).push<T>(AppRoutes.login);
  void goToSignup() => go(AppRoutes.signup);
  void goToCountrySelection() => go(AppRoutes.countrySelection);
  Future<T?> pushToCountrySelection<T>() =>
      GoRouter.of(this).push<T>(AppRoutes.countrySelection);
  Future<T?> pushToCountrySelectionForOrg<T>() =>
      GoRouter.of(this).push<T>('${AppRoutes.countrySelection}?orgFlow=1');
  void goToOrganizationName() => go(AppRoutes.organizationName);
  Future<T?> pushToOrganizationName<T>() =>
      GoRouter.of(this).push<T>(AppRoutes.organizationName);
  void goToSocialMediaSelection() => go(AppRoutes.socialMediaSelection);
  Future<T?> pushToSocialMediaSelection<T>() =>
      GoRouter.of(this).push<T>(AppRoutes.socialMediaSelection);
  void goToSocialUsername(String socialMedia) =>
      go('${AppRoutes.socialUsername}?socialMedia=$socialMedia');
  Future<T?> pushToSocialUsername<T>(String socialMedia) => GoRouter.of(
    this,
  ).push<T>('${AppRoutes.socialUsername}?socialMedia=$socialMedia');
  void goToVerificationTimeline({
    String status = 'pending',
    String? username,
  }) => go(
    '${AppRoutes.verificationTimeline}?status=$status${username != null ? '&username=$username' : ''}',
  );
  void goToCodeVerification() => go(AppRoutes.codeVerification);
  Future<T?> pushToCodeVerification<T>() =>
      GoRouter.of(this).push<T>(AppRoutes.codeVerification);
  void goToOrgRegistration({String? prefilledUsername}) => go(
    prefilledUsername == null
        ? AppRoutes.orgRegistration
        : '${AppRoutes.orgRegistration}?username=$prefilledUsername',
  );
  void goToStatusLookup() => go(AppRoutes.statusLookup);
  Future<T?> pushToStatusLookup<T>() =>
      GoRouter.of(this).push<T>(AppRoutes.statusLookup);
  void goToHome() => go(AppRoutes.protestorFeed);
  void goToProtestorFeed() => go(AppRoutes.protestorFeed);
  void goToOrganizationFeed() => go(AppRoutes.organizationFeed);

  // Check current route
  bool get isSplashPage =>
      GoRouterState.of(this).matchedLocation == AppRoutes.splash;
  bool get isLoginPage =>
      GoRouterState.of(this).matchedLocation == AppRoutes.login;
  bool get isSignupPage =>
      GoRouterState.of(this).matchedLocation == AppRoutes.signup;
  bool get isCountrySelectionPage =>
      GoRouterState.of(this).matchedLocation == AppRoutes.countrySelection;
  bool get isHomePage =>
      GoRouterState.of(this).matchedLocation == AppRoutes.protestorFeed;

  // Get route parameters
  String? getParam(String name) => GoRouterState.of(this).pathParameters[name];
  String? getQueryParam(String name) =>
      GoRouterState.of(this).uri.queryParameters[name];
}
