import 'dart:convert';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/blessing_model.dart';
import '../data/models/blessing_image_model.dart';

/// BlessingStorageService - Handles local storage of blessings using Hive
class BlessingStorageService extends GetxService {
  static const String _blessingsBoxName = 'blessings';
  static const String _imagesBoxName = 'blessing_images';

  late Box<String> _blessingsBox;
  late Box<String> _imagesBox;

  Future<BlessingStorageService> init() async {
    await Hive.initFlutter();
    _blessingsBox = await Hive.openBox<String>(_blessingsBoxName);
    _imagesBox = await Hive.openBox<String>(_imagesBoxName);
    return this;
  }

  // ============== Blessings ==============

  /// Save a blessing
  Future<void> saveBlessing(BlessingModel blessing) async {
    await _blessingsBox.put(blessing.id, jsonEncode(blessing.toJson()));
  }

  /// Get all blessings
  List<BlessingModel> getAllBlessings() {
    final blessings = <BlessingModel>[];
    
    for (final key in _blessingsBox.keys) {
      final json = _blessingsBox.get(key);
      if (json != null) {
        try {
          blessings.add(BlessingModel.fromJson(jsonDecode(json)));
        } catch (e) {
          print('Error parsing blessing: $e');
        }
      }
    }

    // Sort by date, newest first
    blessings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return blessings;
  }

  /// Get a blessing by ID
  BlessingModel? getBlessing(String id) {
    final json = _blessingsBox.get(id);
    if (json == null) return null;
    
    try {
      return BlessingModel.fromJson(jsonDecode(json));
    } catch (e) {
      print('Error parsing blessing: $e');
      return null;
    }
  }

  /// Delete a blessing
  Future<void> deleteBlessing(String id) async {
    await _blessingsBox.delete(id);
  }

  /// Get blessings count
  int get blessingsCount => _blessingsBox.length;

  // ============== Images ==============

  /// Save an image reference
  Future<void> saveImage(BlessingImageModel image) async {
    await _imagesBox.put(image.id, jsonEncode(image.toJson()));
  }

  /// Get an image by ID
  BlessingImageModel? getImage(String id) {
    final json = _imagesBox.get(id);
    if (json == null) return null;
    
    try {
      return BlessingImageModel.fromJson(jsonDecode(json));
    } catch (e) {
      print('Error parsing image: $e');
      return null;
    }
  }

  /// Delete an image
  Future<void> deleteImage(String id) async {
    await _imagesBox.delete(id);
  }

  // ============== Utility ==============

  /// Clear all data
  Future<void> clearAll() async {
    await _blessingsBox.clear();
    await _imagesBox.clear();
  }
}
