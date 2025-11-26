import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

/// One-time migration service to update existing users
class MigrationService {
  static final _firestore = FirebaseFirestore.instance;
  
  /// Updates all users with empty avatarUrl to have a random gradient avatar
  static Future<void> assignDefaultAvatarsToExistingUsers() async {
    try {
      print('🔄 Starting avatar migration...');
      
      final usersSnapshot = await _firestore.collection('users').get();
      final random = Random();
      int updatedCount = 0;
      
      for (var doc in usersSnapshot.docs) {
        final data = doc.data();
        final avatarUrl = data['avatarUrl'] as String?;
        
        // Update only if avatarUrl is null or empty
        if (avatarUrl == null || avatarUrl.isEmpty) {
          final newAvatarId = 'gradient_${random.nextInt(12) + 1}';
          
          await doc.reference.update({
            'avatarUrl': newAvatarId,
          });
          
          updatedCount++;
          print('✅ Updated ${data['displayName']} with avatar: $newAvatarId');
        }
      }
      
      print('✨ Migration complete! Updated $updatedCount users.');
    } catch (e) {
      print('❌ Migration failed: $e');
      rethrow;
    }
  }
}
