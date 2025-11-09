import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/mock_orders.dart';
import '../../data/order_model.dart';
import 'order_detail_screen.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd MMMM yyyy', 'tr_TR');

    if (mockOrders.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Geçmiş Siparişlerim'),
          centerTitle: true,
          backgroundColor: AppColors.primaryDarkGreen,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        body: const Center(
          child: Text(
            'Henüz geçmiş siparişiniz bulunmamaktadır.',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ),
      );
    }

    // 🔹 Siparişleri aya göre grupla
    final grouped = <String, List<OrderItem>>{};
    for (final order in mockOrders) {
      final key = DateFormat('MMMM yyyy', 'tr_TR').format(order.orderTime);
      grouped.putIfAbsent(key, () => []).add(order);
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.primaryDarkGreen,
        title: const Text(
          'Geçmiş Siparişlerim',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.grey.shade100,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: grouped.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔸 Ay başlığı
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  entry.key[0].toUpperCase() + entry.key.substring(1),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              // 🔹 Sipariş kartları
              ...entry.value.map((order) => GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderDetailScreen(order: order),
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 🟢 Logo
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          order.businessLogo,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 10),

                      // 🟢 İşletme bilgisi
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.businessName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dateFormatter.format(order.orderTime),
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 🔹 Sağ bilgi bloğu (figma düzenine göre 3 satırlı)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _metricColumn(
                            icon: Icons.savings_outlined,
                            value: '${order.newPrice.toStringAsFixed(0)} TL',
                            label: 'Tasarruf Ettin',
                          ),
                          const SizedBox(width: 8),
                          _metricColumn(
                            icon: Icons.eco_outlined,
                            value: '${order.carbonSaved.toStringAsFixed(1)} kg CO₂',
                            label: 'Önledin',
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.chevron_right, color: AppColors.primaryDarkGreen),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
            ],
          );
        }).toList(),
      ),
    );
  }

  // 🔸 Bilgi bloğu (tasarruf ve CO₂)
  Widget _metricColumn({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 30, color: AppColors.primaryDarkGreen),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDarkGreen,
            fontSize: 13,
          ),
        ),
        //const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

}
