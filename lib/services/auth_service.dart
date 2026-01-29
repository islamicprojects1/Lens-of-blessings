import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../data/models/user_model.dart';
import 'storage_service.dart';
import 'firestore_service.dart';

/// AuthService - Handles Firebase Authentication (Google + Anonymous)
class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  late final StorageService _storageService;
  FirestoreService? _firestoreService;

  // Reactive user state
  final Rx<User?> firebaseUser = Rx<User?>(null);
  final Rx<UserModel?> currentUserModel = Rx<UserModel?>(null);

  User? get currentUser => _auth.currentUser;
  String? get userId => currentUser?.uid;
  bool get isAuthenticated => currentUser != null;
  bool get isAnonymous => currentUser?.isAnonymous ?? true;
  bool get isGoogleUser => !isAnonymous && currentUser?.email != null;

  /// Initialize authentication
  Future<AuthService> init() async {
    _storageService = Get.find<StorageService>();

    // Listen to auth state changes
    _auth.authStateChanges().listen((user) {
      firebaseUser.value = user;
      if (user != null) {
        _updateUserModel(user);
      } else {
        currentUserModel.value = null;
      }
    });

    // Auto sign-in
    if (_auth.currentUser == null) {
      await signInAnonymously();
    } else {
      print('AuthService: User already signed in: ${_auth.currentUser!.uid}');
    }

    return this;
  }

  /// Set FirestoreService (called after initialization)
  void setFirestoreService(FirestoreService service) {
    _firestoreService = service;
  }

  /// Update UserModel from Firebase User
  void _updateUserModel(User user) {
    currentUserModel.value = UserModel.fromFirebaseUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      isAnonymous: user.isAnonymous,
    );
  }

  /// Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('AuthService: Google Sign-In cancelled by user');
        return null;
      }

      // Obtain the auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Check if we have an anonymous user to link
      if (_auth.currentUser?.isAnonymous ?? false) {
        return await _linkAnonymousToGoogle(credential);
      }

      // Sign in with the credential
      final userCredential = await _auth.signInWithCredential(credential);

      print('AuthService: Google Sign-In successful: ${userCredential.user?.email}');

      // Save user to Firestore
      await _saveUserToFirestore(userCredential.user!);

      return userCredential;
    } catch (e) {
      print('AuthService: Google Sign-In Error: $e');
      return null;
    }
  }

  /// Link anonymous account to Google
  Future<UserCredential?> _linkAnonymousToGoogle(AuthCredential credential) async {
    try {
      final userCredential =
          await _auth.currentUser!.linkWithCredential(credential);

      print('AuthService: Anonymous account linked to Google: ${userCredential.user?.email}');

      // Save user to Firestore
      await _saveUserToFirestore(userCredential.user!);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use') {
        // Account already exists, sign in directly
        print('AuthService: Account exists, signing in directly');
        return await _auth.signInWithCredential(credential);
      }
      rethrow;
    }
  }

  /// Save user data to Firestore
  Future<void> _saveUserToFirestore(User user) async {
    if (_firestoreService == null) return;

    final userModel = UserModel.fromFirebaseUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      isAnonymous: user.isAnonymous,
    );

    await _firestoreService!.saveUser(userModel);
    currentUserModel.value = userModel;
  }

  /// Sign in anonymously
  Future<UserCredential?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      final uid = userCredential.user!.uid;

      print('AuthService: Anonymous sign in successful: $uid');

      // Store the user ID locally
      await _storageService.setAnonymousUserId(uid);

      return userCredential;
    } catch (e) {
      print('AuthService Error: $e');
      return null;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      currentUserModel.value = null;
      print('AuthService: User signed out');
    } catch (e) {
      print('AuthService: Sign out error: $e');
    }
  }

  /// Get user display name
  String get displayName {
    return currentUser?.displayName ?? currentUser?.email ?? 'ضيف';
  }

  /// Get user photo URL
  String? get photoUrl => currentUser?.photoURL;
}
