// import 'dart:ui'; // Import for ImageFilter.blur
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:collection/collection.dart';
// import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
// import '../../models/chat_models.dart';
// import '../../models/user_profile.dart';
// import '../../services/messaging_service.dart';
// import '../../services/auth_service.dart';
// import '../../theme/app_theme.dart';
// import '../../theme/messaging_theme.dart';
// import '../../widgets/gradient_background.dart';
// import '../../widgets/messaging/message_bubble.dart';
// import '../../widgets/messaging/chat_input_bar.dart';
// import '../../widgets/messaging/empty_state_widget.dart';
// import '../../widgets/animations/staggered_list_item.dart';
// import 'chat_info_page.dart';
//
// class ChatRoomPage extends ConsumerStatefulWidget {
//   final ChatRoom chatRoom;
//   final String? heroTag; // Made heroTag nullable
//
//   const ChatRoomPage({
//     super.key,
//     required this.chatRoom,
//     this.heroTag, // Removed 'required'
//   });
//
//   @override
//   ConsumerState<ChatRoomPage> createState() => _ChatRoomPageState();
// }
//
// class _ChatRoomPageState extends ConsumerState<ChatRoomPage> {
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   final FocusNode _inputFocusNode = FocusNode();
//   UserProfile? _currentUser;
//
//   List<ChatMessage> _olderMessages = [];
//   bool _isLoadingMore = false;
//   bool _canLoadMore = true;
//   bool _initialLoadComplete = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadCurrentUser();
//     _scrollController.addListener(_onScroll);
//     MessagingService.markRoomRead(widget.chatRoom.id);
//   }
//
//   @override
//   void dispose() {
//     _messageController.dispose();
//     _scrollController.removeListener(_onScroll);
//     _scrollController.dispose();
//     _inputFocusNode.dispose();
//     MessagingService.setTyping(chatRoomId: widget.chatRoom.id, isTyping: false);
//     super.dispose();
//   }
//
//   Future<void> _loadCurrentUser() async {
//     final user = await AuthService.getCurrentUserProfile();
//     if (mounted) setState(() => _currentUser = user);
//   }
//
//   void _onScroll() {
//     if (_scrollController.position.pixels >=
//         _scrollController.position.maxScrollExtent - 200 &&
//         !_isLoadingMore &&
//         _canLoadMore) {
//       _loadOlderMessages();
//     }
//   }
//
//   Future<void> _loadOlderMessages() async {
//     if (!_canLoadMore || _isLoadingMore) return;
//     setState(() => _isLoadingMore = true);
//     final oldestMessageTime = _olderMessages.isNotEmpty
//         ? _olderMessages.last.createdAt
//         : (await MessagingService.getChatMessages(widget.chatRoom.id, limit: 1)
//         .first)
//         .firstOrNull
//         ?.createdAt;
//
//     if (oldestMessageTime == null) {
//       setState(() {
//         _isLoadingMore = false;
//         _canLoadMore = false;
//       });
//       return;
//     }
//
//     try {
//       final older = await MessagingService.fetchOlderMessages(
//         chatRoomId: widget.chatRoom.id,
//         before: oldestMessageTime,
//         limit: 30,
//       );
//       if (mounted) {
//         setState(() {
//           _olderMessages.addAll(older);
//           _isLoadingMore = false;
//           _canLoadMore = older.isNotEmpty;
//           if (!_initialLoadComplete) _initialLoadComplete = true;
//         });
//       }
//     } catch (e) {
//       print("Error loading older messages: $e");
//       if (mounted) setState(() => _isLoadingMore = false);
//     }
//   }
//
//   void _sendMessage() {
//     final text = _messageController.text.trim();
//     if (text.isEmpty || _currentUser == null) return;
//     MessagingService.sendMessage(
//         chatRoomId: widget.chatRoom.id, content: text);
//     _messageController.clear();
//     MessagingService.setTyping(chatRoomId: widget.chatRoom.id, isTyping: false);
//     _inputFocusNode.unfocus();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(0.0,
//             duration: const Duration(milliseconds: 300),
//             curve: Curves.easeOutQuad);
//       }
//     });
//   }
//
//   void _sendAttachment() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Attachment feature coming soon!')),
//     );
//   }
//
//   void _showMessageOptions(BuildContext context, ChatMessage message) {
//     final bool canEditOrDelete = message.senderId == _currentUser?.uid;
//     final theme = Theme.of(context);
//
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent, // Transparent for custom container
//       builder: (ctx) {
//         return Container(
//           margin: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: theme.colorScheme.surface.withOpacity(0.9),
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(20),
//             child: BackdropFilter(
//               filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   ListTile(
//                     leading: const Icon(Icons.reply_rounded),
//                     title: const Text('Reply'),
//                     onTap: () => Navigator.pop(ctx),
//                   ),
//                   ListTile(
//                     leading: const Icon(Icons.copy_rounded),
//                     title: const Text('Copy Text'),
//                     onTap: () => Navigator.pop(ctx),
//                   ),
//                   if (canEditOrDelete)
//                     ListTile(
//                       leading: const Icon(Icons.edit_rounded),
//                       title: const Text('Edit Message'),
//                       onTap: () => Navigator.pop(ctx),
//                     ),
//                   if (canEditOrDelete)
//                     ListTile(
//                       leading: Icon(Icons.delete_outline_rounded,
//                           color: theme.colorScheme.error),
//                       title: Text('Delete Message',
//                           style: TextStyle(color: theme.colorScheme.error)),
//                       onTap: () => Navigator.pop(ctx),
//                     ),
//                   const SizedBox(height: 8),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final msgTheme = context.messagingTheme;
//
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       backgroundColor: Colors.transparent,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leadingWidth: 40,
//         leading: Padding(
//           padding: const EdgeInsets.only(left: 8.0),
//           child: IconButton(
//             icon: const Icon(Icons.arrow_back_ios_new_rounded),
//             onPressed: () => Navigator.pop(context),
//             style: IconButton.styleFrom(
//                 backgroundColor: theme.colorScheme.surface.withOpacity(0.3),
//                 iconSize: 20),
//           ),
//         ),
//         title: _buildBlurredAppBarTitle(context),
//         centerTitle: true,
//         flexibleSpace: ClipRRect(
//           child: BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
//             child: Container(
//               color: msgTheme.inputBackgroundColor.withOpacity(0.7),
//               decoration: BoxDecoration(
//                   border: Border(
//                       bottom: BorderSide(
//                           color: Colors.white.withOpacity(0.1), width: 1))),
//             ),
//           ),
//         ),
//         actions: [
//           IconButton(
//             onPressed: _showChatInfo,
//             icon: Icon(Icons.info_outline_rounded,
//                 color: theme.colorScheme.onSurface),
//           ),
//           const SizedBox(width: 8),
//         ],
//       ),
//       body: GradientBackground(
//         child: GestureDetector(
//           onTap: () {
//             _inputFocusNode.unfocus();
//             MessagingService.setTyping(
//                 chatRoomId: widget.chatRoom.id, isTyping: false);
//           },
//           child: Column(
//             children: [
//               Expanded(
//                 child: StreamBuilder<List<ChatMessage>>(
//                   stream: MessagingService.getChatMessages(widget.chatRoom.id,
//                       limit: 30),
//                   builder: (context, snapshot) {
//                     List<ChatMessage> currentMessages = snapshot.data ?? [];
//                     List<ChatMessage> allMessages = [
//                       ..._olderMessages.reversed,
//                       ...currentMessages
//                     ];
//
//                     if (allMessages.isEmpty) {
//                       return const EmptyStateWidget(
//                         icon: Icons.forum_rounded,
//                         title: 'Start the Conversation!',
//                         message: 'Send the first message in this chat.',
//                       );
//                     }
//
//                     return AnimationLimiter(
//                       child: ListView.builder(
//                         controller: _scrollController,
//                         reverse: true,
//                         padding: const EdgeInsets.only(
//                             left: 12,
//                             right: 12,
//                             top: 120, // Padding for floating app bar
//                             bottom: 16),
//                         itemCount:
//                         allMessages.length + (_isLoadingMore ? 1 : 0),
//                         itemBuilder: (context, index) {
//                           if (_isLoadingMore && index == allMessages.length) {
//                             return const Center(
//                               child: Padding(
//                                 padding:
//                                 EdgeInsets.symmetric(vertical: 16.0),
//                                 child: SizedBox(
//                                     width: 24,
//                                     height: 24,
//                                     child: CircularProgressIndicator(
//                                         strokeWidth: 2)),
//                               ),
//                             );
//                           }
//
//                           final message = allMessages[index];
//                           final bool showTail = index == 0 ||
//                               allMessages[index - 1].senderId !=
//                                   message.senderId;
//
//                           return StaggeredListItem(
//                             index: index, // Use index for stagger
//                             duration: const Duration(milliseconds: 300),
//                             child: MessageBubble(
//                               chatRoom: widget.chatRoom, // Pass chatRoom
//                               message: message,
//                               isMe: message.senderId == _currentUser?.uid,
//                               showTail: showTail,
//                               onLongPress: () =>
//                                   _showMessageOptions(context, message),
//                             ),
//                           );
//                         },
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               ChatInputBar(
//                 focusNode: _inputFocusNode,
//                 controller: _messageController,
//                 onSendPressed: _sendMessage,
//                 onAttachmentPressed: _sendAttachment,
//                 onTextChanged: (text) {
//                   MessagingService.setTyping(
//                     chatRoomId: widget.chatRoom.id,
//                     isTyping: text.isNotEmpty,
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBlurredAppBarTitle(BuildContext context) {
//     final theme = Theme.of(context);
//     // Provide a fallback tag if heroTag is null
//     final String effectiveHeroTag =
//         widget.heroTag ?? 'avatar-${widget.chatRoom.id}';
//
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Hero(
//           tag: effectiveHeroTag, // Use the effective tag
//           child: CircleAvatar(
//             radius: 18,
//             backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
//             child: Icon(
//               widget.chatRoom.type == ChatType.group
//                   ? Icons.group_rounded
//                   : Icons.person_rounded,
//               color: theme.colorScheme.primary,
//               size: 20,
//             ),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Flexible(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 widget.chatRoom.name.isEmpty
//                     ? 'Private Chat'
//                     : widget.chatRoom.name,
//                 style: theme.textTheme.titleMedium?.copyWith(
//                   fontWeight: FontWeight.w600,
//                   color: theme.colorScheme.onSurface,
//                 ),
//                 overflow: TextOverflow.ellipsis,
//               ),
//               StreamBuilder<List<String>>(
//                 stream: MessagingService.typingUsers(widget.chatRoom.id),
//                 builder: (context, snapshot) {
//                   final usersTyping = snapshot.data ?? [];
//                   String subtitle;
//                   if (usersTyping.isNotEmpty) {
//                     subtitle = 'typing...';
//                   } else if (widget.chatRoom.type == ChatType.group) {
//                     subtitle = '${widget.chatRoom.memberIds.length} members';
//                   } else {
//                     subtitle = 'online'; // Placeholder
//                   }
//
//                   return AnimatedSwitcher(
//                     duration: const Duration(milliseconds: 200),
//                     child: Text(
//                       subtitle,
//                       key: ValueKey(subtitle), // Key for animation
//                       style: theme.textTheme.bodySmall?.copyWith(
//                         color: usersTyping.isNotEmpty
//                             ? theme.colorScheme.primary
//                             : theme.colorScheme.onSurface.withOpacity(0.6),
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   void _showChatInfo() {
//     Navigator.push(
//         context,
//         MaterialPageRoute(
//             builder: (_) => ChatInfoPage(chatRoom: widget.chatRoom)));
//   }
// }















import 'dart:ui'; // Import for ImageFilter.blur
import 'dart:math'; // Import for cos, sin functions
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../models/chat_models.dart';
import '../../models/user_profile.dart';
import '../../services/messaging_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/messaging_theme.dart';
// REMOVED GradientBackground import, using themed background now
import '../../widgets/messaging/message_bubble.dart';
import '../../widgets/messaging/chat_input_bar.dart';
import '../../widgets/messaging/empty_state_widget.dart'; // Import EmptyStateWidget
import '../../widgets/animations/staggered_list_item.dart';
import '../../widgets/user_avatar.dart';
import 'chat_info_page.dart';

class ChatRoomPage extends ConsumerStatefulWidget {
  final ChatRoom? chatRoom;
  final UserProfile? targetUser; // For draft mode
  final String? heroTag;

  const ChatRoomPage({
    super.key,
    required this.chatRoom,
    this.heroTag,
  }) : targetUser = null;

  // Draft constructor - chat room will be created on first message
  const ChatRoomPage.draft({
    super.key,
    required this.targetUser,
    this.heroTag,
  }) : chatRoom = null;

  @override
  ConsumerState<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends ConsumerState<ChatRoomPage> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();
  UserProfile? _currentUser;
  bool _isLoadingUser = true;
  ChatRoom? _actualChatRoom; // Will be set after first message in draft mode

  List<ChatMessage> _olderMessages = [];
  bool _isLoadingMore = false;
  bool _canLoadMore = true;
  bool _initialLoadComplete = false;
  double _lastMaxScrollExtent = 0.0;

  // Animation controllers for bubble background
  late AnimationController _floatController;

  bool get _isDraftMode => widget.chatRoom == null && widget.targetUser != null;
  ChatRoom? get _chatRoom => _actualChatRoom ?? widget.chatRoom;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller for bubble background
    _floatController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _loadCurrentUser();
    _scrollController.addListener(_onScroll);
    
    // Only mark as read if we have an actual chat room
    if (_chatRoom != null) {
      MessagingService.markRoomRead(_chatRoom!.id);
    }
    
    // Jump to bottom initially AFTER the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0.0);
      }
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    _messageController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _inputFocusNode.dispose();
    
    // Only set typing to false if we have a chat room
    if (_chatRoom != null) {
      MessagingService.setTyping(chatRoomId: _chatRoom!.id, isTyping: false);
    }
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final user = await AuthService.getCurrentUserProfile();
    if (mounted) setState(() {
      _currentUser = user;
      _isLoadingUser = false;
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300 &&
        !_isLoadingMore &&
        _canLoadMore) {
      // Store the current extent *before* starting the load
      _lastMaxScrollExtent = _scrollController.position.maxScrollExtent;
      _loadOlderMessages();
    }
  }

  Future<void> _loadOlderMessages() async {
    if (!_canLoadMore || _isLoadingMore || _chatRoom == null) return;
    print("Loading older messages...");
    setState(() => _isLoadingMore = true);

    final oldestVisibleMessage = _olderMessages.isNotEmpty
        ? _olderMessages.last
        : (await MessagingService.getChatMessages(_chatRoom!.id, limit: 50).first).lastOrNull;


    if (oldestVisibleMessage == null) {
      print("No oldest message found, cannot load more.");
      if (mounted) setState(() { _isLoadingMore = false; _canLoadMore = false; });
      return;
    }
    final oldestTimestamp = oldestVisibleMessage.createdAt;
    print("Oldest timestamp: $oldestTimestamp");


    try {
      final older = await MessagingService.fetchOlderMessages(
        chatRoomId: _chatRoom!.id,
        before: oldestTimestamp,
        limit: 30,
      );
      print("Fetched ${older.length} older messages.");

      if (mounted) {
        // Calculate potential scroll jump *before* adding items
        final double previousPixels = _scrollController.position.pixels;

        setState(() {
          _olderMessages.addAll(older);
          _isLoadingMore = false;
          _canLoadMore = older.isNotEmpty;
          if (!_initialLoadComplete && older.isNotEmpty) _initialLoadComplete = true;
        });

        // Jump scroll after state update completes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients && older.isNotEmpty) {
            final double newMaxScrollExtent = _scrollController.position.maxScrollExtent;
            // Calculate how much the scroll extent *increased*
            final double scrollIncrement = newMaxScrollExtent - _lastMaxScrollExtent;
            // Only jump if extent actually increased significantly (more than a pixel)
            if (scrollIncrement > 1.0) {
              _scrollController.jumpTo(previousPixels + scrollIncrement);
              print("Jumped scroll by: $scrollIncrement"); // Debug print
            } else {
              print("Scroll increment too small ($scrollIncrement), not jumping."); // Debug print
            }
          } else {
            print("No jump needed (no clients or no older messages fetched)."); // Debug print
          }
        });

      }
    } catch (e) {
      print("Error loading older messages: $e");
      if (mounted) {
        setState(() => _isLoadingMore = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading older messages."), backgroundColor: Colors.red));
      }
    }
  }


  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _currentUser == null) return;

    // Clear input immediately for better UX
    _messageController.clear();

    try {
      // If in draft mode, create the chat room first
      if (_isDraftMode && _actualChatRoom == null) {
        final newChatRoom = await MessagingService.createPrivateChat(widget.targetUser!.uid);
        if (mounted) {
          setState(() {
            _actualChatRoom = newChatRoom;
          });
        }
        // Mark the newly created room as read
        MessagingService.markRoomRead(newChatRoom.id);
      }

      // Send the message
      if (_chatRoom != null) {
        await MessagingService.sendMessage(
          chatRoomId: _chatRoom!.id,
          content: text,
        );
        
        if (mounted) {
          MessagingService.setTyping(chatRoomId: _chatRoom!.id, isTyping: false);
          _inputFocusNode.unfocus();
          
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients && _scrollController.position.pixels > 0) {
              _scrollController.animateTo(0.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutQuad);
            } else if (_scrollController.hasClients) {
              _scrollController.jumpTo(0.0);
            }
          });
        }
      }
    } catch (e) {
      print('Error sending message: $e');
      // Restore the text if sending failed
      if (mounted) {
        _messageController.text = text;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _sendAttachment() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Attachment feature coming soon!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        margin: EdgeInsets.all(12),
      ),
    );
  }

  void _showMessageOptions(BuildContext context, ChatMessage message) {
    final bool canEditOrDelete = message.senderId == _currentUser?.uid;
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Important for blur effect
      builder: (ctx) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: theme.colorScheme.surface.withOpacity(0.8),
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).padding.bottom + 8,
                  top: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40, height: 4, margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2)
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.reply_rounded),
                    title: const Text('Reply'),
                    onTap: () => Navigator.pop(ctx), // TODO: Implement reply
                  ),
                  ListTile(
                    leading: const Icon(Icons.copy_rounded),
                    title: const Text('Copy Text'),
                    onTap: () => Navigator.pop(ctx), // TODO: Implement copy
                  ),
                  if (canEditOrDelete)
                    ListTile(
                      leading: const Icon(Icons.edit_rounded),
                      title: const Text('Edit Message'),
                      onTap: () => Navigator.pop(ctx), // TODO: Implement edit
                    ),
                  if (canEditOrDelete)
                    ListTile(
                      leading: Icon(Icons.delete_outline_rounded,
                          color: theme.colorScheme.error),
                      title: Text('Delete Message',
                          style: TextStyle(color: theme.colorScheme.error)),
                      onTap: () => Navigator.pop(ctx), // TODO: Implement delete confirmation
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Small glass-styled icon button used in header
  Widget _glassIconButton(BuildContext context,
      {required IconData icon, required String tooltip, required VoidCallback onPressed}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.06)),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 20, color: theme.colorScheme.onSurface),
        ),
      ),
    );
  }

  void _showHeaderMenu() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: theme.colorScheme.surface.withOpacity(0.86),
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).padding.bottom + 8, top: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: theme.colorScheme.onSurface.withOpacity(0.18), borderRadius: BorderRadius.circular(2))),
                  ListTile(leading: const Icon(Icons.notifications_none_rounded), title: const Text('Notification settings'), onTap: () => Navigator.pop(ctx)),
                  ListTile(leading: const Icon(Icons.search_rounded), title: const Text('Search in conversation'), onTap: () => Navigator.pop(ctx)),
                  ListTile(leading: const Icon(Icons.block_rounded), title: const Text('Block user'), onTap: () => Navigator.pop(ctx)),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final msgTheme = context.messagingTheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: msgTheme.chatRoomBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(86),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? msgTheme.inputBackgroundColor.withOpacity(0.85)
                    : Colors.white.withOpacity(0.92),
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.onSurface.withOpacity(0.06),
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Back button (minimal)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          child: Icon(Icons.arrow_back_ios_new_rounded,
                              color: theme.colorScheme.onSurface, size: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),

                    // Title + typing/status (includes avatar)
                    Expanded(child: _buildPremiumAppBarTitle(context)),

                    // Actions: call (optional) and overflow menu — glass buttons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _glassIconButton(
                          context,
                          icon: Icons.videocam_outlined,
                          tooltip: 'Start video call',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Video call not implemented')),
                            );
                          },
                        ),
                        const SizedBox(width: 8),  
                        _glassIconButton(
                          context,
                          icon: Icons.more_vert_rounded,
                          tooltip: 'More',
                          onPressed: () => _showHeaderMenu(),
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
      body: Container(
        // Beautiful animated bubble background like MessagingHub
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF0B141A) // Dark mode base color
              : Colors.white, // Light mode clean white
        ),
        child: Stack(
          children: [
            // Animated bubble background
            Positioned.fill(
              child: CustomPaint(
                painter: _ChatRoomBackgroundPainter(
                  animation: _floatController,
                  isDark: isDark,
                ),
              ),
            ),
            // Chat content
            GestureDetector(
              onTap: () {
                _inputFocusNode.unfocus();
                if (_chatRoom != null) {
                  MessagingService.setTyping(
                      chatRoomId: _chatRoom!.id, isTyping: false);
                }
              },
              child: Column(
              children: [
                Expanded(
                  child: _isLoadingUser
                    ? Center(
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
                              'Loading chat...',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      )
                    : _chatRoom == null
                      // Draft mode - no chat room created yet
                      ? const EmptyStateWidget(
                          icon: Icons.forum_rounded,
                          title: 'Start the Conversation!',
                          message: 'Send the first message to create this chat.',
                        )
                      // Normal mode - show messages stream
                      : StreamBuilder<List<ChatMessage>>(
                    stream: MessagingService.getChatMessages(_chatRoom!.id, limit: 50),
                    builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting && _olderMessages.isEmpty && !_initialLoadComplete) {
                    return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
                  }
                  if (snapshot.hasError && _olderMessages.isEmpty) {
                    return Center(child: Text('Error loading messages: ${snapshot.error}', style: TextStyle(color: theme.colorScheme.error)));
                  }

                  List<ChatMessage> currentMessages = snapshot.data ?? [];
                  // Both currentMessages and _olderMessages are in descending order (newest first)
                  // Combine: currentMessages (newest recent) + _olderMessages (older messages)
                  List<ChatMessage> allMessages = [...currentMessages, ..._olderMessages];

                  if (allMessages.isEmpty && snapshot.connectionState != ConnectionState.waiting) {
                    // *** FIX: Removed style parameters ***
                    return const EmptyStateWidget(
                      icon: Icons.forum_rounded,
                      title: 'Start the Conversation!',
                      message: 'Send the first message in this chat.',
                    );
                  }

                  if (!_initialLoadComplete && currentMessages.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _initialLoadComplete = true);
                    });
                  }

                  return AnimationLimiter(
                    child: ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: EdgeInsets.only(
                          left: 12,
                          right: 12,
                          top: MediaQuery.of(context).padding.top + kToolbarHeight + 20,
                          bottom: 16),
                      itemCount: allMessages.length + (_isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (_isLoadingMore && index == allMessages.length) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24.0),
                              child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: theme.colorScheme.primary.withOpacity(0.7),
                                  )),
                            ),
                          );
                        }
                        if (index >= allMessages.length) return const SizedBox.shrink();

                        final message = allMessages[index];
                        // Show sender name/tail when sender changes
                        // List is descending (newest first), reversed ListView shows newest at bottom
                        // Check if previous message in list (index-1) is from different sender
                        final bool showTail = index == 0 || allMessages[index - 1].senderId != message.senderId;
                        final double bottomPadding = showTail && index != 0 ? 8.0 : 0.0;

                        return Padding(
                          padding: EdgeInsets.only(bottom: bottomPadding),
                          child: StaggeredListItem(
                            index: index,
                            duration: const Duration(milliseconds: 300),
                            verticalOffset: 20.0,
                            child: MessageBubble(
                              chatRoom: _chatRoom!,
                              message: message,
                              isMe: message.senderId == _currentUser?.uid,
                              showTail: showTail,
                              onLongPress: () => _showMessageOptions(context, message),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            ChatInputBar(
              focusNode: _inputFocusNode,
              controller: _messageController,
              onSendPressed: _sendMessage,
              onAttachmentPressed: _sendAttachment,
              onTextChanged: (text) {
                if (_chatRoom != null) {
                  MessagingService.setTyping(
                    chatRoomId: _chatRoom!.id,
                    isTyping: text.isNotEmpty,
                  );
                }
              },
            ),
          ],
        ), // Column
      ), // GestureDetector
        ],
      ), // Stack
    ), // Container
    );
  }

  Widget _buildPremiumAppBarTitle(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // In draft mode, use target user info
    if (_isDraftMode && widget.targetUser != null) {
      return GestureDetector(
        onTap: () {
          // Don't navigate to chat info in draft mode
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            UserAvatar(
              user: widget.targetUser,
              size: 44,
              showGradientBorder: true,
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.targetUser!.displayName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'New Chat',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    
    // Normal mode with existing chat room
    if (_chatRoom == null) return const SizedBox();
    
    final String effectiveHeroTag = widget.heroTag ?? 'avatar-${_chatRoom!.id}';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatInfoPage(chatRoom: _chatRoom!),
          ),
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Hero(
            tag: effectiveHeroTag,
          flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
            return DefaultTextStyle(
              style: DefaultTextStyle.of(toHeroContext).style,
              child: toHeroContext.widget,
            );
          },
          child: _chatRoom!.type == ChatType.group
              ? Container(
                  width: 44,
                  height: 44,
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.2),
                        theme.colorScheme.secondary.withOpacity(0.2),
                      ],
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.08) : theme.colorScheme.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.group_rounded,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                )
              : FutureBuilder<UserProfile?>(
                  future: MessagingService.getOtherUserInPrivateChat(_chatRoom!),
                  builder: (context, snapshot) {
                    return UserAvatar(
                      user: snapshot.data,
                      size: 44,
                      showGradientBorder: true,
                    );
                  },
                ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _chatRoom!.type == ChatType.private && _chatRoom!.name.isEmpty
                  ? FutureBuilder<UserProfile?>(
                      future: MessagingService.getOtherUserInPrivateChat(_chatRoom!),
                      builder: (context, snapshot) {
                        final otherUser = snapshot.data;
                        final displayName = otherUser?.displayName ?? 'Chat';
                        return Text(
                          displayName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    )
                  : Text(
                      _chatRoom!.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
              const SizedBox(height: 2),
              StreamBuilder<List<String>>(
                stream: MessagingService.typingUsers(_chatRoom!.id),
                builder: (context, snapshot) {
                  final usersTyping = snapshot.data?.where((id) => id != _currentUser?.uid).toList() ?? [];
                  String subtitle;
                  Color subtitleColor;
                  
                  if (usersTyping.isNotEmpty) {
                    subtitle = usersTyping.length == 1
                        ? 'typing...'
                        : '${usersTyping.length} typing...';
                    subtitleColor = theme.colorScheme.primary;
                  } else if (_chatRoom!.type == ChatType.group) {
                    subtitle = '${_chatRoom!.memberIds.length} members';
                    subtitleColor = theme.colorScheme.onSurface.withOpacity(0.6);
                  } else {
                    subtitle = 'online';
                    subtitleColor = AppTheme.successColor;
                  }

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                    child: Row(
                      key: ValueKey(subtitle),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (usersTyping.isEmpty && _chatRoom?.type != ChatType.group)
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.successColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: subtitleColor,
                            fontWeight: usersTyping.isNotEmpty ? FontWeight.w600 : FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    ),
    );
  }

  void _showChatInfo() {
    if (_chatRoom != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatInfoPage(chatRoom: _chatRoom!),
          )
      );
    }
  }
}

// Animated Bubble Background Painter (like Journal page)
// Beautiful animated bubble background painter for ChatRoomPage
class _ChatRoomBackgroundPainter extends CustomPainter {
  final Animation<double> animation;
  final bool isDark;

  _ChatRoomBackgroundPainter({required this.animation, required this.isDark})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Beautiful bubble colors with enhanced visibility for chat
    final bubbleColors = [
      Colors.blue.withOpacity(isDark ? 0.12 : 0.06),
      Colors.pink.withOpacity(isDark ? 0.12 : 0.06),
      Colors.purple.withOpacity(isDark ? 0.12 : 0.06),
      Colors.green.withOpacity(isDark ? 0.12 : 0.06),
      Colors.orange.withOpacity(isDark ? 0.12 : 0.06),
      Colors.teal.withOpacity(isDark ? 0.12 : 0.06),
    ];

    final animValue = animation.value * 2 * pi; // 0 to 2π

    // Large orbs
    paint.color = bubbleColors[0];
    canvas.drawCircle(
      Offset(
        size.width * 0.15 + sin(animValue * 0.8) * 25,
        size.height * 0.25 + cos(animValue * 0.6) * 20,
      ),
      70,
      paint,
    );

    paint.color = bubbleColors[1];
    canvas.drawCircle(
      Offset(
        size.width * 0.85 + cos(animValue * 0.7) * 30,
        size.height * 0.65 + sin(animValue * 0.5) * 25,
      ),
      85,
      paint,
    );

    paint.color = bubbleColors[2];
    canvas.drawCircle(
      Offset(
        size.width * 0.45 + sin(animValue * 0.9) * 35,
        size.height * 0.85 + cos(animValue * 0.4) * 18,
      ),
      55,
      paint,
    );

    // Medium bubbles positioned for better chat experience
    final mediumPositions = [
      Offset(
        size.width * 0.08 + sin(animValue * 1.1) * 18,
        size.height * 0.45 + cos(animValue * 0.85) * 15,
      ),
      Offset(
        size.width * 0.75 + cos(animValue * 1.2) * 22,
        size.height * 0.2 + sin(animValue * 0.95) * 16,
      ),
      Offset(
        size.width * 0.92 + sin(animValue * 0.75) * 12,
        size.height * 0.8 + cos(animValue * 1.15) * 20,
      ),
      Offset(
        size.width * 0.25 + cos(animValue * 1.3) * 25,
        size.height * 0.1 + sin(animValue * 1.05) * 14,
      ),
      Offset(
        size.width * 0.65 + sin(animValue * 0.65) * 20,
        size.height * 0.95 + cos(animValue * 1.25) * 16,
      ),
      Offset(
        size.width * 0.35 + cos(animValue * 1.4) * 28,
        size.height * 0.55 + sin(animValue * 0.8) * 18,
      ),
    ];

    for (int i = 0; i < mediumPositions.length; i++) {
      paint.color = bubbleColors[(i + 1) % bubbleColors.length];
      canvas.drawCircle(mediumPositions[i], 42.0, paint);
    }

    // Small accent bubbles
    final smallPositions = [
      Offset(
        size.width * 0.05 + cos(animValue * 1.5) * 12,
        size.height * 0.15 + sin(animValue * 1.3) * 10,
      ),
      Offset(
        size.width * 0.95 + sin(animValue * 1.4) * 8,
        size.height * 0.35 + cos(animValue * 1.6) * 15,
      ),
      Offset(
        size.width * 0.18 + cos(animValue * 1.2) * 16,
        size.height * 0.75 + sin(animValue * 1.45) * 12,
      ),
      Offset(
        size.width * 0.82 + sin(animValue * 1.7) * 14,
        size.height * 0.05 + cos(animValue * 1.1) * 9,
      ),
      Offset(
        size.width * 0.55 + cos(animValue * 0.9) * 18,
        size.height * 0.35 + sin(animValue * 1.8) * 11,
      ),
      Offset(
        size.width * 0.02 + sin(animValue * 1.25) * 10,
        size.height * 0.9 + cos(animValue * 1.35) * 13,
      ),
      Offset(
        size.width * 0.98 + cos(animValue * 1.6) * 6,
        size.height * 0.6 + sin(animValue * 1.15) * 17,
      ),
      Offset(
        size.width * 0.4 + sin(animValue * 1.55) * 15,
        size.height * 0.4 + cos(animValue * 1.28) * 11,
      ),
    ];

    for (int i = 0; i < smallPositions.length; i++) {
      paint.color = bubbleColors[(i + 3) % bubbleColors.length];
      canvas.drawCircle(smallPositions[i], 25.0, paint);
    }
  }

  @override
  bool shouldRepaint(_ChatRoomBackgroundPainter oldDelegate) {
    // Only repaint when theme (isDark) changes
    // Animation repaints are handled by super(repaint: animation)
    return isDark != oldDelegate.isDark;
  }
}