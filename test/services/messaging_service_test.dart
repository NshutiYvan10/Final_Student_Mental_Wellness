import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:student_mental_wellness/services/messaging_service.dart';
import 'package:student_mental_wellness/services/auth_service.dart';
import 'package:student_mental_wellness/models/chat_models.dart';
import 'package:student_mental_wellness/models/user_profile.dart';

import 'messaging_service_test.mocks.dart';

@GenerateMocks([
  FirebaseFirestore,
  FirebaseAuth,
  CollectionReference<Map<String, dynamic>>,
  DocumentReference<Map<String, dynamic>>,
  QuerySnapshot<Map<String, dynamic>>,
  DocumentSnapshot<Map<String, dynamic>>,
])
void main() {
  group('MessagingService', () {
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseAuth mockAuth;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDocument;
  late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;
  late MockDocumentSnapshot<Map<String, dynamic>> mockDocumentSnapshot;

    setUp(() {
  mockFirestore = MockFirebaseFirestore();
  mockAuth = MockFirebaseAuth();
  mockCollection = MockCollectionReference<Map<String, dynamic>>();
  mockDocument = MockDocumentReference<Map<String, dynamic>>();
  mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
  mockDocumentSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
      // Inject test instances into the MessagingService so it uses our mocks
      MessagingService.setTestInstances(db: mockFirestore, auth: mockAuth);
      // Inject a test user profile (mentor) so mentor-only flows succeed in tests
      AuthService.setTestProfile(UserProfile(
        uid: 'creator',
        displayName: 'Test Mentor',
        email: 'mentor@example.com',
        avatarUrl: '',
        school: 'Test School',
        role: UserRole.mentor,
        createdAt: DateTime.now(),
      ));
    });

    group('createGroupChat', () {
      test('should create a group chat successfully', () async {
        // Arrange
        const name = 'Test Group';
        const description = 'Test Description';
        const memberIds = ['user1', 'user2'];
        const isPrivate = false;

  when(mockAuth.currentUser).thenReturn(MockUser()..uid = 'creator');
  when(mockFirestore.collection('chat_rooms')).thenReturn(mockCollection as CollectionReference<Map<String, dynamic>>);
        when(mockCollection.doc(any)).thenReturn(mockDocument);
        when(mockDocument.set(any)).thenAnswer((_) async => {});

        // Act
        final result = await MessagingService.createGroupChat(
          name: name,
          description: description,
          memberIds: memberIds,
          isPrivate: isPrivate,
        );

        // Assert
        expect(result.name, equals(name));
        expect(result.description, equals(description));
        expect(result.memberIds, contains('creator'));
        expect(result.memberIds, containsAll(memberIds));
        expect(result.type, equals(ChatType.group));
        expect(result.isPrivate, equals(isPrivate));
      });

      test('should throw exception when user not authenticated', () async {
        // Arrange
        when(mockAuth.currentUser).thenReturn(null);

        // Act & Assert
        expect(
          () => MessagingService.createGroupChat(
            name: 'Test Group',
            description: 'Test Description',
            memberIds: ['user1'],
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('createPrivateChat', () {
      test('should create a private chat successfully', () async {
        // Arrange
        const targetUserId = 'target_user';
  when(mockAuth.currentUser).thenReturn(MockUser()..uid = 'current_user');
  when(mockFirestore.collection('chat_rooms')).thenReturn(mockCollection as CollectionReference<Map<String, dynamic>>);
        when(mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')))
            .thenReturn(mockCollection);
        when(mockCollection.where(any, arrayContains: anyNamed('arrayContains')))
            .thenReturn(mockCollection);
        when(mockCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs).thenReturn([]);
        when(mockCollection.doc(any)).thenReturn(mockDocument);
        when(mockDocument.set(any)).thenAnswer((_) async => {});

        // Act
        final result = await MessagingService.createPrivateChat(targetUserId);

        // Assert
        expect(result.type, equals(ChatType.private));
        expect(result.memberIds, contains('current_user'));
        expect(result.memberIds, contains(targetUserId));
        expect(result.memberIds.length, equals(2));
      });
    });

    group('sendMessage', () {
      test('should send a message successfully', () async {
        // Arrange
        const chatRoomId = 'chat_room_1';
        const content = 'Hello, world!';
        const senderId = 'sender_1';
        const senderName = 'John Doe';

  when(mockAuth.currentUser).thenReturn(MockUser()..uid = senderId);
  when(mockFirestore.collection('chat_rooms')).thenReturn(mockCollection as CollectionReference<Map<String, dynamic>>);
        when(mockCollection.doc(chatRoomId)).thenReturn(mockDocument);
  when(mockDocument.collection('messages')).thenReturn(mockCollection as CollectionReference<Map<String, dynamic>>);
        when(mockCollection.doc(any)).thenReturn(mockDocument);
        when(mockDocument.set(any)).thenAnswer((_) async => {});
        when(mockDocument.update(any)).thenAnswer((_) async => {});

        // Mock AuthService.getCurrentUserProfile
        // This would need to be mocked in a real test

        // Act & Assert — ensure sendMessage completes without throwing
        await MessagingService.sendMessage(
          chatRoomId: chatRoomId,
          content: content,
        );

        expect(true, isTrue);
      });
    });

    group('searchUsers', () {
      test('should return empty list when Firebase not initialized', () async {
        // Act
        final result = await MessagingService.searchUsers('test');

        // Assert
        expect(result, isEmpty);
      });
    });

    group('getMentors', () {
      test('should return empty list when Firebase not initialized', () async {
        // Act
        final result = await MessagingService.getMentors();

        // Assert
        expect(result, isEmpty);
      });
    });
  });
}

// Mock User class
class MockUser extends Mock implements User {
  String _uid = 'mock_uid';

  @override
  String get uid => _uid;

  set uid(String v) => _uid = v;
}


