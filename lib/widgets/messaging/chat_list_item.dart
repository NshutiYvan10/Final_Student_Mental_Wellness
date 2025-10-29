import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
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
                const SnackBar(content: Text('Chat Pinned (TBD)')),
              );
            },
            backgroundColor: AppTheme.secondaryColor,
            foregroundColor: Colors.white,
            icon: Icons.push_pin_rounded,
            label: 'Pin',
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
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
                const SnackBar(content: Text('Chat Muted (TBD)')),
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
                const SnackBar(content: Text('Chat Archived (TBD)')),
              );
            },
            backgroundColor: AppTheme.errorColor,
            foregroundColor: Colors.white,
            icon: Icons.archive_rounded,
            label: 'Archive',
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
        ],
      ),
      // --- Chat List Item Content ---
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: GradientCard(
          padding: const EdgeInsets.all(12.0),
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
          child: Row(
            children: [
              // Avatar with Hero Animation
              Hero(
                tag: heroTag,
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  // TODO: Replace with actual image loading
                  child: Icon(
                    chatRoom.type == ChatType.group
                        ? Icons.group_rounded
                        : Icons.person_rounded,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Title & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chatRoom.name.isEmpty ? 'Private Chat' : chatRoom.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // TODO: Fetch and display actual last message preview
                    Text(
                      chatRoom.description ?? "Tap to open chat",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
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
                        Text(
                          _formatTimestamp(chatRoom.lastMessageAt!),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      const SizedBox(height: 4),
                      // Animated Unread Badge
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                              scale: animation, child: child);
                        },
                        child: unreadCount > 0
                            ? Container(
                          key: const ValueKey('unread_badge'),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        )
                            : const SizedBox(
                          key: ValueKey('no_unread'),
                          height: 20, // Placeholder to maintain alignment
                          width: 10, // Minimum width
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
}