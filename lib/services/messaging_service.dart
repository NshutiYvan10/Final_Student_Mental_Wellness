import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_models.dart';
import '../models/user_profile.dart';
import 'firebase_service.dart';
import 'auth_service.dart';

class MessagingService {
  // Note: use __db and __auth which allow test overrides via setTestInstances
  // Test overrides (used by unit tests to inject mocks)
  static FirebaseFirestore? _testDb;
  static FirebaseAuth? _testAuth;

  static void setTestInstances({FirebaseFirestore? db, FirebaseAuth? auth}) {
    _testDb = db;
    _testAuth = auth;
  }

  static bool get _isReady => FirebaseService.isInitialized || _testDb != null || _testAuth != null;

  static FirebaseFirestore get __db => _testDb ?? FirebaseFirestore.instance;
  static FirebaseAuth get __auth => _testAuth ?? FirebaseAuth.instance;
  // Backwards-compatible aliases for existing code that references _db/_auth
  static FirebaseFirestore get _db => __db;
  static FirebaseAuth get _auth => __auth;
  static const _uuid = Uuid();

  // Chat Rooms
  static Stream<List<ChatRoom>> getUserChatRooms() {
    if (!_isReady) {
      return const Stream.empty();
    }

    final user = __auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return __db
        .collection('chat_rooms')
        .where('memberIds', arrayContains: user.uid)
        .snapshots()
        .map((snapshot) {
          final rooms = snapshot.docs
              .map((doc) => ChatRoom.fromMap({...doc.data(), 'id': doc.id}))
              .toList();
          rooms.sort((a, b) {
            // Use lastMessageAt if available, otherwise use createdAt for new chats
            final aTime = a.lastMessageAt ?? a.createdAt;
            final bTime = b.lastMessageAt ?? b.createdAt;
            return bTime.compareTo(aTime);
          });
          return rooms;
        });
  }

  // Public Groups Discovery
  static Stream<List<ChatRoom>> getPublicGroups() {
    if (!_isReady) {
      return const Stream.empty();
    }

    // Check if user is authenticated
    final user = __auth.currentUser;
    if (user == null) {
      return Stream.error(Exception('User must be authenticated to view public groups'));
    }

    return __db
          .collection('chat_rooms')
          .where('type', isEqualTo: ChatType.group.name)
        .where('isPrivate', isEqualTo: false)
        .limit(100)
        .snapshots()
        .handleError((error) {
          // Handle Firestore permission errors more gracefully
          if (error is FirebaseException && error.code == 'permission-denied') {
            throw Exception('Permission denied: Please make sure Firestore security rules allow reading public groups');
          }
          throw error;
        })
        .map((snapshot) {
          final groups = snapshot.docs
              .map((doc) => ChatRoom.fromMap({...doc.data(), 'id': doc.id}))
              .toList();
          groups.sort((a, b) {
            final aTime = a.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bTime = b.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bTime.compareTo(aTime);
          });
          return groups;
        });
  }

  static Future<ChatRoom> createGroupChat({
    required String name,
    required String description,
    required List<String> memberIds,
    String? imageUrl,
    bool isPrivate = false,
  }) async {
    if (!_isReady) {
      throw Exception('Firebase not initialized');
    }

    final user = __auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Enforce mentor-only group creation
    final creatorProfile = await AuthService.getCurrentUserProfile();
    if (creatorProfile == null || creatorProfile.role != UserRole.mentor) {
      throw Exception('Only mentors can create support groups');
    }

    // Ensure the creator is in the members list and remove duplicates
    final uniqueMemberIds = {...memberIds, user.uid}.toList();

    final chatRoom = ChatRoom(
      id: _uuid.v4(),
      name: name,
      description: description,
      imageUrl: imageUrl,
      type: ChatType.group,
      memberIds: uniqueMemberIds,
      createdBy: user.uid,
      createdAt: DateTime.now(),
      isPrivate: isPrivate,
    );

    await _db
        .collection('chat_rooms')
        .doc(chatRoom.id)
        .set(chatRoom.toMap());

    return chatRoom;
  }

  static Future<ChatRoom> createPrivateChat(String targetUserId) async {
    if (!_isReady) {
      throw Exception('Firebase not initialized');
    }

    final user = __auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    print('Checking for existing chat between ${user.uid} and $targetUserId');
    
    // Check if private chat already exists
    final existingChats = await __db
        .collection('chat_rooms')
        .where('type', isEqualTo: ChatType.private.name)
        .where('memberIds', arrayContains: user.uid)
        .get();

    for (final doc in existingChats.docs) {
      final chat = ChatRoom.fromMap({...doc.data(), 'id': doc.id});
      if (chat.memberIds.contains(targetUserId) && chat.memberIds.length == 2) {
        print('Found existing chat: ${chat.id}');
        return chat;
      }
    }

    // Create new private chat
    final chatId = _uuid.v4();
    print('Creating new private chat with ID: $chatId');
    
    final chatRoom = ChatRoom(
      id: chatId,
      name: '', // Will be set based on participants
      type: ChatType.private,
      memberIds: [user.uid, targetUserId],
      createdAt: DateTime.now(),
    );

    final chatData = chatRoom.toMap();
    chatData['id'] = chatId; // Ensure ID is in the document
    
    await __db
        .collection('chat_rooms')
        .doc(chatId)
        .set(chatData);
    
    print('Chat room document created successfully');
    return chatRoom;
  }

  static Future<void> joinGroupChat(String chatRoomId) async {
    if (!FirebaseService.isInitialized) return;

    final user = _auth.currentUser;
    if (user == null) return;

      await __db
        .collection('chat_rooms')
        .doc(chatRoomId)
        .update({
      'memberIds': FieldValue.arrayUnion([user.uid]),
    });
  }

  static Future<void> leaveGroupChat(String chatRoomId) async {
    if (!FirebaseService.isInitialized) return;

    final user = _auth.currentUser;
    if (user == null) return;

      await __db
        .collection('chat_rooms')
        .doc(chatRoomId)
        .update({
      'memberIds': FieldValue.arrayRemove([user.uid]),
    });
  }

  static Future<void> deleteChat(String chatRoomId) async {
    if (!FirebaseService.isInitialized) return;

    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final chatDoc = await __db.collection('chat_rooms').doc(chatRoomId).get();
      if (!chatDoc.exists) return;

      final chat = ChatRoom.fromMap({...chatDoc.data()!, 'id': chatDoc.id});

      // For private chats, remove the user from memberIds
      // If it becomes empty, delete the entire chat room
      if (chat.type == ChatType.private) {
        final updatedMembers = chat.memberIds.where((id) => id != user.uid).toList();
        
        if (updatedMembers.isEmpty) {
          // Delete all messages in the chat
          final messagesSnapshot = await __db
              .collection('chat_rooms')
              .doc(chatRoomId)
              .collection('messages')
              .get();
          
          for (final messageDoc in messagesSnapshot.docs) {
            await messageDoc.reference.delete();
          }
          
          // Delete the chat room itself
          await __db.collection('chat_rooms').doc(chatRoomId).delete();
        } else {
          // Just remove the current user from members
          await __db.collection('chat_rooms').doc(chatRoomId).update({
            'memberIds': updatedMembers,
          });
        }
      } else {
        // For group chats, just remove the user (same as leaving)
        await leaveGroupChat(chatRoomId);
      }
    } catch (e) {
      print('Error deleting chat: $e');
      rethrow;
    }
  }

  static Future<void> pinChat(String chatRoomId, bool isPinned) async {
    if (!FirebaseService.isInitialized) return;

    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await __db.collection('chat_rooms').doc(chatRoomId).set({
        'pinnedBy': isPinned 
            ? FieldValue.arrayUnion([user.uid])
            : FieldValue.arrayRemove([user.uid]),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error pinning chat: $e');
      rethrow;
    }
  }

  static Future<void> muteChat(String chatRoomId, bool isMuted) async {
    if (!FirebaseService.isInitialized) return;

    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await __db.collection('chat_rooms').doc(chatRoomId).set({
        'mutedBy': isMuted 
            ? FieldValue.arrayUnion([user.uid])
            : FieldValue.arrayRemove([user.uid]),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error muting chat: $e');
      rethrow;
    }
  }

  static Future<void> archiveChat(String chatRoomId, bool isArchived) async {
    if (!FirebaseService.isInitialized) return;

    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await __db.collection('chat_rooms').doc(chatRoomId).set({
        'archivedBy': isArchived 
            ? FieldValue.arrayUnion([user.uid])
            : FieldValue.arrayRemove([user.uid]),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error archiving chat: $e');
      rethrow;
    }
  }

  // Messages
  static Stream<List<ChatMessage>> getChatMessages(String chatRoomId, {int limit = 50}) {
    if (!FirebaseService.isInitialized) {
      return const Stream.empty();
    }

    print('Setting up message stream for chat room: $chatRoomId');

    return __db
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          print('Received ${snapshot.docs.length} messages for chat room: $chatRoomId');
          return snapshot.docs
              .map((doc) => ChatMessage.fromMap({...doc.data(), 'id': doc.id}))
              .toList();
        });
  }

  static Future<List<ChatMessage>> fetchOlderMessages({
    required String chatRoomId,
    required DateTime before,
    int limit = 50,
  }) async {
    if (!FirebaseService.isInitialized) return [];

      QuerySnapshot snap;
      try {
        // Prefer Timestamp cursor (new messages use server timestamps)
        snap = await __db
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .startAfter([Timestamp.fromDate(before)])
          .limit(limit)
          .get();
      } catch (e) {
        // Fallback to ISO string cursor for older messages that might be stored as strings
        snap = await __db
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .startAfter([before.toIso8601String()])
          .limit(limit)
          .get();
      }
    return snap.docs
        .map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return ChatMessage.fromMap({...data, 'id': doc.id});
        })
        .toList();
  }

  static Future<void> sendMessage({
    required String chatRoomId,
    required String content,
    MessageType type = MessageType.text,
    String? replyToMessageId,
  }) async {
    if (!FirebaseService.isInitialized) {
      print('ERROR: Firebase not initialized');
      return;
    }

    final user = _auth.currentUser;
    if (user == null) {
      print('ERROR: No authenticated user');
      return;
    }

    // Get user profile for sender info
    final userProfile = await AuthService.getCurrentUserProfile();
    if (userProfile == null) {
      print('ERROR: Could not get user profile');
      return;
    }

    final message = ChatMessage(
      id: _uuid.v4(),
      chatRoomId: chatRoomId,
      senderId: user.uid,
      senderName: userProfile.displayName,
      senderAvatar: userProfile.avatarUrl,
      content: content,
      type: type,
      createdAt: DateTime.now(),
      replyToMessageId: replyToMessageId,
    );

    try {
      print('Sending message to chat room: $chatRoomId');
      print('Sender: ${user.uid} (${userProfile.displayName})');
      print('Content: $content');
      
      // Verify chat room exists and user is a member
      final chatRoomDoc = await __db.collection('chat_rooms').doc(chatRoomId).get();
      if (!chatRoomDoc.exists) {
        print('ERROR: Chat room does not exist!');
        throw Exception('Chat room not found');
      }
      
      final chatRoomData = chatRoomDoc.data()!;
      final memberIds = List<String>.from(chatRoomData['memberIds'] ?? []);
      print('Chat room members: $memberIds');
      
      if (!memberIds.contains(user.uid)) {
        print('ERROR: Current user is not a member of this chat room!');
        throw Exception('User is not a member of this chat room');
      }
      
      // Add message to chat room using server timestamp for createdAt
      final messageMap = Map<String, dynamic>.from(message.toMap());
      // Replace createdAt with server timestamp so all clients receive consistent timestamp types
      messageMap['createdAt'] = FieldValue.serverTimestamp();

      await __db
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(message.id)
        .set(messageMap);

      print('Message written to Firestore: ${message.id}');

      // Update last message timestamp using server timestamp for consistency
      await __db
        .collection('chat_rooms')
        .doc(chatRoomId)
        .update({
        'lastMessageAt': FieldValue.serverTimestamp(),
      });

      print('Updated lastMessageAt for chat room: $chatRoomId');
    } catch (e) {
      print('ERROR sending message: $e');
      rethrow;
    }
  }

  // Read state and unread count
  static Future<void> markRoomRead(String chatRoomId) async {
    if (!FirebaseService.isInitialized) return;
    final user = _auth.currentUser;
    if (user == null) return;
    await __db
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('read_states')
        .doc(user.uid)
        .set({'lastReadAt': DateTime.now().toIso8601String()}, SetOptions(merge: true));
  }

  static Stream<int> getUnreadCount(String chatRoomId) {
    if (!FirebaseService.isInitialized) return const Stream.empty();
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

      final roomRef = __db.collection('chat_rooms').doc(chatRoomId);
    final readRef = roomRef.collection('read_states').doc(user.uid);

    return readRef.snapshots().asyncMap((readSnap) async {
      final lastReadAtStr = (readSnap.data() ?? {})['lastReadAt'] as String?;
      final lastReadAt = lastReadAtStr != null ? DateTime.parse(lastReadAtStr) : DateTime.fromMillisecondsSinceEpoch(0);

      QuerySnapshot newerSnapshot;
      try {
        newerSnapshot = await roomRef
            .collection('messages')
            .where('createdAt', isGreaterThan: Timestamp.fromDate(lastReadAt))
            .get();
      } catch (e) {
        // Fallback to string comparison for older stored messages
        newerSnapshot = await roomRef
            .collection('messages')
            .where('createdAt', isGreaterThan: lastReadAt.toIso8601String())
            .get();
      }
      final newer = newerSnapshot;
      // Exclude user's own messages
      final count = newer.docs.where((d) {
        final data = d.data() as Map<String, dynamic>;
        return (data['senderId'] as String?) != user.uid;
      }).length;
      return count;
    });
  }

  // Typing indicators
  static Future<void> setTyping({required String chatRoomId, required bool isTyping}) async {
    if (!FirebaseService.isInitialized) return;
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      await __db
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('typing')
          .doc(user.uid)
          .set({'isTyping': isTyping, 'updatedAt': DateTime.now().toIso8601String()}, SetOptions(merge: true));
    } catch (e) {
      // Ignore permission errors for typing indicators (e.g., user not yet a member of public group)
      print('setTyping: could not write typing state (ignored): $e');
    }
  }

  static Stream<List<String>> typingUsers(String chatRoomId) {
    if (!FirebaseService.isInitialized) return const Stream.empty();
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return __db
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('typing')
        .snapshots()
        .map((snap) => snap.docs
            .where((d) => (d.data()['isTyping'] == true) && d.id != user.uid)
            .map((d) => d.id)
            .toList());
  }

  static Future<void> addMessageReaction({
    required String chatRoomId,
    required String messageId,
    required String emoji,
  }) async {
    if (!FirebaseService.isInitialized) return;

    final user = _auth.currentUser;
    if (user == null) return;

      final messageRef = __db
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId);

    // Get current reactions
    final messageDoc = await messageRef.get();
    if (!messageDoc.exists) return;

    final message = ChatMessage.fromMap({...messageDoc.data()!, 'id': messageId});
    final reactions = Map<String, List<String>>.from(message.reactions);

    // Add or remove user from reaction
    if (reactions.containsKey(emoji)) {
      final users = List<String>.from(reactions[emoji]!);
      if (users.contains(user.uid)) {
        users.remove(user.uid);
        if (users.isEmpty) {
          reactions.remove(emoji);
        } else {
          reactions[emoji] = users;
        }
      } else {
        users.add(user.uid);
        reactions[emoji] = users;
      }
    } else {
      reactions[emoji] = [user.uid];
    }

    // Update message
    await messageRef.update({
      'reactions': reactions,
    });
  }

  // Update nested chat room settings (pinned, muted, archived, etc.)
  // 'updates' is a map of settingKey -> value, e.g. {'pinned': true}
  static Future<void> updateChatRoomSettings(String chatRoomId, Map<String, dynamic> updates) async {
    if (!FirebaseService.isInitialized) return;

      final docRef = __db.collection('chat_rooms').doc(chatRoomId);

    // Convert to dotted field names so nested map fields are updated safely
    final data = <String, dynamic>{};
    updates.forEach((k, v) {
      data['settings.$k'] = v;
    });

    try {
      await docRef.update(data);
    } catch (e) {
      // If update fails (e.g., doc doesn't exist), try set with merge
      await docRef.set({'settings': updates}, SetOptions(merge: true));
    }
  }

  static Future<void> editMessage({
    required String chatRoomId,
    required String messageId,
    required String newContent,
  }) async {
    if (!FirebaseService.isInitialized) return;

    final user = _auth.currentUser;
    if (user == null) return;

      await __db
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId)
        .update({
      'content': newContent,
      'editedAt': DateTime.now().toIso8601String(),
      'isEdited': true,
    });
  }

  static Future<void> deleteMessage({
    required String chatRoomId,
    required String messageId,
  }) async {
    if (!FirebaseService.isInitialized) return;

    final user = _auth.currentUser;
    if (user == null) return;

    // Check if user is the sender
      final messageDoc = await __db
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId)
        .get();

    if (messageDoc.exists) {
      final message = ChatMessage.fromMap({...messageDoc.data()!, 'id': messageId});
      if (message.senderId == user.uid) {
        await _db
            .collection('chat_rooms')
            .doc(chatRoomId)
            .collection('messages')
            .doc(messageId)
            .delete();
      }
    }
  }

  // Chat Requests
  static Future<void> sendChatRequest({
    required String targetUserId,
    String? message,
  }) async {
    if (!FirebaseService.isInitialized) return;

    final user = _auth.currentUser;
    if (user == null) return;

    final userProfile = await AuthService.getCurrentUserProfile();
    if (userProfile == null) return;

    final chatRequest = ChatRequest(
      id: _uuid.v4(),
      requesterId: user.uid,
      requesterName: userProfile.displayName,
      requesterAvatar: userProfile.avatarUrl,
      targetUserId: targetUserId,
      message: message,
      status: ChatRequestStatus.pending,
      createdAt: DateTime.now(),
    );

      await __db
        .collection('chat_requests')
        .doc(chatRequest.id)
        .set(chatRequest.toMap());
  }

  static Stream<List<ChatRequest>> getChatRequests() {
    if (!FirebaseService.isInitialized) {
      return const Stream.empty();
    }

    final user = _auth.currentUser;
    if (user == null) {
      return Stream.error(Exception('User must be authenticated to view chat requests'));
    }

      return __db
        .collection('chat_requests')
        .where('targetUserId', isEqualTo: user.uid)
        .where('status', isEqualTo: ChatRequestStatus.pending.name)
        .snapshots()
        .handleError((error) {
          // Handle Firestore permission errors more gracefully
          if (error is FirebaseException && error.code == 'permission-denied') {
            throw Exception('Permission denied: Please check Firestore security rules for chat_requests collection');
          }
          throw error;
        })
        .map((snapshot) {
          final requests = snapshot.docs
              .map((doc) => ChatRequest.fromMap({...doc.data(), 'id': doc.id}))
              .toList();
          requests.sort((a, b) {
            final aTime = a.createdAt;
            final bTime = b.createdAt;
            return bTime.compareTo(aTime);
          });
          return requests;
        });
  }

  static Future<void> respondToChatRequest({
    required String requestId,
    required ChatRequestStatus status,
    String? responseMessage,
  }) async {
    if (!FirebaseService.isInitialized) return;

    try {
      await __db
          .collection('chat_requests')
          .doc(requestId)
          .update({
        'status': status.name,
        'respondedAt': DateTime.now().toIso8601String(),
        'responseMessage': responseMessage,
      });

      // If approved, create private chat and send welcome message
      if (status == ChatRequestStatus.approved) {
        final requestDoc = await __db
            .collection('chat_requests')
            .doc(requestId)
            .get();

        if (requestDoc.exists) {
          final request = ChatRequest.fromMap({...requestDoc.data()!, 'id': requestId});
          
          print('Creating private chat for requester: ${request.requesterId}');
          final chatRoom = await createPrivateChat(request.requesterId);
          print('Chat room created with ID: ${chatRoom.id}');
          
          // Send a welcome message to make the chat visible immediately
          final user = __auth.currentUser;
          if (user != null) {
            final userProfile = await AuthService.getCurrentUserProfile();
            final welcomeMessage = ChatMessage(
              id: _uuid.v4(),
              chatRoomId: chatRoom.id,
              senderId: user.uid,
              senderName: userProfile?.displayName ?? 'User',
              content: responseMessage?.isNotEmpty == true 
                  ? responseMessage! 
                  : 'Chat request accepted! Feel free to start the conversation.',
              type: MessageType.text,
              createdAt: DateTime.now(),
            );

            print('Sending welcome message to chat: ${chatRoom.id}');

            final welcomeMap = Map<String, dynamic>.from(welcomeMessage.toMap());
            welcomeMap['createdAt'] = FieldValue.serverTimestamp();

            await __db
                .collection('chat_rooms')
                .doc(chatRoom.id)
                .collection('messages')
                .doc(welcomeMessage.id)
                .set(welcomeMap);

            // Update lastMessageAt so the chat appears at the top (use server timestamp)
            print('Updating lastMessageAt for chat: ${chatRoom.id}');
            await __db
                .collection('chat_rooms')
                .doc(chatRoom.id)
                .update({
              'lastMessageAt': FieldValue.serverTimestamp(),
            });
            
            print('Chat setup complete for: ${chatRoom.id}');
          }
        }
      }
    } catch (e) {
      print('Error responding to chat request: $e');
      rethrow;
    }
  }

  // User Search
  static Future<List<UserProfile>> searchUsers(String query) async {
    if (!FirebaseService.isInitialized) {
      return [];
    }

    final user = _auth.currentUser;
    if (user == null) {
      return [];
    }

    try {
        final snapshot = await __db
          .collection('users')
          .where('displayName', isGreaterThanOrEqualTo: query)
          .where('displayName', isLessThan: query + 'z')
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => UserProfile.fromMap(doc.data()))
          .where((profile) => profile.uid != user.uid)
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Get the other user's profile in a private chat
  static Future<UserProfile?> getOtherUserInPrivateChat(ChatRoom chatRoom) async {
    if (!FirebaseService.isInitialized) return null;
    if (chatRoom.type != ChatType.private) return null;
    if (chatRoom.memberIds.length != 2) return null;

    final currentUser = __auth.currentUser;
    if (currentUser == null) return null;

    // Find the other user's ID
    final otherUserId = chatRoom.memberIds.firstWhere(
      (id) => id != currentUser.uid,
      orElse: () => '',
    );

    if (otherUserId.isEmpty) return null;

    try {
      final userDoc = await __db.collection('users').doc(otherUserId).get();
      if (!userDoc.exists) return null;
      return UserProfile.fromMap(userDoc.data()!);
    } catch (e) {
      print('Error fetching other user profile: $e');
      return null;
    }
  }

  static Future<List<UserProfile>> getMentors() async {
    if (!FirebaseService.isInitialized) {
      return [];
    }

    try {
      final currentUser = __auth.currentUser;
      final snapshot = await __db
          .collection('users')
          .where('role', isEqualTo: UserRole.mentor.name)
          .limit(50)
          .get();

      return snapshot.docs
          .map((doc) => UserProfile.fromMap(doc.data()))
          .where((mentor) => mentor.uid != currentUser?.uid) // Exclude current user
          .toList();
    } catch (_) {
      return [];
    }
  }

  // Stream version for real-time updates
  static Stream<List<UserProfile>> getMentorsStream() {
    if (!FirebaseService.isInitialized) {
      return Stream.value([]);
    }
    final currentUser = __auth.currentUser;
    return __db
        .collection('users')
        .where('role', isEqualTo: UserRole.mentor.name)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserProfile.fromMap(doc.data()))
            .where((mentor) => mentor.uid != currentUser?.uid) // Exclude current user
            .toList());
  }

  // Get private chat requests for current user
  static Stream<List<PrivateChatRequest>> getPrivateChatRequests() {
    if (!FirebaseService.isInitialized) {
      return Stream.value([]);
    }
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

      return __db
        .collection('private_chat_requests')
        .where('receiverId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PrivateChatRequest.fromMap(doc.data()))
            .toList());
  }

  // Accept private chat request
  static Future<ChatRoom?> acceptPrivateChatRequest(String requestId) async {
    if (!FirebaseService.isInitialized) return null;

    final user = _auth.currentUser;
    if (user == null) return null;

    final requestRef = _db.collection('private_chat_requests').doc(requestId);
    
    return await _db.runTransaction((transaction) async {
      final requestDoc = await transaction.get(requestRef);
      if (!requestDoc.exists) return null;

      final request = PrivateChatRequest.fromMap(requestDoc.data()!);
      if (request.receiverId != user.uid) return null;

      // Update request status
      transaction.update(requestRef, {'status': 'accepted'});

      // Create private chat room
      final chatRoom = ChatRoom(
        id: _uuid.v4(),
        type: ChatType.private,
        name: 'Private Chat',
        memberIds: [request.senderId, request.receiverId],
        createdAt: DateTime.now(),
      );

      transaction.set(_db.collection('chat_rooms').doc(chatRoom.id), chatRoom.toMap());
      return chatRoom;
    });
  }

  // Reject private chat request
  static Future<void> rejectPrivateChatRequest(String requestId) async {
    if (!FirebaseService.isInitialized) return;

    final user = _auth.currentUser;
    if (user == null) return;

    final requestRef = _db.collection('private_chat_requests').doc(requestId);
    await requestRef.update({'status': 'rejected'});
  }

  // Send private chat request
  static Future<void> sendPrivateChatRequest(String mentorId) async {
    if (!FirebaseService.isInitialized) return;

    final user = _auth.currentUser;
    if (user == null) return;

    final request = {
      'id': _uuid.v4(),
      'senderId': user.uid,
      'receiverId': mentorId,
      'timestamp': DateTime.now().toIso8601String(),
      'status': 'pending',
    };

      await __db.collection('private_chat_requests').doc(request['id']).set(request);
  }

  // Helper: Get existing private chat between current user and target
  static Future<ChatRoom?> getExistingPrivateChat(String targetUserId) async {
    if (!_isReady) return null;

    final user = __auth.currentUser;
    if (user == null) return null;

    try {
      final existingChats = await __db
          .collection('chat_rooms')
          .where('type', isEqualTo: ChatType.private.name)
          .where('memberIds', arrayContains: user.uid)
          .get();

      for (final doc in existingChats.docs) {
        final chat = ChatRoom.fromMap({...doc.data(), 'id': doc.id});
        if (chat.memberIds.contains(targetUserId) && chat.memberIds.length == 2) {
          return chat;
        }
      }
      return null;
    } catch (e) {
      print('Error checking for existing chat: $e');
      return null;
    }
  }

  // Helper: Get existing chat request from current user to target
  static Future<ChatRequest?> getExistingChatRequest(String targetUserId) async {
    if (!_isReady) return null;

    final user = __auth.currentUser;
    if (user == null) return null;

    try {
      final snapshot = await __db
          .collection('chat_requests')
          .where('requesterId', isEqualTo: user.uid)
          .where('targetUserId', isEqualTo: targetUserId)
          .where('status', isEqualTo: ChatRequestStatus.pending.name)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return ChatRequest.fromMap({...snapshot.docs.first.data(), 'id': snapshot.docs.first.id});
      }
      return null;
    } catch (e) {
      print('Error checking for existing request: $e');
      return null;
    }
  }
}
