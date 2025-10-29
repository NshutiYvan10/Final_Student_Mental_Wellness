import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatService {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;
  static const _anonKey = 'anon_id';

  static Future<String> _anonId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_anonKey);
    if (id == null || id.isEmpty) {
      id = DateTime.now().millisecondsSinceEpoch.toString();
      await prefs.setString(_anonKey, id);
    }
    return id;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> messagesStream() {
    if (!FirebaseService.isInitialized) {
      return const Stream.empty();
    }
    return _db
        .collection('rooms')
        .doc('general')
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots();
  }

  static Future<void> sendMessage(String text) async {
    if (!FirebaseService.isInitialized) return;
    final anonId = await _anonId();
    await _db.collection('rooms').doc('general').collection('messages').add({
      'text': text,
      'sender': anonId,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }
}


