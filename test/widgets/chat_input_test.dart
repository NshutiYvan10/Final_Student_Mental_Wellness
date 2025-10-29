import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student_mental_wellness/widgets/chat_input.dart';

void main() {
  testWidgets('ChatInput send button disabled when empty and enabled when text present', (tester) async {
    String? sent;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ChatInput(
          chatRoomId: 'room',
          onSend: (text) async {
            sent = text;
          },
        ),
      ),
    ));

    final sendButton = find.byIcon(Icons.send_rounded);
    expect(sendButton, findsOneWidget);

    // Initially button should be disabled
    await tester.tap(sendButton);
    await tester.pumpAndSettle();
    expect(sent, isNull);

    // Enter text
    await tester.enterText(find.byType(TextField), 'hi');
    await tester.pumpAndSettle();

    await tester.tap(sendButton);
    await tester.pumpAndSettle();
    expect(sent, 'hi');
  });
}
