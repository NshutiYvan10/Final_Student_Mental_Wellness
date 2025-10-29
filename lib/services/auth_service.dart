import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';
import '../models/user_profile.dart';
import 'hive_service.dart';

class AuthService {
  static fb.FirebaseAuth get _auth => fb.FirebaseAuth.instance;
  // Test hook: allow injecting a fake current user profile for unit tests
  static UserProfile? _testProfile;
  static void setTestProfile(UserProfile? profile) => _testProfile = profile;

  static Stream<fb.User?> authStateChanges() {
    if (!FirebaseService.isInitialized) {
      return const Stream<fb.User?>.empty();
    }
    return _auth.authStateChanges();
  }

  static Future<void> signInWithEmail(String email, String password) async {
    if (!FirebaseService.isInitialized) {
      throw StateError('Firebase is not initialized. Please configure Firebase.');
    }
    
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> signUpWithEmail(
    String email, 
    String password, {
    required String displayName,
    required String school,
    required UserRole role,
  }) async {
    if (!FirebaseService.isInitialized) {
      throw StateError('Firebase is not initialized. Please configure Firebase.');
    }
    
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password,
      );
      
      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName(displayName);
        
        // Create user profile in Firestore
        final userProfile = UserProfile(
          uid: credential.user!.uid,
          displayName: displayName,
          email: email,
          avatarUrl: '', // Default avatar
          school: school,
          role: role,
          createdAt: DateTime.now(),
        );
        
        await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user!.uid)
            .set(userProfile.toMap());

        // Cache essentials locally
        await HiveService.setProfileName(displayName);
        await HiveService.setProfileSchool(school);
        await HiveService.setProfileRole(role.name);
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> signOut() async {
    if (!FirebaseService.isInitialized) return;
    await _auth.signOut();
  }

  static Future<UserProfile?> getCurrentUserProfile() async {
    // If a test profile is injected, return it immediately (tests use this hook)
    if (_testProfile != null) return _testProfile;

    if (!FirebaseService.isInitialized) {
      return null;
    }

    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final profile = UserProfile.fromMap(doc.data()!);
        // Keep local cache in sync
        await HiveService.setProfileName(profile.displayName);
        await HiveService.setProfileSchool(profile.school);
        await HiveService.setProfileRole(profile.role.name);
        return profile;
      }
    } catch (_) {
      // Handle error
    }
    return null;
  }

  static Stream<UserProfile?> getCurrentUserProfileStream() {
    if (!FirebaseService.isInitialized) {
      return const Stream.empty();
    }
    
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }
    
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return UserProfile.fromMap(doc.data()!);
      }
      return null;
    });
  }
}



