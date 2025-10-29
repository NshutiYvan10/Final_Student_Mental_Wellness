import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dashboard/dashboard_page.dart';
import '../groups/groups_page.dart';
import '../journal/journal_page.dart';
import '../resources/resources_page.dart';
import '../profile/profile_page.dart';
import '../messaging/messaging_hub_page.dart';
import '../analytics/analytics_page.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _current = 0;
  UserProfile? _currentUser;
  List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await AuthService.getCurrentUserProfile();
    if (mounted) {
      setState(() {
        _currentUser = user;
        _updatePages();
      });
    }
  }

  void _updatePages() {
    if (_currentUser == null) return;

    setState(() {
      if (_currentUser!.role == UserRole.student) {
        _pages = const [
          DashboardPage(),
          MessagingHubPage(),
          JournalPage(),
          AnalyticsPage(),
          ProfilePage(),
        ];
      } else {
        // Mentor pages (Groups removed as requested)
        _pages = const [
          DashboardPage(),
          MessagingHubPage(),
          ResourcesPage(),
          ProfilePage(),
        ];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null || _pages.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: IndexedStack(key: ValueKey(_current), index: _current, children: _pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _current,
        onDestinationSelected: (i) => setState(() => _current = i),
        destinations: _getNavigationDestinations(),
      ),
    );
  }

  List<NavigationDestination> _getNavigationDestinations() {
    if (_currentUser == null) return [];

    if (_currentUser!.role == UserRole.student) {
      return const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble_rounded), label: 'Messages'),
        NavigationDestination(icon: Icon(Icons.edit_outlined), selectedIcon: Icon(Icons.edit), label: 'Journal'),
        NavigationDestination(icon: Icon(Icons.analytics_outlined), selectedIcon: Icon(Icons.analytics_rounded), label: 'Analytics'),
        NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
      ];
    } else {
      return const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble_rounded), label: 'Messages'),
        NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book_rounded), label: 'Resources'),
        NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
      ];
    }
  }
}








