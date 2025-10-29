import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../models/chat_models.dart';
import '../../services/auth_service.dart';
import '../../services/messaging_service.dart';
import '../../theme/messaging_theme.dart';
import '../../widgets/animations/staggered_list_item.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/messaging/empty_state_widget.dart';
import 'chat_room_page.dart';
import '../../widgets/gradient_card.dart';
import '../../theme/app_theme.dart';
import 'package:intl/intl.dart';

class PublicGroupsPage extends ConsumerStatefulWidget {
  const PublicGroupsPage({super.key});

  @override
  ConsumerState<PublicGroupsPage> createState() => _PublicGroupsPageState();
}

class _PublicGroupsPageState extends ConsumerState<PublicGroupsPage> {
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  void _loadCurrentUser() async {
    final user = await AuthService.getCurrentUserProfile();
    if (mounted) {
      setState(() {
        _currentUserId = user?.uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final msgTheme = context.messagingTheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Discover Public Groups'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: GradientBackground(
        child: SafeArea(
          bottom: false,
          child: StreamBuilder<List<ChatRoom>>(
            stream: MessagingService.getPublicGroups(),
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
              final groups = snapshot.data ?? [];

              if (groups.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.explore_off_rounded,
                  title: 'No Public Groups',
                  message:
                  'There are currently no public groups available to join.',
                );
              }

              return AnimationLimiter(
                child: ListView.builder(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    final bool isMember = _currentUserId != null &&
                        group.memberIds.contains(_currentUserId);
                    return StaggeredListItem(
                      index: index,
                      child: _PublicGroupTile(
                        group: group,
                        isMember: isMember,
                        onTap: () => _viewOrJoinGroup(context, group, isMember),
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

  void _viewOrJoinGroup(
      BuildContext context, ChatRoom group, bool isMember) async {
    final heroTag = 'avatar-${group.id}'; // Create a hero tag

    if (isMember) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatRoomPage(
            chatRoom: group,
            heroTag: heroTag, // Pass the tag
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Join Group?'),
          content: Text('Do you want to join "${group.name}"?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            ElevatedButton(
              child: const Text('Join'),
              onPressed: () async {
                Navigator.of(ctx).pop(); // Close dialog
                try {
                  await MessagingService.joinGroupChat(group.id);
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatRoomPage(
                          chatRoom: group,
                          heroTag: heroTag, // Pass the tag
                        ),
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Joined group successfully!'),
                          backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Failed to join group: $e'),
                          backgroundColor: Colors.red),
                    );
                  }
                }
              },
            ),
          ],
        ),
      );
    }
  }
}

// A custom tile for the public groups page
class _PublicGroupTile extends StatelessWidget {
  final ChatRoom group;
  final bool isMember;
  final VoidCallback onTap;

  const _PublicGroupTile({
    required this.group,
    required this.isMember,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: GradientCard(
        onTap: onTap,
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: Icon(
                Icons.group_rounded,
                color: theme.colorScheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    group.description ??
                        '${group.memberIds.length} members',
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
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(80, 36),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                backgroundColor:
                isMember ? AppTheme.successColor : AppTheme.primaryColor,
              ),
              child: Text(isMember ? 'View' : 'Join'),
            ),
          ],
        ),
      ),
    );
  }
}