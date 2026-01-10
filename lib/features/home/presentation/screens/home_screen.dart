import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/platform/haptics.dart';
import '../../../../core/platform/platform_utils.dart';
import '../../../../core/platform/platform_widgets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_home_app_bar.dart';
import '../../../../core/widgets/floating_order_button.dart';

import '../../../account/domain/providers/user_notifier.dart';
import '../../../category/domain/category_notifier.dart';
import '../../../explore/domain/providers/explore_state_provider.dart';
import '../../../explore/presentation/widgets/explore_filter_sheet.dart';
import '../../../location/domain/address_notifier.dart';

import '../../../notification/domain/providers/notification_provider.dart';
import '../../../orders/domain/providers/order_provider.dart';
import '../data/models/home_state.dart';
import '../domain/providers/home_state_provider.dart';

import '../widgets/home_active_order_box.dart';
import '../widgets/home_banner_slider.dart';
import '../widgets/home_category_bar.dart';
import '../widgets/home_email_warning_banner.dart';
import '../widgets/home_location_request_sheet.dart';
import '../widgets/home_product_list.dart';
import '../widgets/home_section_title.dart';

import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';


class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      debugPrint("🏠 [HOME] Veriler Tazeleniyor...");
      
      // 🎯 loadUser'ı bekle (await koyarsak veri gelene kadar banner beklemede kalır)
      await ref.read(userNotifierProvider.notifier).loadUser();

      // Diğerlerini de sırayla veya beraber yükle
      ref.read(categoryProvider.notifier).load();

      // 🎯 Siparişleri de tazele!
      ref.invalidate(orderHistoryProvider);

      final address = ref.read(addressProvider);
      if (address.isSelected) {
        ref.read(homeStateProvider.notifier).loadHome(
          latitude: address.lat,
          longitude: address.lng,
        );
      }
    });
  }


  Future<void> _updateNotificationToken() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) return;

      final deviceInfo = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();

      String deviceName = "Unknown";
      String deviceId = "Unknown";

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceName = androidInfo.model;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceName = iosInfo.name;
        deviceId = iosInfo.identifierForVendor ?? "unknown_ios";
      }

      // Repository üzerinden backend'e gönderiyoruz
      await ref.read(notificationRepositoryProvider).saveDeviceToken(
        fcmToken: fcmToken,
        deviceId: deviceId,
        deviceName: deviceName,
        deviceType: Platform.isAndroid ? "android" : "ios",
        appVersion: packageInfo.version,
      );

      debugPrint("✅ [FCM] Token başarıyla backend'e kaydedildi.");
    } catch (e) {
      debugPrint("❌ [FCM] Token kaydedilirken hata: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeStateProvider);
    final addressState = ref.watch(addressProvider);
    final categoryState = ref.watch(categoryProvider);
    final categories = categoryState.categories;

    debugPrint(
      "🏠 [HOME BUILD] sections="
          "${homeState.sectionProducts.map((k,v)=>MapEntry(k.name,v.length))}",
    );

    final bool isHome = GoRouterState.of(context).uri.toString() == '/home' ||
        GoRouterState.of(context).uri.toString() == '/';


    // 🔥 KONUM DEĞİŞTİĞİNDE VERİLERİ YENİLE
    ref.listen(addressProvider, (previous, next) {
      if (next.isSelected && (previous?.lat != next.lat || previous?.lng != next.lng)) {
        debugPrint("📍 Konum değişti, ana sayfa yenileniyor...");
        ref.read(homeStateProvider.notifier).loadHome(
          latitude: next.lat,
          longitude: next.lng,
        );
      }
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // Android: Siyah ikonlar
        statusBarBrightness: Brightness.light,    // iOS: Siyah ikonlar
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: CustomHomeAppBar(
            address: addressState.title,
            onLocationTap: () {
              final address = ref.read(addressProvider);
      
              if (!address.isSelected) {
                // Ayrı sınıf yaptığımız widget'ı burada çağırıyoruz
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (context) => const HomeLocationRequestSheet(),
                );
              } else {
                context.push('/location-picker');
              }
            },
              onNotificationsTap: () => context.push('/notifications'),
          ),
        ),
        body: Stack(
          children: [
            NestedScrollView(
              headerSliverBuilder: (context, _) => [
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: HomeBannerSlider(),
                  ),
                ),
      
                if (categories.isNotEmpty)
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: HomeCategoryBar(
                      categories: categories,
                      selectedIndex: homeState.selectedCategoryIndex,
                        onSelected: (index) {
                          // 1) home state güncelle (istersen kalsın)
                          ref.read(homeStateProvider.notifier).setCategory(index);
      
                          final id = categories[index].id;
      
                          debugPrint("🏠➡️ [HOME_CAT→EXPLORE] index=$index id=$id");
      
                          // 2) Explore’a git + extra ile categoryId gönder
                          context.push(
                            '/explore',
                            extra: {
                              'fromHome': true,
                              'categoryId': id, // ✅ int gönder, explore'da toString yaparsın
                              // 'filter': ExploreFilterOption.hemenYaninda, // istersen boş bırak
                            },
                          );
                        }
                    ),
      
                  ),
      
                if (homeState.hasActiveOrder)
                  SliverToBoxAdapter(
                    child: HomeActiveOrderBox(
                      onTap: () => context.push('/order-tracking'),
                    ),
                  ),
              ],
              body: const HomeContent(),
            ),
            const FloatingOrderButton(),
          ],
        ),
      ),
    );
  }
}

class HomeContent extends ConsumerWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeStateProvider);

    // Yükleme ve veri kontrolü
    final isLoading = homeState.loadingSections.values.any((v) => v);
    final hasAnyData = homeState.sectionProducts.values.any((l) => l.isNotEmpty);

    if (isLoading && !hasAnyData) {
      return Center(
        child: PlatformWidgets.loader(),
      );
    }

    // Verileri lokal değişkenlere alıyoruz
    final hemenYaninda = homeState.sectionProducts[HomeSection.hemenYaninda] ?? const [];
    final sonSans = homeState.sectionProducts[HomeSection.sonSans] ?? const [];
    final yeni = homeState.sectionProducts[HomeSection.yeni] ?? const [];
    final bugun = homeState.sectionProducts[HomeSection.bugun] ?? const [];
    final yarin = homeState.sectionProducts[HomeSection.yarin] ?? const [];

    // 🚀 1. Ortak Yenileme Fonksiyonu
    Future<void> onRefresh() async {
      // Platforma özel dokunsal geri bildirim
      await Haptics.light();

      final address = ref.read(addressProvider);
      if (address.isSelected) {
        await ref.read(homeStateProvider.notifier).loadHome(
          latitude: address.lat,
          longitude: address.lng,
          forceRefresh: true,
        );
      }
    }

    // 🚀 2. Ortak Liste İçeriği (Body)
    // Her iki platform da bu içeriği kullanacak
    Widget buildBody() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HomeEmailWarningBanner(),
          if (hemenYaninda.isNotEmpty) ...[
            _buildSectionHeader(context, ref, "Hemen Yanında", ExploreFilterOption.hemenYaninda),
            HomeProductList(products: hemenYaninda),
          ],
          if (sonSans.isNotEmpty) ...[
            _buildSectionHeader(context, ref, "Son Şans", ExploreFilterOption.sonSans),
            HomeProductList(products: sonSans),
          ],
          if (yeni.isNotEmpty) ...[
            _buildSectionHeader(context, ref, "Yeni", ExploreFilterOption.yeni),
            HomeProductList(products: yeni),
          ],
          if (bugun.isNotEmpty) ...[
            _buildSectionHeader(context, ref, "Bugün", ExploreFilterOption.bugun),
            HomeProductList(products: bugun),
          ],
          if (yarin.isNotEmpty) ...[
            _buildSectionHeader(context, ref, "Yarın", ExploreFilterOption.yarin),
            HomeProductList(products: yarin),
          ],
          const SizedBox(height: 32),
        ],
      );
    }

    // 🚀 3. Platforma Özel Gösterim (Adaptive UI)
    // PlatformUtils kullanarak cihazı kontrol ediyoruz
    if (PlatformUtils.isIOS) {
      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // iOS Stili Yenileme (Native Çark)
          CupertinoSliverRefreshControl(onRefresh: onRefresh),

          SliverPadding(
            padding: const EdgeInsets.only(bottom: kBottomNavigationBarHeight + 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                buildBody(),
              ]),
            ),
          ),
        ],
      );
    } else {
      // Android Stili Yenileme (Material Halka)
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: kBottomNavigationBarHeight + 24),
          children: [
            buildBody(),
          ],
        ),
      );
    }
  }

  // Section Header Metodu (Değişmedi)
  Widget _buildSectionHeader(
      BuildContext context,
      WidgetRef ref,
      String title,
      ExploreFilterOption filter,
      ) {
    return InkWell(
      onTap: () async {
        await Haptics.light(); // Tıklama hissi [cite: 25]
        ref.read(exploreStateProvider.notifier).setFeedFilter(filter);
        final homeState = ref.read(homeStateProvider);
        final categories = ref.read(categoryProvider).categories;
        final selectedCategoryId = categories.isNotEmpty
            ? categories[homeState.selectedCategoryIndex].id
            : null;

        ref.read(exploreStateProvider.notifier).setCategoryId(selectedCategoryId.toString());

        context.push(
          '/explore',
          extra: {
            'filter': filter,
            'fromHome': true,
            'categoryId': selectedCategoryId,
          },
        );
      },
      child: HomeSectionTitle(title: title),
    );
  }
}