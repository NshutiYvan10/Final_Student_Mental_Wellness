import 'package:flutter/material.dart';

import '../pages/onboarding/onboarding_page.dart';
import '../pages/auth/login_page.dart';
import '../pages/auth/signup_page.dart';
import '../pages/mood/mood_logger_page.dart';
import '../pages/mood/mood_list_page.dart';
import '../pages/journal/journal_page.dart';
import '../pages/meditation/meditation_page.dart';
import '../pages/chat/chat_page.dart';
import '../pages/analytics/analytics_page.dart';
import '../pages/profile/profile_page.dart';
import '../pages/notifications/notifications_page.dart';
import '../pages/settings/settings_page.dart';
import '../pages/groups/groups_page.dart';
import '../pages/resources/resources_page.dart';
import '../pages/home/home_shell.dart';
import '../pages/messaging/messaging_hub_page.dart';
import '../pages/messaging/chat_room_page.dart';

class AppRouter {
  static const String initialRoute = '/onboarding';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/onboarding':
        return _transition(const OnboardingPage());
      case '/login':
        return _transition(const LoginPage());
      case '/signup':
        return _transition(const SignupPage());
      case '/dashboard':
        return _transition(const HomeShell());
      case '/mood/logger':
        return _transition(const MoodLoggerPage());
      case '/mood/list':
        return _transition(const MoodListPage());
      case '/journal':
        return _transition(const JournalPage());
      case '/meditation':
        return _transition(const MeditationPage());
      case '/chat':
        return _transition(const ChatPage());
      case '/groups':
        return _transition(const GroupsPage());
      case '/resources':
        return _transition(const ResourcesPage());
      case '/analytics':
        return _transition(const AnalyticsPage());
      case '/profile':
        return _transition(const ProfilePage());
      case '/notifications':
        return _transition(const NotificationsPage());
      case '/settings':
        return _transition(const SettingsPage());
      case '/messaging':
        return _transition(const MessagingHubPage());
      case '/chat-room':
        final args = settings.arguments as Map<String, dynamic>?;
        final chatRoom = args?['chatRoom'];
        if (chatRoom != null) {
          return _transition(ChatRoomPage(chatRoom: chatRoom));
        }
        return _transition(
          Scaffold(
            body: Center(
              child: Text('Chat room not found'),
            ),
          ),
        );
      default:
        return _transition(
          Scaffold(
            body: Center(
              child: Text('Route not found: ${settings.name}'),
            ),
          ),
        );
    }
  }

  static PageRouteBuilder _transition(Widget child) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => child,
        transitionsBuilder: (_, animation, __, widget) {
          final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return FadeTransition(opacity: curve, child: widget);
        },
      );
}


