import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../dashboard/dashboard_page.dart';
import '../groups/groups_page.dart';
import '../journal/journal_page.dart';
import '../resources/resources_page.dart';
import '../profile/profile_page.dart';
import '../messaging/messaging_hub_page.dart';
import '../analytics/analytics_page.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

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

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBody: true, // Allow body to extend behind navigation bar
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: IndexedStack(key: ValueKey(_current), index: _current, children: _pages),
      ),
      bottomNavigationBar: _PremiumNavigationBar(
        currentIndex: _current,
        onDestinationSelected: (i) {
          HapticFeedback.lightImpact();
          setState(() => _current = i);
        },
        destinations: _getNavigationDestinations(),
        isDark: isDark,
      ),
    );
  }

  List<NavigationDestination> _getNavigationDestinations() {
    if (_currentUser == null) return [];

    if (_currentUser!.role == UserRole.student) {
      return const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard_rounded),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.forum_outlined),
          selectedIcon: Icon(Icons.forum_rounded),
          label: 'Messages',
        ),
        NavigationDestination(
          icon: Icon(Icons.book_outlined),
          selectedIcon: Icon(Icons.book_rounded),
          label: 'Journal',
        ),
        NavigationDestination(
          icon: Icon(Icons.insights_outlined),
          selectedIcon: Icon(Icons.insights_rounded),
          label: 'Analytics',
        ),
        NavigationDestination(
          icon: Icon(Icons.account_circle_outlined),
          selectedIcon: Icon(Icons.account_circle_rounded),
          label: 'Profile',
        ),
      ];
    } else {
      return const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard_rounded),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.forum_outlined),
          selectedIcon: Icon(Icons.forum_rounded),
          label: 'Messages',
        ),
        NavigationDestination(
          icon: Icon(Icons.library_books_outlined),
          selectedIcon: Icon(Icons.library_books_rounded),
          label: 'Resources',
        ),
        NavigationDestination(
          icon: Icon(Icons.account_circle_outlined),
          selectedIcon: Icon(Icons.account_circle_rounded),
          label: 'Profile',
        ),
      ];
    }
  }
}

// Premium Custom Navigation Bar
class _PremiumNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;
  final bool isDark;

  const _PremiumNavigationBar({
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
      padding: EdgeInsets.only(
        left: 8,
        right: 8,
        top: 12,
        bottom: bottomPadding > 0 ? bottomPadding / 2 + 8 : 12,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.4)
                : Colors.black.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          if (!isDark)
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Colors.white.withOpacity(0.08), // Glassmorphism like chat cards
                        Colors.white.withOpacity(0.05),
                      ]
                    : [
                        Colors.white.withOpacity(0.95),
                        Colors.grey.shade50.withOpacity(0.95),
                      ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.12)
                    : Colors.black.withOpacity(0.06),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                destinations.length,
                (index) => _NavItem(
                  destination: destinations[index],
                  isSelected: currentIndex == index,
                  onTap: () => onDestinationSelected(index),
                  isDark: isDark,
                  theme: theme,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final NavigationDestination destination;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;
  final ThemeData theme;

  const _NavItem({
    required this.destination,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon with animated gradient background
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.primaryColor.withOpacity(0.2),
                              AppTheme.secondaryColor.withOpacity(0.2),
                            ],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ShaderMask(
                    shaderCallback: (bounds) {
                      if (isSelected) {
                        return LinearGradient(
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.secondaryColor,
                          ],
                        ).createShader(bounds);
                      }
                      return LinearGradient(
                        colors: [
                          isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                          isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ],
                      ).createShader(bounds);
                    },
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: child,
                        );
                      },
                      child: Icon(
                        isSelected
                            ? (destination.selectedIcon as Icon).icon
                            : (destination.icon as Icon).icon,
                        key: ValueKey(isSelected),
                        size: 26,
                        color: Colors.white, // Will be masked by shader
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Label
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: isSelected ? 12 : 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? (isDark ? Colors.white : theme.colorScheme.onSurface)
                        : (isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600),
                  ),
                  child: Text(
                    destination.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}






