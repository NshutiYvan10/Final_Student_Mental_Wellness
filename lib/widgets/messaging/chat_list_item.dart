import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../../models/chat_models.dart';
import '../../services/messaging_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/gradient_card.dart';
import 'package:student_mental_wellness/pages/messaging/chat_room_page.dart';
import 'package:student_mental_wellness/models/user_profile.dart';

class ChatListItem extends StatelessWidget {
  final ChatRoom chatRoom;
  final UserProfile? userProfile;

  const ChatListItem({
    super.key,
    required this.chatRoom,
    this.userProfile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final heroTag = 'avatar-${chatRoom.id}';

    return Slidable(
      key: ValueKey(chatRoom.id),
      // --- Start Slide Actions (Left) ---
      startActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              // TODO: Implement Pin Chat Logic
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Chat Pinned'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            backgroundColor: AppTheme.secondaryColor,
            foregroundColor: Colors.white,
            icon: Icons.push_pin_rounded,
            label: 'Pin',
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              bottomLeft: Radius.circular(18),
            ),
          ),
        ],
      ),
      // --- End Slide Actions (Right) ---
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              // TODO: Implement Mute Logic
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Chat Muted'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            backgroundColor: AppTheme.warningColor,
            foregroundColor: Colors.white,
            icon: Icons.volume_off_rounded,
            label: 'Mute',
          ),
          SlidableAction(
            onPressed: (context) {
              // TODO: Implement Archive Logic
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Chat Archived'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            backgroundColor: AppTheme.errorColor,
            foregroundColor: Colors.white,
            icon: Icons.archive_rounded,
            label: 'Archive',
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
          ),
        ],
      ),
      // --- Premium Chat List Item Content ---
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Colors.white.withOpacity(0.08),
                    Colors.white.withOpacity(0.05),
                  ]
                : [
                    Colors.white,
                    Colors.white.withOpacity(0.95),
                  ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.12)
                : theme.colorScheme.primary.withOpacity(0.08),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(isDark ? 0.12 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              MessagingService.markRoomRead(chatRoom.id);
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ChatRoomPage(
                    chatRoom: chatRoom,
                    heroTag: heroTag,
                  ),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              );
            },
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                children: [
                  // Premium Avatar with gradient border
                  Hero(
                    tag: heroTag,
                    child: chatRoom.type == ChatType.private
                        ? FutureBuilder<UserProfile?>(
                            future: MessagingService.getOtherUserInPrivateChat(chatRoom),
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data != null) {
                                return _buildUserAvatar(snapshot.data!, theme, isDark);
                              }
                              return _buildDefaultAvatar(theme, isDark, Icons.person_rounded);
                            },
                          )
                        : _buildDefaultAvatar(theme, isDark, Icons.group_rounded),
                  ),
                  const SizedBox(width: 14),
                  // Title & Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Row(
                          children: [
                            Expanded(
                              child: chatRoom.type == ChatType.private
                                  ? FutureBuilder<UserProfile?>(
                                      future: MessagingService.getOtherUserInPrivateChat(chatRoom),
                                      builder: (context, snapshot) {
                                        final displayName = snapshot.hasData && snapshot.data != null
                                            ? snapshot.data!.displayName
                                            : 'Private Chat';
                                        return Text(
                                          displayName,
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: theme.colorScheme.onSurface,
                                            fontSize: 16,
                                            letterSpacing: -0.2,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        );
                                      },
                                    )
                                  : Text(
                                      chatRoom.name.isEmpty ? 'Group Chat' : chatRoom.name,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: theme.colorScheme.onSurface,
                                        fontSize: 16,
                                        letterSpacing: -0.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          chatRoom.description ?? "Tap to open chat",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.55),
                            fontSize: 14,
                            height: 1.3,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Timestamp & Unread Count
                  StreamBuilder<int>(
                    stream: MessagingService.getUnreadCount(chatRoom.id),
                    builder: (context, snapshot) {
                      final unreadCount = snapshot.data ?? 0;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (chatRoom.lastMessageAt != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _formatTimestamp(chatRoom.lastMessageAt!),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          const SizedBox(height: 8),
                          // Premium Animated Unread Badge
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(
                                  scale: animation, child: child);
                            },
                            child: unreadCount > 0
                                ? Container(
                              key: const ValueKey('unread_badge'),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.accentColor,
                                    AppTheme.accentColor.withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.accentColor.withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Text(
                                unreadCount > 99 ? '99+' : unreadCount.toString(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            )
                                : const SizedBox(
                              key: ValueKey('no_unread'),
                              height: 22,
                              width: 10,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper function for formatting timestamp
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      return DateFormat.Hm().format(timestamp); // e.g., 14:30
    } else if (today.difference(messageDate).inDays == 1) {
      return 'Yesterday';
    } else if (today.difference(messageDate).inDays < 7) {
      return DateFormat('EEE').format(timestamp); // e.g., Mon
    } else {
      return DateFormat('dd/MM/yy').format(timestamp); // e.g., 27/10/25
    }
  }

  // Helper to build user avatar with gradient border
  Widget _buildUserAvatar(UserProfile user, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? theme.colorScheme.surface : Colors.white,
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: _buildAvatarContent(user, theme),
        ),
      ),
    );
  }

  // Helper to build avatar content (image or gradient)
  Widget _buildAvatarContent(UserProfile user, ThemeData theme) {
    print('🎨 Building avatar for ${user.displayName}, avatarUrl: "${user.avatarUrl}"');
    if (user.avatarUrl.isNotEmpty) {
      if (user.avatarUrl.startsWith('gradient_')) {
        print('✅ Using gradient avatar: ${user.avatarUrl}');
        return _buildGradientAvatar(user.avatarUrl, theme);
      } else if (user.avatarUrl.startsWith('assets/')) {
        print('✅ Using asset avatar: ${user.avatarUrl}');
        return Image.asset(
          user.avatarUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildDefaultAvatarIcon(theme, Icons.person_rounded),
        );
      } else {
        print('✅ Using network avatar: ${user.avatarUrl}');
        return Image.network(
          user.avatarUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildDefaultAvatarIcon(theme, Icons.person_rounded),
        );
      }
    }
    print('⚠️ Empty avatarUrl, using default');
    return _buildDefaultAvatarIcon(theme, Icons.person_rounded);
  }

  // Helper to build gradient avatar
  Widget _buildGradientAvatar(String avatarId, ThemeData theme) {
    final avatarData = {
      'gradient_1': {'icon': Icons.person_rounded, 'colors': [Color(0xFF6366F1), Color(0xFF8B5CF6)]},
      'gradient_2': {'icon': Icons.face_rounded, 'colors': [Color(0xFFEC4899), Color(0xFFF472B6)]},
      'gradient_3': {'icon': Icons.emoji_emotions_rounded, 'colors': [Color(0xFF10B981), Color(0xFF34D399)]},
      'gradient_4': {'icon': Icons.sentiment_very_satisfied_rounded, 'colors': [Color(0xFFF59E0B), Color(0xFFFBBF24)]},
      'gradient_5': {'icon': Icons.star_rounded, 'colors': [Color(0xFF3B82F6), Color(0xFF60A5FA)]},
      'gradient_6': {'icon': Icons.favorite_rounded, 'colors': [Color(0xFFEF4444), Color(0xFFF87171)]},
      'gradient_7': {'icon': Icons.psychology_rounded, 'colors': [Color(0xFF8B5CF6), Color(0xFFA78BFA)]},
      'gradient_8': {'icon': Icons.wb_sunny_rounded, 'colors': [Color(0xFFF59E0B), Color(0xFFEF4444)]},
      'gradient_9': {'icon': Icons.auto_awesome_rounded, 'colors': [Color(0xFF06B6D4), Color(0xFF3B82F6)]},
      'gradient_10': {'icon': Icons.spa_rounded, 'colors': [Color(0xFF10B981), Color(0xFF06B6D4)]},
      'gradient_11': {'icon': Icons.diamond_rounded, 'colors': [Color(0xFFEC4899), Color(0xFF8B5CF6)]},
      'gradient_12': {'icon': Icons.palette_rounded, 'colors': [Color(0xFFF59E0B), Color(0xFF10B981)]},
    };

    final data = avatarData[avatarId];
    if (data == null) {
      return _buildDefaultAvatarIcon(theme, Icons.person_rounded);
    }

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: data['colors'] as List<Color>,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        data['icon'] as IconData,
        size: 22,
        color: Colors.white,
      ),
    );
  }

  // Helper to build default avatar with icon
  Widget _buildDefaultAvatar(ThemeData theme, bool isDark, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? theme.colorScheme.surface : Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 24,
        ),
      ),
    );
  }

  // Helper to build default avatar icon content
  Widget _buildDefaultAvatarIcon(ThemeData theme, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.3),
            theme.colorScheme.secondary.withOpacity(0.2),
          ],
        ),
      ),
      child: Icon(
        icon,
        size: 22,
        color: theme.colorScheme.primary,
      ),
    );
  }
}