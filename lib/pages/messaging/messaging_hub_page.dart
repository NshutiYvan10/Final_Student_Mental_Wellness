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














import 'dart:ui'; // For blur
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
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
import '../../widgets/messaging/empty_state_widget.dart'; // Import EmptyStateWidget
import 'create_group_page.dart';
import 'user_search_page.dart';
import 'public_groups_page.dart';

class MessagingHubPage extends ConsumerStatefulWidget {
  const MessagingHubPage({super.key});

  @override
  ConsumerState<MessagingHubPage> createState() => _MessagingHubPageState();
}

class _MessagingHubPageState extends ConsumerState<MessagingHubPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  UserProfile? _currentUser;

  final PageStorageKey _chatsKey = const PageStorageKey('chatsList');
  final PageStorageKey _mentorsKey = const PageStorageKey('mentorsList');
  final PageStorageKey _requestsKey = const PageStorageKey('requestsList');


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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final msgTheme = context.messagingTheme;

    final appBarForegroundColor = theme.brightness == Brightness.dark
        ? Colors.white
        : theme.colorScheme.onSurface;

    final double topPadding = MediaQuery.of(context).padding.top;
    final double appBarHeight = kToolbarHeight;
    final double tabBarHeight = 64.0;
    final double totalAppBarHeight = topPadding + appBarHeight + tabBarHeight;


    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        iconTheme: IconThemeData(color: appBarForegroundColor),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: appBarForegroundColor,
        title: Text(
          'Messages',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: appBarForegroundColor,
          ),
        ),
        actions: [
          if (_currentUser?.role == UserRole.mentor)
            IconButton(
              onPressed: _navigateToCreateGroup,
              icon: Icon(Icons.group_add_rounded, color: appBarForegroundColor),
              tooltip: 'Create Group',
            ),
          IconButton(
            onPressed: _navigateToSearch,
            icon: Icon(Icons.search_rounded, color: appBarForegroundColor),
            tooltip: 'Search Users',
          ),
          const SizedBox(width: 8),
        ],
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? msgTheme.inputBackgroundColor.withOpacity(0.75)
                    : AppTheme.softBg.withOpacity(0.85),
                border: Border(
                  bottom: BorderSide(
                      color: theme.brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.08),
                      width: 1),
                ),
              ),
            ),
          ),
        ),
        bottom: StyledTabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Chats'),
            Tab(text: 'Mentors'),
            Tab(text: 'Requests'),
          ],
        ),
      ),
      body: GradientBackground(
        child: Padding(
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

// --- StyledTabBar (Corrected for theme adaptation) ---
class StyledTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController controller;
  final List<Widget> tabs;

  const StyledTabBar({super.key, required this.controller, required this.tabs});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final msgTheme = context.messagingTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? msgTheme.tabBarBackgroundColor.withOpacity(0.9)
                : theme.colorScheme.surface.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2)),
            ],
            border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2))
        ),
        child: TabBar(
          controller: controller,
          tabs: tabs,
          indicator: BoxDecoration(
              color: msgTheme.tabBarIndicatorColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: msgTheme.tabBarIndicatorColor.withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2)
                )
              ]
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: msgTheme.selectedTabTextColor,
          unselectedLabelColor: theme.brightness == Brightness.dark
              ? msgTheme.unselectedTabTextColor
              : theme.colorScheme.onSurface.withOpacity(0.6),
          splashBorderRadius: BorderRadius.circular(12),
          labelStyle: theme.textTheme.labelLarge
              ?.copyWith(fontWeight: FontWeight.w700),
          unselectedLabelStyle: theme.textTheme.labelLarge,
          dividerColor: Colors.transparent,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}


// --- _ChatsTab ---
class _ChatsTab extends StatelessWidget {
  const _ChatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ChatRoom>>(
      stream: MessagingService.getUserChatRooms(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }
        if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white70)));
        }
        final chatRooms = snapshot.data ?? [];

        if (chatRooms.isEmpty) {
          return const Center( // Wrap EmptyStateWidget in Center
            child: EmptyStateWidget(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'No Conversations Yet',
              message: 'Start a chat with a mentor or discover public groups.',
              // *** FIX: Removed style parameters ***
              // titleStyle: TextStyle(color: emptyStateColor.withOpacity(0.9), fontSize: 20, fontWeight: FontWeight.w600),
              // messageStyle: TextStyle(color: emptyStateColor, fontSize: 16),
              actionButton: _DiscoverGroupsButton(), // Extracted button
            ),
          );
        }

        return AnimationLimiter(
          child: ListView.builder(
            key: key, // Use key passed from parent
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final chatRoom = chatRooms[index];
              return StaggeredListItem(
                index: index,
                child: ChatListItem(
                  chatRoom: chatRoom,
                ),
              );
            },
          ),
        );
      },
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


// --- _MentorsTab ---
class _MentorsTab extends StatelessWidget {
  const _MentorsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<List<UserProfile>>(
      future: MessagingService.getMentors(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white70)));
        }
        final mentors = snapshot.data ?? [];

        if (mentors.isEmpty) {
          return const Center(
            child: EmptyStateWidget(
              icon: Icons.volunteer_activism_outlined,
              title: 'No Mentors Available',
              message: 'Check back later for available mentors.',
              // *** FIX: Removed style parameters ***
              // titleStyle: TextStyle(color: emptyStateColor.withOpacity(0.9), fontSize: 20, fontWeight: FontWeight.w600),
              // messageStyle: TextStyle(color: emptyStateColor, fontSize: 16),
            ),
          );
        }

        return AnimationLimiter(
          child: ListView.builder(
            key: key, // Use key
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: mentors.length,
            itemBuilder: (context, index) {
              final mentor = mentors[index];
              return StaggeredListItem(
                index: index,
                child: UserProfileTile(
                  user: mentor,
                  trailing: ElevatedButton(
                    onPressed: () => _sendChatRequest(context, mentor),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(80, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Chat'),
                  ),
                  onTap: () {
                    // Optional: Navigate to full mentor profile
                  },
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
      builder: (context) => _ChatRequestDialog(mentor: mentor),
    );
  }
}

// --- _RequestsTab ---
class _RequestsTab extends ConsumerWidget {
  const _RequestsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return StreamBuilder<List<ChatRequest>>(
      stream: MessagingService.getChatRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white70)));
        }
        final requests = snapshot.data ?? [];

        if (requests.isEmpty) {
          return const Center(
            child: EmptyStateWidget(
              icon: Icons.person_add_disabled_rounded,
              title: 'No Pending Requests',
              message: 'You have no incoming chat requests.',
              // *** FIX: Removed style parameters ***
              // titleStyle: TextStyle(color: emptyStateColor.withOpacity(0.9), fontSize: 20, fontWeight: FontWeight.w600),
              // messageStyle: TextStyle(color: emptyStateColor, fontSize: 16),
            ),
          );
        }

        return AnimationLimiter(
          child: ListView.builder(
            key: key, // Use key
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return StaggeredListItem(
                index: index,
                child: RequestTile(request: request),
              );
            },
          ),
        );
      },
    );
  }
}


// --- _ChatRequestDialog (Style Improvements) ---
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
    final scaffoldMessenger = ScaffoldMessenger.of(context); // Store for async use
    try {
      await MessagingService.sendChatRequest(
        targetUserId: widget.mentor.uid,
        message: _messageController.text.trim().isEmpty
            ? null
            : _messageController.text.trim(),
      );
      if (mounted) {
        Navigator.pop(context);
        scaffoldMessenger.showSnackBar( // Use stored messenger
          const SnackBar(
            content: Text('Chat request sent successfully!'),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            margin: EdgeInsets.all(12),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar( // Use stored messenger
          SnackBar(
            content: Text('Failed to send request: $e'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            margin: EdgeInsets.all(12),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: theme.colorScheme.surface,
      elevation: 5,
      title: Row(
        children: [
          Icon(Icons.send_rounded, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          const Text('Send Chat Request'),
        ],
      ),
      titleTextStyle: theme.textTheme.titleLarge,
      contentTextStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.8)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Send a request to chat with ${widget.mentor.displayName}.'),
            const SizedBox(height: 16),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'Message (Optional)',
                hintText: 'Add a brief message...',
                prefixIcon: Icon(Icons.message_outlined, size: 20),
                // Ensure input decoration uses theme defaults
              ),
              maxLines: 3,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          icon: _loading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.send_rounded, size: 18),
          label: const Text('Send'),
          onPressed: _loading ? null : _sendRequest,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
      ],
    );
  }
}


// --- EmptyStateWidget Extension (For reference, no changes needed if widget is correct) ---
// Add these properties to your EmptyStateWidget class if they don't exist
/*
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? actionButton;
  final TextStyle? titleStyle; // Add this
  final TextStyle? messageStyle; // Add this

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionButton,
    this.titleStyle, // Add this
    this.messageStyle, // Add this
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // ... rest of build method, using titleStyle and messageStyle if provided ...
    // Example:
    // Text(title, style: titleStyle ?? theme.textTheme.headlineSmall?.copyWith(...))
    // Text(message, style: messageStyle ?? theme.textTheme.bodyLarge?.copyWith(...))
  }
}
*/