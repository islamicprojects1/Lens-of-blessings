import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'storage_service.dart';

/// AuthService - Handles Firebase Anonymous Authentication
class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final StorageService _storageService = Get.find<StorageService>();

  User? get currentUser => _auth.currentUser;
  String? get userId => currentUser?.uid;

  /// Initialize anonymous authentication
  Future<AuthService> init() async {
    await _ensureAnonymousAuth();
    return this;
  }

  /// Ensure user is signed in anonymously
  Future<void> _ensureAnonymousAuth() async {
    try {
      // Check if already signed in
      if (_auth.currentUser != null) {
        print('AuthService: User already signed in: ${_auth.currentUser!.uid}');
        return;
      }

      // Check if we have a stored user ID
      final storedUserId = _storageService.getAnonymousUserId();

      // Sign in anonymously
      final userCredential = await _auth.signInAnonymously();
      final uid = userCredential.user!.uid;

      print('AuthService: Anonymous sign in successful: $uid');

      // Store the user ID
      await _storageService.setAnonymousUserId(uid);
    } catch (e) {
      print('AuthService Error: $e');
      // App can work in offline mode without auth
    }
  }

  /// Sign out (rarely needed, but included for completeness)
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;
}
