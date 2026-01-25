// lib/core/widgets/platform_app_bar.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../platform/platform_utils.dart';

class PlatformAppBar extends StatelessWidget implements PreferredSizeWidget, ObstructingPreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const PlatformAppBar({
    super.key,
    required this.title,
    this.centerTitle = true,
    this.actions,
    this.leading,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isIOS) {
      return CupertinoNavigationBar(
        middle: Text(title, style: TextStyle(color: foregroundColor)),
        trailing: actions != null && actions!.isNotEmpty
            ? Row(
          mainAxisSize: MainAxisSize.min,
          children: actions!,
        )
            : null,
        leading: leading,
        backgroundColor: backgroundColor ?? CupertinoTheme.of(context).barBackgroundColor,
        // CupertinoNavigationBar by default uses safe area top etc
      );
    } else {
      return AppBar(
        title: Text(title),
        centerTitle: centerTitle,
        leading: leading,
        actions: actions,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
      );
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  bool shouldFullyObstruct(BuildContext context) => PlatformUtils.isIOS;
}
