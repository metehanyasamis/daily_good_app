import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomToggleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isActive;
  final bool alignRight;

  const CustomToggleButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isActive = true,
    this.alignRight = true,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: alignRight ? 0 : null,
      left: alignRight ? null : 0,
      bottom: (MediaQuery.of(context).padding.bottom > 0
          ? MediaQuery.of(context).padding.bottom
          : 20) +
          90,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: isActive ? Colors.white : AppColors.primaryDarkGreen),
        label: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.primaryDarkGreen,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? AppColors.primaryDarkGreen : Colors.white,
          elevation: 5,
          shadowColor: Colors.black26,
          minimumSize: const Size(100, 44),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              bottomLeft: Radius.circular(30),
            ),
          ),
        ),
      ),
    );
  }
}
