// lib/core/widgets/platform_scaffold.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../platform/platform_utils.dart';

class PlatformScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Color? backgroundColor;

  const PlatformScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: appBar is ObstructingPreferredSizeWidget
            ? appBar as ObstructingPreferredSizeWidget
            : null,
        backgroundColor: backgroundColor,
        child: SafeArea(child: body),
      );
    }
    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      body: body,
    );
  }
}
