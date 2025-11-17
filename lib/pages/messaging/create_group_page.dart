// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
// import '../../models/user_profile.dart';
// import '../../services/messaging_service.dart';
// import '../../theme/app_theme.dart';
// import '../../theme/messaging_theme.dart';
// import '../../widgets/animations/staggered_list_item.dart';
// import '../../widgets/gradient_background.dart';
// import '../../widgets/gradient_card.dart';
// import '../../widgets/messaging/user_profile_tile.dart';
//
// // Debouncer class
// class Debouncer {
//   final int milliseconds;
//   VoidCallback? action;
//   Timer? _timer;
//
//   Debouncer({required this.milliseconds});
//
//   run(VoidCallback action) {
//     _timer?.cancel();
//     _timer = Timer(Duration(milliseconds: milliseconds), action);
//   }
// }
//
// class CreateGroupPage extends ConsumerStatefulWidget {
//   const CreateGroupPage({super.key});
//
//   @override
//   ConsumerState<CreateGroupPage> createState() => _CreateGroupPageState();
// }
//
// class _CreateGroupPageState extends ConsumerState<CreateGroupPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _searchController = TextEditingController();
//   final FocusNode _searchFocusNode = FocusNode();
//
//   bool _loading = false;
//   bool _isPrivate = false;
//   final List<UserProfile> _selectedMembers = [];
//   List<UserProfile> _searchResults = [];
//   bool _isSearching = false;
//   String _searchQuery = '';
//   final Debouncer _debouncer = Debouncer(milliseconds: 400);
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _descriptionController.dispose();
//     _searchController.dispose();
//     _searchFocusNode.dispose();
//     _debouncer._timer?.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final msgTheme = context.messagingTheme;
//
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       backgroundColor: Colors.transparent, // Use gradient background
//       appBar: AppBar(
//         title: const Text('Create New Group'),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         foregroundColor: Colors.white, // White text on gradient
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 8.0),
//             child: ElevatedButton(
//               onPressed: _loading ? null : _createGroup,
//               style: ElevatedButton.styleFrom(
//                 minimumSize: const Size(80, 36),
//               ),
//               child: _loading
//                   ? const SizedBox(
//                   width: 16,
//                   height: 16,
//                   child: CircularProgressIndicator(
//                       strokeWidth: 2, color: Colors.white))
//                   : const Text('Create'),
//             ),
//           ),
//         ],
//       ),
//       body: GradientBackground(
//         child: SafeArea(
//           child: Form(
//             key: _formKey,
//             child: ListView(
//               padding: const EdgeInsets.all(16.0),
//               children: [
//                 // Group Icon Placeholder
//                 Center(
//                   child: CircleAvatar(
//                     radius: 40,
//                     backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
//                     child: Icon(
//                       Icons.group_add_rounded,
//                       size: 40,
//                       color: theme.colorScheme.primary,
//                     ),
//                     // TODO: Add image picker functionality here
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//
//                 // Group Name
//                 TextFormField(
//                   controller: _nameController,
//                   decoration: const InputDecoration(
//                     labelText: 'Group Name *',
//                     hintText: 'Enter a name for your group',
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.all(Radius.circular(12))),
//                     prefixIcon: Icon(Icons.title),
//                   ),
//                   validator: (value) => (value == null || value.trim().isEmpty)
//                       ? 'Group name is required'
//                       : null,
//                   textCapitalization: TextCapitalization.sentences,
//                 ),
//                 const SizedBox(height: 16),
//
//                 // Description
//                 TextFormField(
//                   controller: _descriptionController,
//                   decoration: const InputDecoration(
//                     labelText: 'Description (Optional)',
//                     hintText: 'What is this group about?',
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.all(Radius.circular(12))),
//                     prefixIcon: Icon(Icons.description_outlined),
//                   ),
//                   maxLines: 3,
//                   textCapitalization: TextCapitalization.sentences,
//                 ),
//                 const SizedBox(height: 16),
//
//                 // Privacy Setting
//                 GradientCard(
//                   padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
//                   child: SwitchListTile(
//                     title: Text('Private Group',
//                         style: theme.textTheme.titleMedium
//                             ?.copyWith(fontWeight: FontWeight.w600)),
//                     subtitle: Text('Only invited members can join',
//                         style: theme.textTheme.bodySmall?.copyWith(
//                             color:
//                             theme.colorScheme.onSurface.withOpacity(0.6))),
//                     value: _isPrivate,
//                     onChanged: (value) => setState(() => _isPrivate = value),
//                     secondary: Icon(_isPrivate
//                         ? Icons.lock_outline_rounded
//                         : Icons.lock_open_rounded),
//                     contentPadding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12)),
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//
//                 // --- Add Members Section ---
//                 Text(
//                   'Add Members',
//                   style: theme.textTheme.titleMedium
//                       ?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
//                 ),
//                 const SizedBox(height: 8),
//
//                 // Search Bar
//                 TextField(
//                   controller: _searchController,
//                   focusNode: _searchFocusNode,
//                   decoration: InputDecoration(
//                     hintText: 'Search students to add...',
//                     prefixIcon: const Icon(Icons.search),
//                     border: const OutlineInputBorder(
//                         borderRadius: BorderRadius.all(Radius.circular(12))),
//                     enabledBorder: OutlineInputBorder(
//                         borderSide: BorderSide(color: msgTheme.dividerColor),
//                         borderRadius:
//                         const BorderRadius.all(Radius.circular(12))),
//                     focusedBorder: OutlineInputBorder(
//                         borderSide: BorderSide(color: theme.colorScheme.primary),
//                         borderRadius:
//                         const BorderRadius.all(Radius.circular(12))),
//                     filled: true,
//                     fillColor: msgTheme.inputBackgroundColor,
//                     isDense: true,
//                     suffixIcon: _searchQuery.isNotEmpty
//                         ? IconButton(
//                       icon: const Icon(Icons.clear),
//                       onPressed: () {
//                         _searchController.clear();
//                         _searchFocusNode.unfocus();
//                         setState(() {
//                           _searchResults = [];
//                           _isSearching = false;
//                           _searchQuery = '';
//                         });
//                       },
//                     )
//                         : null,
//                   ),
//                   onChanged: (query) {
//                     setState(() => _searchQuery = query);
//                     _searchUsers(query);
//                   },
//                   textInputAction: TextInputAction.search,
//                 ),
//                 const SizedBox(height: 8),
//
//                 // Selected Members Horizontal List
//                 if (_selectedMembers.isNotEmpty)
//                   Container(
//                     margin: const EdgeInsets.only(bottom: 8),
//                     height: 85,
//                     child: ListView.builder(
//                       scrollDirection: Axis.horizontal,
//                       itemCount: _selectedMembers.length,
//                       itemBuilder: (context, index) {
//                         final member = _selectedMembers[index];
//                         return Padding(
//                           padding: const EdgeInsets.only(right: 8.0),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Stack(
//                                 clipBehavior: Clip.none,
//                                 children: [
//                                   CircleAvatar(
//                                     radius: 24,
//                                     backgroundColor: theme
//                                         .colorScheme.primary
//                                         .withOpacity(0.1),
//                                     child: Icon(Icons.person_rounded,
//                                         color: theme.colorScheme.primary),
//                                   ),
//                                   Positioned(
//                                     top: -4,
//                                     right: -4,
//                                     child: GestureDetector(
//                                       onTap: () =>
//                                           _toggleMemberSelection(member),
//                                       child: Container(
//                                         padding: const EdgeInsets.all(2),
//                                         decoration: BoxDecoration(
//                                           color: Colors.grey[700],
//                                           shape: BoxShape.circle,
//                                         ),
//                                         child: const Icon(Icons.close_rounded,
//                                             size: 14, color: Colors.white),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 4),
//                               SizedBox(
//                                 width: 60,
//                                 child: Text(
//                                   member.displayName,
//                                   style: theme.textTheme.bodySmall
//                                       ?.copyWith(color: Colors.white70),
//                                   textAlign: TextAlign.center,
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//
//                 // Search Results or Loading/Empty State
//                 AnimatedContainer(
//                   duration: const Duration(milliseconds: 300),
//                   constraints: BoxConstraints(
//                     maxHeight: _searchResults.isEmpty && !_isSearching
//                         ? 60
//                         : 200,
//                   ),
//                   child: _isSearching
//                       ? const Center(
//                       child: Padding(
//                           padding: EdgeInsets.all(16.0),
//                           child: CircularProgressIndicator()))
//                       : _searchResults.isEmpty && _searchQuery.isNotEmpty
//                       ? Center(
//                       child: Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: Text(
//                               'No students found matching "$_searchQuery".',
//                               style: TextStyle(
//                                   color: theme.colorScheme.onSurface
//                                       .withOpacity(0.6)))))
//                       : AnimationLimiter(
//                     child: ListView.builder(
//                       shrinkWrap: true,
//                       itemCount: _searchResults.length,
//                       itemBuilder: (context, index) {
//                         final user = _searchResults[index];
//                         final isSelected = _selectedMembers
//                             .any((m) => m.uid == user.uid);
//                         return StaggeredListItem(
//                           index: index,
//                           child: UserProfileTile(
//                             user: user,
//                             trailing: Checkbox(
//                               value: isSelected,
//                               onChanged: (_) =>
//                                   _toggleMemberSelection(user),
//                               shape: const CircleBorder(),
//                               activeColor: theme.colorScheme.primary,
//                             ),
//                             onTap: () =>
//                                 _toggleMemberSelection(user),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 30),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _searchUsers(String query) {
//     _debouncer.run(() async {
//       if (!mounted) return;
//       final currentQuery = query.trim();
//       if (currentQuery.isEmpty) {
//         setState(() {
//           _searchResults = [];
//           _isSearching = false;
//         });
//         return;
//       }
//       setState(() => _isSearching = true);
//       try {
//         final results = await MessagingService.searchUsers(currentQuery);
//         if (!mounted) return;
//         if (currentQuery == _searchQuery) {
//           setState(() {
//             _searchResults = results
//                 .where((user) =>
//             user.role == UserRole.student &&
//                 !_selectedMembers.any((m) => m.uid == user.uid))
//                 .toList();
//           });
//         }
//       } catch (e) {
//         print("Search error: $e");
//       } finally {
//         if (mounted && currentQuery == _searchQuery) {
//           setState(() => _isSearching = false);
//         }
//       }
//     });
//   }
//
//   void _toggleMemberSelection(UserProfile user) {
//     setState(() {
//       final index = _selectedMembers.indexWhere((m) => m.uid == user.uid);
//       if (index >= 0) {
//         _selectedMembers.removeAt(index);
//       } else {
//         _selectedMembers.add(user);
//       }
//       if (_searchQuery.isNotEmpty) {
//         _searchUsers(_searchQuery);
//       }
//     });
//   }
//
//   Future<void> _createGroup() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (_selectedMembers.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text('Please add at least one member.'),
//             backgroundColor: Colors.orange),
//       );
//       return;
//     }
//
//     setState(() => _loading = true);
//     try {
//       await MessagingService.createGroupChat(
//         name: _nameController.text.trim(),
//         description: _descriptionController.text.trim(),
//         memberIds: _selectedMembers.map((m) => m.uid).toList(),
//         isPrivate: _isPrivate,
//       );
//
//       if (mounted) {
//         Navigator.pop(context);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//               content: Text('Group created successfully!'),
//               backgroundColor: Colors.green),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content: Text('Failed to create group: $e'),
//               backgroundColor: Colors.red),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _loading = false);
//     }
//   }
// }







import 'dart:async';
import 'dart:ui'; // For blur
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../models/user_profile.dart';
import '../../services/messaging_service.dart';
import '../../services/auth_service.dart'; // <-- *** ADD THIS IMPORT ***
import '../../theme/app_theme.dart';
import '../../theme/messaging_theme.dart';
import '../../widgets/animations/staggered_list_item.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/gradient_card.dart';
import '../../widgets/messaging/user_profile_tile.dart';

// Debouncer class
class Debouncer {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

class CreateGroupPage extends ConsumerStatefulWidget {
  const CreateGroupPage({super.key});

  @override
  ConsumerState<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends ConsumerState<CreateGroupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  bool _loading = false;
  bool _isPrivate = false;
  final List<UserProfile> _selectedMembers = [];
  List<UserProfile> _searchResults = [];
  List<UserProfile> _allUsers = []; // All users loaded initially
  bool _isSearching = false;
  bool _isLoadingUsers = true; // Loading state for initial users
  String _searchQuery = '';
  final Debouncer _debouncer = Debouncer(milliseconds: 400);
  UserProfile? _currentUser; // Added for loading current user

  @override
  void initState() {
    super.initState();
    _loadCurrentUser(); // Load current user info
    _loadAllUsers(); // Load all users on init
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
        setState(() {
          _allUsers = users.where((u) => u.uid != _currentUser?.uid).toList();
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
    _nameController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debouncer._timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final msgTheme = context.messagingTheme;
    final isDark = theme.brightness == Brightness.dark;

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
                            // Title & Subtitle
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Create New Group',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Add members and customize',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? Colors.white.withOpacity(0.6)
                                          : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Create Button
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
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _loading || _currentUser == null ? null : _createGroup,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    child: _loading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text(
                                            'Create',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
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
                ),
              ),
              
              // Scrollable Content
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      // Group Icon with Gradient Ring
                      Center(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            // Gradient Ring
                            Container(
                              padding: const EdgeInsets.all(2.5),
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
                                  radius: 42,
                                  backgroundColor: theme.colorScheme.surface.withOpacity(0.3),
                                  child: Icon(
                                    Icons.group_add_rounded,
                                    size: 42,
                                    color: isDark
                                        ? Colors.white.withOpacity(0.8)
                                        : Colors.black54,
                                  ),
                                ),
                              ),
                            ),
                            // Add Photo Button
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.primaryColor,
                                      AppTheme.secondaryColor,
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryColor.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.add_a_photo_rounded, size: 18),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Image picker coming soon')),
                                    );
                                  },
                                  color: Colors.white,
                                  padding: const EdgeInsets.all(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Premium Form Card
                      Container(
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
                          children: [
                            // Group Name
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Group Name *',
                                hintText: 'Enter a name for your group',
                                prefixIcon: Icon(
                                  Icons.title,
                                  color: AppTheme.primaryColor,
                                ),
                                filled: true,
                                fillColor: isDark
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.black.withOpacity(0.03),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (value) => (value == null || value.trim().isEmpty)
                                  ? 'Group name is required'
                                  : null,
                              textCapitalization: TextCapitalization.sentences,
                            ),
                            const SizedBox(height: 16),
                            // Description
                            TextFormField(
                              controller: _descriptionController,
                              decoration: InputDecoration(
                                labelText: 'Description (Optional)',
                                hintText: 'What is this group about?',
                                prefixIcon: Icon(
                                  Icons.description_outlined,
                                  color: AppTheme.primaryColor,
                                ),
                                filled: true,
                                fillColor: isDark
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.black.withOpacity(0.03),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              maxLines: 3,
                              textCapitalization: TextCapitalization.sentences,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Privacy Setting Card
                      Container(
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
                        child: SwitchListTile(
                          title: Text(
                            'Private Group',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            'Only invited members can join',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          value: _isPrivate,
                          onChanged: (value) => setState(() => _isPrivate = value),
                          secondary: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _isPrivate
                                  ? AppTheme.primaryColor.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _isPrivate ? Icons.lock_outline_rounded : Icons.lock_open_rounded,
                              color: _isPrivate ? AppTheme.primaryColor : Colors.grey,
                            ),
                          ),
                          activeColor: AppTheme.primaryColor,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Add Members Section Header
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
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
                              child: const Icon(
                                Icons.person_add_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Add Members',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Premium Search Bar
                      TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Search students to add...',
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppTheme.primaryColor,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    _searchFocusNode.unfocus();
                                    setState(() {
                                      _searchResults = [];
                                      _isSearching = false;
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: isDark
                              ? theme.colorScheme.surface.withOpacity(0.5)
                              : Colors.white.withOpacity(0.9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.08),
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.08),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        onChanged: (query) {
                          setState(() => _searchQuery = query);
                          _searchUsers(query);
                        },
                        textInputAction: TextInputAction.search,
                      ),
                      const SizedBox(height: 16),

                      // Selected Members Chips
                      if (_selectedMembers.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          height: 90,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _selectedMembers.length,
                            itemBuilder: (context, index) {
                              final member = _selectedMembers[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: Column(
                                  children: [
                                    Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        // Gradient Ring Avatar
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
                                              radius: 26,
                                              backgroundColor: theme.colorScheme.surface.withOpacity(0.3),
                                              child: Icon(
                                                Icons.person_rounded,
                                                color: isDark ? Colors.white70 : Colors.black54,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Remove Button
                                        Positioned(
                                          top: -4,
                                          right: -4,
                                          child: GestureDetector(
                                            onTap: () => _toggleMemberSelection(member),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.red.shade400,
                                                    Colors.red.shade600,
                                                  ],
                                                ),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.red.withOpacity(0.3),
                                                    blurRadius: 6,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                Icons.close_rounded,
                                                size: 12,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    SizedBox(
                                      width: 65,
                                      child: Text(
                                        member.displayName,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: isDark ? Colors.white70 : Colors.black87,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                      // User List - Sectioned by Role
                      _isLoadingUsers
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: CircularProgressIndicator(
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            )
                          : _isSearching
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: CircularProgressIndicator(
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                )
                              : _buildUserList(theme, isDark),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserList(ThemeData theme, bool isDark) {
    // Get the list to display (search results or all users)
    final usersToDisplay = _searchQuery.isNotEmpty ? _searchResults : _allUsers;
    
    // Filter out already selected members
    final availableUsers = usersToDisplay.where((u) => !_selectedMembers.any((m) => m.uid == u.uid)).toList();

    if (availableUsers.isEmpty && _searchQuery.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'No users found matching "$_searchQuery".',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ),
      );
    }

    if (availableUsers.isEmpty && _searchQuery.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'No users available to add',
            style: TextStyle(
              color: isDark ? Colors.white60 : Colors.black45,
            ),
          ),
        ),
      );
    }

    // Section users by role
    final students = availableUsers.where((u) => u.role == UserRole.student).toList();
    final mentors = availableUsers.where((u) => u.role == UserRole.mentor).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Students Section
        if (students.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4.0, top: 8, bottom: 12.0),
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
                final isSelected = _selectedMembers.any((m) => m.uid == user.uid);
                return StaggeredListItem(
                  index: index,
                  child: _MemberSearchTile(
                    user: user,
                    isSelected: isSelected,
                    onToggle: () => _toggleMemberSelection(user),
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
                final isSelected = _selectedMembers.any((m) => m.uid == user.uid);
                return StaggeredListItem(
                  index: index,
                  child: _MemberSearchTile(
                    user: user,
                    isSelected: isSelected,
                    onToggle: () => _toggleMemberSelection(user),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  void _searchUsers(String query) {
    _debouncer.run(() async {
      if (!mounted) return;
      final currentQuery = query.trim();
      if (currentQuery.isEmpty) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
        return;
      }
      setState(() => _isSearching = true);
      try {
        final results = await MessagingService.searchUsers(currentQuery);
        if (!mounted) return;
        if (currentQuery == _searchQuery) {
          setState(() {
            _searchResults = results
                .where((user) => user.uid != _currentUser?.uid) // Exclude self only
                .toList();
          });
        }
      } catch (e) {
        print("Search error: $e");
        if (mounted && currentQuery == _searchQuery) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error searching: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted && currentQuery == _searchQuery) {
          setState(() => _isSearching = false);
        }
      }
    });
  }

  void _toggleMemberSelection(UserProfile user) {
    setState(() {
      final index = _selectedMembers.indexWhere((m) => m.uid == user.uid);
      if (index >= 0) {
        _selectedMembers.removeAt(index);
      } else {
        _selectedMembers.add(user);
      }
      // Re-run search to filter out the selected/deselected user if they were in results
      if (_searchQuery.isNotEmpty) {
        _searchUsers(_searchQuery);
      }
    });
  }

  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please add at least one member.'),
            backgroundColor: Colors.orange),
      );
      return;
    }
    // Ensure current user is loaded before creating group
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error: Could not verify current user.'),
            backgroundColor: Colors.red),
      );
      return;
    }


    setState(() => _loading = true);
    try {
      // Add current user automatically to the group members list
      final allMemberIds = [_currentUser!.uid, ..._selectedMembers.map((m) => m.uid)].toSet().toList();

      await MessagingService.createGroupChat(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        memberIds: allMemberIds,
        isPrivate: _isPrivate,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Group created successfully!'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to create group: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

// Custom Member Search Tile Widget
class _MemberSearchTile extends StatelessWidget {
  final UserProfile user;
  final bool isSelected;
  final VoidCallback onToggle;

  const _MemberSearchTile({
    required this.user,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.surface.withOpacity(0.5)
              : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor.withOpacity(0.3)
                : Colors.white.withOpacity(0.08),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppTheme.primaryColor.withOpacity(0.15)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
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
                        radius: 24,
                        backgroundColor: theme.colorScheme.surface.withOpacity(0.3),
                        child: Icon(
                          Icons.person_rounded,
                          color: isDark ? Colors.white70 : Colors.black54,
                          size: 26,
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
                        Text(
                          user.displayName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
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
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Checkbox
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                AppTheme.primaryColor,
                                AppTheme.secondaryColor,
                              ],
                            )
                          : null,
                      border: !isSelected
                          ? Border.all(
                              color: theme.colorScheme.onSurface.withOpacity(0.3),
                              width: 2,
                            )
                          : null,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Icon(
                        isSelected ? Icons.check_rounded : null,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}