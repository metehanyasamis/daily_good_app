import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class BusinessLogo extends StatelessWidget {
  final String imagePath;
  final double size;

  const BusinessLogo({
    super.key,
    required this.imagePath,
    this.size = 70,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primaryDarkGreen,
          width: 1.2,
        ),
      ),
      child: ClipOval(
        child: FittedBox(
          clipBehavior: Clip.hardEdge,
          fit: BoxFit.cover,
          child: Image.asset(imagePath),
        ),
      ),
    );
  }
}
