// import 'dart:async'; // For Timer
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
// import '../../models/user_profile.dart';
// import '../../services/messaging_service.dart';
// import '../../theme/messaging_theme.dart';
// import '../../widgets/animations/staggered_list_item.dart';
// import '../../widgets/gradient_background.dart';
// import '../../widgets/messaging/user_profile_tile.dart';
// import '../../widgets/messaging/empty_state_widget.dart';
// import 'chat_room_page.dart'; // For navigation
//
// // Debouncer class
// class Debouncer {
//   final int milliseconds;
//   VoidCallback? action;
//   Timer? _timer;
//
//   Debouncer({required this.milliseconds});
//   run(VoidCallback action) {
//     _timer?.cancel();
//     _timer = Timer(Duration(milliseconds: milliseconds), action);
//   }
// }
//
// class UserSearchPage extends ConsumerStatefulWidget {
//   const UserSearchPage({super.key});
//
//   @override
//   ConsumerState<UserSearchPage> createState() => _UserSearchPageState();
// }
//
// class _UserSearchPageState extends ConsumerState<UserSearchPage> {
//   final _searchController = TextEditingController();
//   final FocusNode _searchFocus = FocusNode();
//   List<UserProfile> _searchResults = [];
//   bool _isSearching = false;
//   String _query = "";
//   final Debouncer _debouncer = Debouncer(milliseconds: 400);
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     _searchFocus.dispose();
//     _debouncer._timer?.cancel();
//     super.dispose();
//   }
//
//   void _searchUsers(String query) {
//     _query = query.trim();
//     if (_query.isEmpty) {
//       if (mounted)
//         setState(() {
//           _searchResults = [];
//           _isSearching = false;
//         });
//       return;
//     }
//     _debouncer.run(() async {
//       if (!mounted) return;
//       setState(() => _isSearching = true);
//       try {
//         final results = await MessagingService.searchUsers(_query);
//         if (mounted && _query == query.trim()) {
//           setState(() => _searchResults = results);
//         }
//       } catch (e) {
//         print("Search error: $e");
//         if (mounted && _query == query.trim()) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//                 content: Text('Error searching: $e'),
//                 backgroundColor: Colors.red),
//           );
//         }
//       } finally {
//         if (mounted && _query == query.trim()) {
//           setState(() => _isSearching = false);
//         }
//       }
//     });
//   }
//
//   void _startChat(UserProfile targetUser) async {
//     Navigator.pop(context); // Close search page first
//     try {
//       final chatRoom = await MessagingService.createPrivateChat(targetUser.uid);
//
//       // Navigate to the chat room page, passing a null heroTag
//       Navigator.of(context, rootNavigator: true).push(
//         MaterialPageRoute(
//           builder: (context) => ChatRoomPage(
//             chatRoom: chatRoom,
//             heroTag: null, // Pass null, ChatRoomPage will handle it
//           ),
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//             content: Text('Failed to start chat: $e'),
//             backgroundColor: Colors.red),
//       );
//     }
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
//         backgroundColor: msgTheme.inputBackgroundColor.withOpacity(0.8),
//         elevation: 0,
//         title: TextField(
//           controller: _searchController,
//           focusNode: _searchFocus,
//           autofocus: true,
//           decoration: InputDecoration(
//             hintText: 'Search by name...',
//             border: InputBorder.none,
//             hintStyle: TextStyle(color: msgTheme.inputHintColor),
//           ),
//           style: TextStyle(color: msgTheme.inputTextColor),
//           onChanged: _searchUsers,
//           textInputAction: TextInputAction.search,
//         ),
//         actions: [
//           if (_query.isNotEmpty)
//             IconButton(
//               icon: Icon(Icons.clear, color: msgTheme.inputHintColor),
//               onPressed: () {
//                 _searchController.clear();
//                 _searchFocus.unfocus();
//                 setState(() {
//                   _searchResults = [];
//                   _isSearching = false;
//                   _query = '';
//                 });
//               },
//             ),
//           const SizedBox(width: 8),
//         ],
//       ),
//       body: GradientBackground(
//         child: SafeArea(
//           bottom: false,
//           child: _isSearching
//               ? const Center(child: CircularProgressIndicator(color: Colors.white))
//               : _searchResults.isEmpty && _query.isNotEmpty
//               ? const EmptyStateWidget(
//             icon: Icons.search_off_rounded,
//             title: 'No Users Found',
//             message: 'Try searching with a different name or check spelling.',
//           )
//               : _searchResults.isEmpty && _query.isEmpty
//               ? const EmptyStateWidget(
//             icon: Icons.search_rounded,
//             title: 'Search for Users',
//             message: 'Find students and mentors to connect with.',
//           )
//               : AnimationLimiter(
//             child: ListView.builder(
//               padding: const EdgeInsets.symmetric(
//                   horizontal: 12, vertical: 8),
//               itemCount: _searchResults.length,
//               itemBuilder: (context, index) {
//                 final user = _searchResults[index];
//                 return StaggeredListItem(
//                   index: index,
//                   child: UserProfileTile(
//                     user: user,
//                     trailing: ElevatedButton(
//                       onPressed: () => _startChat(user),
//                       style: ElevatedButton.styleFrom(
//                         minimumSize: const Size(80, 36),
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 12),
//                       ),
//                       child: const Text('Chat'),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }














// import 'dart:async'; // For Timer
// import 'dart:ui'; // For blur
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
// import '../../models/user_profile.dart';
// import '../../services/messaging_service.dart';
// import '../../services/auth_service.dart'; // <-- *** FIX: Added missing import ***
// import '../../theme/messaging_theme.dart';
// import '../../theme/app_theme.dart'; // Import AppTheme
// import '../../widgets/animations/staggered_list_item.dart';
// import '../../widgets/gradient_background.dart';
// import '../../widgets/messaging/user_profile_tile.dart';
// import '../../widgets/messaging/empty_state_widget.dart'; // Import EmptyStateWidget
// import 'chat_room_page.dart';
//
// // Debouncer class
// class Debouncer {
//   final int milliseconds; VoidCallback? action; Timer? _timer;
//   Debouncer({required this.milliseconds});
//   run(VoidCallback action) { _timer?.cancel(); _timer = Timer(Duration(milliseconds: milliseconds), action); }
// }
//
// class UserSearchPage extends ConsumerStatefulWidget {
//   final bool isAddingMembers;
//   final String? chatRoomId;
//
//   const UserSearchPage({
//     super.key,
//     this.isAddingMembers = false,
//     this.chatRoomId,
//   }) : assert(isAddingMembers == false || chatRoomId != null);
//
//   @override
//   ConsumerState<UserSearchPage> createState() => _UserSearchPageState();
// }
//
// class _UserSearchPageState extends ConsumerState<UserSearchPage> {
//   final _searchController = TextEditingController();
//   final FocusNode _searchFocus = FocusNode();
//   List<UserProfile> _searchResults = [];
//   bool _isSearching = false;
//   String _query = "";
//   final Debouncer _debouncer = Debouncer(milliseconds: 400);
//   final Set<String> _addingMemberIds = {};
//
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     _searchFocus.dispose();
//     _debouncer._timer?.cancel();
//     super.dispose();
//   }
//
//   void _searchUsers(String query) {
//     _query = query.trim();
//     if (_query.isEmpty) {
//       if (mounted) setState(() { _searchResults = []; _isSearching = false; });
//       return;
//     }
//     _debouncer.run(() async {
//       if (!mounted) return;
//       setState(() => _isSearching = true);
//       try {
//         final results = await MessagingService.searchUsers(_query);
//         final currentUser = await AuthService.getCurrentUserProfile(); // Use AuthService here
//         if (mounted && _query == query.trim()) {
//           setState(() => _searchResults = results.where((user) {
//             if (user.uid == currentUser?.uid) return false;
//             // Add more filtering if needed for adding members
//             return true;
//           }).toList());
//         }
//       } catch (e) {
//         print("Search error: $e");
//         if (mounted && _query == query.trim()) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Error searching: $e'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
//           );
//         }
//       } finally {
//         if (mounted && _query == query.trim()) {
//           setState(() => _isSearching = false);
//         }
//       }
//     });
//   }
//
//   Future<void> _handleUserTap(UserProfile user) async {
//     if (widget.isAddingMembers) {
//       await _addMember(user);
//     } else {
//       await _startChat(user);
//     }
//   }
//
//
//   Future<void> _startChat(UserProfile targetUser) async {
//     try {
//       final chatRoom = await MessagingService.createPrivateChat(targetUser.uid);
//       if (!mounted) return;
//       Navigator.pop(context);
//       Navigator.of(context, rootNavigator: true).push(
//         MaterialPageRoute(
//           builder: (context) => ChatRoomPage(
//             chatRoom: chatRoom,
//             heroTag: null,
//           ),
//         ),
//       );
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to start chat: $e'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
//       );
//     }
//   }
//
//   Future<void> _addMember(UserProfile userToAdd) async {
//     if (_addingMemberIds.contains(userToAdd.uid)) return;
//     setState(() => _addingMemberIds.add(userToAdd.uid));
//     final scaffoldMessenger = ScaffoldMessenger.of(context);
//
//     try {
//       await MessagingService.addMemberToGroup(widget.chatRoomId!, userToAdd.uid);
//       scaffoldMessenger.showSnackBar(
//         SnackBar(
//             content: Text('${userToAdd.displayName} added to group.'),
//             backgroundColor: AppTheme.successColor,
//             behavior: SnackBarBehavior.floating
//         ),
//       );
//       if (mounted) {
//         setState(() { _searchResults.removeWhere((user) => user.uid == userToAdd.uid); });
//       }
//     } catch (e) {
//       print("Error adding member: $e");
//       scaffoldMessenger.showSnackBar(
//         SnackBar(
//             content: Text('Failed to add ${userToAdd.displayName}: $e'),
//             backgroundColor: AppTheme.errorColor,
//             behavior: SnackBarBehavior.floating
//         ),
//       );
//     } finally {
//       if (mounted) {
//         setState(() => _addingMemberIds.remove(userToAdd.uid));
//       }
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final msgTheme = context.messagingTheme;
//     final appBarForegroundColor = theme.brightness == Brightness.dark ? Colors.white : theme.colorScheme.onSurface;
//
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       backgroundColor: Colors.transparent,
//       appBar: AppBar(
//         iconTheme: IconThemeData(color: appBarForegroundColor),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         flexibleSpace: ClipRRect(
//           child: BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
//             child: Container(
//               decoration: BoxDecoration(
//                   color: theme.brightness == Brightness.dark
//                       ? msgTheme.inputBackgroundColor.withOpacity(0.75)
//                       : AppTheme.softBg.withOpacity(0.85),
//                   border: Border(bottom: BorderSide(
//                       color: theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08),
//                       width: 1))
//               ),
//             ),
//           ),
//         ),
//         title: TextField(
//           controller: _searchController,
//           focusNode: _searchFocus,
//           autofocus: true,
//           decoration: InputDecoration(
//             hintText: widget.isAddingMembers ? 'Search users to add...' : 'Search by name...',
//             border: InputBorder.none,
//             hintStyle: TextStyle(color: appBarForegroundColor.withOpacity(0.6)),
//           ),
//           style: TextStyle(color: appBarForegroundColor),
//           onChanged: _searchUsers,
//           textInputAction: TextInputAction.search,
//         ),
//         actions: [
//           if (_query.isNotEmpty)
//             IconButton(
//               icon: Icon(Icons.clear, color: appBarForegroundColor.withOpacity(0.7)),
//               onPressed: () {
//                 _searchController.clear();
//                 _searchFocus.unfocus();
//                 setState(() { _searchResults = []; _isSearching = false; _query = ''; });
//               },
//             ),
//           const SizedBox(width: 8),
//         ],
//       ),
//       body: GradientBackground(
//         child: SafeArea(
//           bottom: false,
//           child: Column(
//             children: [
//               Flexible(
//                 child: _isSearching
//                     ? const Center(child: CircularProgressIndicator(color: Colors.white))
//                     : _searchResults.isEmpty && _query.isNotEmpty
//                     ? Center(child: EmptyStateWidget(
//                   icon: Icons.search_off_rounded,
//                   title: 'No Users Found',
//                   message: 'Try searching with a different name or check spelling.',
//                   // *** FIX: Removed style parameters ***
//                   // titleStyle: TextStyle(color: Colors.white70.withOpacity(0.9), fontSize: 20, fontWeight: FontWeight.w600),
//                   // messageStyle: TextStyle(color: Colors.white70, fontSize: 16),
//                 ))
//                     : _searchResults.isEmpty && _query.isEmpty
//                     ? Center(child: EmptyStateWidget(
//                   icon: Icons.search_rounded,
//                   title: widget.isAddingMembers ? 'Search Users to Add' : 'Search for Users',
//                   message: widget.isAddingMembers ? 'Find users to add to the group.' : 'Find students and mentors to connect with.',
//                   // *** FIX: Removed style parameters ***
//                   // titleStyle: TextStyle(color: Colors.white70.withOpacity(0.9), fontSize: 20, fontWeight: FontWeight.w600),
//                   // messageStyle: TextStyle(color: Colors.white70, fontSize: 16),
//                 ))
//                     : AnimationLimiter(
//                   child: ListView.builder(
//                     padding: const EdgeInsets.only(left: 12, right: 12, top: 16, bottom: 16),
//                     itemCount: _searchResults.length,
//                     itemBuilder: (context, index) {
//                       final user = _searchResults[index];
//                       final bool isBeingAdded = _addingMemberIds.contains(user.uid);
//                       final buttonText = widget.isAddingMembers ? 'Add' : 'Chat';
//                       final buttonIcon = widget.isAddingMembers ? Icons.add_circle_outline_rounded : Icons.chat_bubble_outline_rounded;
//
//                       return StaggeredListItem(
//                         index: index,
//                         child: UserProfileTile(
//                           user: user,
//                           trailing: ElevatedButton.icon(
//                             icon: isBeingAdded
//                                 ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
//                                 : Icon(buttonIcon, size: 18),
//                             label: Text(buttonText),
//                             onPressed: isBeingAdded ? null : () => _handleUserTap(user),
//                             style: ElevatedButton.styleFrom(
//                               minimumSize: const Size(80, 36),
//                               padding: const EdgeInsets.symmetric(horizontal: 12),
//                               backgroundColor: theme.colorScheme.primary,
//                               foregroundColor: Colors.white,
//                             ),
//                           ),
//                           onTap: isBeingAdded ? null : () => _handleUserTap(user),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
















import 'dart:async'; // For Timer
import 'dart:ui'; // For blur
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../models/user_profile.dart';
import '../../services/messaging_service.dart';
import '../../services/auth_service.dart'; // <-- *** FIX: Added missing import ***
import '../../theme/messaging_theme.dart';
import '../../theme/app_theme.dart'; // Import AppTheme
import '../../widgets/animations/staggered_list_item.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/messaging/user_profile_tile.dart';
import '../../widgets/messaging/empty_state_widget.dart'; // Import EmptyStateWidget
import 'chat_room_page.dart';

// Debouncer class
class Debouncer {
  final int milliseconds; VoidCallback? action; Timer? _timer;
  Debouncer({required this.milliseconds});
  run(VoidCallback action) { _timer?.cancel(); _timer = Timer(Duration(milliseconds: milliseconds), action); }
}

class UserSearchPage extends ConsumerStatefulWidget {
  // *** FIX: Removed isAddingMembers and chatRoomId parameters ***
  const UserSearchPage({ super.key });

  @override
  ConsumerState<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends ConsumerState<UserSearchPage> {
  final _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  List<UserProfile> _searchResults = [];
  List<UserProfile> _allUsers = []; // All users loaded initially
  bool _isSearching = false;
  bool _isLoadingUsers = true; // Loading state for initial users
  String _query = "";
  final Debouncer _debouncer = Debouncer(milliseconds: 400);
  UserProfile? _currentUser; // Current user reference

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadAllUsers();
  }

  Future<void> _loadCurrentUser() async {
    final user = await AuthService.getCurrentUserProfile();
    if (mounted) setState(() => _currentUser = user);
  }

  Future<void> _loadAllUsers() async {
    try {
      setState(() => _isLoadingUsers = true);
      final users = await MessagingService.searchUsers(''); // Empty search returns all
      if (mounted) {
        final currentUser = await AuthService.getCurrentUserProfile();
        setState(() {
          _allUsers = users.where((u) => u.uid != currentUser?.uid).toList();
          _isLoadingUsers = false;
        });
      }
    } catch (e) {
      print("Error loading users: $e");
      if (mounted) setState(() => _isLoadingUsers = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _debouncer._timer?.cancel();
    super.dispose();
  }

  void _searchUsers(String query) {
    _query = query.trim();
    if (_query.isEmpty) {
      if (mounted) setState(() { _searchResults = []; _isSearching = false; });
      return;
    }
    _debouncer.run(() async {
      if (!mounted) return;
      setState(() => _isSearching = true);
      try {
        final results = await MessagingService.searchUsers(_query);
        final currentUser = await AuthService.getCurrentUserProfile(); // Use AuthService here
        if (mounted && _query == query.trim()) {
          // Exclude self from search results
          setState(() => _searchResults = results.where((user) => user.uid != currentUser?.uid).toList());
        }
      } catch (e) {
        print("Search error: $e");
        if (mounted && _query == query.trim()) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error searching: $e'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
          );
        }
      } finally {
        if (mounted && _query == query.trim()) {
          setState(() => _isSearching = false);
        }
      }
    });
  }

  // *** FIX: Renamed _handleUserTap back to _startChat and removed add member logic ***
  Future<void> _startChat(UserProfile targetUser) async {
    // Optionally show a loading indicator
    // final scaffoldMessenger = ScaffoldMessenger.of(context); // Store for async use if needed

    try {
      final chatRoom = await MessagingService.createPrivateChat(targetUser.uid);
      if (!mounted) return;

      Navigator.pop(context); // Pop search page first
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => ChatRoomPage(
            chatRoom: chatRoom,
            heroTag: null, // No specific hero from search results page
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start chat: $e'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
      );
    }
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
        preferredSize: const Size.fromHeight(70),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        onPressed: () => Navigator.pop(context),
                        color: theme.colorScheme.onSurface,
                      ),
                      Expanded(
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: isDark
                                ? theme.colorScheme.surface.withOpacity(0.4)
                                : theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: theme.colorScheme.onSurface.withOpacity(0.08),
                            ),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 16),
                              Icon(
                                Icons.search_rounded,
                                color: theme.colorScheme.onSurface.withOpacity(0.5),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  focusNode: _searchFocus,
                                  autofocus: true,
                                  style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15),
                                  decoration: InputDecoration(
                                    hintText: 'Search by name...',
                                    hintStyle: TextStyle(
                                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                                      fontSize: 15,
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 11),
                                    filled: false,
                                  ),
                                  onChanged: _searchUsers,
                                  textInputAction: TextInputAction.search,
                                ),
                              ),
                              if (_query.isNotEmpty)
                                IconButton(
                                  icon: Icon(Icons.clear_rounded, size: 20),
                                  onPressed: () {
                                    _searchController.clear();
                                    _searchFocus.unfocus();
                                    setState(() {
                                      _searchResults = [];
                                      _isSearching = false;
                                      _query = '';
                                    });
                                  },
                                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                                ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: _isLoadingUsers
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(color: AppTheme.primaryColor),
                ),
              )
            : _isSearching
                ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
                : _buildUserList(theme),
      ),
    );
  }

  Widget _buildUserList(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    
    // Get the list to display (search results or all users)
    final usersToDisplay = _query.isNotEmpty ? _searchResults : _allUsers;

    if (usersToDisplay.isEmpty && _query.isNotEmpty) {
      return const Center(
        child: EmptyStateWidget(
          icon: Icons.search_off_rounded,
          title: 'No Users Found',
          message: 'Try searching with a different name or check spelling.',
        ),
      );
    }

    if (usersToDisplay.isEmpty && _query.isEmpty) {
      return const Center(
        child: EmptyStateWidget(
          icon: Icons.people_outline_rounded,
          title: 'No Users Available',
          message: 'There are no users to display at the moment.',
        ),
      );
    }

    // Section users by role
    final students = usersToDisplay.where((u) => u.role == UserRole.student).toList();
    final mentors = usersToDisplay.where((u) => u.role == UserRole.mentor).toList();

    return ListView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 24),
      children: [
        // Students Section
        if (students.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4.0, top: 0, bottom: 12.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor.withOpacity(0.2),
                        AppTheme.secondaryColor.withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    size: 16,
                    color: isDark ? Colors.white : Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Students',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${students.length}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AnimationLimiter(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final user = students[index];
                return StaggeredListItem(
                  index: index,
                  child: _UserSearchTile(
                    user: user,
                    onChatTap: () => _startChat(user),
                  ),
                );
              },
            ),
          ),
        ],

        // Mentors Section
        if (mentors.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4.0, top: 16, bottom: 12.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.withOpacity(0.2),
                        Colors.deepOrange.withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.volunteer_activism_rounded,
                    size: 16,
                    color: isDark ? Colors.orange.shade300 : Colors.orange,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Mentors',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${mentors.length}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AnimationLimiter(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: mentors.length,
              itemBuilder: (context, index) {
                final user = mentors[index];
                return StaggeredListItem(
                  index: index,
                  child: _UserSearchTile(
                    user: user,
                    onChatTap: () => _startChat(user),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

// Premium user tile for search results
class _UserSearchTile extends StatelessWidget {
  final UserProfile user;
  final VoidCallback onChatTap;

  const _UserSearchTile({
    required this.user,
    required this.onChatTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onChatTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.surface.withOpacity(0.5)
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: theme.colorScheme.onSurface.withOpacity(0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar with gradient ring
                Container(
                  width: 50,
                  height: 50,
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.25),
                        theme.colorScheme.secondary.withOpacity(0.25),
                      ],
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? theme.colorScheme.surface : Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.person_rounded,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (user.school.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          user.school,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Chat button
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onChatTap,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.chat_bubble_outline_rounded, size: 16, color: Colors.white),
                            SizedBox(width: 6),
                            Text(
                              'Chat',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
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