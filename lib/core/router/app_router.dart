import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Screens
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
import '../../features/explore/presentation/widgets/category_filter_option.dart';


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
    // 🚦 Redirect Kuralları
    // ----------------------------------------------------------
    redirect: (context, state) {
      final app = ref.read(appStateProvider);
      final loc = state.uri.toString();

      if (loc == '/splash') return null;

      // 1) Not logged in → login
      if (!app.isLoggedIn) {
        if (loc != '/login') return '/login';
        return null;
      }

      // 2) Onboarding yapılmamış → profileDetail
      if (!app.hasSeenOnboarding) {
        if (loc != '/profileDetail') return '/profileDetail';
        return null;
      }

      // 3) Konum seçilmemiş → locationInfo
      final isLocationRoute = loc == '/locationInfo' || loc == '/map';
      if (!app.hasSelectedLocation && !isLocationRoute) {
        return '/locationInfo';
      }

      // 4) Tamamsa login/onboarding/location'a geri dönemez
      if (app.hasSelectedLocation &&
          ['/login', '/onboarding', '/locationInfo', '/profileDetail']
              .contains(loc)) {
        return '/home';
      }

      return null;
    },

    // ----------------------------------------------------------
    // 🔥 ROUTE TREE
    // ----------------------------------------------------------
    routes: [

      // ---------------- AUTH ----------------
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

      // ---------------- FULLSCREEN (ShellRoute DIŞI) ----------------
      GoRoute(
        path: '/locationInfo',
        pageBuilder: (_, state) =>
            buildAnimatedPage(key: state.pageKey, child: const LocationInfoScreen()),
      ),
      GoRoute(
        path: '/map',
        builder: (_, __) => const LocationMapScreen(),
      ),

      GoRoute(
        path: '/profileDetail',
        builder: (_, state) => ProfileDetailsScreen(
          fromOnboarding: (state.extra as Map?)?['fromOnboarding'] == true,
        ),
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
          final business = state.extra as BusinessModel;
          return buildAnimatedPage(
            key: state.pageKey,
            child: BusinessShopDetailsScreen(business: business),
          );
        },
      ),

      GoRoute(
        path: '/payment',
        builder: (_, state) =>
            PaymentScreen(amount: state.extra as double? ?? 0.0),
      ),

      GoRoute(path: '/cart', builder: (_, __) => const CartScreen()),
      GoRoute(path: '/notifications', builder: (_, __) => const NotificationScreen()),
      GoRoute(path: '/order-success', builder: (_, __) => const OrderSuccessScreen()),
      GoRoute(path: '/order-tracking', builder: (_, __) => const OrderTrackingScreen()),
      GoRoute(path: '/thank-you', builder: (_, __) => const ThankYouScreen()),
      GoRoute(path: '/order-history', builder: (_, __) => const OrderHistoryScreen()),
      GoRoute(path: '/support', builder: (_, __) => const SupportScreen()),
      GoRoute(path: '/support-success', builder: (_, __) => const SupportSuccessScreen()),


      // ----------------------------------------------------------
      // 🔥 SHELL ROUTE (BOTTOM NAV) — SADECE NAVBAR EKRANLARI
      // ----------------------------------------------------------
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(location: state.uri.toString(), child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),

          GoRoute(
            path: '/explore',
            builder: (_, state) {
              final extra = (state.extra as Map?)?.cast<String, dynamic>();

              final initialCategory = extra?['category'] as CategoryFilterOption?;
              final fromHome = extra?['fromHome'] == true;

              return ExploreListScreen(
                initialCategory: initialCategory,
                fromHome: fromHome,
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
