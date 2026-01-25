import 'package:daily_good/core/widgets/custom_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class AppShell extends StatelessWidget {
  final Widget child;
  final String location;

  const AppShell({super.key, required this.child, required this.location});

// lib/core/router/app_shell.dart

  @override
  Widget build(BuildContext context) {
    // Sistemin alt bar yüksekliğini alıyoruz
    final double bottomGap = MediaQuery.of(context).viewPadding.bottom;
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    debugPrint("⌨️ [APP_SHELL] keyboardOpen=$keyboardOpen location=$location");

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      body: Stack(
        children: [
          child, // Ekran içeriği

          Positioned(
            left: 16,
            right: 16,
            bottom: (bottomGap > 0 ? bottomGap : 20) + 8,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 180),
              offset: keyboardOpen ? const Offset(0, 1.2) : Offset.zero, // ✅ aşağı kaydır
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: keyboardOpen ? 0 : 1, // ✅ görünmez yap
                child: IgnorePointer(
                  ignoring: keyboardOpen, // ✅ tıklanamasın
                  child: CustomBottomNavBar(
                    currentIndex: _calculateSelectedIndex(location),
                    onTabSelected: (index) {
                      switch (index) {
                        case 0: context.go('/home'); break;
                        case 1: context.go('/explore'); break;
                        case 2: context.go('/favorites'); break;
                        case 3: context.go('/account'); break;
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(String location) {
    if (location.startsWith('/explore')) return 1;
    if (location.startsWith('/favorites')) return 2;
    if (location.startsWith('/account')) return 3;
    return 0;
  }
}

