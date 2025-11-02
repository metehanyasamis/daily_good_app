import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// 🔹 Feature imports
import '../../features/account/presentation/screens/account_screen.dart';
import '../../features/auth/presentation/screens/intro_screen.dart';
import '../../features/businessShop/data/model/businessShop_model.dart';
import '../../features/businessShop/presentation/screens/businessShop_details_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/checkout/presentation/screens/payment_screen.dart';
import '../../features/explore/presentation/screens/explore_map_screen.dart';
import '../../features/notification/presentation/screens/notification_screen.dart';
import '../../features/orders/presentation/screens/order_success_screen.dart';
import '../../features/orders/presentation/screens/order_tracking_screen.dart';
import '../../features/orders/presentation/screens/thank_you_screen.dart';
import '../../features/product/data/models/product_model.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/account/presentation/screens/profile_details_screen.dart';
import '../../features/location/presentation/screens/location_info_screen.dart';
import '../../features/location/presentation/screens/location_map_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/explore/presentation/screens/explore_list_screen.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/product/presentation/screens/product_detail_screen.dart';
import 'app_shell.dart';

CustomTransitionPage buildAnimatedPage({
  required Widget child,
  required LocalKey key,
}) {
  return CustomTransitionPage(
    key: key,
    transitionDuration: const Duration(milliseconds: 600),
    reverseTransitionDuration: const Duration(milliseconds: 600),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const beginOffset = Offset(0.0, 0.08);
      const endOffset = Offset.zero;

      // 🌙 Fade yavaşça başlar
      final fade = CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 0.8, curve: Curves.easeInOutCubic),
      );

      // 🌊 Slide biraz gecikmeli başlar (daha “soft” his)
      final slide = CurvedAnimation(
        parent: animation,
        curve: const Interval(0.2, 1.0, curve: Curves.easeInOutCubic),
      );

      final slideTween = Tween(begin: beginOffset, end: endOffset)
          .chain(CurveTween(curve: Curves.easeOutCubic));

      return FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: slide.drive(slideTween),
          child: child,
        ),
      );
    },
  );
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash', // ✅ uygulama artık SplashScreen ile açılır
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) =>
            buildAnimatedPage(key: state.pageKey, child: const SplashScreen()),
      ),
      GoRoute(
        path: '/intro',
        pageBuilder: (context, state) =>
            buildAnimatedPage(key: state.pageKey, child: const IntroScreen()),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) =>
            buildAnimatedPage(key: state.pageKey, child: const LoginScreen()),
      ),
      GoRoute(
        path: '/profileDetail',
        pageBuilder: (context, state) {
          final fromOnboarding =
              state.extra is Map && (state.extra as Map)['fromOnboarding'] == true;

          return buildAnimatedPage(
            key: state.pageKey,
            child: ProfileDetailsScreen(fromOnboarding: fromOnboarding),
          );
        },
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) =>
            buildAnimatedPage(key: state.pageKey, child: const OnboardingScreen()),
      ),
      GoRoute(
        path: '/location',
        pageBuilder: (context, state) =>
            buildAnimatedPage(key: state.pageKey, child: const LocationInfoScreen()),
      ),
      GoRoute(
        path: '/map',
        pageBuilder: (context, state) =>
            buildAnimatedPage(key: state.pageKey, child: const LocationMapScreen()),
      ),

      GoRoute(
        path: '/product-detail',
        pageBuilder: (context, state) {
          final product = state.extra as ProductModel;
          return buildAnimatedPage(
            key: state.pageKey,
            child: ProductDetailScreen(product: product),
          );
        },
      ),
      GoRoute(
        path: '/businessShop-detail',
        pageBuilder: (context, state) {
          final business = state.extra as BusinessModel;
          return buildAnimatedPage(
            key: state.pageKey,
            child: BusinessShopDetailsScreen(business: business),
          );
        },
      ),
      GoRoute(
        path: '/payment',
        pageBuilder: (context, state) {
          final amount = state.extra as double? ?? 0.0;
          return buildAnimatedPage(
            key: state.pageKey,
            child: PaymentScreen(amount: amount),
          );
        },
      ),

      GoRoute(
        path: '/cart',
        pageBuilder: (context, state) =>
            buildAnimatedPage(key: state.pageKey, child: const CartScreen()),
      ),


      GoRoute(
        path: '/notifications',
        pageBuilder: (context, state) =>
            buildAnimatedPage(key: state.pageKey, child: const NotificationScreen()),
      ),

      GoRoute(
        path: '/order-success',
        builder: (context, state) => const OrderSuccessScreen(),
      ),
      GoRoute(
        path: '/order-tracking',
        builder: (context, state) => const OrderTrackingScreen(),
      ),
      GoRoute(
        path: '/thank-you',
        builder: (context, state) => const ThankYouScreen(),
      ),



      // 🔹 ShellRoute (bottom nav)
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(child: child, location: state.uri.toString()),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),

          GoRoute(path: '/explore', builder: (_, __) => const ExploreListScreen()),
          GoRoute(path: '/explore-list', builder: (_, __) => const ExploreListScreen()),
          GoRoute(path: '/explore-map', builder: (_, __) => const ExploreMapScreen()),

          GoRoute(path: '/favorites', builder: (_, __) => const FavoritesScreen()),
          GoRoute(path: '/account', builder: (_, __) => const AccountScreen()),
        ],
      ),
    ],
  );
});
