import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../config/app_config.dart';
import 'cloudinary_service.dart';

class StorageService {
  final CloudinaryService _cloudinaryService = CloudinaryService();

  /// Uploads [imageFile] directly to Cloudinary and returns the secure URL.
  /// That URL is later stored in Firestore as the event's [imageUrl].
  Future<String> uploadEventImage(
    XFile imageFile,
    String eventId, {
    String? authToken,
  }) async {
    debugPrint('StorageService: uploading image via Cloudinary for event $eventId');
    try {
      final url = await _cloudinaryService.uploadEventImage(imageFile, eventId);
      debugPrint('StorageService: Cloudinary URL = $url');
      return url;
    } catch (e) {
      debugPrint('StorageService: direct Cloudinary upload failed: $e');
      final fallbackUrl = await _uploadEventImageViaBackend(
        imageFile,
        eventId,
        authToken,
      );
      debugPrint('StorageService: backend Cloudinary URL = $fallbackUrl');
      return fallbackUrl;
    }
  }

  Future<String> _uploadEventImageViaBackend(
    XFile imageFile,
    String eventId,
    String? authToken,
  ) async {
    final uri = Uri.parse('$backendBaseUrl/api/events/$eventId/upload-image');
    final bytes = await imageFile.readAsBytes();

    final String ext = imageFile.name.split('.').last.toLowerCase();
    final MediaType contentType = MediaType(
      'image',
      ext == 'png'
          ? 'png'
          : ext == 'gif'
              ? 'gif'
              : ext == 'webp'
                  ? 'webp'
                  : 'jpeg',
    );

    final request = http.MultipartRequest('POST', uri)
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: imageFile.name,
          contentType: contentType,
        ),
      );

    if (authToken != null && authToken.trim().isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $authToken';
    }

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 45),
    );
    final response = await http.Response.fromStream(streamedResponse);

    if (streamedResponse.statusCode == 200 || streamedResponse.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
      final String? imageUrl = (data['image_url'] ?? data['imageUrl']) as String?;
      if (imageUrl == null || imageUrl.trim().isEmpty) {
        throw Exception('Backend upload succeeded but no image URL returned.');
      }
      return imageUrl;
    }

    throw Exception(
      'Backend image upload failed [${streamedResponse.statusCode}]: ${response.body}',
    );
  }

  Future<XFile?> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    return picker.pickImage(source: source);
  }
}
