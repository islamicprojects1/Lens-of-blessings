import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:get/get.dart';
import 'package:lens_of_blessings/core/constants/api_constants.dart';

/// CloudinaryService - Handles image upload to cloud storage
class CloudinaryService extends GetxService {
  late final CloudinaryPublic _cloudinary;

  @override
  void onInit() {
    super.onInit();
    _cloudinary = CloudinaryPublic(
      ApiConstants.cloudinaryCloudName,
      ApiConstants.cloudinaryUploadPreset,
      cache: false,
    );
  }

  /// Upload image file to Cloudinary
  Future<String?> uploadImage(File imageFile) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: 'blessings',
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      
      print('CloudinaryService: Image uploaded: ${response.secureUrl}');
      return response.secureUrl;
    } catch (e) {
      print('CloudinaryService Error: $e');
      return null;
    }
  }

  /// Upload image from bytes
  Future<String?> uploadBytes(List<int> bytes, String fileName) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromBytesData(
          bytes,
          identifier: fileName,
          folder: 'blessings',
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      
      return response.secureUrl;
    } catch (e) {
      print('CloudinaryService Error: $e');
      return null;
    }
  }
}
