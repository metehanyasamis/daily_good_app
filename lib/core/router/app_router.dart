import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Screens
import '../../features/account/domain/providers/user_notifier.dart';
import '../../features/account/presentation/screens/profile_details_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/intro_screen.dart';
import '../../features/contact/presentation/contact_screen.dart';
import '../../features/contact/presentation/contact_success_screen.dart';
import '../../features/location/presentation/screens/location_picker_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';

import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/explore/presentation/screens/explore_list_screen.dart';
import '../../features/explore/presentation/screens/explore_map_screen.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/account/presentation/screens/account_screen.dart';

import '../../features/location/presentation/screens/location_info_screen.dart';

import '../../features/product/presentation/screens/product_detail_screen.dart';

// STORE
import '../../features/stores/presentation/screens/store_detail_screen.dart';

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

// --------------------------------------------------------------
// GO_ROUTER
// --------------------------------------------------------------
final appRouterProvider = Provider<GoRouter>((ref) {
  final routerNotifier = RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: routerNotifier,  // ❗ BU SAYEDE REDIRECT ARTIK ÇALIŞACAK

    redirect: (context, state) {

      final app = ref.read(appStateProvider);
      final userState = ref.read(userNotifierProvider);
      final user = userState.user;

      final loc = state.uri.toString();
      if (loc.startsWith('/order-tracking')) return null;
      if (loc.startsWith('/store-detail')) return null;


      debugPrint("\n──────────────────────────────────────────────");
      debugPrint("🔀 ROUTER REDIRECT ÇALIŞTI");
      //debugPrint("📍 Current: $loc");


      // ───────────────────────────────────────────
      // SPLASH → initialize sonrası nereye gidilecek?
      // ───────────────────────────────────────────
      if (loc == "/splash") {
        // App henüz load edilmediyse splash’ta kal
        if (!app.isInitialized) return null;

        // 1) Login DEĞİLSE → intro/login akışı
        if (!app.isLoggedIn) {
          return !app.hasSeenIntro ? "/intro" : "/login";
        }

        // 2) Yeni kullanıcı onboarding akışı
        final hasProfile = user?.firstName?.isNotEmpty == true;

        if (app.isNewUser) {
          if (!hasProfile) return "/profileDetail";
          if (!app.hasSeenOnboarding) return "/onboarding";
          if (!app.hasSelectedLocation) return "/location-info";
          return "/home";
        }

        // 3) Normal kullanıcı ama konum seçmemiş
        if (!app.hasSelectedLocation) return "/location-info";

        // 4) Her şey tamamsa → HOME
        return "/home";
      }


      // --------------------------------------------------
      // ALLOW → /location-picker (redirect engellenmesin)
      // --------------------------------------------------
      if (loc == "/location-picker") {
        debugPrint("➡️ (/location-picker) redirect BYPASS");
        return null;
      }

      debugPrint("📍 Current: $loc");
      debugPrint("📦 AppState: "
          "initialized=${app.isInitialized}, "
          "loggedIn=${app.isLoggedIn}, "
          "newUser=${app.isNewUser}, "
          "profile=${user?.firstName}, "
          "onboarding=${app.hasSeenOnboarding}, "
          "location=${app.hasSelectedLocation}");
      debugPrint("──────────────────────────────────────────────\n");


      // ⭐ SPLASH çıkış fix
      // Eğer app initialize olduysa ve hala splash'taysak → splash’tan çık
      if (loc == "/splash" && app.isInitialized) {
        debugPrint("➡️ Splash tamam → yönlendirme başlasın");

        // Login değilse login'e
        if (!app.isLoggedIn) return "/login";

        // Yeni kullanıcıysa new user flow'a
        if (app.isNewUser) {
          return "/profileDetail";
        }

        // Login + eski kullanıcı
        return "/home";
      }


      // ───────────────────────────────────────────
      // 0) App initialize edilmemiş → Splash
      // ───────────────────────────────────────────
      if (!app.isInitialized) {
        debugPrint("⏳ [INIT] App not initialized → redirect → /splash");
        return "/splash";
      }


      // ───────────────────────────────────────────
      // 1) Login değil → Intro → Login
      // ───────────────────────────────────────────
      if (!app.isLoggedIn) {
        debugPrint("🔒 [AUTH] User not logged in");

        if (!app.hasSeenIntro && loc != "/intro") {
          debugPrint("➡️  Intro görülmedi → redirect → /intro");
          return "/intro";
        }

        if (loc == "/intro") {
          debugPrint("ℹ️ Intro screen allowed");
          return null;
        }

        if (loc != "/login") {
          debugPrint("➡️  Require login → redirect → /login");
          return "/login";
        }

        debugPrint("👍 Login screen allowed");
        return null;
      }


      // ───────────────────────────────────────────
      // 2) Yeni kullanıcı onboarding flow
      // ───────────────────────────────────────────
      final hasProfile = user?.firstName?.isNotEmpty == true;

      if (app.isNewUser) {
        debugPrint("🆕 [NEW USER FLOW] Active");

        if (!hasProfile) {
          if (loc != "/profileDetail") {
            debugPrint("➡️  No profile → redirect → /profileDetail");
            return "/profileDetail";
          }
          debugPrint("👍 Profile screen allowed");
          return null;
        }

        if (!app.hasSeenOnboarding) {
          if (loc != "/onboarding") {
            debugPrint("➡️  Onboarding needed → redirect → /onboarding");
            return "/onboarding";
          }
          debugPrint("👍 Onboarding screen allowed");
          return null;
        }

        if (!app.hasSelectedLocation) {
          if (loc != "/location-info") {
            debugPrint("➡️  Location required → redirect → /location-info");
            return "/location-info";
          }
          debugPrint("👍 Location Info allowed");
          return null;
        }

        const restricted = [
          "/login", "/intro", "/profileDetail", "/onboarding", "/location-info"
        ];

        if (restricted.contains(loc)) {
          debugPrint("🚫 Restricted → redirect → /home");
          return "/home";
        }

        debugPrint("🟢 New user flow completed. Continue normally.");
        return null;
      }


      // ───────────────────────────────────────────
      // 3) Normal kullanıcı ama lokasyon yok → Location Info
      // ───────────────────────────────────────────
      if (!app.hasSelectedLocation) {
        if (loc != "/location-info") {
          debugPrint("📍 Location missing → redirect → /location-info");
          return "/location-info";
        }
        debugPrint("👍 Location Info allowed");
        return null;
      }


      // ───────────────────────────────────────────
      // 4) Normal kullanıcı login/onboarding ekranlarına gidemez
      // ───────────────────────────────────────────
      const blocked = [
        "/login",
        "/intro",
        "/onboarding",
        "/location-info"
        // "/profileDetail" artık serbest
      ];

      if (blocked.contains(loc)) {
        debugPrint("🚫 Old user accessing blocked screen → redirect → /home");
        return "/home";
      }

      debugPrint("✅ No redirect. Continue → $loc");
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
        pageBuilder: (_, state) => buildAnimatedPage(
          child: const OnboardingScreen(),
          key: state.pageKey,
        ),
      ),

      // ---------------- FULLSCREEN ----------------
      GoRoute(
        path: '/location-info',
        builder: (_, state) => const LocationInfoScreen(),
      ),

      GoRoute(
        path: '/location-picker',
        builder: (_, state) => const LocationPickerScreen(),
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
        path: '/store-detail/:id',
        pageBuilder: (_, state) {
          final storeId = state.pathParameters['id']!;
          return buildAnimatedPage(
            key: state.pageKey,
            child: StoreDetailScreen(storeId: storeId),
          );
        },
      ),


      // ---------------- PAYMENT & CART ----------------
      GoRoute(
        path: '/payment',
        builder: (_, state) => const PaymentScreen(),
      ),
      GoRoute(path: '/cart', builder: (_, _) => const CartScreen()),

      // ---------------- NOTIFICATIONS & ORDERS & SUPPORT ----------------
      GoRoute(
        path: '/notifications',
        builder: (_, _) => const NotificationScreen(),
      ),
      GoRoute(
        path: '/order-success',
        builder: (_, _) => const OrderSuccessScreen(),
      ),
      GoRoute(
        path: '/order-tracking/:id',
        builder: (context, state) {
          final orderId = state.pathParameters['id']!;
          return OrderTrackingScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/thank-you',
        builder: (_, _) => const ThankYouScreen(),
      ),
      GoRoute(
        path: '/order-history',
        builder: (_, _) => const OrderHistoryScreen(),
      ),
      GoRoute(path: '/contact', builder: (_, _) => const ContactScreen()),
      GoRoute(
        path: '/contact-success',
        builder: (_, _) => const ContactSuccessScreen(),
      ),

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
          GoRoute(
              path: '/favorites', builder: (_, _) => const FavoritesScreen()),
          GoRoute(path: '/account', builder: (_, _) => const AccountScreen()),
        ],
      ),
    ],
  );
});

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