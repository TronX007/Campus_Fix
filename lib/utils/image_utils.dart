import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageUtils {
  /// Compresses the image to max 1024x1024 resolution and quality 85,
  /// converts it to a Base64 encoded string, and validates that it is <= 300 KB.
  static Future<String> compressAndEncode(File image) async {
    final String path = image.path;
    final int originalLength = await image.length();
    print("[ImageUtils] Original image size: ${(originalLength / 1024).toStringAsFixed(2)} KB");

    Uint8List? compressedBytes;
    try {
      compressedBytes = await FlutterImageCompress.compressWithFile(
        path,
        minWidth: 1024,
        minHeight: 1024,
        quality: 85,
        format: CompressFormat.jpeg,
      );
    } catch (e) {
      print("[ImageUtils] Compression failed, falling back to reading raw bytes: $e");
      compressedBytes = await image.readAsBytes();
    }

    if (compressedBytes == null) {
      throw Exception("Failed to compress image bytes.");
    }

    final int compressedSize = compressedBytes.length;
    print("[ImageUtils] Compressed image size: ${(compressedSize / 1024).toStringAsFixed(2)} KB");

    // Hard limit of 300 KB
    if (compressedSize > 300 * 1024) {
      throw ImageSizeExceededException("Image is too large. Please select a smaller image.");
    }

    final base64String = base64Encode(compressedBytes);
    return 'data:image/jpeg;base64,$base64String';
  }
}

class ImageSizeExceededException implements Exception {
  final String message;
  ImageSizeExceededException(this.message);

  @override
  String toString() => message;
}
