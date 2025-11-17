import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../models/chat_models.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import '../../services/messaging_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/messaging_theme.dart';
import '../../widgets/animations/staggered_list_item.dart';
import 'user_search_page.dart';

class ChatInfoPage extends ConsumerStatefulWidget {
  final ChatRoom chatRoom;
  const ChatInfoPage({super.key, required this.chatRoom});

  @override
  ConsumerState<ChatInfoPage> createState() => _ChatInfoPageState();
}

class _ChatInfoPageState extends ConsumerState<ChatInfoPage> {
  List<UserProfile> _members = [];
  bool _isLoadingMembers = true;
  UserProfile? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserAndMembers();
  }

  Future<void> _loadCurrentUserAndMembers() async {
    final user = await AuthService.getCurrentUserProfile();
    if (!mounted) return;
    setState(() {
      _currentUser = user;
    });
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    if (!mounted) return;
    setState(() => _isLoadingMembers = true);
    try {
      List<UserProfile> fetchedMembers = [];
      List<String> memberIds = List.from(widget.chatRoom.memberIds);

      if (_currentUser != null && memberIds.contains(_currentUser!.uid)) {
        fetchedMembers.add(_currentUser!);
        memberIds.remove(_currentUser!.uid);
      }

      if (memberIds.isNotEmpty) {
        const chunkSize = 10;
        for (var i = 0; i < memberIds.length; i += chunkSize) {
          final chunk = memberIds.sublist(
              i, i + chunkSize > memberIds.length ? memberIds.length : i + chunkSize);
          if (chunk.isNotEmpty) {
            final snapshot = await FirebaseFirestore.instance
                .collection('users')
                .where(FieldPath.documentId, whereIn: chunk)
                .get();
            fetchedMembers.addAll(
                snapshot.docs.map((doc) => UserProfile.fromMap(doc.data())));
          }
        }
      }

      fetchedMembers = fetchedMembers.toSet().toList();
      fetchedMembers.sort((a, b) {
        if (a.uid == _currentUser?.uid) return -1;
        if (b.uid == _currentUser?.uid) return 1;
        if (a.uid == widget.chatRoom.createdBy) return -1;
        if (b.uid == widget.chatRoom.createdBy) return 1;
        return a.displayName.compareTo(b.displayName);
      });

      if (mounted) {
        setState(() {
          _members = fetchedMembers;
          _isLoadingMembers = false;
        });
      }
    } catch (e) {
      print("Error loading members: $e");
      if (mounted) setState(() => _isLoadingMembers = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading members: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final msgTheme = context.messagingTheme;
    final isDark = theme.brightness == Brightness.dark;
    final bool isGroup = widget.chatRoom.type == ChatType.group;
    final bool isCreator = widget.chatRoom.createdBy == _currentUser?.uid;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: msgTheme.chatRoomBackground is LinearGradient
              ? msgTheme.chatRoomBackground as LinearGradient
              : LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.1),
                    AppTheme.secondaryColor.withOpacity(0.1),
                  ],
                ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Premium Glass AppBar
              PreferredSize(
                preferredSize: const Size.fromHeight(70),
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      height: 70,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.black.withOpacity(0.3)
                            : Colors.white.withOpacity(0.3),
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white.withOpacity(0.08),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        child: Row(
                          children: [
                            // Back Button
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: theme.colorScheme.onSurface,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Title
                            Expanded(
                              child: Text(
                                isGroup ? 'Group Info' : 'Chat Info',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Scrollable Content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // Header with Avatar and Title
                    _buildInfoHeader(context, isDark),
                    const SizedBox(height: 24),

                    // Members Section for Groups
                    if (isGroup) _buildMembersSection(context, isDark, isCreator),

                    // Actions Section
                    if (isGroup) ...[
                      const SizedBox(height: 16),
                      _buildActionsSection(context, isDark, isCreator),
                    ],

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoHeader(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final isGroup = widget.chatRoom.type == ChatType.group;
    final heroTag = 'avatar-${widget.chatRoom.id}';

    return Center(
      child: Column(
        children: [
          // Avatar with Gradient Ring
          Hero(
            tag: heroTag,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.3),
                    AppTheme.secondaryColor.withOpacity(0.3),
                  ],
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? Colors.black.withOpacity(0.4)
                      : Colors.white.withOpacity(0.4),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: theme.colorScheme.surface.withOpacity(0.3),
                  child: Icon(
                    isGroup ? Icons.group_rounded : Icons.person_rounded,
                    size: 50,
                    color: isDark
                        ? Colors.white.withOpacity(0.8)
                        : Colors.black54,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Chat/Group Name
          Text(
            widget.chatRoom.name.isEmpty && !isGroup
                ? 'Private Chat'
                : widget.chatRoom.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          
          // Description
          if (widget.chatRoom.description != null &&
              widget.chatRoom.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              widget.chatRoom.description!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? Colors.white.withOpacity(0.7)
                    : Colors.black.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
          
          // Member Count
          if (isGroup) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.people_rounded,
                    size: 16,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${widget.chatRoom.memberIds.length} members',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMembersSection(BuildContext context, bool isDark, bool isCreator) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surface.withOpacity(0.5)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withOpacity(0.2),
                          AppTheme.secondaryColor.withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.people_rounded,
                      size: 20,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Members',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_members.length}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              if (isCreator)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.secondaryColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _addMembers,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          Icons.person_add_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            height: 1,
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          
          // Members List
          _isLoadingMembers
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                )
              : _members.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Center(
                        child: Text(
                          'No members found',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                    )
                  : AnimationLimiter(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _members.length,
                        itemBuilder: (context, index) {
                          final member = _members[index];
                          final isAdmin = member.uid == widget.chatRoom.createdBy;
                          final isCurrentUser = member.uid == _currentUser?.uid;
                          
                          return StaggeredListItem(
                            index: index,
                            child: _MemberTile(
                              member: member,
                              isAdmin: isAdmin,
                              isCurrentUser: isCurrentUser,
                              canRemove: isCreator && !isAdmin && !isCurrentUser,
                              onRemove: () => _confirmRemoveMember(member),
                            ),
                          );
                        },
                      ),
                    ),
        ],
      ),
    );
  }

  void _addMembers() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserSearchPage(),
      ),
    );
  }

  void _confirmRemoveMember(UserProfile member) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Member?'),
        content: Text('Are you sure you want to remove ${member.displayName} from this group?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                // Note: You'll need to implement this method in MessagingService
                // await MessagingService.removeMemberFromGroup(widget.chatRoom.id, member.uid);
                _loadMembers(); // Reload members list
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${member.displayName} removed from group'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to remove member: $e'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context, bool isDark, bool isCreator) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surface.withOpacity(0.5)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Leave Group
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _confirmLeaveGroup,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.exit_to_app_rounded,
                        color: Colors.red,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Leave Group',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'You won\'t receive messages anymore',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.red.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLeaveGroup() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Leave Group?'),
        content: const Text(
            'Are you sure you want to leave this group? You won\'t be able to send or receive messages unless added back.'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Leave', style: TextStyle(color: Colors.white)),
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await MessagingService.leaveGroupChat(widget.chatRoom.id);
                if (mounted) {
                  int count = 0;
                  Navigator.of(context).popUntil((_) => count++ >= 2);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('You have left the group'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to leave group: $e'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
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

// Custom Member Tile Widget
class _MemberTile extends StatelessWidget {
  final UserProfile member;
  final bool isAdmin;
  final bool isCurrentUser;
  final bool canRemove;
  final VoidCallback onRemove;

  const _MemberTile({
    required this.member,
    required this.isAdmin,
    required this.isCurrentUser,
    required this.canRemove,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          // Avatar with Gradient Ring
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.3),
                  AppTheme.secondaryColor.withOpacity(0.3),
                ],
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? Colors.black.withOpacity(0.4)
                    : Colors.white.withOpacity(0.4),
              ),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: theme.colorScheme.surface.withOpacity(0.3),
                child: Icon(
                  Icons.person_rounded,
                  color: isDark ? Colors.white70 : Colors.black54,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        member.displayName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'You',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  member.school,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Admin Badge or Remove Button
          if (isAdmin)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.shade400,
                    Colors.orange.shade400,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Admin',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            )
          else if (canRemove)
            IconButton(
              icon: Icon(
                Icons.remove_circle_outline_rounded,
                color: Colors.red.withOpacity(0.7),
                size: 22,
              ),
              onPressed: onRemove,
              tooltip: 'Remove member',
            ),
        ],
      ),
    );
  }
}
