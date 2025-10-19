import 'package:daily_good/core/widgets/custom_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class AppShell extends StatelessWidget {
  final Widget child;
  final String location;

  const AppShell({super.key, required this.child, required this.location});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      extendBody: true, // 👈 içerik barın altına “akar”
      body: Stack(
       // clipBehavior: Clip.none,
        children: [
          child, // ekranın asıl içeriği

          // 👇 bar artık sayfa içinde ayrı bir overlay
          Positioned(
            left: 16,
            right: 16,
            bottom: 12,
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
