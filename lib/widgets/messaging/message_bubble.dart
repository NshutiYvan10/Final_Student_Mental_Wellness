import 'dart:ui';
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
    final textColor = isMe ? msgTheme.myMessageTextColor : msgTheme.otherMessageTextColor;
    final borderRadius = BorderRadius.only(
      topLeft: radius,
      topRight: radius,
      bottomLeft: isMe ? radius : (showTail ? zeroRadius : radius),
      bottomRight: isMe ? (showTail ? zeroRadius : radius) : radius,
    );

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
        bottom: showTail ? 12 : 6, // Slightly larger spacing for new sender
        left: isMe ? 48 : 4,
        right: isMe ? 4 : 48,
      ),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Display sender name for group chats (only for "other" users)
          if (!isMe && showTail && chatRoom.type == ChatType.group)
            Padding(
              padding: const EdgeInsets.only(bottom: 6.0, left: 8.0),
              child: Text(
                message.senderName.isNotEmpty ? message.senderName : 'User',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.64),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),

          GestureDetector(
            onLongPress: () {
              HapticFeedback.lightImpact(); // Haptic feedback on long press
              onLongPress();
            },
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isMe
                      ? const LinearGradient(colors: [AppTheme.primaryColor, AppTheme.secondaryColor], begin: Alignment.topLeft, end: Alignment.bottomRight)
                      : null,
                  color: isMe ? null : theme.colorScheme.surface.withOpacity(0.88),
                  borderRadius: borderRadius,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isMe ? 0.12 : 0.06),
                      blurRadius: isMe ? 8 : 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: isMe 
                        ? Colors.transparent 
                        : theme.colorScheme.onSurface.withOpacity(0.08),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    messageContent,
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (message.isEdited)
                          Text('edited · ', style: theme.textTheme.bodySmall?.copyWith(color: textColor.withOpacity(0.72), fontStyle: FontStyle.italic, fontSize: 11)),
                        Text(_formatTimestamp(message.createdAt), style: theme.textTheme.bodySmall?.copyWith(color: textColor.withOpacity(0.72), fontSize: 11)),
                        if (isMe) ...[
                          const SizedBox(width: 6),
                          Icon(Icons.done_all_rounded, size: 14, color: textColor.withOpacity(0.72)),
                        ]
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // placeholder for reactions or thread preview
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return DateFormat.Hm().format(timestamp); // e.g., 14:30
  }
}