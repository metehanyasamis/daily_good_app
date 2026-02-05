import 'package:daily_good/features/orders/presentation/screens/thank_you_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Screens
import '../../features/account/domain/providers/user_notifier.dart';
import '../../features/account/presentation/screens/legal_documents_screen.dart';
import '../../features/account/presentation/screens/profile_details_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/intro_screen.dart';
import '../../features/contact/presentation/contact_screen.dart';
import '../../features/location/presentation/screens/location_picker_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/explore/presentation/screens/explore_list_screen.dart';
import '../../features/explore/presentation/screens/explore_map_screen.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/account/presentation/screens/account_screen.dart';
import '../../features/location/presentation/screens/location_info_screen.dart';
import '../../features/orders/data/models/order_details_response.dart';
import '../../features/orders/data/models/order_list_item.dart';
import '../../features/orders/presentation/screens/order_detail_screen.dart';
import '../../features/orders/presentation/screens/order_history_screen.dart';
import '../../features/product/presentation/screens/product_detail_screen.dart';
import '../../features/review/presentation/screens/store_review_screen.dart';
import '../../features/stores/presentation/screens/store_detail_screen.dart';

import '../../features/notification/presentation/screens/notification_screen.dart';
import '../../features/orders/presentation/screens/order_success_screen.dart';
import '../../features/orders/presentation/screens/order_tracking_screen.dart';
import '../../features/checkout/presentation/screens/payment_screen.dart';
import '../../features/checkout/presentation/screens/payment_webview_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';

import '../../core/widgets/global_error_screen.dart';
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

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();


final appRouterProvider = Provider<GoRouter>((ref) {
  final routerNotifier = RouterNotifier(ref);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: routerNotifier,
    redirect: (context, state) {
      final app = ref.read(appStateProvider);
      final userState = ref.read(userNotifierProvider);
      final user = userState.user;
      final loc = state.uri.toString();

      // 🔥 RÖNTGEN LOGLARI (Hata ayıklama için kalsın)
      debugPrint("""
  🔍 [ROUTER CHECK]
  📍 Mevcut Konum: $loc
  🔑 LoggedIn: ${app.isLoggedIn}
  👶 NewUser: ${app.isNewUser}
  👤 User Data: ${user != null ? 'VAR (Ad: ${user.firstName})' : 'YOK'}
  🗺️ Location Selected: ${app.hasSelectedLocation}
  ---------------------------------
  """);

      // 1️⃣ İSTİSNALAR (Her zaman serbest olanlar)
      if (loc.startsWith('/order-tracking')) return null;
      if (loc.startsWith('/order-success')) return null;
      if (loc.startsWith('/store-detail')) return null;
      if (loc.contains('/reviews')) return null;

      // 2️⃣ BAŞLATMA KONTROLÜ (Initialize bitmeden hiçbir yere gidemez)
      if (loc != "/splash" && !app.isInitialized) return "/splash";
      if (loc == "/splash" && !app.isInitialized) return null;

      // 3️⃣ AUTH KONTROLÜ (Giriş yapılmadıysa)
      if (!app.isLoggedIn) {
        if (loc == "/intro" || loc == "/login" || loc == "/splash") {
          // Eğer splash bittiyse ve intro görülmediyse introya, aksi halde logine
          if (loc == "/splash") return !app.hasSeenIntro ? "/intro" : "/login";
          return null;
        }
        return "/login";
      }

      // 4️⃣ YENİ KULLANICI AKIŞI (AŞIRI KRİTİK: Konumdan önce gelmeli)
      // Loglarda gördüğümüz "Ad: null" durumunu burada yakalıyoruz
      if (app.isNewUser) {
        // Profil detayları (Ad-Soyad) eksik mi?
        if (user?.firstName == null || user!.firstName!.isEmpty) {
          if (loc == "/profileDetail") return null;
          return "/profileDetail";
        }

        // Onboarding süreci tamamlandı mı?
        if (!app.hasSeenOnboarding) {
          if (loc == "/onboarding") return null;
          return "/onboarding";
        }
      }

      // 5️⃣ KONUM KONTROLÜ (Sadece Profil ve Onboarding TAMAMSA bakılır)
      if (!app.hasSelectedLocation) {
        if (loc == "/location-info" || loc == "/location-picker") return null;
        return "/location-info";
      }

      // 6️⃣ ANA SAYFAYA YÖNLENDİRME
      if ((loc == "/login" || loc == "/intro" || loc == "/splash") && app.isLoggedIn && !app.isNewUser) {
        return "/home";
      }

      // Diğer tüm durumlarda kullanıcının gitmek istediği yere izin ver
      return null;
    },
    routes: [
      // ... routes listen aynen kalıyor, oraya dokunmaya gerek yok ...
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
      GoRoute(path: '/location-info', builder: (_, _) => const LocationInfoScreen()),
      GoRoute(path: '/location-picker', builder: (_, _) => const LocationPickerScreen()),
      GoRoute(
        path: '/profileDetail',
        builder: (context, state) {
          final bool isFromReg = (state.extra is bool) ? (state.extra as bool) : false;

          return ProfileDetailsScreen(isFromRegister: isFromReg);
        },
      ),


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
      GoRoute(path: '/payment', builder: (_, _) => const PaymentScreen()),
      GoRoute(
        path: '/payment-webview',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final checkoutUrl = extra?['checkout_url'] as String? ?? '';
          return PaymentWebViewScreen(checkoutUrl: checkoutUrl);
        },
      ),
      GoRoute(path: '/cart', builder: (_, _) => const CartScreen()),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => NotificationScreen(),
      ),
      GoRoute(
        path: '/order-success',
        builder: (_, state) => OrderSuccessScreen(orderId: state.uri.queryParameters['id']),
      ),


      GoRoute(
        path: '/order-tracking',
        builder: (_, _) => const OrderTrackingScreen(),
      ),

      GoRoute(
        path: '/thank-you',
        builder: (_, _) => const ThankYouScreen(),
      ),

      GoRoute(
        path: '/order-history',
        builder: (context, state) => const OrderHistoryScreen(),
        routes: [
          // 🟢 Burası /order-history/detail/:orderId olur
          GoRoute(
            path: 'detail/:orderId',
            builder: (context, state) {
              // 🔥 Burayı OrderListItem olarak değiştiriyoruz
              final orderObj = state.extra as OrderListItem;

              // Detay ekranına gönderiyoruz
              return OrderDetailScreen(order: orderObj);
            },
          ),
        ],
      ),


      GoRoute(
        path: 'detail/:orderId',
        builder: (context, state) {
          // state.extra, senin gönderdiğin OrderDetailResponse objesidir.
          final orderObj = state.extra as OrderDetailResponse;

          return OrderDetailScreen(order: orderObj); // Hata veren yer burasıydı, düzeldi.
        },
      ),

      GoRoute(
        path: '/contact',
        builder: (context, state) => const ContactScreen(), // Artık bu sayfa bulunabilir olacak
      ),

      GoRoute(
        path: '/legal-documents',
        name: 'legal_docs',
        builder: (context, state) => const LegalDocumentsScreen(),
      ),

      GoRoute(
        path: '/global-error',
        builder: (context, state) => const GlobalErrorScreen(),
      ),

      ShellRoute(
        builder: (_, state, child) => AppShell(location: state.uri.toString(), child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
          GoRoute(path: '/explore', builder: (_, _) => const ExploreListScreen()),
          GoRoute(path: '/explore-map', builder: (_, _) => const ExploreMapScreen()),
          GoRoute(path: '/favorites', builder: (_, _) => const FavoritesScreen()),
          GoRoute(path: '/account', builder: (_, _) => const AccountScreen()),
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
    ref.listen(appStateProvider, (_, _) {
      notifyListeners();
    });

    // auth değiştiğinde de tetikle
    ref.listen(userNotifierProvider, (_, _) {
      notifyListeners();
    });
  }
}