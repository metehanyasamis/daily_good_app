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
import '../../features/location/presentation/screens/location_map_screen.dart'; // HATA: LocationPickerScreen yerine LocationMapScreen kullanılıyor.

import '../../features/businessShop/presentation/screens/businessShop_details_screen.dart';
import '../../features/businessShop/data/model/businessShop_model.dart';

import '../../features/product/presentation/screens/product_detail_screen.dart';

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
// 🔥 EKSİK TANIMLAR
// --------------------------------------------------------------
abstract class AppRoutes {
  static const String home = 'home';
  static const String productDetail = 'product-detail';
}

Widget fadeTransition(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
  return FadeTransition( // <-- Burası direkt Widget dönüyor
    opacity: animation,
    child: child,
  );
}


// --------------------------------------------------------------
// 🔥 CUSTOM PAGE TRANSITION (buildAnimatedPage fonksiyonu)
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
    // 🚦 REDIRECT RULES
    // ----------------------------------------------------------
    // Hata 1: redirect fonksiyonunun en sonunda tek bir return ifadesi olmalı.
    // Hata 2: hasProfile tanımı redirect içinde yapılmalı.
    redirect: (context, state) {
      final app = ref.watch(appStateProvider);
      final user = ref.watch(userNotifierProvider).user;
      final loc = state.uri.toString();

      debugPrint("🔍 [ROUTER] loc=$loc, isLoggedIn=${app.isLoggedIn}, user=${user != null ? '✅' : '❌'}");

      // ----------------------------------------------------------
      // 0) Splash her zaman serbest
      // ----------------------------------------------------------
      if (loc == '/splash') return null;

      // ----------------------------------------------------------
      // 1) Login değilse → sadece login & intro serbest
      // ----------------------------------------------------------
      if (!app.isLoggedIn) {
        if (loc == '/login' || loc == '/intro') return null;
        return '/login';
      }

      // ----------------------------------------------------------
      // 2) Login olduysa (app.isLoggedIn == true)
      // ----------------------------------------------------------

      // Profil doldurma kontrolü için hasProfile değişkeni tanımlanmalı (Hata çözümü)
      final bool hasProfile = user != null && user.firstName != null && user.firstName!.isNotEmpty;

      // YENİ KULLANICI AKIŞI
      if (app.isNewUser) {
        // 2a) Profil doldurulmadıysa:
        if (!hasProfile) {
          if (loc != '/profileDetail') return '/profileDetail';
          return null;
        }

        // 2b) Onboarding görülmediyse:
        if (!app.hasSeenOnboarding) {
          if (loc != '/onboarding') return '/onboarding';
          return null;
        }

        // 2c) Konum seçilmemişse:
        if (!app.hasSelectedLocation || app.latitude == null || app.longitude == null) {
          if (loc != '/locationInfo') return '/locationInfo';
          return null;
        }

        // Her şey tamamlandıysa, isNewUser bayrağını resetleyebiliriz (opsiyonel ama ideal)
        // Bu kısım UI'da halledilebilir, şimdilik sadece yönlendirme yapalım:
        return '/home';
      }


      // MEVCUT KULLANICI AKIŞI (isNewUser == false)

      // Konum seçimi tamamlanmadıysa (Eski kullanıcı ama konum bilgisi eksik):
      if (!app.hasSelectedLocation || app.latitude == null || app.longitude == null) {
        if (loc != '/locationInfo') return '/locationInfo';
        return null;
      }

      // Giriş akışını bloke et (Hata çözümü)
      const blocked = [
        '/login',
        '/intro',
        '/profileDetail',
        '/onboarding',
        '/locationInfo',
      ];

      if (blocked.contains(loc)) return '/home';

      // ----------------------------------------------------------
      // 3) Geri kalan tüm rotalar serbest
      // ----------------------------------------------------------
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

      // ---------------- FULLSCREEN (ShellRoute DIŞI) ----------------
      GoRoute(
        path: '/location-info',
        builder: (context, state) => const LocationInfoScreen(),
      ),
      GoRoute(
        // LocationPickerScreen yerine LocationMapScreen kullanıldı (Hata çözümü)
        path: '/location-picker',
        builder: (context, state) => const LocationMapScreen(),
      ),

      GoRoute(
        path: '/profileDetail',
        builder: (_, state) => const ProfileDetailsScreen(),
      ),

      GoRoute(
        path: 'product-detail/:productId',
        name: AppRoutes.productDetail,
        pageBuilder: (context, state) {
          final productId = state.pathParameters['productId']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: ProductDetailScreen(
              productId: productId,
            ),
            transitionsBuilder: fadeTransition,
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

      GoRoute(path: '/cart', builder: (_, _) => const CartScreen()),
      GoRoute(path: '/notifications', builder: (_, _) => const NotificationScreen()),
      GoRoute(path: '/order-success', builder: (_, _) => const OrderSuccessScreen()),
      GoRoute(path: '/order-tracking', builder: (_, _) => const OrderTrackingScreen()),
      GoRoute(path: '/thank-you', builder: (_, _) => const ThankYouScreen()),
      GoRoute(path: '/order-history', builder: (_, _) => const OrderHistoryScreen()),
      GoRoute(path: '/support', builder: (_, _) => const SupportScreen()),
      GoRoute(path: '/support-success', builder: (_, _) => const SupportSuccessScreen()),


      // ----------------------------------------------------------
      // 🔥 SHELL ROUTE (BOTTOM NAV) — SADECE NAVBAR EKRANLARI
      // ----------------------------------------------------------
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(location: state.uri.toString(), child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),

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

          GoRoute(path: '/explore-map', builder: (_, _) => const ExploreMapScreen()),
          GoRoute(path: '/favorites', builder: (_, _) => const FavoritesScreen()),
          GoRoute(path: '/account', builder: (_, _) => const AccountScreen()),
        ],
      ),
    ],
  );
});