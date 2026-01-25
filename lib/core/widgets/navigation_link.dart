import 'package:flutter/material.dart';

import '../utils/navigation_utils.dart';

class NavigationLink extends StatelessWidget {
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? label;
  final TextStyle? textStyle;

  const NavigationLink({
    super.key,
    this.address,
    this.latitude,
    this.longitude,
    this.label,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final hasAddress = address != null && address!.isNotEmpty;
    final hasCoords = latitude != null && longitude != null;

    if (!hasAddress && !hasCoords) {
      return const SizedBox.shrink();
    }



    return InkWell(
      onTap: () {
        openMap(
          latitude: latitude,
          longitude: longitude,
          address: address,
          label: label,
        );
      },
      child: Text(
        "Navigasyon için tıklayın 📍",
        style: textStyle ??
            const TextStyle(
              color: Colors.green,
              decoration: TextDecoration.underline,
              fontSize: 13,
            ),
      ),
    );
  }
}
