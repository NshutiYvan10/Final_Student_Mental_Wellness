import 'package:flutter/material.dart';
import 'package:student_mental_wellness/theme/app_theme.dart'; // Adjust import path if needed

// Helper Extension Method to easily get MessagingTheme
extension MessagingThemeContext on BuildContext {
  MessagingTheme get messagingTheme => Theme.of(this).extension<MessagingTheme>()!;
}

// Theme Extension for consistent messaging styles
class MessagingTheme extends ThemeExtension<MessagingTheme> {
  final Color chatListBackground;
  final Color chatRoomBackground;
  final Color myMessageBubbleColor;
  final Color myMessageTextColor;
  final Color otherMessageBubbleColor;
  final Color otherMessageTextColor;
  final Color inputBackgroundColor;
  final Color inputTextColor;
  final Color inputHintColor;
  final Color sendButtonColor;
  final Color sendButtonIconColor;
  final Color tabBarIndicatorColor;
  final Color tabBarBackgroundColor;
  final Color unselectedTabColor;
  final Color selectedTabColor;
  final Color selectedTabTextColor; // Text color for selected tab
  final Color unselectedTabTextColor; // Text color for unselected tab
  final Color attachmentButtonColor;
  final Color infoPageBackgroundColor;
  final Color dividerColor;

  const MessagingTheme({
    required this.chatListBackground,
    required this.chatRoomBackground,
    required this.myMessageBubbleColor,
    required this.myMessageTextColor,
    required this.otherMessageBubbleColor,
    required this.otherMessageTextColor,
    required this.inputBackgroundColor,
    required this.inputTextColor,
    required this.inputHintColor,
    required this.sendButtonColor,
    required this.sendButtonIconColor,
    required this.tabBarIndicatorColor,
    required this.tabBarBackgroundColor,
    required this.unselectedTabColor,
    required this.selectedTabColor,
    required this.selectedTabTextColor,
    required this.unselectedTabTextColor,
    required this.attachmentButtonColor,
    required this.infoPageBackgroundColor,
    required this.dividerColor,
  });

  // --- Light Theme Definition ---
  static const light = MessagingTheme(
    chatListBackground: AppTheme.softBg, // Use main theme's soft background
    chatRoomBackground: Color(0xFFF1F5F9), // Slightly off-white
    myMessageBubbleColor: AppTheme.primaryColor,
    myMessageTextColor: Colors.white,
    otherMessageBubbleColor: Colors.white,
    otherMessageTextColor: Color(0xFF1E293B), // Dark slate gray for text
    inputBackgroundColor: Colors.white,
    inputTextColor: Color(0xFF0F172A),
    inputHintColor: Colors.black45,
    sendButtonColor: AppTheme.primaryColor,
    sendButtonIconColor: Colors.white,
    tabBarIndicatorColor: AppTheme.primaryColor,
    tabBarBackgroundColor: Colors.white,
    unselectedTabColor: Color(0xFF64748B), // Slate 500
    selectedTabColor: AppTheme.primaryColor, // Background color for selected tab
    selectedTabTextColor: Colors.white, // Text color for selected tab
    unselectedTabTextColor: Color(0xFF64748B), // Slate 500
    attachmentButtonColor: Color(0xFF64748B),
    infoPageBackgroundColor: AppTheme.softBg,
    dividerColor: Color(0xFFE2E8F0), // Slate 200
  );

  // --- Dark Theme Definition ---
  static const dark = MessagingTheme(
    chatListBackground: Color(0xFF0F172A), // Use main theme's dark background
    chatRoomBackground: Color(0xFF162135), // Slightly lighter dark
    myMessageBubbleColor: AppTheme.primaryColor,
    myMessageTextColor: Colors.white,
    otherMessageBubbleColor: Color(0xFF334155), // Dark surface color (Slate 700)
    otherMessageTextColor: Color(0xFFF1F5F9), // Light text (Slate 100)
    inputBackgroundColor: Color(0xFF1E293B), // Slate 800
    inputTextColor: Colors.white,
    inputHintColor: Colors.white60,
    sendButtonColor: AppTheme.primaryColor,
    sendButtonIconColor: Colors.white,
    tabBarIndicatorColor: AppTheme.primaryColor,
    tabBarBackgroundColor: Color(0xFF1E293B), // Slate 800
    unselectedTabColor: Color(0xFF94A3B8), // Slate 400
    selectedTabColor: AppTheme.primaryColor, // Background color for selected tab
    selectedTabTextColor: Colors.white, // Text color for selected tab
    unselectedTabTextColor: Color(0xFF94A3B8), // Slate 400
    attachmentButtonColor: Color(0xFF94A3B8),
    infoPageBackgroundColor: Color(0xFF0F172A),
    dividerColor: Color(0xFF334155), // Slate 700
  );

  // --- ThemeExtension Methods ---
  @override
  MessagingTheme copyWith({
    Color? chatListBackground,
    Color? chatRoomBackground,
    Color? myMessageBubbleColor,
    Color? myMessageTextColor,
    Color? otherMessageBubbleColor,
    Color? otherMessageTextColor,
    Color? inputBackgroundColor,
    Color? inputTextColor,
    Color? inputHintColor,
    Color? sendButtonColor,
    Color? sendButtonIconColor,
    Color? tabBarIndicatorColor,
    Color? tabBarBackgroundColor,
    Color? unselectedTabColor,
    Color? selectedTabColor,
    Color? selectedTabTextColor,
    Color? unselectedTabTextColor,
    Color? attachmentButtonColor,
    Color? infoPageBackgroundColor,
    Color? dividerColor,
  }) {
    return MessagingTheme(
      chatListBackground: chatListBackground ?? this.chatListBackground,
      chatRoomBackground: chatRoomBackground ?? this.chatRoomBackground,
      myMessageBubbleColor: myMessageBubbleColor ?? this.myMessageBubbleColor,
      myMessageTextColor: myMessageTextColor ?? this.myMessageTextColor,
      otherMessageBubbleColor: otherMessageBubbleColor ?? this.otherMessageBubbleColor,
      otherMessageTextColor: otherMessageTextColor ?? this.otherMessageTextColor,
      inputBackgroundColor: inputBackgroundColor ?? this.inputBackgroundColor,
      inputTextColor: inputTextColor ?? this.inputTextColor,
      inputHintColor: inputHintColor ?? this.inputHintColor,
      sendButtonColor: sendButtonColor ?? this.sendButtonColor,
      sendButtonIconColor: sendButtonIconColor ?? this.sendButtonIconColor,
      tabBarIndicatorColor: tabBarIndicatorColor ?? this.tabBarIndicatorColor,
      tabBarBackgroundColor: tabBarBackgroundColor ?? this.tabBarBackgroundColor,
      unselectedTabColor: unselectedTabColor ?? this.unselectedTabColor,
      selectedTabColor: selectedTabColor ?? this.selectedTabColor,
      selectedTabTextColor: selectedTabTextColor ?? this.selectedTabTextColor,
      unselectedTabTextColor: unselectedTabTextColor ?? this.unselectedTabTextColor,
      attachmentButtonColor: attachmentButtonColor ?? this.attachmentButtonColor,
      infoPageBackgroundColor: infoPageBackgroundColor ?? this.infoPageBackgroundColor,
      dividerColor: dividerColor ?? this.dividerColor,
    );
  }

  @override
  MessagingTheme lerp(ThemeExtension<MessagingTheme>? other, double t) {
    if (other is! MessagingTheme) {
      return this;
    }
    return MessagingTheme(
      chatListBackground: Color.lerp(chatListBackground, other.chatListBackground, t)!,
      chatRoomBackground: Color.lerp(chatRoomBackground, other.chatRoomBackground, t)!,
      myMessageBubbleColor: Color.lerp(myMessageBubbleColor, other.myMessageBubbleColor, t)!,
      myMessageTextColor: Color.lerp(myMessageTextColor, other.myMessageTextColor, t)!,
      otherMessageBubbleColor: Color.lerp(otherMessageBubbleColor, other.otherMessageBubbleColor, t)!,
      otherMessageTextColor: Color.lerp(otherMessageTextColor, other.otherMessageTextColor, t)!,
      inputBackgroundColor: Color.lerp(inputBackgroundColor, other.inputBackgroundColor, t)!,
      inputTextColor: Color.lerp(inputTextColor, other.inputTextColor, t)!,
      inputHintColor: Color.lerp(inputHintColor, other.inputHintColor, t)!,
      sendButtonColor: Color.lerp(sendButtonColor, other.sendButtonColor, t)!,
      sendButtonIconColor: Color.lerp(sendButtonIconColor, other.sendButtonIconColor, t)!,
      tabBarIndicatorColor: Color.lerp(tabBarIndicatorColor, other.tabBarIndicatorColor, t)!,
      tabBarBackgroundColor: Color.lerp(tabBarBackgroundColor, other.tabBarBackgroundColor, t)!,
      unselectedTabColor: Color.lerp(unselectedTabColor, other.unselectedTabColor, t)!,
      selectedTabColor: Color.lerp(selectedTabColor, other.selectedTabColor, t)!,
      selectedTabTextColor: Color.lerp(selectedTabTextColor, other.selectedTabTextColor, t)!,
      unselectedTabTextColor: Color.lerp(unselectedTabTextColor, other.unselectedTabTextColor, t)!,
      attachmentButtonColor: Color.lerp(attachmentButtonColor, other.attachmentButtonColor, t)!,
      infoPageBackgroundColor: Color.lerp(infoPageBackgroundColor, other.infoPageBackgroundColor, t)!,
      dividerColor: Color.lerp(dividerColor, other.dividerColor, t)!,
    );
  }
}