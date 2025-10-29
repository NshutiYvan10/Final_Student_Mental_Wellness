import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:student_mental_wellness/widgets/gradient_card.dart';
import '../../models/chat_models.dart';
import '../../services/messaging_service.dart';
import '../../theme/app_theme.dart';

class RequestTile extends StatelessWidget {
  final ChatRequest request;

  const RequestTile({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: GradientCard(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 20, // Slightly smaller avatar for requests
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  // TODO: Use request.requesterAvatar
                  child: Icon(
                    Icons.person_rounded,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // Name & Request time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.requesterName.isEmpty
                            ? 'Someone'
                            : request.requesterName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Sent request ${_formatTimestamp(request.createdAt)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Optional Message
            if (request.message != null && request.message!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                width: double.infinity,
                decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.5))),
                child: Text(
                  request.message!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            const SizedBox(height: 12),
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _respond(context, ChatRequestStatus.rejected),
                  style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8)),
                  child: const Text('Decline'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _respond(context, ChatRequestStatus.approved),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successColor, // Use success color
                    foregroundColor: Colors.white,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Accept'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _respond(BuildContext context, ChatRequestStatus status) async {
    try {
      await MessagingService.respondToChatRequest(
        requestId: request.id,
        status: status,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Request ${status == ChatRequestStatus.approved ? 'accepted' : 'declined'}'),
          backgroundColor:
          status == ChatRequestStatus.approved ? Colors.green : Colors.grey,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to respond: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Use the same timestamp formatting as ChatListItem
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      return DateFormat.Hm().format(timestamp); // e.g., 14:30
    } else if (today.difference(messageDate).inDays == 1) {
      return 'yesterday';
    } else if (today.difference(messageDate).inDays < 7) {
      return DateFormat('EEE').format(timestamp); // e.g., Mon
    } else {
      return DateFormat('dd/MM/yy').format(timestamp); // e.g., 27/10/25
    }
  }
}