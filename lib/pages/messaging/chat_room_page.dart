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
import 'chat_info_page.dart';

class ChatRoomPage extends ConsumerStatefulWidget {
  final ChatRoom chatRoom;
  final String? heroTag; // Made nullable

  const ChatRoomPage({
    super.key,
    required this.chatRoom,
    this.heroTag, // Removed required
  });

  @override
  ConsumerState<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends ConsumerState<ChatRoomPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();
  UserProfile? _currentUser;

  List<ChatMessage> _olderMessages = [];
  bool _isLoadingMore = false;
  bool _canLoadMore = true;
  bool _initialLoadComplete = false;
  double _lastMaxScrollExtent = 0.0; // To track scroll position during older load


  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _scrollController.addListener(_onScroll);
    MessagingService.markRoomRead(widget.chatRoom.id);
    // Jump to bottom initially AFTER the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0.0);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _inputFocusNode.dispose();
    MessagingService.setTyping(chatRoomId: widget.chatRoom.id, isTyping: false);
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final user = await AuthService.getCurrentUserProfile();
    if (mounted) setState(() => _currentUser = user);
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
    if (!_canLoadMore || _isLoadingMore) return;
    print("Loading older messages...");
    setState(() => _isLoadingMore = true);

    final oldestVisibleMessage = _olderMessages.isNotEmpty
        ? _olderMessages.last
        : (await MessagingService.getChatMessages(widget.chatRoom.id, limit: 50).first).lastOrNull;


    if (oldestVisibleMessage == null) {
      print("No oldest message found, cannot load more.");
      if (mounted) setState(() { _isLoadingMore = false; _canLoadMore = false; });
      return;
    }
    final oldestTimestamp = oldestVisibleMessage.createdAt;
    print("Oldest timestamp: $oldestTimestamp");


    try {
      final older = await MessagingService.fetchOlderMessages(
        chatRoomId: widget.chatRoom.id,
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


  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || _currentUser == null) return;
    MessagingService.sendMessage(
        chatRoomId: widget.chatRoom.id, content: text);
    _messageController.clear();
    MessagingService.setTyping(chatRoomId: widget.chatRoom.id, isTyping: false);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final msgTheme = context.messagingTheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: msgTheme.chatRoomBackground, // Apply themed background
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: theme.colorScheme.onSurface.withOpacity(0.9),
                size: 22),
            style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.surface.withOpacity(0.4),
                padding: const EdgeInsets.only(left: 6),
                shape: const CircleBorder(),
                fixedSize: const Size(40,40)
            ),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Back',
          ),
        ),
        leadingWidth: 56,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: _buildBlurredAppBarTitle(context),
        centerTitle: true,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? msgTheme.inputBackgroundColor.withOpacity(0.8)
                      : AppTheme.softBg.withOpacity(0.9),
                  border: Border(
                      bottom: BorderSide(
                          color: theme.brightness == Brightness.dark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.08),
                          width: 1.5))),
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showChatInfo,
            icon: Icon(Icons.info_outline_rounded,
                color: theme.colorScheme.onSurface.withOpacity(0.8)),
            tooltip: 'Chat Info',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          _inputFocusNode.unfocus();
          MessagingService.setTyping(
              chatRoomId: widget.chatRoom.id, isTyping: false);
        },
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<ChatMessage>>(
                stream: MessagingService.getChatMessages(widget.chatRoom.id, limit: 50),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting && _olderMessages.isEmpty && !_initialLoadComplete) {
                    return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
                  }
                  if (snapshot.hasError && _olderMessages.isEmpty) {
                    return Center(child: Text('Error loading messages: ${snapshot.error}', style: TextStyle(color: theme.colorScheme.error)));
                  }

                  List<ChatMessage> currentMessages = snapshot.data ?? [];
                  List<ChatMessage> allMessages = [..._olderMessages.reversed, ...currentMessages];

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
                        final bool showTail = index == 0 || allMessages[index - 1].senderId != message.senderId;
                        final double bottomPadding = showTail && index != 0 ? 8.0 : 0.0;

                        return Padding(
                          padding: EdgeInsets.only(bottom: bottomPadding),
                          child: StaggeredListItem(
                            index: index,
                            duration: const Duration(milliseconds: 300),
                            verticalOffset: 20.0,
                            child: MessageBubble(
                              chatRoom: widget.chatRoom,
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
                MessagingService.setTyping(
                  chatRoomId: widget.chatRoom.id,
                  isTyping: text.isNotEmpty,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlurredAppBarTitle(BuildContext context) {
    final theme = Theme.of(context);
    final String effectiveHeroTag = widget.heroTag ?? 'avatar-${widget.chatRoom.id}';

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Hero(
          tag: effectiveHeroTag,
          // Prevent font size changes during hero transition
          flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
            return DefaultTextStyle(
              style: DefaultTextStyle.of(toHeroContext).style,
              child: toHeroContext.widget,
            );
          },
          child: CircleAvatar(
            radius: 18,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            child: Icon(
              widget.chatRoom.type == ChatType.group
                  ? Icons.group_rounded
                  : Icons.person_rounded,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.chatRoom.name.isEmpty && widget.chatRoom.type != ChatType.group
                    ? 'Chat'
                    : widget.chatRoom.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              StreamBuilder<List<String>>(
                stream: MessagingService.typingUsers(widget.chatRoom.id),
                builder: (context, snapshot) {
                  final usersTyping = snapshot.data?.where((id) => id != _currentUser?.uid).toList() ?? [];
                  String subtitle;
                  if (usersTyping.isNotEmpty) {
                    subtitle = usersTyping.length == 1
                        ? 'typing...'
                        : '${usersTyping.length} typing...';
                  } else if (widget.chatRoom.type == ChatType.group) {
                    subtitle = '${widget.chatRoom.memberIds.length} members';
                  } else {
                    subtitle = 'online'; // TODO: Fetch real status
                  }

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                    child: Text(
                      subtitle,
                      key: ValueKey(subtitle),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: usersTyping.isNotEmpty
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: usersTyping.isNotEmpty ? FontWeight.w600 : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showChatInfo() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatInfoPage(chatRoom: widget.chatRoom),
        )
    );
  }
}