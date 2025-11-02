import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class CountdownProgress extends StatelessWidget {
  final Duration remaining;
  final double progress;

  const CountdownProgress({
    super.key,
    required this.remaining,
    required this.progress,
  });

  String get timeLeft {
    if (remaining.isNegative) return "Süre doldu";
    final h = remaining.inHours;
    final m = remaining.inMinutes.remainder(60);
    return "$h sa ${m.toString().padLeft(2, '0')} dk";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: progress,
          minHeight: 6,
          backgroundColor: Colors.grey.shade300,
          color: AppColors.primaryDarkGreen,
          borderRadius: BorderRadius.circular(10),
        ),
        const SizedBox(height: 6),
        Text(
          "Teslim süresine kalan: $timeLeft",
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
      ],
    );
  }
}
