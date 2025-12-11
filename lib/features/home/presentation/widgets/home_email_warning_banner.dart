import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../account/domain/providers/user_notifier.dart';

class HomeEmailWarningBanner extends ConsumerWidget {
  const HomeEmailWarningBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userNotifierProvider);
    final user = userState.user;

    // Kullanıcı yoksa gösterme
    if (user == null) return const SizedBox.shrink();

    // E-posta doğrulanmışsa gösterme
    if (user.isEmailVerified == true) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: Colors.orange.shade800, size: 22),
          const SizedBox(width: 8),

          Expanded(
            child: Text(
              "E-posta adresinizi doğrulamanız gerekiyor.",
              style: TextStyle(
                color: Colors.orange.shade900,
                fontSize: 14,
              ),
            ),
          ),

          TextButton(
            onPressed: () => context.push('/email-verify'),
            child: Text(
              "Doğrula",
              style: TextStyle(
                color: Colors.orange.shade900,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }
}
