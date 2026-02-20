import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/order_list_item.dart';

// 🚀 KRİTİK IMPORT:
import '../screens/order_history_screen.dart';

class MonthlyOrderGroup extends StatefulWidget {
  final String monthTitle;
  final List<OrderListItem> orders;
  final DateFormat dateFormatter;

  const MonthlyOrderGroup({
    super.key,
    required this.monthTitle,
    required this.orders,
    required this.dateFormatter,
  });

  @override
  State<MonthlyOrderGroup> createState() => _MonthlyOrderGroupState();
}

class _MonthlyOrderGroupState extends State<MonthlyOrderGroup> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${widget.monthTitle} (${widget.orders.length} Sipariş)",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.primaryDarkGreen,
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded)
          Column(
            children: widget.orders.map((order) {
              return GestureDetector(
                onTap: () => context.push(
                  '/order-history/detail/${order.id}',
                  extra: order,
                ),
                child: buildOrderCard(
                  // 👈 Artık hatasız çalışacak
                  context: context,
                  order: order,
                  dateFormatter: widget.dateFormatter,
                ),
              );
            }).toList(),
          ),
        Divider(thickness: 1, color: Colors.grey.shade300),
      ],
    );
  }
}
