import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class HomeActiveOrderBox extends StatelessWidget {
  final VoidCallback onTap;

  const HomeActiveOrderBox({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primaryDarkGreen.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primaryDarkGreen,
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              "Sipariş Durumunu Görüntüle!",
              style: TextStyle(
                color: AppColors.primaryDarkGreen,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: AppColors.primaryDarkGreen,
            ),
          ],
        ),
      ),
    );
  }
}
