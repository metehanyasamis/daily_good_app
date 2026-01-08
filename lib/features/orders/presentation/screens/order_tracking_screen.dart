/*

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/time_formatter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/know_more_full.dart';
import '../../../settings/domain/providers/legal_settings_provider.dart';
import '../../data/models/order_details_response.dart';
import '../../domain/providers/active_order_provider.dart';

class OrderTrackingScreen extends ConsumerStatefulWidget {
  final String orderId;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
  });

  @override
  ConsumerState<OrderTrackingScreen> createState() =>
      _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends ConsumerState<OrderTrackingScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      ref.invalidate(activeOrderProvider(widget.orderId));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orderAsync =
    ref.watch(activeOrderProvider(widget.orderId));

    final settingsAsync = ref.watch(legalSettingsProvider);

    return orderAsync.when(
      loading: () => _loadingScaffold(theme),
      error: (e, _) => _errorScaffold(theme, e.toString()),
      data: (order) => _content(context, theme, order, settingsAsync),
    );
  }

  // ---------------------------------------------------------------------------
  // SCAFFOLDS
  // ---------------------------------------------------------------------------

  Scaffold _loadingScaffold(ThemeData theme) {
    return Scaffold(
      appBar: _appBar(theme),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Scaffold _errorScaffold(ThemeData theme, String error) {
    return Scaffold(
      appBar: _appBar(theme),
      body: Center(child: Text("Hata: $error")),
    );
  }

  AppBar _appBar(ThemeData theme) {
    return AppBar(
      backgroundColor: AppColors.primaryDarkGreen,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Text(
        "Sipariş Takibi",
        style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.home_rounded, color: Colors.white),
          onPressed: () => context.go('/home'),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // CONTENT
  // ---------------------------------------------------------------------------

  Scaffold _content(
      BuildContext context,
      ThemeData theme,
      OrderDetailResponse order,
      AsyncValue settingsAsync,
      ) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _appBar(theme),
      body: ListView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildBusinessCard(context, theme, order),
          const SizedBox(height: 12),
          _buildOrderSummary(theme, order),
          const SizedBox(height: 16),
          KnowMoreFull(
            forceBoxMode: true,
            customInfo: settingsAsync.value?.importantInfo,
          ),
        ],
      ),
      // 🎯 Butonu buraya taşıyoruz:
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: CustomButton(
            text: 'Anasayfaya Dön',
            onPressed: () => context.go('/home'),
            showPrice: false,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BUSINESS CARD
  // ---------------------------------------------------------------------------

  Widget _buildBusinessCard(
      BuildContext context,
      ThemeData theme,
      OrderDetailResponse order,
      ) {
    final store = order.store;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Teslim Alma Bilgileri",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {
              context.push('/store-detail/${store.id}');
            },
            child: Row(
              children: [
                Image.network(
                  store.bannerImageUrl,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                  const Icon(Icons.store, size: 48),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.name,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        store.address,
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () => _openMaps(store.address),
                        child: const Text(
                          "Navigasyon için tıklayın 📍",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ORDER SUMMARY
  // ---------------------------------------------------------------------------

  Widget _buildOrderSummary(
      ThemeData theme,
      OrderDetailResponse order,
      ) {
    final item = order.items.first;
    final start = TimeFormatter.hm(item.product.startHour ?? "09:00");
    final end = TimeFormatter.hm(item.product.endHour ?? "18:00");

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Sepet Özeti",
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            "Sipariş No: ${order.orderNumber}",
            style: theme.textTheme.bodySmall,
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item.product.name,
                  style: theme.textTheme.bodyLarge),
              Text(
                "${item.totalPrice.toStringAsFixed(2)} ₺",
                style: theme.textTheme.bodyLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "Teslim alma zamanı: $start - $end",
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Center(
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryDarkGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                order.pickupCode,
                style: const TextStyle(
                  color: Colors.white,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  BoxDecoration _box() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 6,
      ),
    ],
  );

  Future<void> _openMaps(String address) async {
    final uri = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

 */

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/time_formatter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/know_more_full.dart';
import '../../../settings/domain/providers/legal_settings_provider.dart';
import '../../data/models/order_details_response.dart';
import '../../domain/providers/order_provider.dart'; // Aktif sipariş listesini çeken provider

class OrderTrackingScreen extends ConsumerStatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  ConsumerState<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends ConsumerState<OrderTrackingScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Her 30 saniyede bir tüm aktif siparişleri tazele
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      // Not: activeOrdersProvider senin aktif siparişleri liste olarak dönen provider'ın olmalı
      ref.invalidate(activeOrdersProvider);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeOrdersAsync = ref.watch(activeOrdersProvider);
    final settingsAsync = ref.watch(legalSettingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        // 🚀 TÜM STİLİ TEMADAN PAKET OLARAK ÇEKİYORUZ
        backgroundColor: AppTheme.greenAppBarTheme.backgroundColor,
        foregroundColor: AppTheme.greenAppBarTheme.foregroundColor,
        systemOverlayStyle: AppTheme.greenAppBarTheme.systemOverlayStyle, // Şebeke/Pil ikonlarını beyaz yapar
        iconTheme: AppTheme.greenAppBarTheme.iconTheme, // Geri butonunu beyaz yapar
        titleTextStyle: AppTheme.greenAppBarTheme.titleTextStyle,
        centerTitle: AppTheme.greenAppBarTheme.centerTitle,

        title: const Text("Sipariş Takibi"),

        actions: [
          IconButton(
            icon: const Icon(Icons.home_rounded), // Renk artık iconTheme'den otomatik beyaz gelir
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
      body: activeOrdersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Hata: $e")),
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(child: Text("Aktif siparişiniz bulunmamaktadır."));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            children: [
              // 📦 Her bir aktif sipariş için bir beyaz kart basıyoruz
              ...orders.map((order) => _UnifiedOrderCard(order: order)),

              const SizedBox(height: 8),

              // ℹ️ Bilmeniz gerekenler (Tüm siparişler için tek bir tane)
              KnowMoreFull(
                forceBoxMode: true,
                customInfo: settingsAsync.value?.importantInfo,
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: CustomButton(
            text: 'Anasayfaya Dön',
            onPressed: () => context.go('/home'),
            showPrice: false,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 📦 BİRLEŞTİRİLMİŞ SİPARİŞ KARTI (Teslimat + Özet + Kod)
// ---------------------------------------------------------------------------
class _UnifiedOrderCard extends StatelessWidget {
  final OrderDetailResponse order;

  const _UnifiedOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = order.store;
    final item = order.items.first;
    final start = TimeFormatter.hm(item.product.startHour ?? "09:00");
    final end = TimeFormatter.hm(item.product.endHour ?? "18:00");

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- TESLİMAT BİLGİLERİ BAŞLIK ---
          Text(
            "Teslim Alma Bilgileri",
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),

          // --- MAĞAZA SATIRI ---
          InkWell(
            onTap: () => context.push('/store-detail/${store.id}'),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    store.bannerImageUrl,
                    width: 48, height: 48, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.store, size: 48),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(store.name, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
                      Text(store.address, style: theme.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                      InkWell(
                        onTap: () => _openMaps(store.address),
                        child: const Text(
                          "Navigasyon için tıklayın 📍",
                          style: TextStyle(fontSize: 12, decoration: TextDecoration.underline, color: AppColors.primaryDarkGreen),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),

          // --- SEPET ÖZETİ ---
          Text(
            "Sepet Özeti (No: ${order.orderNumber})",
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item.product.name, style: theme.textTheme.bodyLarge),
              Text("${item.totalPrice.toStringAsFixed(2)} ₺",
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          Text("Zaman: $start - $end", style: theme.textTheme.bodySmall),

          const SizedBox(height: 16),

          // --- PICKUP CODE ---
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primaryDarkGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                order.pickupCode,
                style: const TextStyle(color: Colors.white, letterSpacing: 2, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openMaps(String address) async {
    final uri = Uri.parse("https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}