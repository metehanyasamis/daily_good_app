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

import '../../features/businessShop/presentation/screens/businessShop_details_screen.dart';
import '../../features/businessShop/data/model/businessShop_model.dart';

import '../../features/product/presentation/screens/product_detail_screen.dart';
import '../../features/product/data/models/product_model.dart';

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
// 🔥 CUSTOM PAGE TRANSITION
// --------------------------------------------------------------
CustomTransitionPage buildAnimatedPage({
  required Widget child,
  required LocalKey key,
}) {
  return CustomTransitionPage(
    key: key,
    transitionDuration: const Duration(milliseconds: 450),
    child: child,
    transitionsBuilder: (context, animation, sec, child) {
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
// 🔥 FINAL — DOĞRU ROUTER YAPISI
// --------------------------------------------------------------
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',

    // ----------------------------------------------------------
    // 🚦 REDIRECT RULES (TAM PROFESYONEL FINAL VERSİYON)
    // ----------------------------------------------------------
    redirect: (context, state) {
      final app = ref.watch(appStateProvider);
      final user = ref.watch(userNotifierProvider).user;
      final loc = state.uri.toString();

      debugPrint("🚦 [REDIRECT] → $loc");
      debugPrint("   isLoggedIn = ${app.isLoggedIn}");
      debugPrint("   isNewUser = ${app.isNewUser}");
      debugPrint("   hasSeenOnboarding = ${app.hasSeenOnboarding}");
      debugPrint("   hasSelectedLocation = ${app.hasSelectedLocation}");
      debugPrint("   user = $user");

      // ----------------------------------------------------------
      // 0) Splash her zaman serbest
      // ----------------------------------------------------------
      //if (loc == '/splash') return null;

      // ----------------------------------------------------------
      // 1) Login değilse → sadece login & intro serbest
      // ----------------------------------------------------------
      if (!app.isLoggedIn) {
        if (loc == '/login' || loc == '/intro') return null;
        return '/login';
      }

      // ----------------------------------------------------------
      // 2) YENİ KULLANICI AKIŞI
      // ----------------------------------------------------------
      if (app.isNewUser) {
        // Profil doldurulmadıysa:
        final hasProfile =
            user != null &&
                user.firstName != null &&
                user.firstName!.isNotEmpty;

        if (!hasProfile) {
          if (loc != '/profileDetail') return '/profileDetail';
          return null;
        }

        if (!hasProfile || !app.hasSeenProfileDetails) {
          if (loc != '/profileDetail') return '/profileDetail';
          return null;
        }

        // Onboarding görülmediyse:
        if (!app.hasSeenOnboarding) {
          if (loc != '/onboarding') return '/onboarding';
          return null;
        }

        // Konum seçilmemişse:
        if (!app.hasSelectedLocation ||
            app.latitude == null ||
            app.longitude == null) {
          if (loc != '/locationInfo') return '/locationInfo';
          return null;
        }

        // LocationInfo → Map zorunlu
        if (loc == '/locationInfo') return '/map';

        // Her şey tamamlandı → Home
        if (loc != '/home') return '/home';

        return null;
      }

      // ----------------------------------------------------------
      // 3) MEVCUT KULLANICI AKIŞI
      // ----------------------------------------------------------
      if (!app.hasSelectedLocation ||
          app.latitude == null ||
          app.longitude == null) {
        if (loc != '/locationInfo') return '/locationInfo';
        return null;
      }

      // Geri dönüş engelleme:
      const blocked = [
        '/login',
        '/intro',
        '/profileDetail',
        '/onboarding',
        '/locationInfo',
      ];

      if (blocked.contains(loc)) return '/home';

      return null;
    },

    // ----------------------------------------------------------
    // ROUTES
    // ----------------------------------------------------------
    routes: [
      // AUTH
      GoRoute(
        path: '/splash',
        pageBuilder: (_, state) =>
            buildAnimatedPage(key: state.pageKey, child: const SplashScreen()),
      ),
      GoRoute(
        path: '/intro',
        pageBuilder: (_, state) =>
            buildAnimatedPage(key: state.pageKey, child: const IntroScreen()),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (_, state) =>
            buildAnimatedPage(key: state.pageKey, child: const LoginScreen()),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (_, state) =>
            buildAnimatedPage(key: state.pageKey, child: const OnboardingScreen()),
      ),

      // FULLSCREEN
      GoRoute(
        path: '/locationInfo',
        pageBuilder: (_, state) =>
            buildAnimatedPage(key: state.pageKey, child: const LocationInfoScreen()),
      ),
      GoRoute(path: '/map', builder: (_, __) => const LocationMapScreen()),

      GoRoute(
        path: '/profileDetail',
        builder: (_, state) => const ProfileDetailsScreen(),
      ),

      GoRoute(
        path: '/product-detail',
        pageBuilder: (_, state) {
          final product = state.extra as ProductModel;
          return buildAnimatedPage(
            key: state.pageKey,
            child: ProductDetailScreen(product: product),
          );
        },
      ),

      GoRoute(
        path: '/businessShop-detail',
        pageBuilder: (_, state) {
          final b = state.extra as BusinessModel;
          return buildAnimatedPage(
            key: state.pageKey,
            child: BusinessShopDetailsScreen(business: b),
          );
        },
      ),

      GoRoute(
        path: '/payment',
        builder: (_, state) =>
            PaymentScreen(amount: state.extra as double? ?? 0),
      ),

      GoRoute(path: '/cart', builder: (_, __) => const CartScreen()),
      GoRoute(path: '/notifications', builder: (_, __) => const NotificationScreen()),
      GoRoute(path: '/order-success', builder: (_, __) => const OrderSuccessScreen()),
      GoRoute(path: '/order-tracking', builder: (_, __) => const OrderTrackingScreen()),
      GoRoute(path: '/thank-you', builder: (_, __) => const ThankYouScreen()),
      GoRoute(path: '/order-history', builder: (_, __) => const OrderHistoryScreen()),
      GoRoute(path: '/support', builder: (_, __) => const SupportScreen()),
      GoRoute(path: '/support-success', builder: (_, __) => const SupportSuccessScreen()),

      // SHELL NAV BAR
      ShellRoute(
        builder: (_, state, child) =>
            AppShell(location: state.uri.toString(), child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),

          GoRoute(
            path: '/explore',
            builder: (_, state) {
              final extra = state.extra as Map?;
              return ExploreListScreen(
                initialCategory: extra?['category'],
                fromHome: extra?['fromHome'] ?? false,
              );
            },
          ),

          GoRoute(path: '/explore-map', builder: (_, __) => const ExploreMapScreen()),
          GoRoute(path: '/favorites', builder: (_, __) => const FavoritesScreen()),
          GoRoute(path: '/account', builder: (_, __) => const AccountScreen()),
        ],
      ),
    ],
  );
});
