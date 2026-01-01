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
          const SizedBox(height: 16),


          CustomButton(
            text: 'Teslim Almayı Onayla',
            onPressed: () async {
              // Kullanıcıya bir onay penceresi açalım
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Teslimat Onayı"),
                  content: const Text("Ürünü mağazadan teslim aldığınızı onaylıyor musunuz?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Vazgeç")),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDarkGreen),
                      child: const Text("Evet, Aldım"),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                // Burada normalde API çağrısı olurdu. Şimdilik direkt gidiyoruz.
                context.go('/thank-you');
              }
            },
            showPrice: false,
          ),

          const SizedBox(height: 16),

          CustomButton(
            text: 'Anasayfaya Dön',
            onPressed: () => context.go('/home'),
            showPrice: false,
          ),
        ],
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
            "Teslim alma bilgileri",
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
