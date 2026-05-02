import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

/// Cloudinary configuration constants
/// Keep these values client-safe: cloud name + unsigned upload preset only.
///
/// You can override with:
/// flutter run --dart-define=CLOUDINARY_CLOUD_NAME=your_cloud_name
/// flutter run --dart-define=CLOUDINARY_UPLOAD_PRESET=your_unsigned_preset
const String _cloudName = String.fromEnvironment(
  'CLOUDINARY_CLOUD_NAME',
  defaultValue: 'dlsmusqcz',
);

/// Upload preset — must be set to an UNSIGNED preset in your Cloudinary dashboard.
/// Go to Settings → Upload → Upload Presets → Add unsigned preset.
/// Name it exactly as below, or change this constant to match yours.
const String _uploadPreset = String.fromEnvironment(
  'CLOUDINARY_UPLOAD_PRESET',
  defaultValue: 'festio_lk_events',
);

class CloudinaryService {
  String _buildCloudinaryErrorMessage(int statusCode, String responseBody) {
    String backendMessage = responseBody;

    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) {
        final error = decoded['error'];
        if (error is Map<String, dynamic>) {
          backendMessage = (error['message'] ?? responseBody).toString();
        }
      }
    } catch (_) {
      // Keep the raw body when it's not valid JSON.
    }

    final normalized = backendMessage.toLowerCase();
    if (statusCode == 400 && normalized.contains('upload preset not found')) {
      return 'Cloudinary upload preset not found. Create an unsigned preset named "$_uploadPreset" in Cloudinary Settings > Upload > Upload presets, or run with --dart-define=CLOUDINARY_UPLOAD_PRESET=your_preset_name.';
    }

    if (statusCode == 401 || normalized.contains('invalid api key')) {
      return 'Cloudinary authentication failed. Verify CLOUDINARY_CLOUD_NAME and upload preset settings.';
    }

    return 'Cloudinary Error [$statusCode]: $backendMessage';
  }

  /// Uploads [imageFile] to Cloudinary and returns the secure URL.
  ///
  /// Uses the **unsigned** upload endpoint so no API secret is exposed
  /// in the client. The [_uploadPreset] must be configured in the
  /// Cloudinary dashboard as an unsigned preset.
  ///
  /// Throws an [Exception] on failure.
  Future<String> uploadEventImage(XFile imageFile, String eventId) async {
    if (_cloudName.trim().isEmpty || _uploadPreset.trim().isEmpty) {
      throw Exception(
        'Cloudinary configuration missing. Set CLOUDINARY_CLOUD_NAME and CLOUDINARY_UPLOAD_PRESET.',
      );
    }

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );

    // Read file bytes
    final bytes = await imageFile.readAsBytes();

    // Determine MIME type
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

    // Build multipart request
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..fields['folder'] = 'festio_lk/events'
      ..fields['public_id'] = '${eventId}_${DateTime.now().millisecondsSinceEpoch}'
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: imageFile.name,
          contentType: contentType,
        ),
      );

    debugPrint('Uploading image to Cloudinary (unsigned preset)...');
    debugPrint('Preset: $_uploadPreset');

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 30),
    );

    final response = await http.Response.fromStream(streamedResponse);

    if (streamedResponse.statusCode == 200 || streamedResponse.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final String secureUrl = data['secure_url'] as String;
      debugPrint('Cloudinary upload successful: $secureUrl');
      return secureUrl;
    } else {
      final errorMsg = _buildCloudinaryErrorMessage(
        streamedResponse.statusCode,
        response.body,
      );
      debugPrint(errorMsg);
      throw Exception(errorMsg);
    }
  }
}
