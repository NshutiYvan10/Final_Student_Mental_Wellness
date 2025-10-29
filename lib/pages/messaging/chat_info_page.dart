// import 'dart:ui';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
// import '../../models/chat_models.dart';
// import '../../models/user_profile.dart';
// import '../../services/auth_service.dart';
// import '../../services/messaging_service.dart';
// import '../../theme/app_theme.dart';
// import '../../theme/messaging_theme.dart';
// import '../../widgets/animations/staggered_list_item.dart';
// import '../../widgets/gradient_background.dart';
// import '../../widgets/gradient_card.dart';
// import '../../widgets/messaging/user_profile_tile.dart';
//
// class ChatInfoPage extends ConsumerStatefulWidget {
//   final ChatRoom chatRoom;
//   const ChatInfoPage({super.key, required this.chatRoom});
//
//   @override
//   ConsumerState<ChatInfoPage> createState() => _ChatInfoPageState();
// }
//
// class _ChatInfoPageState extends ConsumerState<ChatInfoPage> {
//   List<UserProfile> _members = [];
//   bool _isLoadingMembers = true;
//   UserProfile? _currentUser;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadCurrentUserAndMembers();
//   }
//
//   Future<void> _loadCurrentUserAndMembers() async {
//     final user = await AuthService.getCurrentUserProfile();
//     if (!mounted) return;
//     setState(() {
//       _currentUser = user;
//     });
//     _loadMembers();
//   }
//
//   Future<void> _loadMembers() async {
//     if (!mounted) return;
//     setState(() => _isLoadingMembers = true);
//     try {
//       List<UserProfile> fetchedMembers = [];
//       List<String> memberIds = List.from(widget.chatRoom.memberIds);
//
//       if (_currentUser != null && memberIds.contains(_currentUser!.uid)) {
//         fetchedMembers.add(_currentUser!);
//         memberIds.remove(_currentUser!.uid);
//       }
//
//       if (memberIds.isNotEmpty) {
//         // Fetch in chunks of 10 (Firestore 'in' limit)
//         for (var i = 0; i < memberIds.length; i += 10) {
//           final chunk = memberIds.sublist(
//               i, i + 10 > memberIds.length ? memberIds.length : i + 10);
//           if (chunk.isNotEmpty) {
//             final snapshot = await FirebaseFirestore.instance
//                 .collection('users')
//                 .where(FieldPath.documentId, whereIn: chunk)
//                 .get();
//             fetchedMembers.addAll(
//                 snapshot.docs.map((doc) => UserProfile.fromMap(doc.data())));
//           }
//         }
//       }
//
//       fetchedMembers = fetchedMembers.toSet().toList(); // Deduplicate
//       fetchedMembers.sort((a, b) => a.displayName.compareTo(b.displayName));
//
//       if (mounted) {
//         setState(() {
//           _members = fetchedMembers;
//           _isLoadingMembers = false;
//         });
//       }
//     } catch (e) {
//       print("Error loading members: $e");
//       if (mounted) setState(() => _isLoadingMembers = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//             content: Text('Error loading members: $e'),
//             backgroundColor: Colors.red),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final msgTheme = context.messagingTheme;
//     final bool isGroup = widget.chatRoom.type == ChatType.group;
//     final bool isCreator = widget.chatRoom.createdBy == _currentUser?.uid;
//
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       backgroundColor: Colors.transparent,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         foregroundColor: Colors.white,
//         title: Text(isGroup ? 'Group Info' : 'Chat Info',
//             style: const TextStyle(color: Colors.white)),
//         flexibleSpace: ClipRRect(
//           child: BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
//             child: Container(
//               color: msgTheme.inputBackgroundColor.withOpacity(0.7),
//               decoration: BoxDecoration(
//                   border: Border(
//                       bottom:
//                       BorderSide(color: Colors.white.withOpacity(0.1), width: 1))),
//             ),
//           ),
//         ),
//       ),
//       body: GradientBackground(
//         child: SafeArea(
//           child: ListView(
//             padding: const EdgeInsets.all(16.0),
//             children: [
//               // Header
//               _buildInfoHeader(context),
//               const SizedBox(height: 24),
//
//               // Members List
//               if (isGroup) _buildMembersSection(context, isCreator),
//
//               // Actions
//               const SizedBox(height: 24),
//               _buildActionsSection(context, isGroup),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInfoHeader(BuildContext context) {
//     final theme = Theme.of(context);
//     final isGroup = widget.chatRoom.type == ChatType.group;
//
//     return Center(
//       child: Column(
//         children: [
//           CircleAvatar(
//             radius: 45,
//             backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
//             child: Icon(
//               isGroup ? Icons.group_rounded : Icons.person_rounded,
//               color: theme.colorScheme.primary,
//               size: 45,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             widget.chatRoom.name.isEmpty && !isGroup
//                 ? 'Private Chat'
//                 : widget.chatRoom.name,
//             style: theme.textTheme.headlineSmall
//                 ?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
//             textAlign: TextAlign.center,
//           ),
//           if (widget.chatRoom.description != null &&
//               widget.chatRoom.description!.isNotEmpty) ...[
//             const SizedBox(height: 8),
//             Text(
//               widget.chatRoom.description!,
//               style: theme.textTheme.bodyLarge?.copyWith(
//                 color: Colors.white.withOpacity(0.7),
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMembersSection(BuildContext context, bool isCreator) {
//     final theme = Theme.of(context);
//
//     return GradientCard(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Members (${_isLoadingMembers ? '...' : _members.length})',
//                 style: theme.textTheme.titleMedium
//                     ?.copyWith(fontWeight: FontWeight.w600),
//               ),
//               if (isCreator)
//                 IconButton(
//                   icon: Icon(Icons.person_add_alt_1_rounded,
//                       color: theme.colorScheme.primary),
//                   onPressed: _addMembers,
//                   tooltip: 'Add Members',
//                 ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           _isLoadingMembers
//               ? const Center(
//               child: Padding(
//                   padding: EdgeInsets.all(16.0),
//                   child: CircularProgressIndicator()))
//               : _members.isEmpty
//               ? Padding(
//             padding: const EdgeInsets.symmetric(vertical: 16.0),
//             child: Text(
//               'No members found.',
//               style: TextStyle(
//                   color: theme.colorScheme.onSurface.withOpacity(0.6)),
//             ),
//           )
//               : AnimationLimiter(
//             child: ListView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: _members.length,
//               itemBuilder: (context, index) {
//                 final member = _members[index];
//                 return StaggeredListItem(
//                   index: index,
//                   child: UserProfileTile(
//                     user: member,
//                     trailing: member.uid == widget.chatRoom.createdBy
//                         ? Text('Admin',
//                         style: theme.textTheme.labelSmall
//                             ?.copyWith(
//                             color: theme.colorScheme.secondary))
//                         : null,
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _addMembers() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Add member functionality TBD')),
//     );
//   }
//
//   Widget _buildActionsSection(BuildContext context, bool isGroup) {
//     final theme = Theme.of(context);
//
//     return Column(
//       children: [
//         if (isGroup)
//           GradientCard(
//             padding: const EdgeInsets.all(4),
//             onTap: _confirmLeaveGroup,
//             child: ListTile(
//               leading:
//               Icon(Icons.exit_to_app_rounded, color: theme.colorScheme.error),
//               title: Text('Leave Group',
//                   style: TextStyle(color: theme.colorScheme.error)),
//               tileColor: theme.colorScheme.error.withOpacity(0.05),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12)),
//             ),
//           ),
//       ],
//     );
//   }
//
//   void _confirmLeaveGroup() {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text('Leave Group?'),
//         content: const Text(
//             'Are you sure you want to leave this group? You will lose access to the chat history.'),
//         actions: [
//           TextButton(
//             child: const Text('Cancel'),
//             onPressed: () => Navigator.of(ctx).pop(),
//           ),
//           TextButton(
//             child: Text('Leave',
//                 style: TextStyle(color: Theme.of(context).colorScheme.error)),
//             onPressed: () async {
//               Navigator.of(ctx).pop(); // Close dialog
//               try {
//                 await MessagingService.leaveGroupChat(widget.chatRoom.id);
//                 if (mounted) {
//                   int count = 0;
//                   Navigator.of(context).popUntil((_) => count++ >= 2);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                         content: Text('You have left the group'),
//                         backgroundColor: Colors.green),
//                   );
//                 }
//               } catch (e) {
//                 if (mounted) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                         content: Text('Failed to leave group: $e'),
//                         backgroundColor: Colors.red),
//                   );
//                 }
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }














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
import '../../widgets/gradient_background.dart';
import '../../widgets/gradient_card.dart';
import '../../widgets/messaging/user_profile_tile.dart';

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

      // Add current user first if they are a member
      if (_currentUser != null && memberIds.contains(_currentUser!.uid)) {
        fetchedMembers.add(_currentUser!);
        memberIds.remove(_currentUser!.uid);
      }

      // Fetch remaining members in chunks
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

      fetchedMembers = fetchedMembers.toSet().toList(); // Deduplicate
      // Sort: Current user first, then admin, then alphabetically
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error loading members: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final msgTheme = context.messagingTheme;
    final bool isGroup = widget.chatRoom.type == ChatType.group;
    final bool isCreator = widget.chatRoom.createdBy == _currentUser?.uid;

    // Determine AppBar foreground color
    final appBarForegroundColor = theme.brightness == Brightness.dark
        ? Colors.white
        : theme.colorScheme.onSurface;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent, // Use GradientBackground
      appBar: AppBar(
        iconTheme: IconThemeData(color: appBarForegroundColor), // Adapt icon color
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: appBarForegroundColor, // Adapt title color
        title: Text(isGroup ? 'Group Info' : 'Chat Info',
            style: TextStyle(color: appBarForegroundColor)),
        flexibleSpace: ClipRRect( // Blurred background
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            // *** FIX: Moved color inside BoxDecoration ***
            child: Container(
              decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark // Adapt color
                      ? msgTheme.inputBackgroundColor.withOpacity(0.75)
                      : AppTheme.softBg.withOpacity(0.85),
                  border: Border(
                      bottom:
                      BorderSide(
                          color: theme.brightness == Brightness.dark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.08),
                          width: 1))),
            ),
          ),
        ),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Header
              _buildInfoHeader(context),
              const SizedBox(height: 24),

              // Members List (inside GradientCard)
              if (isGroup) _buildMembersSection(context, isCreator),

              // Actions (inside GradientCard)
              const SizedBox(height: 24),
              _buildActionsSection(context, isGroup),

              const SizedBox(height: 20), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoHeader(BuildContext context) {
    final theme = Theme.of(context);
    final isGroup = widget.chatRoom.type == ChatType.group;
    final heroTag = 'avatar-${widget.chatRoom.id}'; // Use consistent tag

    return Center(
      child: Column(
        children: [
          // Use Hero animation if coming from chat room
          Hero(
            tag: heroTag,
            child: CircleAvatar(
              radius: 45,
              backgroundColor: theme.colorScheme.surface.withOpacity(0.2), // Light background
              child: Icon(
                isGroup ? Icons.group_rounded : Icons.person_rounded,
                color: Colors.white.withOpacity(0.8), // White icon
                size: 45,
              ),
              // TODO: Add image support with background image
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.chatRoom.name.isEmpty && !isGroup
                ? 'Private Chat'
                : widget.chatRoom.name,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          if (widget.chatRoom.description != null &&
              widget.chatRoom.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              widget.chatRoom.description!,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMembersSection(BuildContext context, bool isCreator) {
    final theme = Theme.of(context);

    return GradientCard( // Wrap members list in a card
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Members (${_isLoadingMembers ? '...' : _members.length})',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (isCreator)
                IconButton(
                  icon: Icon(Icons.person_add_alt_1_rounded,
                      color: theme.colorScheme.primary),
                  onPressed: _addMembers,
                  tooltip: 'Add Members',
                ),
            ],
          ),
          const SizedBox(height: 12), // Increased spacing
          Divider(height: 1, color: theme.colorScheme.outline.withOpacity(0.3)), // Add divider
          const SizedBox(height: 12),
          _isLoadingMembers
              ? const Center(
              child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: CircularProgressIndicator()))
              : _members.isEmpty
              ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'No members found.',
              style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.6)),
            ),
          )
              : AnimationLimiter(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _members.length,
              itemBuilder: (context, index) {
                final member = _members[index];
                // Use UserProfileTile without the card background (already in GradientCard)
                return StaggeredListItem(
                  index: index,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0), // Spacing between members
                    child: UserProfileTile(
                      user: member,
                      // Remove internal card styling from UserProfileTile if needed
                      // or create a version without the outer card
                      trailing: member.uid == widget.chatRoom.createdBy
                          ? Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text('Admin',
                            style: theme.textTheme.labelSmall
                                ?.copyWith(
                                color: theme.colorScheme.secondary, fontWeight: FontWeight.bold)),
                      )
                          : null,
                      onTap: () {
                        // TODO: View profile?
                      },
                    ),
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add member functionality TBD'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        margin: EdgeInsets.all(12),
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context, bool isGroup) {
    final theme = Theme.of(context);

    // Only show actions if they are relevant (e.g., leaving a group)
    if (!isGroup) return const SizedBox.shrink(); // No actions for private chat info yet

    return GradientCard( // Wrap actions in card
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Column(
        children: [
          if (isGroup)
            ListTile(
              leading: Icon(Icons.exit_to_app_rounded, color: theme.colorScheme.error),
              title: Text('Leave Group', style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.w600)),
              onTap: _confirmLeaveGroup,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          // TODO: Add "Delete Group" action for creator
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
          ElevatedButton( // Use ElevatedButton for destructive action confirmation
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Leave', style: TextStyle(color: Colors.white)),
            onPressed: () async {
              Navigator.of(ctx).pop(); // Close dialog
              try {
                // Show loading indicator?
                await MessagingService.leaveGroupChat(widget.chatRoom.id);
                if (mounted) {
                  // Pop twice to go back past the chat room screen
                  int count = 0;
                  Navigator.of(context).popUntil((_) => count++ >= 2);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('You have left the group'),
                      backgroundColor: Colors.green, // Use theme color?
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      margin: EdgeInsets.all(12),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      margin: EdgeInsets.all(12),
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