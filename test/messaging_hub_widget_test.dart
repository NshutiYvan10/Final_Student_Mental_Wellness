import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_mental_wellness/pages/messaging/messaging_hub_page.dart';

void main() {
  testWidgets('MessagingHub shows tabs and discover button', (tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(home: MessagingHubPage()),
    ));

    // Tabs
    expect(find.text('Chats'), findsOneWidget);
    expect(find.text('Mentors'), findsOneWidget);
    expect(find.text('Requests'), findsOneWidget);

    // Discover Groups button in Chats tab
    expect(find.text('Discover Groups'), findsOneWidget);
  });
}



