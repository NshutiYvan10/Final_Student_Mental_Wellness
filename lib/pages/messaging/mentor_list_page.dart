import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'dart:ui';
import '../../models/user_profile.dart';
import '../../services/messaging_service.dart';
import '../../theme/messaging_theme.dart';
import '../../widgets/animations/staggered_list_item.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/messaging/user_profile_tile.dart';
import '../../widgets/messaging/empty_state_widget.dart';

class MentorListPage extends ConsumerWidget {
  const MentorListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final msgTheme = context.messagingTheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Available Mentors'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              color: msgTheme.inputBackgroundColor.withOpacity(0.7),
              decoration: BoxDecoration(
                  border: Border(
                      bottom:
                      BorderSide(color: Colors.white.withOpacity(0.1), width: 1))),
            ),
          ),
        ),
      ),
      body: GradientBackground(
        child: SafeArea(
          bottom: false,
          child: StreamBuilder<List<UserProfile>>(
            stream: MessagingService.getMentorsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.white));
              }
              if (snapshot.hasError) {
                return Center(
                    child: Text('Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white)));
              }
              final mentors = snapshot.data ?? [];

              if (mentors.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.volunteer_activism_outlined,
                  title: 'No Mentors Available',
                  message: 'Check back later for available mentors.',
                );
              }

              return AnimationLimiter(
                child: ListView.builder(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: mentors.length,
                  itemBuilder: (context, index) {
                    final mentor = mentors[index];
                    return StaggeredListItem(
                      index: index,
                      child: UserProfileTile(
                        user: mentor,
                        trailing: ElevatedButton.icon(
                          icon: const Icon(Icons.chat_bubble_outline_rounded,
                              size: 18),
                          label: const Text('Chat'),
                          onPressed: () => _sendChatRequest(context, mentor),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(80, 36),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _sendChatRequest(BuildContext context, UserProfile mentor) {
    showDialog(
      context: context,
      builder: (context) => _ChatRequestDialog(mentor: mentor),
    );
  }
}

// --- Re-usable Dialog for sending request ---
class _ChatRequestDialog extends StatefulWidget {
  final UserProfile mentor;
  const _ChatRequestDialog({required this.mentor});
  @override
  State<_ChatRequestDialog> createState() => _ChatRequestDialogState();
}

class _ChatRequestDialogState extends State<_ChatRequestDialog> {
  final _messageController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendRequest() async {
    setState(() => _loading = true);
    try {
      await MessagingService.sendChatRequest(
        targetUserId: widget.mentor.uid,
        message: _messageController.text.trim().isEmpty
            ? null
            : _messageController.text.trim(),
      );
      if (mounted) {
        Navigator.pop(context); // Close dialog on success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chat request sent'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Send Chat Request'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Send a request to chat with ${widget.mentor.displayName}.'),
          const SizedBox(height: 16),
          TextField(
            controller: _messageController,
            decoration: const InputDecoration(
              labelText: 'Message (Optional)',
              hintText: 'Add a brief message...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _sendRequest,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          child: _loading
              ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white))
              : const Text('Send Request'),
        ),
      ],
    );
  }
}