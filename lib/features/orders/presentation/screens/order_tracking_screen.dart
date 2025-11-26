import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/know_more_full.dart';
import '../../../businessShop/data/mock/mock_businessShop_model.dart';
import '../../data/order_model.dart';
import '../../providers/order_provider.dart';

class OrderTrackingScreen extends ConsumerStatefulWidget {
  const OrderTrackingScreen({super.key});

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
      if (mounted) setState(() {});
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
    final orders = ref.watch(ordersProvider);
    final activeOrders = orders.where((o) => !o.isDelivered).toList();

    if (activeOrders.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryDarkGreen,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
              "Sipariş Takibi", style: TextStyle(color: Colors.white)),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.home_rounded, color: Colors.white),
              onPressed: () => context.go('/home'),
            ),
          ],
        ),
        body: const Center(child: Text("Aktif sipariş bulunmuyor.")),
      );
    }

    final first = activeOrders.first;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDarkGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text("Sipariş Takibi",
            style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.home_rounded, color: Colors.white),
            tooltip: "Ana Sayfa",
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        children: [
          // 🔹 Teslim Alma Bilgileri Kartı
          _buildBusinessCard(context, first),

          const SizedBox(height: 12),

          // 🔹 Sepet Özeti + Ürünler tek kart içinde
          _buildOrderSummaryCard(context, activeOrders, first),

          const SizedBox(height: 16),

          // 🔹 Bilmeniz Gerekenler (widget içinde ama padding uyumu artırıldı)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 8, bottom: 24),
            child: const KnowMoreFull(forceBoxMode: true),
          ),

          // 🔹 Teslim Onay Butonu
          CustomButton(
            text: 'Teslim Almayı Onayla',
            onPressed: () {
              for (final o in activeOrders) {
                ref.read(ordersProvider.notifier).markDelivered(o.id);
              }
              context.go('/thank-you');
            },
            showPrice: false, // 🟢 sade buton
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessCard(BuildContext context, OrderItem order) {
    final theme = Theme.of(context);
    final business = findBusinessById(order.businessId);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // 🟢 Başlık
          Text(
          "Teslim alma bilgileri",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 1,
          width: double.infinity,
          color: AppColors.primaryDarkGreen.withOpacity(0.3),
        ),
        const SizedBox(height: 12),

        // 🏪 İşletme Bilgisi
        InkWell(
        onTap: () {
          if (business != null) {
            context.push('/businessShop-detail', extra: business);
          }
        },
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            order.businessLogo,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
          ),
          const SizedBox(width: 10),

          // 🔹 Metinler
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // İşletme Adı
                Text(
                  order.businessName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),

                // Adres Bilgisi
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.primaryDarkGreen,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        order.businessAddress,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                InkWell(
                  onTap: () => _launchMaps(order.businessAddress),
                  child: Text(
                    "Navigasyon yönlendirmesi için tıklayınız 📍",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[700],
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.primaryDarkGreen,
            size: 22,
          ),
        ],
      ),
    ),]
    ,
    )
    ,
    )
    ,
    );
  }

  Widget _buildOrderSummaryCard(BuildContext context,
      List<OrderItem> activeOrders, dynamic order) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 🟢 Başlık
              Text(
                "Sepet Özeti",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                "Sipariş Numaranız: ${order.id}",
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 1,
            width: double.infinity,
            color: AppColors.primaryDarkGreen.withOpacity(0.3),
          ),
          const SizedBox(height: 12),

          for (final order in activeOrders) ...[
            _buildSingleProduct(context, order),
            if (order != activeOrders.last) const Divider(
                height: 20, thickness: 0.7),
          ],
        ],
      ),
    );
  }

  Widget _buildSingleProduct(BuildContext context, OrderItem order) {
    final theme = Theme.of(context);
    final remaining = order.remainingTime;
    final remainingMinutes = remaining.inMinutes.clamp(0, 9999);
    final progress = 1 - order.progress;
    final start = "${order.pickupStart.hour.toString().padLeft(2, '0')}:${order
        .pickupStart.minute.toString().padLeft(2, '0')}";
    final end = "${order.pickupEnd.hour.toString().padLeft(2, '0')}:${order
        .pickupEnd.minute.toString().padLeft(2, '0')}";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(order.productName, style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600)),
            Text("${order.newPrice.toStringAsFixed(2)} ₺",
                style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "Teslim alma zamanı: Bugün $start - $end",
          style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(AppColors.primaryDarkGreen),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Teslim süresine kalan: ${remainingMinutes ~/
              60} sa ${(remainingMinutes % 60)} dk",
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryDarkGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              order.pickupCode,
              style: theme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _launchMaps(String address) async {
    final encoded = Uri.encodeComponent(address);
    final uri = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=$encoded");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
