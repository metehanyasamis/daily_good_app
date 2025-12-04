import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Screens
import '../../features/account/domain/providers/user_notifier.dart';
import '../../features/account/presentation/screens/profile_details_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/intro_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';

import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/explore/presentation/screens/explore_list_screen.dart';
import '../../features/explore/presentation/screens/explore_map_screen.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/account/presentation/screens/account_screen.dart';

import '../../features/location/presentation/screens/location_info_screen.dart';
import '../../features/location/presentation/screens/location_map_screen.dart';

import '../../features/product/data/models/store_summary.dart';
import '../../features/product/presentation/screens/product_detail_screen.dart';

// 🔥 STORE — DOĞRU İMPORT (BusinessModel değil!)
import '../../features/stores/presentation/screens/store_detail_screen.dart';

import '../../features/support/presentation/support_screen.dart';
import '../../features/support/presentation/support_success_screen.dart';

import '../../features/notification/presentation/screens/notification_screen.dart';
import '../../features/orders/presentation/screens/order_history_screen.dart';
import '../../features/orders/presentation/screens/order_success_screen.dart';
import '../../features/orders/presentation/screens/order_tracking_screen.dart';
import '../../features/orders/presentation/screens/thank_you_screen.dart';

import '../../features/checkout/presentation/screens/payment_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';

import '../providers/app_state_provider.dart';
import 'app_shell.dart';

// --------------------------------------------------------------
// ROUTE CONSTANTS
// --------------------------------------------------------------
abstract class AppRoutes {
  static const String home = 'home';
  static const String productDetail = 'product-detail';
}

// --------------------------------------------------------------
// TRANSITION
// --------------------------------------------------------------
CustomTransitionPage buildAnimatedPage({
  required Widget child,
  required LocalKey key,
}) {
  return CustomTransitionPage(
    key: key,
    transitionDuration: const Duration(milliseconds: 350),
    child: child,
    transitionsBuilder: (_, animation, _, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ),
        child: child,
      );
    },
  );
}

// --------------------------------------------------------------
// GO_ROUTER — FINAL, CLEAN VERSION
// --------------------------------------------------------------
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',

    redirect: (context, state) {
      final app = ref.watch(appStateProvider);
      final userState = ref.watch(userNotifierProvider);
      final user = userState.user;

      final loc = state.uri.toString();

      if (loc == '/splash') return null;

      if (!app.isLoggedIn) {
        if (loc == '/login' || loc == '/intro') return null;
        return '/login';
      }

      final hasProfile =
          user != null && user.firstName != null && user.firstName!.isNotEmpty;

      if (app.isNewUser) {
        if (!hasProfile && loc != '/profileDetail') return '/profileDetail';
        if (!app.hasSeenOnboarding && loc != '/onboarding') return '/onboarding';
        if (!app.hasSelectedLocation && loc != '/location-info') {
          return '/location-info';
        }
        return '/home';
      }

      const blocked = [
        '/login',
        '/intro',
        '/profileDetail',
        '/onboarding',
        '/location-info',
      ];

      if (blocked.contains(loc)) return '/home';

      return null;
    },

    routes: [
      // ---------------- AUTH ----------------
      GoRoute(
        path: '/splash',
        pageBuilder: (_, state) =>
            buildAnimatedPage(child: const SplashScreen(), key: state.pageKey),
      ),

      GoRoute(
        path: '/intro',
        pageBuilder: (_, state) =>
            buildAnimatedPage(child: const IntroScreen(), key: state.pageKey),
      ),

      GoRoute(
        path: '/login',
        pageBuilder: (_, state) =>
            buildAnimatedPage(child: const LoginScreen(), key: state.pageKey),
      ),

      GoRoute(
        path: '/onboarding',
        pageBuilder: (_, state) =>
            buildAnimatedPage(child: const OnboardingScreen(), key: state.pageKey),
      ),

      // ---------------- FULLSCREEN ----------------
      GoRoute(
        path: '/location-info',
        builder: (_, state) => const LocationInfoScreen(),
      ),

      GoRoute(
        path: '/location-picker',
        builder: (_, state) => const LocationMapScreen(),
      ),

      GoRoute(
        path: '/profileDetail',
        builder: (_, state) => const ProfileDetailsScreen(),
      ),

      // ---------------- PRODUCT DETAIL ----------------
      GoRoute(
        path: '/product-detail/:productId',
        name: AppRoutes.productDetail,
        pageBuilder: (context, state) {
          final productId = state.pathParameters['productId']!;
          return buildAnimatedPage(
            key: state.pageKey,
            child: ProductDetailScreen(productId: productId),
          );
        },
      ),

      // ---------------- STORE DETAIL ----------------
      GoRoute(
        path: '/store-detail',
        pageBuilder: (_, state) {
          final store = state.extra as StoreSummary;
          return buildAnimatedPage(
            key: state.pageKey,
            child: StoreDetailScreen(storeId: store.id),
          );
        },
      ),

      // ---------------- PAYMENT ----------------
      GoRoute(
        path: '/payment',
        builder: (_, state) => const PaymentScreen(),
      ),


      GoRoute(path: '/cart', builder: (_, _) => const CartScreen()),
      GoRoute(path: '/notifications', builder: (_, _) => const NotificationScreen()),
      GoRoute(path: '/order-success', builder: (_, _) => const OrderSuccessScreen()),
      GoRoute(path: '/order-tracking', builder: (_, _) => const OrderTrackingScreen()),
      GoRoute(path: '/thank-you', builder: (_, _) => const ThankYouScreen()),
      GoRoute(path: '/order-history', builder: (_, _) => const OrderHistoryScreen()),
      GoRoute(path: '/support', builder: (_, _) => const SupportScreen()),
      GoRoute(path: '/support-success', builder: (_, _) => const SupportSuccessScreen()),

      // ---------------- SHELL ROUTE ----------------
      ShellRoute(
        builder: (_, state, child) =>
            AppShell(location: state.uri.toString(), child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),

          GoRoute(
            path: '/explore',
            builder: (_, _) => const ExploreListScreen(),
          ),

          GoRoute(
            path: '/explore-map',
            builder: (_, _) => const ExploreMapScreen(),
          ),

          GoRoute(path: '/favorites', builder: (_, _) => const FavoritesScreen()),
          GoRoute(path: '/account', builder: (_, _) => const AccountScreen()),
        ],
      ),
    ],
  );
});
