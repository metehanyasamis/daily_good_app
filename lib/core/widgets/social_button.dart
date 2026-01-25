import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class SocialButton extends StatelessWidget {
  final String text;
  final String? assetIcon;
  final IconData? icon;
  final VoidCallback onTap;

  const SocialButton({
    super.key,
    required this.text,
    this.assetIcon,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: AppColors.gray.withValues(alpha: 0.4), width: 1.2),
          color: AppColors.surface,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(icon, size: 26, color: AppColors.textPrimary)
            else if (assetIcon != null)
              Image.asset(assetIcon!, height: 26),

            const SizedBox(width: 12),

            Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
