import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../data/models/user_model.dart';
import '../data/models/blessing_model.dart';
import 'auth_service.dart';

/// FirestoreService - Handles cloud storage in Firebase Firestore
class FirestoreService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final AuthService _authService;

  // Collection references
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _blessingsCollection =>
      _firestore.collection('blessings');

  /// Initialize service
  Future<FirestoreService> init() async {
    _authService = Get.find<AuthService>();
    
    // Link this service to AuthService
    _authService.setFirestoreService(this);
    
    return this;
  }

  // ============== USERS ==============

  /// Save user data to Firestore
  Future<void> saveUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.id).set(
        user.toJson(),
        SetOptions(merge: true), // Merge to preserve existing data
      );
      print('FirestoreService: User saved: ${user.id}');
    } catch (e) {
      print('FirestoreService: Error saving user: $e');
    }
  }

  /// Get user by ID
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!);
      }
    } catch (e) {
      print('FirestoreService: Error getting user: $e');
    }
    return null;
  }

  /// Update user's last login time
  Future<void> updateLastLogin(String userId) async {
    try {
      await _usersCollection.doc(userId).update({
        'lastLoginAt': Timestamp.now(),
      });
    } catch (e) {
      print('FirestoreService: Error updating last login: $e');
    }
  }

  // ============== BLESSINGS ==============

  /// Save blessing to Firestore
  Future<void> saveBlessing({
    required BlessingModel blessing,
    String? aiRawResponse,
  }) async {
    try {
      final userId = _authService.userId;
      if (userId == null) {
        print('FirestoreService: No user ID, skipping cloud save');
        return;
      }

      final data = {
        ...blessing.toJson(),
        'userId': userId, // Ensure userId is set
        'aiRawResponse': aiRawResponse,
        'syncedAt': Timestamp.now(),
      };

      await _blessingsCollection.doc(blessing.id).set(data);
      print('FirestoreService: Blessing saved: ${blessing.id}');
    } catch (e) {
      print('FirestoreService: Error saving blessing: $e');
    }
  }

  /// Get all blessings for current user
  Future<List<BlessingModel>> getUserBlessings() async {
    try {
      final userId = _authService.userId;
      if (userId == null) return [];

      final snapshot = await _blessingsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return BlessingModel.fromJson(doc.data());
      }).toList();
    } catch (e) {
      print('FirestoreService: Error getting blessings: $e');
      return [];
    }
  }

  /// Get blessing by ID
  Future<Map<String, dynamic>?> getBlessingWithDetails(String blessingId) async {
    try {
      final doc = await _blessingsCollection.doc(blessingId).get();
      if (doc.exists) {
        return doc.data();
      }
    } catch (e) {
      print('FirestoreService: Error getting blessing: $e');
    }
    return null;
  }

  /// Delete blessing from Firestore
  Future<void> deleteBlessing(String blessingId) async {
    try {
      await _blessingsCollection.doc(blessingId).delete();
      print('FirestoreService: Blessing deleted: $blessingId');
    } catch (e) {
      print('FirestoreService: Error deleting blessing: $e');
    }
  }

  /// Sync local blessings to cloud
  Future<int> syncLocalToCloud(List<BlessingModel> localBlessings) async {
    int synced = 0;
    final userId = _authService.userId;
    if (userId == null) return synced;

    for (final blessing in localBlessings) {
      try {
        // Check if already exists in cloud
        final doc = await _blessingsCollection.doc(blessing.id).get();
        if (!doc.exists) {
          await _blessingsCollection.doc(blessing.id).set({
            ...blessing.toJson(),
            'userId': userId,
            'syncedAt': Timestamp.now(),
          });
          synced++;
        }
      } catch (e) {
        print('FirestoreService: Error syncing blessing ${blessing.id}: $e');
      }
    }

    print('FirestoreService: Synced $synced blessings to cloud');
    return synced;
  }

  /// Get user's blessing count
  Future<int> getBlessingCount() async {
    try {
      final userId = _authService.userId;
      if (userId == null) return 0;

      final snapshot = await _blessingsCollection
          .where('userId', isEqualTo: userId)
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      print('FirestoreService: Error getting blessing count: $e');
      return 0;
    }
  }
}
