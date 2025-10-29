import 'package:flutter_test/flutter_test.dart';
import 'package:student_mental_wellness/models/chat_models.dart';
import 'package:student_mental_wellness/pages/messaging/messaging_hub_page.dart';

void main() {
  group('MessagingHub filterAndSortChatRooms', () {
    final now = DateTime.now();

    final roomA = ChatRoom(
      id: 'a',
      name: 'Algebra Club',
      description: 'Math club',
      type: ChatType.group,
      memberIds: ['u1'],
      createdAt: now.subtract(const Duration(days: 5)),
      lastMessageAt: now.subtract(const Duration(minutes: 30)),
      settings: {'pinned': false},
    );

    final roomB = ChatRoom(
      id: 'b',
      name: '',
      description: 'Private discussion with Bob',
      type: ChatType.private,
      memberIds: ['u1','u2'],
      createdAt: now.subtract(const Duration(days: 2)),
      lastMessageAt: now.subtract(const Duration(minutes: 10)),
      settings: {'pinned': true},
    );

    final roomC = ChatRoom(
      id: 'c',
      name: 'Chemistry',
      description: 'Lab group',
      type: ChatType.group,
      memberIds: ['u1','u3'],
      createdAt: now.subtract(const Duration(days: 1)),
      lastMessageAt: now.subtract(const Duration(hours: 1)),
      settings: {'pinned': false},
    );

    test('returns pinned rooms first and preserves others order', () {
      final list = [roomA, roomB, roomC];
      final out = filterAndSortChatRooms(list, '');

      // roomB is pinned and should be first
      expect(out.first.id, equals('b'));
      expect(out.sublist(1).map((r) => r.id), containsAll(['a','c']));
    });

    test('filters by name or description (case insensitive)', () {
      final list = [roomA, roomB, roomC];
      final out = filterAndSortChatRooms(list, 'chem');

      expect(out.length, equals(1));
      expect(out.first.id, equals('c'));

      final out2 = filterAndSortChatRooms(list, 'bob');
      expect(out2.length, equals(1));
      expect(out2.first.id, equals('b'));
    });

    test('empty filter returns all rooms with pinned first', () {
      final list = [roomC, roomA, roomB];
      final out = filterAndSortChatRooms(list, '');
      expect(out.length, equals(3));
      expect(out.first.id, equals('b'));
    });
  });
}
