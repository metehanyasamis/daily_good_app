import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/data/prefs_service.dart';
import '../../../../core/providers/app_state_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Şehrinde keşif zamanı',
      'description':
      'Daily Good ile yerel restoran, kafe ve dükkanlardan günün sürpriz paketlerini uygun fiyata alabilir, hem bütçene hem doğaya katkı sağlarsın.',
      'icon': Image.asset('assets/icons/city_icon.png')
    },
    {
      'title': 'Sürpriz lezzet paketleri',
      'description':
      'İşletmeler günün sonunda tam olarak hangi yiyeceklerin kalacağını bilemezler, bu sebeple tüm paketler her zaman sürprizlerle doludur.',
      'icon': Image.asset('assets/icons/surprise_icon.png')
    },
    {
      'title': 'Birlikte kazanalım',
      'description':
      'Farklı ürünlere uygun fiyatla ulaşırken aynı zamanda işletmelere destek olursun. Onlar israfı azaltır, sen de yeni tatlar keşfedersin.',
      'icon': Image.asset('assets/icons/together_icon.png')
    },
    {
      'title': 'Daha bilinçli bir seçim',
      'description':
      'Daily Good ile yaptığın her alışveriş, yiyeceklerin israfını engeller. Küçük bir seçimle büyük bir fark yaratabilirsin.',
      'icon': Image.asset('assets/icons/world_icon.png')
    },
    {
      'title': 'Paketini al ve keyfini çıkar',
      'description':
      'Uygulamadaki sipariş kodunu mağazada doğrula, paketini teslim al ve gününe lezzet kat.',
      'icon': Image.asset('assets/icons/dailyGoodBox_icon.png')
    },
  ];

  void _nextPage() async {
    if (_currentPage == _pages.length - 1) {
      await PrefsService.setHasSeenOnboarding(true);
      ref.read(appStateProvider.notifier).setHasSeenOnboarding(true);
      await ref.read(appStateProvider.notifier).setIsNewUser(false);

      if (!mounted) return; // ✅ LINT FIX

      context.go('/location-info');
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _currentPage = index;
                  });
                }
              });
            },
            itemBuilder: (context, index) {
              final page = _pages[index];
              final isLast = index == _pages.length - 1;

              return OnboardingPage(
                title: page['title'],
                description: page['description'],
                icon: page['icon'],
                isLast: isLast,
                onNext: _nextPage,
              );
            },
          ),
          Positioned(
            top: 70,
            right: 24,
            child: TextButton(
              onPressed: () async {
                await PrefsService.setHasSeenOnboarding(true);
                ref.read(appStateProvider.notifier).setHasSeenOnboarding(true);
                await ref.read(appStateProvider.notifier).setIsNewUser(false);

                if (!context.mounted) return;

                context.go('/location-info');
              },
              child: Text(
                'Atla',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final Widget icon;
  final bool isLast;
  final VoidCallback onNext;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.isLast,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: size.height,
      decoration: const BoxDecoration(
        gradient: AppGradients.light,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: size.width * 0.25,
              height: size.width * 0.25,
              child: icon, // ✅ direkt widget bas
            ),
            const SizedBox(height: 48),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: isLast ? 'Hazırım!' : 'İleri',
                onPressed: onNext,
                showPrice: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
