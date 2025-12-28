import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Screens
import '../../features/account/domain/providers/user_notifier.dart';
import '../../features/account/presentation/screens/profile_details_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/intro_screen.dart';
import '../../features/location/presentation/screens/location_picker_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/explore/presentation/screens/explore_list_screen.dart';
import '../../features/explore/presentation/screens/explore_map_screen.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/account/presentation/screens/account_screen.dart';
import '../../features/location/presentation/screens/location_info_screen.dart';
import '../../features/product/presentation/screens/product_detail_screen.dart';
import '../../features/review/presentation/screens/store_review_screen.dart';
import '../../features/stores/presentation/screens/store_detail_screen.dart';

import '../../features/notification/presentation/screens/notification_screen.dart';
import '../../features/orders/presentation/screens/order_success_screen.dart';
import '../../features/orders/presentation/screens/order_tracking_screen.dart';
import '../../features/checkout/presentation/screens/payment_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';

import '../providers/app_state_provider.dart';
import 'app_shell.dart';


abstract class AppRoutes {
  static const String home = 'home';
  static const String productDetail = 'product-detail';
  static const String storeDetail = 'store-detail';
  static const String storeReviews = 'store-reviews';
}

CustomTransitionPage buildAnimatedPage({
  required Widget child,
  required LocalKey key,
}) {
  return CustomTransitionPage(
    key: key,
    transitionDuration: const Duration(milliseconds: 350),
    child: child,
    transitionsBuilder: (_, animation, __, child) {
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

final appRouterProvider = Provider<GoRouter>((ref) {
  final routerNotifier = RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: routerNotifier,
    redirect: (context, state) {
      final app = ref.read(appStateProvider);
      final userState = ref.read(userNotifierProvider);
      final user = userState.user;
      final loc = state.uri.toString();

      // 1. İstisnalar (Hiçbir koşula bakılmadan izin verilenler)
      if (loc.startsWith('/order-tracking')) return null;
      if (loc.startsWith('/store-detail')) return null;
      if (loc.contains('/reviews')) return null; // 🎯 Review sayfasına gidişi serbest bırak

      // 2. Initialize Kontrolü
      if (loc != "/splash" && !app.isInitialized) return "/splash";

      // 3. Splash Kontrolü
      if (loc == "/splash") {
        if (!app.isInitialized) return null;
        if (!app.isLoggedIn) return !app.hasSeenIntro ? "/intro" : "/login";

        if (app.isNewUser) {
          if (user?.firstName?.isEmpty ?? true) return "/profileDetail";
          if (!app.hasSeenOnboarding) return "/onboarding";
          if (!app.hasSelectedLocation) return "/location-info";
          return "/home";
        }
        if (!app.hasSelectedLocation) return "/location-info";
        return "/home";
      }

      // 4. Auth Kontrolü
      if (!app.isLoggedIn) {
        if (loc == "/intro" || loc == "/login") return null;
        return "/login";
      }

      // 5. Konum Kontrolü
      if (!app.hasSelectedLocation && loc != "/location-info" && loc != "/location-picker") {
        return "/location-info";
      }

      // Diğer durumlarda gitmek istediği yere izin ver
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (_, state) => buildAnimatedPage(child: const SplashScreen(), key: state.pageKey),
      ),
      GoRoute(
        path: '/intro',
        pageBuilder: (_, state) => buildAnimatedPage(child: const IntroScreen(), key: state.pageKey),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (_, state) => buildAnimatedPage(child: const LoginScreen(), key: state.pageKey),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (_, state) => buildAnimatedPage(child: const OnboardingScreen(), key: state.pageKey),
      ),
      GoRoute(path: '/location-info', builder: (_, __) => const LocationInfoScreen()),
      GoRoute(path: '/location-picker', builder: (_, __) => const LocationPickerScreen()),
      GoRoute(path: '/profileDetail', builder: (_, __) => const ProfileDetailsScreen()),

      GoRoute(
        path: '/product-detail/:productId',
        name: AppRoutes.productDetail,
        builder: (_, state) => ProductDetailScreen(productId: state.pathParameters['productId']!),
      ),

      GoRoute(
        path: '/store-detail/:id',
        name: AppRoutes.storeDetail,
        builder: (context, state) => StoreDetailScreen(storeId: state.pathParameters['id']!),
      ),

// 🎯 REVIEWS ROTASINI DIŞARI ÇIKARDIK (Bağımsız hale getirdik)
      GoRoute(
        path: '/store-reviews/:id',
        name: AppRoutes.storeReviews,
        pageBuilder: (context, state) {
          final storeId = state.pathParameters['id']!;
          return buildAnimatedPage(
            key: state.pageKey,
            child: StoreReviewScreen(storeId: storeId),
          );
        },
      ),

      GoRoute(path: '/payment', builder: (_, __) => const PaymentScreen()),
      GoRoute(path: '/cart', builder: (_, __) => const CartScreen()),
      GoRoute(path: '/notifications', builder: (_, __) => const NotificationScreen()),
      GoRoute(
        path: '/order-success',
        builder: (_, state) => OrderSuccessScreen(orderId: state.uri.queryParameters['id']),
      ),
      GoRoute(
        path: '/order-tracking/:id',
        builder: (_, state) => OrderTrackingScreen(orderId: state.pathParameters['id']!),
      ),

      ShellRoute(
        builder: (_, state, child) => AppShell(location: state.uri.toString(), child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/explore', builder: (_, __) => const ExploreListScreen()),
          GoRoute(path: '/explore-map', builder: (_, __) => const ExploreMapScreen()),
          GoRoute(path: '/favorites', builder: (_, __) => const FavoritesScreen()),
          GoRoute(path: '/account', builder: (_, __) => const AccountScreen()),
        ],
      ),
    ],
  );
});

// RouterNotifier class'ın aynı kalıyor...

class RouterNotifier extends ChangeNotifier {
  final Ref ref;

  RouterNotifier(this.ref) {
    // appState değiştiğinde router'ı refresh et
    ref.listen(appStateProvider, (_, __) {
      notifyListeners();
    });

    // auth değiştiğinde de tetikle
    ref.listen(userNotifierProvider, (_, __) {
      notifyListeners();
    });
  }
}