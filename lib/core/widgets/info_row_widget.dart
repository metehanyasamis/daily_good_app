import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class InfoRowWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool? isVerified;
  final VoidCallback? onVerify;

  const InfoRowWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.isVerified,
    this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryDarkGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                '$label : ',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(color: Colors.black87),
                ),
              ),
            ],
          ),
          if (isVerified != null)
            Padding(
              padding: const EdgeInsets.only(left: 28, top: 2),
              child: Row(
                children: [
                  Icon(
                    isVerified! ? Icons.check_circle : Icons.info_outline,
                    color: isVerified! ? Colors.green : Colors.orange,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isVerified! ? 'Doğrulandı' : 'Doğrulanmadı',
                    style: TextStyle(
                      fontSize: 12,
                      color: isVerified! ? Colors.green : Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (!isVerified! && onVerify != null)
                    TextButton(
                      onPressed: onVerify,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Padding'i daralttık
                        minimumSize: Size.zero, // Minimum yükseklik zorunluluğunu kaldırdık
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Tıklama alanını metne göre daralttık
                      ),
                      child: const Text(
                        'Şimdi Doğrula',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
