// // import 'package:flutter/material.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import '../../models/chat_models.dart';
// // import '../../models/user_profile.dart';
// // import '../../services/messaging_service.dart';
// // import '../../services/auth_service.dart';
// // import '../../widgets/gradient_background.dart';
// // import 'chat_room_page.dart';
// // import 'create_group_page.dart';
// // import 'user_search_page.dart';
// // import 'public_groups_page.dart';
// //
// // // Public helper used by tests to apply the same filtering + ordering logic
// // // used in the Chats tab. Extracted so it can be unit tested.
// // List<ChatRoom> filterAndSortChatRooms(List<ChatRoom> rooms, String filter) {
// //   final q = filter.trim().toLowerCase();
// //
// //   final filtered = rooms.where((r) {
// //     if (q.isEmpty) return true;
// //     final name = (r.name.isNotEmpty ? r.name : 'Private Chat').toLowerCase();
// //     final desc = (r.description ?? '').toLowerCase();
// //     return name.contains(q) || desc.contains(q);
// //   }).toList();
// //
// //   final pinned = filtered.where((r) => (r.settings['pinned'] as bool?) == true).toList();
// //   final others = filtered.where((r) => (r.settings['pinned'] as bool?) != true).toList();
// //
// //   return [...pinned, ...others];
// // }
// //
// // class MessagingHubPage extends ConsumerStatefulWidget {
// //   const MessagingHubPage({super.key});
// //
// //   @override
// //   ConsumerState<MessagingHubPage> createState() => _MessagingHubPageState();
// // }
// //
// // class _MessagingHubPageState extends ConsumerState<MessagingHubPage>
// //     with TickerProviderStateMixin {
// //   late TabController _tabController;
// //   UserProfile? _currentUser;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _tabController = TabController(length: 3, vsync: this);
// //     _loadCurrentUser();
// //   }
// //
// //   @override
// //   void dispose() {
// //     _tabController.dispose();
// //     super.dispose();
// //   }
// //
// //   Future<void> _loadCurrentUser() async {
// //     final user = await AuthService.getCurrentUserProfile();
// //     if (mounted) {
// //       setState(() {
// //         _currentUser = user;
// //       });
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final theme = Theme.of(context);
// //
// //     return Scaffold(
// //       floatingActionButton: FloatingActionButton.extended(
// //         onPressed: () {
// //           // Start a new chat/search people
// //           Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UserSearchPage()));
// //         },
// //         label: const Text('New'),
// //         icon: const Icon(Icons.add_rounded),
// //       ),
// //       body: GradientBackground(
// //         colors: [
// //           theme.colorScheme.primary.withValues(alpha: 0.1),
// //           theme.colorScheme.secondary.withValues(alpha: 0.05),
// //           theme.scaffoldBackgroundColor,
// //         ],
// //         child: SafeArea(
// //           child: Column(
// //             children: [
// //               // Header (modern)
// //               Padding(
// //                 padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
// //                 child: Row(
// //                   children: [
// //                     Container(
// //                       padding: const EdgeInsets.all(6),
// //                       decoration: BoxDecoration(
// //                         gradient: LinearGradient(colors: [theme.colorScheme.primary.withOpacity(0.12), theme.colorScheme.primary.withOpacity(0.04)]),
// //                         borderRadius: BorderRadius.circular(12),
// //                       ),
// //                       child: Icon(
// //                         Icons.chat_bubble_rounded,
// //                         color: theme.colorScheme.primary,
// //                         size: 30,
// //                       ),
// //                     ),
// //                     const SizedBox(width: 12),
// //                     Expanded(
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Text('Messages', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
// //                           const SizedBox(height: 2),
// //                           Text('All conversations in one place', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7))),
// //                         ],
// //                       ),
// //                     ),
// //                     if (_currentUser?.role == UserRole.mentor)
// //                       Tooltip(
// //                         message: 'Create group',
// //                         child: IconButton(
// //                           onPressed: () => _showCreateGroupDialog(),
// //                           icon: Icon(Icons.group_add_rounded, color: theme.colorScheme.primary),
// //                         ),
// //                       ),
// //                     IconButton(
// //                       onPressed: () => _showSearchDialog(),
// //                       icon: Icon(Icons.search_rounded, color: theme.colorScheme.onSurface.withOpacity(0.9)),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //
// //               // Tab Bar (compact with icons)
// //               Container(
// //                 margin: const EdgeInsets.symmetric(horizontal: 16),
// //                 decoration: BoxDecoration(
// //                   color: theme.colorScheme.surface.withOpacity(0.9),
// //                   borderRadius: BorderRadius.circular(14),
// //                 ),
// //                 child: TabBar(
// //                   controller: _tabController,
// //                   indicator: BoxDecoration(
// //                     color: theme.colorScheme.primary,
// //                     borderRadius: BorderRadius.circular(12),
// //                     boxShadow: [BoxShadow(color: theme.colorScheme.primary.withOpacity(0.24), blurRadius: 8, offset: const Offset(0, 2))],
// //                   ),
// //                   labelColor: Colors.white,
// //                   unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.7),
// //                   tabs: const [
// //                     Tab(icon: Icon(Icons.chat_rounded), text: 'Chats'),
// //                     Tab(icon: Icon(Icons.volunteer_activism_rounded), text: 'Mentors'),
// //                     Tab(icon: Icon(Icons.inbox_rounded), text: 'Requests'),
// //                   ],
// //                 ),
// //               ),
// //
// //               const SizedBox(height: 16),
// //
// //               // Tab Content
// //               Expanded(
// //                 child: TabBarView(
// //                   controller: _tabController,
// //                   children: [
// //                     Column(
// //                       children: [
// //                         Padding(
// //                           padding: const EdgeInsets.symmetric(horizontal: 16),
// //                           child: Row(
// //                             children: [
// //                               TextButton.icon(
// //                                 onPressed: () {
// //                                   Navigator.of(context).push(
// //                                     MaterialPageRoute(
// //                                       builder: (_) => const PublicGroupsPage(),
// //                                     ),
// //                                   );
// //                                 },
// //                                 icon: const Icon(Icons.explore_rounded),
// //                                 label: const Text('Discover Groups'),
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //                         Expanded(child: _ChatsTab()),
// //                       ],
// //                     ),
// //                     _MentorsTab(),
// //                     _RequestsTab(),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   void _showCreateGroupDialog() {
// //     showDialog(
// //       context: context,
// //       builder: (context) => const CreateGroupDialog(),
// //     );
// //   }
// //
// //   void _showSearchDialog() {
// //     // Open the full-page user search instead of a dialog for a modern UX
// //     Navigator.of(context).push(MaterialPageRoute(builder: (context) => const UserSearchPage()));
// //   }
// // }
// //
// // class _ChatsTab extends StatefulWidget {
// //   const _ChatsTab({Key? key}) : super(key: key);
// //
// //   @override
// //   State<_ChatsTab> createState() => _ChatsTabState();
// // }
// //
// // class _ChatsTabState extends State<_ChatsTab> {
// //   final TextEditingController _filterController = TextEditingController();
// //   String _filter = '';
// //
// //   @override
// //   void dispose() {
// //     _filterController.dispose();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final theme = Theme.of(context);
// //     return Column(
// //       children: [
// //         Padding(
// //           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //           child: Material(
// //             elevation: 2,
// //             borderRadius: BorderRadius.circular(12),
// //             child: TextField(
// //               controller: _filterController,
// //               decoration: InputDecoration(
// //                 hintText: 'Search conversations',
// //                 prefixIcon: const Icon(Icons.search_rounded),
// //                 suffixIcon: _filterController.text.isNotEmpty
// //                     ? IconButton(
// //                         onPressed: () {
// //                           _filterController.clear();
// //                           setState(() => _filter = '');
// //                         },
// //                         icon: const Icon(Icons.clear_rounded),
// //                       )
// //                     : null,
// //                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
// //                 isDense: true,
// //                 filled: true,
// //                 fillColor: Theme.of(context).colorScheme.surface,
// //               ),
// //               onChanged: (v) => setState(() => _filter = v.trim().toLowerCase()),
// //             ),
// //           ),
// //         ),
// //
// //         Expanded(
// //           child: StreamBuilder<List<ChatRoom>>(
// //             stream: MessagingService.getUserChatRooms(),
// //             builder: (context, snapshot) {
// //               if (snapshot.connectionState == ConnectionState.waiting) {
// //                 return const Center(child: CircularProgressIndicator());
// //               }
// //
// //               if (snapshot.hasError) {
// //                 return Center(child: Text('Error: ${snapshot.error}'));
// //               }
// //
// //               final chatRooms = (snapshot.data ?? [])
// //                   .where((r) {
// //                     if (_filter.isEmpty) return true;
// //                     final name = (r.name.isNotEmpty ? r.name : 'Private Chat').toLowerCase();
// //                     final desc = (r.description ?? '').toLowerCase();
// //                     return name.contains(_filter) || desc.contains(_filter);
// //                   })
// //                   .toList();
// //
// //               if (chatRooms.isEmpty) {
// //                 return Center(
// //                   child: Column(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       Icon(Icons.chat_bubble_outline_rounded, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
// //                       const SizedBox(height: 16),
// //                       Text('No conversations found', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
// //                     ],
// //                   ),
// //                 );
// //               }
// //
// //               // Pinned first
// //               final pinned = chatRooms.where((r) => (r.settings['pinned'] as bool?) == true).toList();
// //               final others = chatRooms.where((r) => (r.settings['pinned'] as bool?) != true).toList();
// //
// //               return ListView(
// //                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// //                 children: [
// //                   if (pinned.isNotEmpty) ...[
// //                     Padding(
// //                       padding: const EdgeInsets.only(bottom: 8.0, top: 6),
// //                       child: Text('Pinned', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
// //                     ),
// //                     ...pinned.map((r) => _wrapWithActions(r)).toList(),
// //                     const SizedBox(height: 8),
// //                   ],
// //                   ...others.map((r) => _wrapWithActions(r)).toList(),
// //                 ],
// //               );
// //             },
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// //
// //   Widget _wrapWithActions(ChatRoom room) {
// //     return Dismissible(
// //       key: ValueKey(room.id),
// //       direction: DismissDirection.endToStart,
// //       confirmDismiss: (direction) async {
// //         final action = await showModalBottomSheet<String>(
// //           context: context,
// //           builder: (context) {
// //             return SafeArea(
// //               child: Column(
// //                 mainAxisSize: MainAxisSize.min,
// //                 children: [
// //                   ListTile(
// //                     leading: const Icon(Icons.volume_off_rounded),
// //                     title: const Text('Mute conversation'),
// //                     onTap: () => Navigator.pop(context, 'mute'),
// //                   ),
// //                   ListTile(
// //                     leading: const Icon(Icons.push_pin_outlined),
// //                     title: const Text('Pin/unpin'),
// //                     onTap: () => Navigator.pop(context, 'pin'),
// //                   ),
// //                   ListTile(
// //                     leading: const Icon(Icons.archive_outlined),
// //                     title: const Text('Archive'),
// //                     onTap: () => Navigator.pop(context, 'archive'),
// //                   ),
// //                   ListTile(
// //                     leading: const Icon(Icons.close),
// //                     title: const Text('Cancel'),
// //                     onTap: () => Navigator.pop(context, null),
// //                   ),
// //                 ],
// //               ),
// //             );
// //           },
// //         );
// //
// //         if (action == null) return false;
// //
// //         try {
// //           switch (action) {
// //             case 'mute':
// //               final currentlyMuted = (room.settings['muted'] as bool?) == true;
// //               await MessagingService.updateChatRoomSettings(room.id, {'muted': !currentlyMuted});
// //               if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${!currentlyMuted ? 'Muted' : 'Unmuted'} ${room.name.isNotEmpty ? room.name : 'conversation'}')));
// //               break;
// //             case 'pin':
// //               final currentlyPinned = (room.settings['pinned'] as bool?) == true;
// //               await MessagingService.updateChatRoomSettings(room.id, {'pinned': !currentlyPinned});
// //               if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${!currentlyPinned ? 'Pinned' : 'Unpinned'} ${room.name.isNotEmpty ? room.name : 'conversation'}')));
// //               break;
// //             case 'archive':
// //               await MessagingService.updateChatRoomSettings(room.id, {'archived': true});
// //               if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Archived ${room.name.isNotEmpty ? room.name : 'conversation'}')));
// //               break;
// //           }
// //         } catch (e) {
// //           if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Action failed: $e')));
// //         }
// //
// //         return false;
// //       },
// //       background: Container(
// //         padding: const EdgeInsets.only(right: 20),
// //         alignment: Alignment.centerRight,
// //         color: Theme.of(context).colorScheme.primary,
// //         child: const Icon(Icons.more_horiz, color: Colors.white),
// //       ),
// //       child: _ChatRoomTile(chatRoom: room),
// //     );
// //   }
// // }
// //
// // class _MentorsTab extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     // Use a stream for live updates and present mentors as modern cards with actions
// //     return StreamBuilder<List<UserProfile>>(
// //       stream: MessagingService.getMentorsStream(),
// //       builder: (context, snapshot) {
// //         if (snapshot.connectionState == ConnectionState.waiting) {
// //           return const Center(child: CircularProgressIndicator());
// //         }
// //
// //         if (snapshot.hasError) {
// //           return Center(child: Text('Error: ${snapshot.error}'));
// //         }
// //
// //         final mentors = snapshot.data ?? [];
// //
// //         if (mentors.isEmpty) {
// //           return Center(
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 Icon(Icons.volunteer_activism_rounded, size: 64, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.28)),
// //                 const SizedBox(height: 16),
// //                 Text('No mentors available', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
// //               ],
// //             ),
// //           );
// //         }
// //
// //         return ListView.separated(
// //           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// //           itemCount: mentors.length,
// //           separatorBuilder: (_, __) => const SizedBox(height: 8),
// //           itemBuilder: (context, index) {
// //             final mentor = mentors[index];
// //             return Card(
// //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //               child: ListTile(
// //                 leading: CircleAvatar(
// //                   radius: 26,
// //                   backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.06),
// //                   child: mentor.avatarUrl.isNotEmpty ? ClipOval(child: Image.network(mentor.avatarUrl, width: 44, height: 44, fit: BoxFit.cover)) : Icon(mentor.role.icon, color: Theme.of(context).colorScheme.primary),
// //                 ),
// //                 title: Text(mentor.displayName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
// //                 subtitle: Text(mentor.school),
// //                 trailing: Row(
// //                   mainAxisSize: MainAxisSize.min,
// //                   children: [
// //                     OutlinedButton(
// //                       onPressed: () async {
// //                         // Send a private chat request to the mentor
// //                         await MessagingService.sendPrivateChatRequest(mentor.uid);
// //                         if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Requested chat with ${mentor.displayName}')));
// //                       },
// //                       child: const Text('Request'),
// //                     ),
// //                     const SizedBox(width: 8),
// //                     ElevatedButton(
// //                       onPressed: () async {
// //                         // Create or open private chat
// //                         try {
// //                           final room = await MessagingService.createPrivateChat(mentor.uid);
// //                           if (!context.mounted) return;
// //                           Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatRoomPage(chatRoom: room)));
// //                         } catch (e) {
// //                           if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open chat: $e')));
// //                         }
// //                       },
// //                       child: const Text('Chat'),
// //                     ),
// //                   ],
// //                 ),
// //                 onTap: () {},
// //               ),
// //             );
// //           },
// //         );
// //       },
// //     );
// //   }
// // }
// //
// // class _RequestsTab extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return StreamBuilder<List<ChatRequest>>(
// //       stream: MessagingService.getChatRequests(),
// //       builder: (context, snapshot) {
// //         if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
// //         if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
// //
// //         final requests = snapshot.data ?? [];
// //         if (requests.isEmpty) return Center(child: Text('No chat requests', style: Theme.of(context).textTheme.titleMedium));
// //
// //         return ListView.separated(
// //           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// //           itemCount: requests.length,
// //           separatorBuilder: (_, __) => const SizedBox(height: 8),
// //           itemBuilder: (context, index) {
// //             final r = requests[index];
// //             return Card(
// //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //               child: ListTile(
// //                 leading: CircleAvatar(
// //                   backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.06),
// //                   child: r.requesterAvatar != null && r.requesterAvatar!.isNotEmpty ? ClipOval(child: Image.network(r.requesterAvatar!, width: 40, height: 40, fit: BoxFit.cover)) : Icon(Icons.person_rounded, color: Theme.of(context).colorScheme.primary),
// //                 ),
// //                 title: Text(r.requesterName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
// //                 subtitle: Text(r.message ?? 'Wants to start a conversation', maxLines: 2, overflow: TextOverflow.ellipsis),
// //                 trailing: Row(
// //                   mainAxisSize: MainAxisSize.min,
// //                   children: [
// //                     TextButton(
// //                       onPressed: () async {
// //                         // Confirm decline
// //                         final confirm = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Decline request'), content: Text('Decline request from ${r.requesterName}?'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Decline'))]));
// //                         if (confirm == true) {
// //                           await MessagingService.respondToChatRequest(requestId: r.id, status: ChatRequestStatus.rejected);
// //                           if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Declined ${r.requesterName}')));
// //                         }
// //                       },
// //                       child: const Text('Decline'),
// //                     ),
// //                     const SizedBox(width: 8),
// //                     ElevatedButton(
// //                       onPressed: () async {
// //                         await MessagingService.respondToChatRequest(requestId: r.id, status: ChatRequestStatus.approved);
// //                         if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Accepted request from ${r.requesterName}')));
// //                       },
// //                       style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white),
// //                       child: const Text('Accept'),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             );
// //           },
// //         );
// //       },
// //     );
// //   }
// // }
// //
// // class _ChatRoomTile extends StatelessWidget {
// //   final ChatRoom chatRoom;
// //
// //   const _ChatRoomTile({required this.chatRoom});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final theme = Theme.of(context);
// //     final muted = (chatRoom.settings['muted'] as bool?) == true;
// //     final pinned = (chatRoom.settings['pinned'] as bool?) == true;
// //     return Card(
// //       margin: const EdgeInsets.only(bottom: 8),
// //       elevation: 1,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //       child: InkWell(
// //         borderRadius: BorderRadius.circular(12),
// //         onTap: () {
// //           MessagingService.markRoomRead(chatRoom.id);
// //           Navigator.push(
// //             context,
// //             MaterialPageRoute(builder: (context) => ChatRoomPage(chatRoom: chatRoom)),
// //           );
// //         },
// //         child: Padding(
// //           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
// //           child: Row(
// //             children: [
// //               CircleAvatar(
// //                 radius: 28,
// //                 backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.06),
// //                 child: chatRoom.imageUrl != null && chatRoom.imageUrl!.isNotEmpty
// //                     ? ClipOval(
// //                         child: Image.network(chatRoom.imageUrl!, width: 48, height: 48, fit: BoxFit.cover),
// //                       )
// //                     : Icon(chatRoom.type == ChatType.group ? Icons.group_rounded : Icons.person_rounded, color: theme.colorScheme.primary, size: 28),
// //               ),
// //               const SizedBox(width: 12),
// //
// //               // Title + preview
// //               Expanded(
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Row(
// //                       children: [
// //                         Expanded(
// //                           child: Text(
// //                             chatRoom.name.isEmpty ? 'Private Chat' : chatRoom.name,
// //                             style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
// //                             maxLines: 1,
// //                             overflow: TextOverflow.ellipsis,
// //                           ),
// //                         ),
// //                         if (pinned) ...[
// //                           const SizedBox(width: 8),
// //                           Container(
// //                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //                             decoration: BoxDecoration(
// //                               color: theme.colorScheme.primary.withOpacity(0.14),
// //                               borderRadius: BorderRadius.circular(12),
// //                             ),
// //                             child: Row(
// //                               children: [
// //                                 Icon(Icons.push_pin, size: 14, color: theme.colorScheme.primary),
// //                                 const SizedBox(width: 6),
// //                                 Text('Pinned', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary)),
// //                               ],
// //                             ),
// //                           ),
// //                         ],
// //                         if (muted) ...[
// //                           const SizedBox(width: 6),
// //                           Icon(Icons.volume_off_outlined, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.6)),
// //                         ],
// //                       ],
// //                     ),
// //                     const SizedBox(height: 6),
// //                     StreamBuilder<List<ChatMessage>>(
// //                       stream: MessagingService.getChatMessages(chatRoom.id, limit: 1),
// //                       builder: (context, snap) {
// //                         final latest = (snap.data ?? []).isNotEmpty ? (snap.data ?? [])[0] : null;
// //                         final preview = latest != null ? (latest.type == MessageType.text ? latest.content : '[${latest.type.name}]') : (chatRoom.description ?? 'Tap to start chatting');
// //                         return Text(
// //                           preview,
// //                           maxLines: 1,
// //                           overflow: TextOverflow.ellipsis,
// //                           style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
// //                         );
// //                       },
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //
// //               // Time + unread
// //               Column(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 crossAxisAlignment: CrossAxisAlignment.end,
// //                 children: [
// //                   Text(
// //                     chatRoom.lastMessageAt != null ? _formatTime(chatRoom.lastMessageAt!) : '',
// //                     style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
// //                   ),
// //                   const SizedBox(height: 8),
// //                   StreamBuilder<int>(
// //                     stream: MessagingService.getUnreadCount(chatRoom.id),
// //                     builder: (context, snapshot) {
// //                       final unread = snapshot.data ?? 0;
// //                       if (unread <= 0) return const SizedBox.shrink();
// //                       return Container(
// //                         width: 30,
// //                         height: 30,
// //                         alignment: Alignment.center,
// //                         decoration: BoxDecoration(
// //                           gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.primaryContainer]),
// //                           shape: BoxShape.circle,
// //                           boxShadow: [BoxShadow(color: theme.colorScheme.primary.withOpacity(0.18), blurRadius: 6, offset: const Offset(0, 3))],
// //                         ),
// //                         child: Text(unread.toString(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
// //                       );
// //                     },
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   String _formatTime(DateTime dateTime) {
// //     final now = DateTime.now();
// //     final difference = now.difference(dateTime);
// //
// //     if (difference.inDays > 0) {
// //       return '${difference.inDays}d ago';
// //     } else if (difference.inHours > 0) {
// //       return '${difference.inHours}h ago';
// //     } else if (difference.inMinutes > 0) {
// //       return '${difference.inMinutes}m ago';
// //     } else {
// //       return 'Just now';
// //     }
// //   }
// // }
// //
// // class _MentorTile extends StatelessWidget {
// //   final UserProfile mentor;
// //
// //   const _MentorTile({required this.mentor});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final theme = Theme.of(context);
// //
// //     return Card(
// //       margin: const EdgeInsets.only(bottom: 8),
// //       child: ListTile(
// //         leading: CircleAvatar(
// //           backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
// //           child: mentor.avatarUrl.isNotEmpty
// //               ? ClipOval(
// //                   child: Image.network(
// //                     mentor.avatarUrl,
// //                     width: 40,
// //                     height: 40,
// //                     fit: BoxFit.cover,
// //                     errorBuilder: (context, error, stackTrace) {
// //                       return Icon(
// //                         Icons.volunteer_activism_rounded,
// //                         color: theme.colorScheme.primary,
// //                       );
// //                     },
// //                   ),
// //                 )
// //               : Icon(
// //                   Icons.volunteer_activism_rounded,
// //                   color: theme.colorScheme.primary,
// //                 ),
// //         ),
// //         title: Text(
// //           mentor.displayName,
// //           style: theme.textTheme.titleMedium?.copyWith(
// //             fontWeight: FontWeight.w600,
// //           ),
// //         ),
// //         subtitle: Text(mentor.school),
// //         trailing: Row(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             if (mentor.isOnline)
// //               Container(
// //                 width: 8,
// //                 height: 8,
// //                 decoration: BoxDecoration(
// //                   color: Colors.green,
// //                   shape: BoxShape.circle,
// //                 ),
// //               ),
// //             const SizedBox(width: 8),
// //             ElevatedButton(
// //               onPressed: () => _sendChatRequest(context),
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: theme.colorScheme.primary,
// //                 foregroundColor: Colors.white,
// //                 minimumSize: const Size(80, 32),
// //               ),
// //               child: const Text('Chat'),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   void _sendChatRequest(BuildContext context) {
// //     showDialog(
// //       context: context,
// //       builder: (context) => _ChatRequestDialog(mentor: mentor),
// //     );
// //   }
// // }
// //
// // class _ChatRequestTile extends StatelessWidget {
// //   final ChatRequest request;
// //
// //   const _ChatRequestTile({required this.request});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final theme = Theme.of(context);
// //
// //     return Card(
// //       margin: const EdgeInsets.only(bottom: 8),
// //       child: ListTile(
// //         leading: CircleAvatar(
// //           backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
// //           child: request.requesterAvatar != null && request.requesterAvatar!.isNotEmpty
// //               ? ClipOval(
// //                   child: Image.network(
// //                     request.requesterAvatar!,
// //                     width: 40,
// //                     height: 40,
// //                     fit: BoxFit.cover,
// //                     errorBuilder: (context, error, stackTrace) {
// //                       return Icon(
// //                         Icons.person_rounded,
// //                         color: theme.colorScheme.primary,
// //                       );
// //                     },
// //                   ),
// //                 )
// //               : Icon(
// //                   Icons.person_rounded,
// //                   color: theme.colorScheme.primary,
// //                 ),
// //         ),
// //         title: Text(
// //           request.requesterName,
// //           style: theme.textTheme.titleMedium?.copyWith(
// //             fontWeight: FontWeight.w600,
// //           ),
// //         ),
// //         subtitle: Text(
// //           request.message ?? 'Wants to start a conversation',
// //           maxLines: 2,
// //           overflow: TextOverflow.ellipsis,
// //         ),
// //         trailing: Row(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             TextButton(
// //               onPressed: () => _respondToRequest(context, ChatRequestStatus.rejected),
// //               child: const Text('Decline'),
// //             ),
// //             const SizedBox(width: 8),
// //             ElevatedButton(
// //               onPressed: () => _respondToRequest(context, ChatRequestStatus.approved),
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: theme.colorScheme.primary,
// //                 foregroundColor: Colors.white,
// //               ),
// //               child: const Text('Accept'),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   void _respondToRequest(BuildContext context, ChatRequestStatus status) {
// //     MessagingService.respondToChatRequest(
// //       requestId: request.id,
// //       status: status,
// //     );
// //   }
// // }
// //
// // class _ChatRequestDialog extends StatefulWidget {
// //   final UserProfile mentor;
// //
// //   const _ChatRequestDialog({required this.mentor});
// //
// //   @override
// //   State<_ChatRequestDialog> createState() => _ChatRequestDialogState();
// // }
// //
// // class _ChatRequestDialogState extends State<_ChatRequestDialog> {
// //   final _messageController = TextEditingController();
// //   bool _loading = false;
// //
// //   @override
// //   void dispose() {
// //     _messageController.dispose();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final theme = Theme.of(context);
// //
// //     return AlertDialog(
// //       title: Text('Send Chat Request'),
// //       content: Column(
// //         mainAxisSize: MainAxisSize.min,
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Text('Send a chat request to ${widget.mentor.displayName}'),
// //           const SizedBox(height: 16),
// //           TextField(
// //             controller: _messageController,
// //             decoration: const InputDecoration(
// //               labelText: 'Message (optional)',
// //               hintText: 'Hi! I\'d like to chat with you...',
// //             ),
// //             maxLines: 3,
// //           ),
// //         ],
// //       ),
// //       actions: [
// //         TextButton(
// //           onPressed: _loading ? null : () => Navigator.pop(context),
// //           child: const Text('Cancel'),
// //         ),
// //         ElevatedButton(
// //           onPressed: _loading ? null : _sendRequest,
// //           child: _loading
// //               ? const SizedBox(
// //                   width: 16,
// //                   height: 16,
// //                   child: CircularProgressIndicator(strokeWidth: 2),
// //                 )
// //               : const Text('Send'),
// //         ),
// //       ],
// //     );
// //   }
// //
// //   Future<void> _sendRequest() async {
// //     setState(() => _loading = true);
// //
// //     try {
// //       await MessagingService.sendChatRequest(
// //         targetUserId: widget.mentor.uid,
// //         message: _messageController.text.trim().isEmpty
// //             ? null
// //             : _messageController.text.trim(),
// //       );
// //
// //       if (mounted) {
// //         Navigator.pop(context);
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(
// //             content: Text('Chat request sent successfully'),
// //             backgroundColor: Colors.green,
// //           ),
// //         );
// //       }
// //     } catch (e) {
// //       if (mounted) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: Text('Failed to send request: $e'),
// //             backgroundColor: Colors.red,
// //           ),
// //         );
// //       }
// //     } finally {
// //       if (mounted) {
// //         setState(() => _loading = false);
// //       }
// //     }
// //   }
// // }
// //
// // class CreateGroupDialog extends StatelessWidget {
// //   const CreateGroupDialog({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return const CreateGroupPage();
// //   }
// // }
// //
// // class UserSearchDialog extends StatelessWidget {
// //   const UserSearchDialog({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return UserSearchPage();
// //   }
// // }
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
// import '../../models/chat_models.dart';
// import '../../models/user_profile.dart';
// import '../../services/messaging_service.dart';
// import '../../services/auth_service.dart';
// import '../../theme/app_theme.dart';
// import '../../theme/messaging_theme.dart';
// import '../../widgets/gradient_background.dart'; // <-- Using your GradientBackground
// import '../../widgets/animations/staggered_list_item.dart'; // <-- Using our new animator
// import '../../widgets/messaging/chat_list_item.dart';
// import '../../widgets/messaging/user_profile_tile.dart';
// import '../../widgets/messaging/request_tile.dart';
// import '../../widgets/messaging/empty_state_widget.dart';
// import 'create_group_page.dart';
// import 'user_search_page.dart';
// import 'public_groups_page.dart';
//
// class MessagingHubPage extends ConsumerStatefulWidget {
//   const MessagingHubPage({super.key});
//
//   @override
//   ConsumerState<MessagingHubPage> createState() => _MessagingHubPageState();
// }
//
// class _MessagingHubPageState extends ConsumerState<MessagingHubPage>
//     with TickerProviderStateMixin {
//   late TabController _tabController;
//   UserProfile? _currentUser;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     _loadCurrentUser();
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _loadCurrentUser() async {
//     final user = await AuthService.getCurrentUserProfile();
//     if (mounted) {
//       setState(() {
//         _currentUser = user;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final msgTheme = context.messagingTheme;
//
//     return Scaffold(
//       // Use transparent appbar to show gradient behind it
//       extendBodyBehindAppBar: true,
//       backgroundColor: Colors.transparent, // Scaffold bg is transparent
//       appBar: AppBar(
//         backgroundColor: Colors.transparent, // Transparent app bar
//         elevation: 0,
//         title: Text(
//           'Messages',
//           style: theme.textTheme.headlineSmall?.copyWith(
//               fontWeight: FontWeight.w700,
//               color: Colors.white, // White title on gradient
//               shadows: [
//                 Shadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: Offset(0,1))
//               ]
//           ),
//         ),
//         actions: [
//           if (_currentUser?.role == UserRole.mentor)
//             IconButton(
//               onPressed: _navigateToCreateGroup,
//               icon: const Icon(Icons.group_add_rounded, color: Colors.white),
//               tooltip: 'Create Group',
//             ),
//           IconButton(
//             onPressed: _navigateToSearch,
//             icon: const Icon(Icons.search_rounded, color: Colors.white),
//             tooltip: 'Search Users',
//           ),
//           const SizedBox(width: 8),
//         ],
//         bottom: StyledTabBar( // Use the new StyledTabBar
//           controller: _tabController,
//           tabs: const [
//             Tab(text: 'Chats'),
//             Tab(text: 'Mentors'),
//             Tab(text: 'Requests'),
//           ],
//         ),
//       ),
//       body: GradientBackground( // <-- THIS IS THE KEY CHANGE
//         child: SafeArea( // SafeArea to avoid overlap with status bar/notch
//           bottom: false, // Allow TabBarView to go to bottom
//           child: TabBarView(
//             controller: _tabController,
//             children: [
//               _ChatsTab(),
//               _MentorsTab(),
//               _RequestsTab(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _navigateToCreateGroup() {
//     Navigator.push(
//         context, MaterialPageRoute(builder: (_) => const CreateGroupPage()));
//   }
//
//   void _navigateToSearch() {
//     Navigator.push(
//         context, MaterialPageRoute(builder: (_) => const UserSearchPage()));
//   }
// }
//
// // --- Polished Tab Bar ---
// class StyledTabBar extends StatelessWidget implements PreferredSizeWidget {
//   final TabController controller;
//   final List<Widget> tabs;
//
//   const StyledTabBar({super.key, required this.controller, required this.tabs});
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final msgTheme = context.messagingTheme;
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//       child: Container(
//         height: 48,
//         decoration: BoxDecoration(
//           // Use GradientCard's visual style
//             gradient: LinearGradient(
//               colors: [
//                 msgTheme.tabBarBackgroundColor.withOpacity(0.8),
//                 msgTheme.tabBarBackgroundColor.withOpacity(0.95),
//               ],
//             ),
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [
//               BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2)),
//             ],
//             border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.1))
//         ),
//         child: TabBar(
//           controller: controller,
//           tabs: tabs,
//           indicator: BoxDecoration(
//               color: msgTheme.tabBarIndicatorColor,
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                     color: msgTheme.tabBarIndicatorColor.withOpacity(0.5),
//                     blurRadius: 8,
//                     offset: const Offset(0, 2)
//                 )
//               ]
//           ),
//           indicatorSize: TabBarIndicatorSize.tab,
//           labelColor: msgTheme.selectedTabTextColor,
//           unselectedLabelColor: msgTheme.unselectedTabTextColor,
//           splashBorderRadius: BorderRadius.circular(12),
//           labelStyle: theme.textTheme.labelLarge
//               ?.copyWith(fontWeight: FontWeight.w700),
//           unselectedLabelStyle: theme.textTheme.labelLarge,
//           dividerColor: Colors.transparent,
//         ),
//       ),
//     );
//   }
//
//   @override
//   Size get preferredSize => const Size.fromHeight(64);
// }
//
// // --- Animated Chats Tab ---
// class _ChatsTab extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<List<ChatRoom>>(
//       stream: MessagingService.getUserChatRooms(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator(color: Colors.white));
//         }
//         if (snapshot.hasError) {
//           return Center(
//               child: Text('Error: ${snapshot.error}',
//                   style: const TextStyle(color: Colors.white)));
//         }
//         final chatRooms = snapshot.data ?? [];
//
//         if (chatRooms.isEmpty) {
//           return EmptyStateWidget(
//             icon: Icons.chat_bubble_outline_rounded,
//             title: 'No Conversations Yet',
//             message: 'Start a chat with a mentor or discover public groups.',
//             actionButton: ElevatedButton.icon(
//               onPressed: () {
//                 Navigator.push(context,
//                     MaterialPageRoute(builder: (_) => const PublicGroupsPage()));
//               },
//               icon: const Icon(Icons.explore_rounded),
//               label: const Text('Discover Groups'),
//             ),
//           );
//         }
//
//         // --- Animated List ---
//         return AnimationLimiter(
//           child: ListView.builder(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             itemCount: chatRooms.length,
//             itemBuilder: (context, index) {
//               final chatRoom = chatRooms[index];
//               return StaggeredListItem( // <-- Apply animation
//                 index: index,
//                 child: ChatListItem(
//                   chatRoom: chatRoom,
//                   // TODO: Pass user profile if available for Hero
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }
//
// // --- Mentors Tab (Also animated) ---
// class _MentorsTab extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<UserProfile>>(
//       future: MessagingService.getMentors(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator(color: Colors.white));
//         }
//         // ... (Error and Empty states) ...
//         final mentors = snapshot.data ?? [];
//
//         if (mentors.isEmpty) {
//           return const EmptyStateWidget(
//             icon: Icons.volunteer_activism_outlined,
//             title: 'No Mentors Available',
//             message: 'Check back later for available mentors.',
//           );
//         }
//
//         return AnimationLimiter(
//           child: ListView.builder(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             itemCount: mentors.length,
//             itemBuilder: (context, index) {
//               final mentor = mentors[index];
//               return StaggeredListItem( // <-- Apply animation
//                 index: index,
//                 child: UserProfileTile( // This widget is also updated (see below)
//                   user: mentor,
//                   trailing: ElevatedButton(
//                     onPressed: () => _sendChatRequest(context, mentor),
//                     style: ElevatedButton.styleFrom(
//                       minimumSize: const Size(80, 36),
//                       padding: const EdgeInsets.symmetric(horizontal: 12),
//                     ),
//                     child: const Text('Chat'),
//                   ),
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
//   void _sendChatRequest(BuildContext context, UserProfile mentor) {
//     showDialog(
//       context: context,
//       builder: (context) => _ChatRequestDialog(mentor: mentor),
//     );
//   }
// }
//
// // --- Requests Tab (Also animated) ---
// class _RequestsTab extends ConsumerWidget {
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return StreamBuilder<List<ChatRequest>>(
//       stream: MessagingService.getChatRequests(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator(color: Colors.white));
//         }
//         // ... (Error and Empty states) ...
//         final requests = snapshot.data ?? [];
//
//         if (requests.isEmpty) {
//           return const EmptyStateWidget(
//             icon: Icons.person_add_disabled_rounded,
//             title: 'No Pending Requests',
//             message: 'You have no incoming chat requests.',
//           );
//         }
//
//         return AnimationLimiter(
//           child: ListView.builder(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             itemCount: requests.length,
//             itemBuilder: (context, index) {
//               final request = requests[index];
//               return StaggeredListItem( // <-- Apply animation
//                 index: index,
//                 child: RequestTile(request: request), // Also updated (see below)
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }
//
// // --- (Re-usable _ChatRequestDialog) ---
// // (No changes needed to _ChatRequestDialog, assuming it exists from previous step)
// // ...
//
//
// // --- Re-usable Dialog for sending request (can be moved) ---
// class _ChatRequestDialog extends StatefulWidget {
//   final UserProfile mentor;
//   const _ChatRequestDialog({required this.mentor});
//   @override
//   State<_ChatRequestDialog> createState() => _ChatRequestDialogState();
// }
//
// class _ChatRequestDialogState extends State<_ChatRequestDialog> {
//   final _messageController = TextEditingController();
//   bool _loading = false;
//
//   @override
//   void dispose() {
//     _messageController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _sendRequest() async {
//     setState(() => _loading = true);
//     try {
//       await MessagingService.sendChatRequest(
//         targetUserId: widget.mentor.uid,
//         message: _messageController.text.trim().isEmpty
//             ? null
//             : _messageController.text.trim(),
//       );
//       if (mounted) {
//         Navigator.pop(context); // Close dialog on success
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Chat request sent'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to send request: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _loading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return AlertDialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       title: const Text('Send Chat Request'),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text('Send a request to chat with ${widget.mentor.displayName}.'),
//           const SizedBox(height: 16),
//           TextField(
//             controller: _messageController,
//             decoration: const InputDecoration(
//               labelText: 'Message (Optional)',
//               hintText: 'Add a brief message...',
//               border: OutlineInputBorder(),
//             ),
//             maxLines: 3,
//             textCapitalization: TextCapitalization.sentences,
//           ),
//         ],
//       ),
//       actions: [
//         TextButton(
//           onPressed: _loading ? null : () => Navigator.pop(context),
//           child: const Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: _loading ? null : _sendRequest,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: theme.colorScheme.primary,
//             foregroundColor: Colors.white,
//           ),
//           child: _loading
//               ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
//               : const Text('Send Request'),
//         ),
//       ],
//     );
//   }
// }














import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/chat_models.dart';
import '../../models/user_profile.dart';
import '../../services/messaging_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/messaging_theme.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/animations/staggered_list_item.dart';
import '../../widgets/messaging/chat_list_item.dart';
import '../../widgets/messaging/user_profile_tile.dart';
import '../../widgets/messaging/request_tile.dart';
import '../../widgets/messaging/empty_state_widget.dart';
import 'create_group_page.dart';
import 'user_search_page.dart';
import 'public_groups_page.dart';

class MessagingHubPage extends ConsumerStatefulWidget {
  const MessagingHubPage({super.key});

  @override
  ConsumerState<MessagingHubPage> createState() => _MessagingHubPageState();
}

class _MessagingHubPageState extends ConsumerState<MessagingHubPage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  UserProfile? _currentUser;
  bool _isLoadingUser = true;

  final PageStorageKey _chatsKey = const PageStorageKey('chatsList');
  final PageStorageKey _mentorsKey = const PageStorageKey('mentorsList');
  final PageStorageKey _requestsKey = const PageStorageKey('requestsList');

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final user = await AuthService.getCurrentUserProfile();
    if (mounted) {
      setState(() {
        _currentUser = user;
        _isLoadingUser = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final theme = Theme.of(context);
    final msgTheme = context.messagingTheme;
    final isDark = theme.brightness == Brightness.dark;

    // Show loading state while user profile is being fetched
    if (_isLoadingUser) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      theme.colorScheme.surface,
                      theme.colorScheme.surface.withOpacity(0.95),
                    ]
                  : [
                      theme.colorScheme.primary.withOpacity(0.03),
                      theme.colorScheme.secondary.withOpacity(0.02),
                      theme.scaffoldBackgroundColor,
                    ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated pulsing container with gradient
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.85 + (value * 0.15),
                      child: Opacity(
                        opacity: 0.4 + (value * 0.6),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                theme.colorScheme.primary.withOpacity(0.25),
                                theme.colorScheme.secondary.withOpacity(0.15),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(0.2 * value),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.secondary,
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.forum_rounded,
                                  color: Colors.white,
                                  size: 36,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  onEnd: () {
                    // Loop the animation
                    if (mounted && _isLoadingUser) {
                      setState(() {});
                    }
                  },
                ),
                const SizedBox(height: 32),
                
                // Animated text with fade
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                        ).createShader(bounds),
                        child: Text(
                          'Loading Messages',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Preparing your conversations...',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Animated loading dots
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        final delay = index * 0.15;
                        final dotValue = ((value + delay) % 1.0);
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Transform.translate(
                            offset: Offset(0, -8 * (1 - (dotValue * 2 - 1).abs())),
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary.withOpacity(0.3 + dotValue * 0.7),
                                    theme.colorScheme.secondary.withOpacity(0.3 + dotValue * 0.7),
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                  onEnd: () {
                    // Loop the animation
                    if (mounted && _isLoadingUser) {
                      setState(() {});
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    final appBarForegroundColor = isDark ? Colors.white : theme.colorScheme.onSurface;
    final double topPadding = MediaQuery.of(context).padding.top;
    final double appBarHeight = kToolbarHeight;
    final double tabBarHeight = 80.0; // Increased for premium look
    final double extraSpacing = 12.0; // Extra spacing we added (8px header + 4px before tab bar)
    final double totalAppBarHeight = topPadding + appBarHeight + tabBarHeight + extraSpacing;

    // Wrap the entire content in a smooth entry animation
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 130), // Increased padding to fully clear nav bar
        child: AnimatedScale(
          scale: _tabController.index == 0 ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutBack,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              onPressed: _navigateToSearch,
              icon: const Icon(Icons.add_rounded, size: 24),
              label: const Text(
                'New Chat',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: 0.5,
                ),
              ),
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              elevation: 0,
              splashColor: Colors.white.withOpacity(0.2),
            ),
          ),
        ),
      ),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight + tabBarHeight + extraSpacing),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [
                          msgTheme.inputBackgroundColor.withOpacity(0.85),
                          msgTheme.inputBackgroundColor.withOpacity(0.75),
                        ]
                      : [
                          AppTheme.softBg.withOpacity(0.95),
                          AppTheme.softBg.withOpacity(0.85),
                        ],
                ),
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // Premium Header with better spacing
                    Container(
                      height: appBarHeight + 8, // Fixed: Added extra height
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          // Stunning icon with animated gradient
                          Hero(
                            tag: 'messaging_hub_icon',
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.secondary,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.forum_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: [
                                      theme.colorScheme.primary,
                                      theme.colorScheme.secondary,
                                    ],
                                  ).createShader(bounds),
                                  child: Text(
                                    'Messages',
                                    style: theme.textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: -1.0,
                                      height: 1.2,
                                      fontSize: 26, // Fixed: Slightly smaller to prevent overlap
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10), // Fixed: More spacing to prevent any overlap
                                Text(
                                  'Stay connected with everyone',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: appBarForegroundColor.withOpacity(0.6),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8), // Fixed: Added spacing before buttons
                          // Premium action buttons
                          if (_currentUser?.role == UserRole.mentor)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _PremiumActionButton(
                                icon: Icons.group_add_rounded,
                                onPressed: _navigateToCreateGroup,
                                tooltip: 'Create Group',
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.secondary.withOpacity(0.2),
                                    theme.colorScheme.secondary.withOpacity(0.1),
                                  ],
                                ),
                                iconColor: theme.colorScheme.secondary,
                              ),
                            ),
                          _PremiumActionButton(
                            icon: Icons.search_rounded,
                            onPressed: _navigateToSearch,
                            tooltip: 'Search',
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary.withOpacity(0.2),
                                theme.colorScheme.primary.withOpacity(0.1),
                              ],
                            ),
                            iconColor: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4), // Fixed: Added spacing before tab bar
                    // Stunning Tab Bar
                    _PremiumTabBar(
                      controller: _tabController,
                      tabs: const [
                        _PremiumTab(
                          icon: Icons.forum_rounded,
                          label: 'Chats',
                        ),
                        _PremiumTab(
                          icon: Icons.volunteer_activism_rounded,
                          label: 'Mentors',
                        ),
                        _PremiumTab(
                          icon: Icons.mark_chat_unread_rounded,
                          label: 'Requests',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: totalAppBarHeight),
        child: TabBarView(
          controller: _tabController,
          children: [
            _ChatsTab(key: _chatsKey),
            _MentorsTab(key: _mentorsKey),
            _RequestsTab(key: _requestsKey),
          ],
        ),
      ),
      ),
    );
  }

  void _navigateToCreateGroup() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const CreateGroupPage()));
  }

  void _navigateToSearch() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const UserSearchPage()));
  }
}

// --- Premium Action Button Widget ---
class _PremiumActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final Gradient gradient;
  final Color iconColor;

  const _PremiumActionButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    required this.gradient,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: iconColor.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: iconColor.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(14),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

// --- Premium Tab Widget ---
class _PremiumTab extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PremiumTab({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Tab(
      height: 48,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Premium TabBar ---
class _PremiumTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController controller;
  final List<Widget> tabs;

  const _PremiumTabBar({
    required this.controller,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Colors.white.withOpacity(0.08),
                    Colors.white.withOpacity(0.04),
                  ]
                : [
                    Colors.white.withOpacity(0.9),
                    Colors.white.withOpacity(0.7),
                  ],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.white.withOpacity(0.8),
            width: 2,
          ),
        ),
        child: TabBar(
          controller: controller,
          tabs: tabs,
          indicator: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.5),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: isDark
              ? Colors.white.withOpacity(0.5)
              : theme.colorScheme.onSurface.withOpacity(0.5),
          splashBorderRadius: BorderRadius.circular(15),
          dividerColor: Colors.transparent,
          indicatorPadding: const EdgeInsets.all(5),
          padding: EdgeInsets.zero,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(76);
}

// --- Remove old StyledTabBar ---


// --- _ChatsTab (Stunning Premium Design) ---
class _ChatsTab extends StatefulWidget {
  const _ChatsTab({super.key});

  @override
  State<_ChatsTab> createState() => _ChatsTabState();
}

class _ChatsTabState extends State<_ChatsTab> with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  String _filter = '';
  late final Stream<List<ChatRoom>> _chatRoomsStream;
  int _animationKey = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Cache the stream to prevent re-subscription on rebuild
    _chatRoomsStream = MessagingService.getUserChatRooms();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _triggerAnimation() {
    setState(() {
      _animationKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Premium search bar - Clean background
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : theme.colorScheme.surface.withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.12)
                    : theme.colorScheme.primary.withOpacity(0.08),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(isDark ? 0.15 : 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                // Search icon with gradient background
                Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.15),
                        theme.colorScheme.secondary.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.search_rounded,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                // Text field
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _filter = value.trim().toLowerCase()),
                    decoration: InputDecoration(
                      hintText: 'Search conversations...',
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.4),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      filled: false,
                      fillColor: Colors.transparent,
                    ),
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // Clear button
                if (_filter.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          _searchController.clear();
                          setState(() => _filter = '');
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: theme.colorScheme.error,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 12),
              ],
            ),
          ),
        ),

        // Quick Actions Bar
        const _QuickActionsBar(),

        // Chat List
        Expanded(
          child: StreamBuilder<List<ChatRoom>>(
            stream: _chatRoomsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary.withOpacity(0.2),
                              theme.colorScheme.secondary.withOpacity(0.1),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: theme.colorScheme.primary,
                            strokeWidth: 3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading conversations...',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.error_outline_rounded,
                          size: 48,
                          color: theme.colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Oops! Something went wrong',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final chatRooms = (snapshot.data ?? []).where((r) {
                if (_filter.isEmpty) return true;
                final name = (r.name.isNotEmpty ? r.name : 'Private Chat').toLowerCase();
                final desc = (r.description ?? '').toLowerCase();
                return name.contains(_filter) || desc.contains(_filter);
              }).toList();

              // Sort: pinned chats first, then by last message time
              final currentUserId = FirebaseAuth.instance.currentUser?.uid;
              chatRooms.sort((a, b) {
                final aPinned = currentUserId != null && a.pinnedBy.contains(currentUserId);
                final bPinned = currentUserId != null && b.pinnedBy.contains(currentUserId);
                
                // Pinned chats come first
                if (aPinned && !bPinned) return -1;
                if (!aPinned && bPinned) return 1;
                
                // Within same pin status, sort by time
                final aTime = a.lastMessageAt ?? a.createdAt;
                final bTime = b.lastMessageAt ?? b.createdAt;
                return bTime.compareTo(aTime);
              });

              if (chatRooms.isEmpty) {
                return const Center(
                  child: EmptyStateWidget(
                    icon: Icons.forum_rounded,
                    title: 'No Conversations Yet',
                    message: 'Start chatting with mentors or join groups to get started!',
                    actionButton: _DiscoverGroupsButton(),
                  ),
                );
              }

              return AnimationLimiter(
                key: ValueKey('chat_animation_$_animationKey'),
                child: ListView.builder(
                  key: const PageStorageKey('chatsList'),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  itemCount: chatRooms.length,
                  itemBuilder: (context, index) {
                    final chatRoom = chatRooms[index];
                    final isPinned = currentUserId != null && chatRoom.pinnedBy.contains(currentUserId);
                    final isLastPinned = isPinned && 
                        (index == chatRooms.length - 1 || 
                         !(currentUserId != null && chatRooms[index + 1].pinnedBy.contains(currentUserId)));
                    
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 475),
                      child: SlideAnimation(
                        verticalOffset: 40.0,
                        curve: Curves.easeOutCubic,
                        child: FadeInAnimation(
                          curve: Curves.easeOut,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ChatListItem(chatRoom: chatRoom),
                              ),
                              // Add divider after last pinned chat
                              if (isLastPinned && index < chatRooms.length - 1)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Divider(
                                          color: theme.colorScheme.onSurface.withOpacity(0.1),
                                          thickness: 1,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        child: Text(
                                          'All Chats',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Divider(
                                          color: theme.colorScheme.onSurface.withOpacity(0.1),
                                          thickness: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
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
      ],
    );
  }
}

// --- Quick Actions Bar Widget - FIXED to match search bar width ---
class _QuickActionsBar extends StatelessWidget {
  const _QuickActionsBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16), // Match search bar padding
      child: Row(
        children: [
          Expanded(
            child: _QuickActionChip(
              icon: Icons.explore_rounded,
              label: 'Discover',
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.tertiary.withOpacity(0.2),
                  theme.colorScheme.tertiary.withOpacity(0.1),
                ],
              ),
              iconColor: theme.colorScheme.tertiary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PublicGroupsPage()),
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _QuickActionChip(
              icon: Icons.people_rounded,
              label: 'People',
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(0.2),
                  theme.colorScheme.primary.withOpacity(0.1),
                ],
              ),
              iconColor: theme.colorScheme.primary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UserSearchPage()),
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _QuickActionChip(
              icon: Icons.star_rounded,
              label: 'Favorites',
              gradient: LinearGradient(
                colors: [
                  AppTheme.warningColor.withOpacity(0.2),
                  AppTheme.warningColor.withOpacity(0.1),
                ],
              ),
              iconColor: AppTheme.warningColor,
              onTap: () {
                // TODO: Filter favorites
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- Quick Action Chip Widget - REFINED to fill available space ---
class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Gradient gradient;
  final Color iconColor;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 48, // Fixed height for consistency
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: iconColor.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: iconColor.withOpacity(0.12),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // Center content
            mainAxisSize: MainAxisSize.max, // Fill available space
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withOpacity(0.9)
                        : theme.colorScheme.onSurface.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    letterSpacing: 0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Extracted Button for _ChatsTab Empty State
class _DiscoverGroupsButton extends StatelessWidget {
  const _DiscoverGroupsButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const PublicGroupsPage()));
      },
      icon: const Icon(Icons.explore_rounded),
      label: const Text('Discover Groups'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }
}


// --- _MentorsTab (Stunning Premium Cards) ---
class _MentorsTab extends StatefulWidget {
  const _MentorsTab({super.key});

  @override
  State<_MentorsTab> createState() => _MentorsTabState();
}

class _MentorsTabState extends State<_MentorsTab> with AutomaticKeepAliveClientMixin {
  late final Future<List<UserProfile>> _mentorsFuture;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Cache the future to prevent re-fetching on rebuild
    _mentorsFuture = MessagingService.getMentors();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final theme = Theme.of(context);

    return FutureBuilder<List<UserProfile>>(
      future: _mentorsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.secondary.withOpacity(0.2),
                        theme.colorScheme.secondary.withOpacity(0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.secondary,
                      strokeWidth: 3,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading mentors...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load mentors',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        final mentors = snapshot.data ?? [];

        if (mentors.isEmpty) {
          return const Center(
            child: EmptyStateWidget(
              icon: Icons.volunteer_activism_outlined,
              title: 'No Mentors Available',
              message: 'Check back later for available mentors to connect with.',
            ),
          );
        }

        return AnimationLimiter(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            itemCount: mentors.length,
            itemBuilder: (context, index) {
              final mentor = mentors[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 475),
                child: SlideAnimation(
                  verticalOffset: 40.0,
                  curve: Curves.easeOutCubic,
                  child: FadeInAnimation(
                    curve: Curves.easeOut,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _PremiumMentorCard(
                        mentor: mentor,
                        onChat: () => _sendChatRequest(context, mentor),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _sendChatRequest(BuildContext context, UserProfile mentor) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => _ChatRequestDialog(mentor: mentor),
    );
  }
}

// --- Premium Mentor Card Widget - REFINED ---
class _PremiumMentorCard extends StatelessWidget {
  final UserProfile mentor;
  final VoidCallback onChat;

  const _PremiumMentorCard({
    required this.mentor,
    required this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.12)
              : theme.colorScheme.primary.withOpacity(0.08),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(isDark ? 0.12 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onChat,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  children: [
                    // Avatar with gradient border - REFINED
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.secondary,
                            theme.colorScheme.primary,
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.secondary.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isDark
                              ? theme.colorScheme.surface
                              : Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: mentor.avatarUrl.isNotEmpty
                              ? Image.network(
                                  mentor.avatarUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.volunteer_activism_rounded,
                                    color: theme.colorScheme.secondary,
                                    size: 30,
                                  ),
                                )
                              : Icon(
                                  Icons.volunteer_activism_rounded,
                                  color: theme.colorScheme.secondary,
                                  size: 30,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Info - REFINED
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  mentor.displayName,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 17,
                                    letterSpacing: -0.5,
                                    height: 1.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.school_rounded,
                                size: 15,
                                color: theme.colorScheme.onSurface.withOpacity(0.5),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  mentor.school,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    height: 1.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Verified badge - REFINED
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.secondary.withOpacity(0.2),
                            theme.colorScheme.secondary.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: theme.colorScheme.secondary.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.verified_rounded,
                        size: 18,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Chat button - Full width, more prominent
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onChat,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 20),
                            SizedBox(width: 10),
                            Text(
                              'Send Chat Request',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- _RequestsTab (Premium Badge Design) ---
class _RequestsTab extends ConsumerStatefulWidget {
  const _RequestsTab({super.key});

  @override
  ConsumerState<_RequestsTab> createState() => _RequestsTabState();
}

class _RequestsTabState extends ConsumerState<_RequestsTab> with AutomaticKeepAliveClientMixin {
  late final Stream<List<ChatRequest>> _requestsStream;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Cache the stream to prevent re-subscription on rebuild
    _requestsStream = MessagingService.getChatRequests();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final WidgetRef ref = this.ref;
    final theme = Theme.of(context);

    return StreamBuilder<List<ChatRequest>>(
      stream: _requestsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.accentColor.withOpacity(0.2),
                        AppTheme.accentColor.withOpacity(0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.accentColor,
                      strokeWidth: 3,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading requests...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          final errorMessage = snapshot.error.toString();
          final isPermissionError = errorMessage.contains('permission-denied') || 
                                   errorMessage.contains('Permission denied');
          
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPermissionError ? Icons.lock_outline_rounded : Icons.error_outline_rounded,
                      size: 48,
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isPermissionError ? 'Permission Required' : 'Failed to load requests',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      height: 1.4,
                    ),
                  ),
                  if (isPermissionError) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: theme.colorScheme.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Check Firestore security rules for chat_requests collection',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        final requests = snapshot.data ?? [];

        if (requests.isEmpty) {
          return const Center(
            child: EmptyStateWidget(
              icon: Icons.mark_chat_read_rounded,
              title: 'All Caught Up!',
              message: 'You have no pending chat requests at the moment.',
            ),
          );
        }

        return Column(
          children: [
            // Header with count
            Container(
              margin: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accentColor.withOpacity(0.15),
                    AppTheme.accentColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.accentColor.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_active_rounded,
                      color: AppTheme.accentColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pending Requests',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          '${requests.length} ${requests.length == 1 ? 'person wants' : 'people want'} to connect',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.accentColor, AppTheme.accentColor.withOpacity(0.8)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${requests.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AnimationLimiter(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index];
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 475),
                      child: SlideAnimation(
                        verticalOffset: 40.0,
                        curve: Curves.easeOutCubic,
                        child: FadeInAnimation(
                          curve: Curves.easeOut,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: RequestTile(request: request),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}


// --- _ChatRequestDialog (Modern, Beautiful Design) ---
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
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      await MessagingService.sendChatRequest(
        targetUserId: widget.mentor.uid,
        message: _messageController.text.trim().isEmpty
            ? null
            : _messageController.text.trim(),
      );
      if (mounted) {
        Navigator.pop(context);
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Chat request sent to ${widget.mentor.displayName}!',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text('Failed: $e')),
              ],
            ),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
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

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      backgroundColor: theme.colorScheme.surface,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface.withOpacity(0.95),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.15),
                        theme.colorScheme.secondary.withOpacity(0.10),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.send_rounded,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Send Request',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'to ${widget.mentor.displayName}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Add a message (optional)',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _messageController,
              maxLines: 4,
              minLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Hi! I\'d like to connect with you...',
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _loading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _sendRequest,
                    icon: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded, size: 20),
                    label: Text(_loading ? 'Sending...' : 'Send Request'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: theme.colorScheme.primary.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}