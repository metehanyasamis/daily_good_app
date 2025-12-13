import 'dart:io';
import 'package:flutter/material.dart';

class PhotoPreviewScreen extends StatelessWidget {
  final List<File> photos;
  final int initialIndex;

  const PhotoPreviewScreen({
    super.key,
    required this.photos,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    final pageController = PageController(initialPage: initialIndex);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: PageView.builder(
        controller: pageController,
        itemCount: photos.length,
        itemBuilder: (_, index) {
          return InteractiveViewer(
            minScale: 0.8,
            maxScale: 4.0,
            child: Center(
              child: Image.file(photos[index]),
            ),
          );
        },
      ),
    );
  }
}
