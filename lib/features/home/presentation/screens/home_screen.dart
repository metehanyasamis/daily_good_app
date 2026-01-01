import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_home_app_bar.dart';
import '../../../../core/widgets/floating_order_button.dart';

import '../../../category/domain/category_notifier.dart';
import '../../../explore/presentation/widgets/explore_filter_sheet.dart';
import '../../../location/domain/address_notifier.dart';

import '../../../notification/domain/providers/notification_provider.dart';
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

    Future.microtask(() {
      debugPrint("🏠 [HOME] initState");

      // 1️⃣ Category load (auth gerekmiyor)
      ref.read(categoryProvider.notifier).load();

      // 2️⃣ Address kontrol
      final address = ref.read(addressProvider);
      debugPrint("📍 [HOME] address.isSelected = ${address.isSelected}");

      if (!address.isSelected) {
        debugPrint("⛔ [HOME] Konum seçilmedi → home load yok");
        return;
      }

      // 3️⃣ HOME TEK ÇAĞRI
      ref.read(homeStateProvider.notifier).loadHome(
        latitude: address.lat,
        longitude: address.lng,
      );

      _updateNotificationToken();
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

    return Scaffold(
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
                      ref
                          .read(homeStateProvider.notifier)
                          .setCategory(index);

                      context.push(
                        '/explore',
                        extra: {
                          'categoryId': categories[index].id,
                          'fromHome': true,
                        },
                      );
                    },
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
    );
  }
}

class HomeContent extends ConsumerWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeStateProvider);

    final isLoading =
    homeState.loadingSections.values.any((v) => v);

    final hasAnyData =
    homeState.sectionProducts.values.any((l) => l.isNotEmpty);

    debugPrint(
      "📄 [HOME CONTENT] "
          "loading=${homeState.loadingSections} "
          "sizes=${homeState.sectionProducts.map((k,v)=>MapEntry(k.name,v.length))}",
    );

    if (isLoading && !hasAnyData) {
      return const Center(child: CircularProgressIndicator());
    }

    final hemenYaninda =
        homeState.sectionProducts[HomeSection.hemenYaninda] ?? const [];
    final sonSans =
        homeState.sectionProducts[HomeSection.sonSans] ?? const [];
    final yeni =
        homeState.sectionProducts[HomeSection.yeni] ?? const [];
    final bugun =
        homeState.sectionProducts[HomeSection.bugun] ?? const [];
    final yarin =
        homeState.sectionProducts[HomeSection.yarin] ?? const [];

    return ListView(
      padding: const EdgeInsets.only(bottom: kBottomNavigationBarHeight + 24),
      children: [
        const HomeEmailWarningBanner(),

        if (hemenYaninda.isNotEmpty) ...[
          _buildSectionHeader(context, "Hemen Yanında", ExploreFilterOption.hemenYaninda),
          HomeProductList(products: hemenYaninda),
        ],

        if (sonSans.isNotEmpty) ...[
          _buildSectionHeader(context, "Son Şans", ExploreFilterOption.sonSans),
          HomeProductList(products: sonSans),
        ],

        if (yeni.isNotEmpty) ...[
          _buildSectionHeader(context, "Yeni", ExploreFilterOption.yeni),
          HomeProductList(products: yeni),
        ],

        if (bugun.isNotEmpty) ...[
          _buildSectionHeader(context, "Bugün", ExploreFilterOption.bugun),
          HomeProductList(products: bugun),
        ],

        if (yarin.isNotEmpty) ...[
          _buildSectionHeader(context, "Yarın", ExploreFilterOption.yarin),
          HomeProductList(products: yarin),
        ],

        const SizedBox(height: 32),
      ],
    );


  }

  Widget _buildSectionHeader(BuildContext context, String title, ExploreFilterOption filter) {
    return InkWell(
      onTap: () => context.push(
        '/explore',
        extra: {
          'filter': filter,
          'fromHome': true,
        },
      ),
      child: HomeSectionTitle(title: title), // Mevcut widget'ın
    );
  }
}
