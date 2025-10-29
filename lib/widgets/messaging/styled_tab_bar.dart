import 'package:flutter/material.dart';
import '../../theme/messaging_theme.dart'; // Import messaging theme extension

class StyledTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController controller;
  final List<Widget> tabs;

  const StyledTabBar({super.key, required this.controller, required this.tabs});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Use the extension method for easy access
    final msgTheme = context.messagingTheme;

    return Padding(
      // Add padding around the tab bar container
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        height: 48, // Set a fixed height for the tab bar container
        decoration: BoxDecoration(
          color: msgTheme.tabBarBackgroundColor,
          borderRadius: BorderRadius.circular(12), // Consistent rounding
          boxShadow: [ // Subtle shadow for depth
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: TabBar(
          controller: controller,
          tabs: tabs,
          // Custom indicator decoration
          indicator: BoxDecoration(
            color: msgTheme.tabBarIndicatorColor, // Use theme color
            borderRadius: BorderRadius.circular(12), // Match container rounding
          ),
          indicatorSize: TabBarIndicatorSize.tab, // Indicator fills the tab background
          labelColor: msgTheme.selectedTabTextColor, // Selected text color
          unselectedLabelColor: msgTheme.unselectedTabTextColor, // Unselected text color
          splashBorderRadius: BorderRadius.circular(12), // Rounded splash effect
          labelStyle: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700), // Bold selected label
          unselectedLabelStyle: theme.textTheme.labelLarge, // Regular unselected label
          dividerColor: Colors.transparent, // Remove default divider line
        ),
      ),
    );
  }

  // Define the preferred size for AppBar bottom placement
  @override
  Size get preferredSize => const Size.fromHeight(64); // Height includes vertical padding
}