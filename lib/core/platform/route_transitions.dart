// lib/core/platform/route_transitions.dart
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'platform_utils.dart';

CustomTransitionPage platformPage({
  required LocalKey key,
  required Widget child,
}) {
  if (PlatformUtils.isIOS) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionsBuilder: (context, animation, secondary, child) {
        return CupertinoPageTransition(
          primaryRouteAnimation: animation,
          secondaryRouteAnimation: secondary,
          linearTransition: true,
          child: child,
        );
      },
    );
  }
  // Android – fade + slight slide
  return CustomTransitionPage(
    key: key,
    transitionDuration: const Duration(milliseconds: 300),
    child: child,
    transitionsBuilder: (context, animation, secondary, child) {
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
      final offset = Tween(begin: const Offset(0, 0.04), end: Offset.zero).animate(fade);
      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: offset, child: child),
      );
    },
  );
}
