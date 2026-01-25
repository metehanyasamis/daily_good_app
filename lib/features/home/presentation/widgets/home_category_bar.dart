import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../category/data/models/category_model.dart';

class HomeCategoryBar extends SliverPersistentHeaderDelegate {
  final List<CategoryModel> categories;
  final int selectedIndex;
  final Function(int) onSelected;

  HomeCategoryBar({
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final maxScroll = maxExtent - minExtent;
    final t = (maxScroll > 0)
        ? (shrinkOffset / maxScroll).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      color: AppColors.background,
      child: ListView.separated( // 👈 Builder yerine Separated kullanıyoruz
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16), // 👈 Kenar boşlukları
        itemCount: categories.length,
        // Elemanlar arası net boşluk:
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;
          final category = categories[index];

          final iconSize = lerpDouble(
            isSelected ? 70 : 62,
            (isSelected ? 70 : 62) * 0.7,
            t,
          )!;

          return GestureDetector(
            onTap: () => onSelected(index),
            child: SizedBox(
              width: 78,
              height: maxExtent,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // 🟢 SELECTED BACKGROUND
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    alignment: isSelected
                        ? Alignment.lerp(
                      const Alignment(0, 0.8),
                      Alignment.center,
                      t,
                    )!
                        : Alignment.bottomCenter,
                    child: Opacity(
                      opacity: isSelected ? 1 : 0,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 72,
                        height: lerpDouble(94, 60, t)!,
                        decoration: BoxDecoration(
                          color: AppColors.primaryDarkGreen,
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                    ),
                  ),

                  // ICON + TEXT
                  Align(
                    alignment: Alignment.lerp(
                      const Alignment(0, -0.4),
                      const Alignment(0, -0.8),
                      t,
                    )!,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: iconSize,
                          height: iconSize,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: ClipOval(
                            child: category.image != null
                                ? Image.network(
                              category.image!,
                              fit: BoxFit.cover,
                            )
                                : const Icon(Icons.storefront),
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: lerpDouble(13, 11, t),
                            fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected
                                ? Colors.white
                                : Colors.black87,
                          ),
                          child: Text(
                            category.name.replaceAll(' & ', ' & \n'),
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  double get maxExtent => 120;

  @override
  double get minExtent => 110;

  @override
  bool shouldRebuild(_) => true;
}
