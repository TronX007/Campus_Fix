import 'dart:io';
import '../utils/image_utils.dart';

class StorageService {
  // Return the image as a Base64 encoded Data URI after compressing and validating
  Future<String> uploadComplaintImage(String complaintId, File file) async {
    print("[Base64Storage] Compressing and encoding complaint image. Path: ${file.path}");
    try {
      final dataUri = await ImageUtils.compressAndEncode(file);
      print("[Base64Storage] Encoded successfully. Base64 length: ${dataUri.length}");
      return dataUri;
    } catch (e) {
      print("[Base64Storage] Failed to compress/encode file: $e");
      rethrow;
    }
  }

  // Return the resolution image as a Base64 encoded Data URI after compressing and validating
  Future<String> uploadResolutionImage(String complaintId, File file) async {
    print("[Base64Storage] Compressing and encoding resolution image. Path: ${file.path}");
    try {
      final dataUri = await ImageUtils.compressAndEncode(file);
      print("[Base64Storage] Encoded successfully. Base64 length: ${dataUri.length}");
      return dataUri;
    } catch (e) {
      print("[Base64Storage] Failed to compress/encode file: $e");
      rethrow;
    }
  }
}
