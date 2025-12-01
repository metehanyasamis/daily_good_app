import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../explore/presentation/widgets/category_filter_option.dart';

class HomeCategoryBar extends SliverPersistentHeaderDelegate {
  final List<CategoryFilterOption> categories;
  final int selectedIndex;
  final Function(int) onSelected;

  HomeCategoryBar({
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double maxScrollExtent = maxExtent - minExtent;
    final double shrinkFactor =
    (maxScrollExtent > 0) ? (shrinkOffset / maxScrollExtent).clamp(0.0, 1.0) : 0.0;

    final double currentContainerHeight =
    lerpDouble(maxExtent, minExtent, shrinkFactor)!;

    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final bool isSelected = selectedIndex == index;
          final CategoryFilterOption category = categories[index];
          final String categoryLabelText = categoryLabel(category);

          final double startIconSize = isSelected ? 70 : 62;
          final double endIconSize = startIconSize * 0.70;
          final double currentIconSize =
          lerpDouble(startIconSize, endIconSize, shrinkFactor)!;

          return GestureDetector(
            onTap: () => onSelected(index),
            child: Container(
              width: 78,
              height: currentContainerHeight,
              margin: const EdgeInsets.only(right: 4),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // ● YEŞİL OVAL ARKA PLAN
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    alignment: isSelected
                        ? Alignment.lerp(
                      const Alignment(0, 0.5),
                      const Alignment(0, 0.0),
                      shrinkFactor,
                    )!
                        : Alignment.lerp(
                      const Alignment(0, 1.3),
                      Alignment.bottomCenter,
                      shrinkFactor,
                    )!,
                    child: Opacity(
                      opacity: isSelected ? 1.0 : 0.0,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        width: lerpDouble(72, 72 * 0.80, shrinkFactor)!,
                        height: isSelected
                            ? lerpDouble(94, 94 * 0.60, shrinkFactor)!
                            : 0,
                        decoration: BoxDecoration(
                          color: AppColors.primaryDarkGreen,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(50),
                            topRight: Radius.circular(50),
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                          boxShadow: isSelected
                              ? [
                            BoxShadow(
                              color: AppColors.primaryDarkGreen
                                  .withOpacity(.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                              : [],
                        ),
                      ),
                    ),
                  ),

                  // ● ICON + TEXT
                  Align(
                    alignment: isSelected
                        ? Alignment.topCenter
                        : Alignment.lerp(
                      const Alignment(0, -0.4),
                      const Alignment(0, -0.8),
                      shrinkFactor,
                    )!,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          width: currentIconSize,
                          height: currentIconSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/icons/${_iconNameFor(category)}.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image_not_supported,
                                  color: Colors.grey),
                            ),
                          ),
                        ),

                        SizedBox(height: lerpDouble(4, 1, shrinkFactor)),

                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: lerpDouble(13, 11, shrinkFactor),
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.black.withOpacity(0.9),
                              height: 1.15,
                            ),
                            child: SizedBox(
                              width: 70,         // sabit genişlik
                              height: 30,        // SABİT YÜKSEKLİK → tüm sorun çözüldü
                              child: Text(
                                categoryLabelText,
                                textAlign: TextAlign.center,
                                maxLines: 2,      // uzun metinler eşitlenir
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                              ),
                            ),
                          )
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

  // ICON MAPPER
  String _iconNameFor(CategoryFilterOption category) {
    switch (category) {
      case CategoryFilterOption.all:
        return "all";
      case CategoryFilterOption.food:
        return "food";
      case CategoryFilterOption.bakery:
        return "bakery";
      case CategoryFilterOption.breakfast:
        return "breakfast";
      case CategoryFilterOption.market:
        return "market";
      case CategoryFilterOption.vegetarian:
        return "vegetarian";
      case CategoryFilterOption.vegan:
        return "vegan";
      case CategoryFilterOption.glutenFree:
        return "glutenfree";
    }
  }

  @override
  double get maxExtent => 120;

  @override
  double get minExtent => 110;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}
