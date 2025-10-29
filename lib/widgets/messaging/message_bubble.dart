import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:intl/intl.dart';
import '../../models/chat_models.dart';
import '../../theme/app_theme.dart';
import '../../theme/messaging_theme.dart';

class MessageBubble extends StatelessWidget {
  final ChatRoom chatRoom; // Added chatRoom
  final ChatMessage message;
  final bool isMe;
  final bool showTail;
  final VoidCallback onLongPress; // Callback for reactions/menu

  const MessageBubble({
    super.key,
    required this.chatRoom, // Added to constructor
    required this.message,
    required this.isMe,
    required this.showTail,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final msgTheme = context.messagingTheme;
    final radius = Radius.circular(20);
    final zeroRadius = Radius.zero;

    // --- Premium Bubble Styling ---
    final decoration = BoxDecoration(
      // Gradient for "my" messages, solid/subtle gradient for "other"
      gradient: isMe
          ? const LinearGradient(
        colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      )
          : LinearGradient(
        colors: [
          msgTheme.otherMessageBubbleColor,
          msgTheme.otherMessageBubbleColor.withOpacity(0.95),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.only(
        topLeft: radius,
        topRight: radius,
        bottomLeft: isMe ? radius : (showTail ? zeroRadius : radius),
        bottomRight: isMe ? (showTail ? zeroRadius : radius) : radius,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isMe ? 0.1 : 0.06),
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
    );

    final textColor =
    isMe ? msgTheme.myMessageTextColor : msgTheme.otherMessageTextColor;

    Widget messageContent;

    // TODO: Build out image/file/attachment message types
    if (message.type == MessageType.image) {
      messageContent = Container(
        // Placeholder for an image
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  // Placeholder
                  height: 150,
                  width: 200,
                  color: Colors.black12,
                  child: const Center(
                      child: Icon(Icons.image_rounded,
                          size: 40, color: Colors.black26)),
                  // TODO: Replace with CachedNetworkImage(imageUrl: message.content)
                ),
              ),
              if (message.content.length <
                  50) // Show text if it's a short caption
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                  child: Text(message.content,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(color: textColor, height: 1.4)),
                ),
            ],
          ));
    } else {
      // Standard text message
      messageContent = Text(
        message.content,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: textColor,
          height: 1.4, // Improve line spacing
        ),
      );
    }

    return Container(
      margin: EdgeInsets.only(
        bottom: showTail ? 10 : 4, // More spacing for new sender
        left: isMe ? 40 : 0,
        right: isMe ? 0 : 40,
      ),
      child: Column(
        crossAxisAlignment:
        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Display sender name for group chats (only for "other" users)
          if (!isMe && showTail && chatRoom.type == ChatType.group)
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0, left: 12.0),
              child: Text(
                message.senderName.isNotEmpty ? message.senderName : 'User',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          // --- Interactive Bubble Container ---
          GestureDetector(
            onLongPress: () {
              HapticFeedback.lightImpact(); // Haptic feedback on long press
              onLongPress();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: decoration,
              child: Column(
                crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  messageContent,
                  const SizedBox(height: 6),
                  // --- Timestamp & Read Receipt ---
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (message.isEdited)
                        Text(
                          'edited · ',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: textColor.withOpacity(0.7),
                            fontStyle: FontStyle.italic,
                            fontSize: 11,
                          ),
                        ),
                      Text(
                        _formatTimestamp(message.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: textColor.withOpacity(0.7),
                          fontSize: 11,
                        ),
                      ),
                      // Read Receipt Logic
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        // TODO: Implement real read receipt logic
                        // (e.g., check if message.readBy contains all other members)
                        Icon(
                          Icons.done_all_rounded, // Double tick
                          size: 14,
                          // Use a brighter color (e.g., blue) when read by all
                          color: true // (message.isReadByAll)
                              ? AppTheme.accentColor
                              : textColor.withOpacity(0.7),
                        ),
                      ]
                    ],
                  ),
                ],
              ),
            ),
          ),
          // TODO: Implement Reactions display
          // if (message.reactions.isNotEmpty)
          //   _buildReactions(context, message.reactions),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return DateFormat.Hm().format(timestamp); // e.g., 14:30
  }
}