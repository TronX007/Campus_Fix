import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class ComplaintImageWidget extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final Widget? errorWidget;
  final Widget? loadingWidget;

  const ComplaintImageWidget({
    Key? key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.errorWidget,
    this.loadingWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return errorWidget ?? _defaultErrorWidget();
    }

    // Check if the string is a base64 data URI
    if (imageUrl.startsWith('data:image') && imageUrl.contains('base64,')) {
      try {
        final base64String = imageUrl.split('base64,').last;
        final Uint8List bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return errorWidget ?? _defaultErrorWidget();
          },
        );
      } catch (e) {
        return errorWidget ?? _defaultErrorWidget();
      }
    }

    // Fallback to standard network URLs
    return Image.network(
      imageUrl,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return loadingWidget ?? _defaultLoadingWidget(loadingProgress);
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? _defaultErrorWidget();
      },
    );
  }

  Widget _defaultErrorWidget() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, color: Colors.grey, size: 36),
            SizedBox(height: 4),
            Text(
              'No photo available',
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _defaultLoadingWidget(ImageChunkEvent loadingProgress) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
