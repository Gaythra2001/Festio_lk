import 'dart:io';
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import '../config/app_config.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadEventImage(XFile imageFile, String eventId, {String? authToken}) async {
    try {
      // Prioritize Backend Local Storage per user request
      try {
        var request = http.MultipartRequest(
          'POST', 
        Uri.parse('$backendBaseUrl/api/events/$eventId/upload-image')
        );
        debugPrint('📤 MultipartRequest created for: ${request.url}');
        
        if (authToken != null) {
          request.headers['Authorization'] = 'Bearer $authToken';
          debugPrint('🔑 Auth token included in request headers');
        }
        
        final bytes = await imageFile.readAsBytes();
        debugPrint('📄 File read successfully: ${bytes.length} bytes');
        
        // Determine content type
        String? extension = imageFile.name.split('.').last.toLowerCase();
        MediaType contentType = MediaType('image', extension == 'png' ? 'png' : 'jpeg');

        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: imageFile.name,
            contentType: contentType,
          )
        );

        debugPrint('🚀 Sending request to backend...');
        // Add a timeout of 30 seconds for the backend upload
        var streamedResponse = await request.send().timeout(const Duration(seconds: 30));
        debugPrint('📡 Response status: ${streamedResponse.statusCode}');
        
        if (streamedResponse.statusCode == 200 || streamedResponse.statusCode == 201) {
          final response = await http.Response.fromStream(streamedResponse);
          final Map<String, dynamic> data = jsonDecode(response.body);
          
          if (data.containsKey('image_url')) {
            final String path = data['image_url'];
            // If the path is relative (starts with /uploads), prepend the base URL
            return path.startsWith('http') ? path : '$backendBaseUrl$path';
          }
        } else {
          debugPrint('Backend upload failed with status: ${streamedResponse.statusCode}');
        }
      } catch (backendError) {
        debugPrint('Backend upload failed, falling back to Firebase: $backendError');
      }

      // Fallback: Firebase Storage if useFirebase is true
      if (useFirebase && !kIsWeb) {
        // Firebase putFile requires dart:io File which isn't available on web
        // For web, use putData/putBlob but we are prioritizing backend anyway
        final ref = _storage.ref().child('events/$eventId/${DateTime.now().millisecondsSinceEpoch}.jpg');
        final bytes = await imageFile.readAsBytes();
        await ref.putData(bytes);
        return await ref.getDownloadURL();
      } else if (useFirebase && kIsWeb) {
        final ref = _storage.ref().child('events/$eventId/${DateTime.now().millisecondsSinceEpoch}.jpg');
        final bytes = await imageFile.readAsBytes();
        await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
        return await ref.getDownloadURL();
      }
      
      throw Exception('Backend upload failed and Firebase is disabled.');
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<String> uploadProfileImage(XFile imageFile, String userId) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final ref = _storage.ref().child('profiles/$userId.jpg');
      await ref.putData(bytes);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  Future<XFile?> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    return pickedFile;
  }
}

