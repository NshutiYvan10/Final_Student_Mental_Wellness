import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student_mental_wellness/widgets/message_bubble.dart';
import 'package:student_mental_wellness/models/chat_models.dart';

void main() {
  testWidgets('MessageBubble displays content and time', (tester) async {
    final msg = ChatMessage(
      id: '1',
      chatRoomId: 'r1',
      senderId: 'u1',
      senderName: 'Alice',
      senderAvatar: '',
      content: 'Hello there',
      type: MessageType.text,
      createdAt: DateTime.now(),
    );

  await tester.pumpWidget(MaterialApp(home: Scaffold(body: Center(child: MessageBubble(message: msg, isMe: false)))));

  expect(find.text('Hello there'), findsOneWidget);
  });
}
