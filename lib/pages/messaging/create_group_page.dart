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
  bool _isSearching = false;
  String _searchQuery = '';
  final Debouncer _debouncer = Debouncer(milliseconds: 400);
  UserProfile? _currentUser; // Added for loading current user

  @override
  void initState() {
    super.initState();
    _loadCurrentUser(); // Load current user info
  }

  Future<void> _loadCurrentUser() async {
    final user = await AuthService.getCurrentUserProfile();
    if (mounted) setState(() => _currentUser = user);
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

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent, // Use gradient background
      appBar: AppBar(
        title: const Text('Create New Group'),
        backgroundColor: Colors.transparent, // Blurred AppBar
        elevation: 0,
        foregroundColor: Colors.white, // White text on gradient
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              color: msgTheme.inputBackgroundColor.withOpacity(0.7),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: Colors.white.withOpacity(0.1), width: 1)
                  )
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton(
              onPressed: _loading || _currentUser == null ? null : _createGroup, // Disable if user not loaded
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(80, 36),
              ),
              child: _loading
                  ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
                  : const Text('Create'),
            ),
          ),
        ],
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Group Icon Placeholder
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: theme.colorScheme.surface.withOpacity(0.2),
                        child: Icon(
                          Icons.group_add_rounded,
                          size: 45,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      // Add Photo Button
                      Padding(
                        padding: const EdgeInsets.only(right: 4, bottom: 4),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: AppTheme.primaryColor,
                          child: IconButton(
                            icon: const Icon(Icons.add_a_photo_rounded, size: 16, color: Colors.white),
                            onPressed: () {
                              // TODO: Implement image picker
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Image picker TBD'))
                              );
                            },
                            tooltip: 'Add group photo',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Use GradientCard for input sections
                GradientCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Group Name
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Group Name *',
                            hintText: 'Enter a name for your group',
                            prefixIcon: Icon(Icons.title),
                            // Make borders transparent inside card
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false, // Don't fill inside card
                          ),
                          validator: (value) =>
                          (value == null || value.trim().isEmpty)
                              ? 'Group name is required'
                              : null,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        Divider(color: theme.colorScheme.outline.withOpacity(0.3), height: 1),
                        // Description
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description (Optional)',
                            hintText: 'What is this group about?',
                            prefixIcon: Icon(Icons.description_outlined),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                          ),
                          maxLines: 3,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ],
                    )
                ),
                const SizedBox(height: 16),

                // Privacy Setting in GradientCard
                GradientCard(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: SwitchListTile(
                    title: Text('Private Group',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    subtitle: Text('Only invited members can join',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color:
                            theme.colorScheme.onSurface.withOpacity(0.6))),
                    value: _isPrivate,
                    onChanged: (value) => setState(() => _isPrivate = value),
                    secondary: Icon(_isPrivate
                        ? Icons.lock_outline_rounded
                        : Icons.lock_open_rounded, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    activeColor: AppTheme.primaryColor, // Use theme color for switch
                  ),
                ),
                const SizedBox(height: 24),

                // --- Add Members Section ---
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                  child: Text(
                    'Add Members',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),

                // Search Bar (Looks better outside card)
                TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Search students to add...',
                    prefixIcon: const Icon(Icons.search),
                    // Use standard input decoration, it adapts to theme
                    border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: msgTheme.dividerColor.withOpacity(0.5)),
                        borderRadius:
                        const BorderRadius.all(Radius.circular(12))),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: theme.colorScheme.primary),
                        borderRadius:
                        const BorderRadius.all(Radius.circular(12))),
                    filled: true,
                    // Use slightly transparent fill color
                    fillColor: msgTheme.inputBackgroundColor.withOpacity(0.8),
                    isDense: true,
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
                  ),
                  onChanged: (query) {
                    setState(() => _searchQuery = query);
                    _searchUsers(query);
                  },
                  textInputAction: TextInputAction.search,
                ),
                const SizedBox(height: 12),

                // Selected Members Horizontal List (Improved look)
                if (_selectedMembers.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    height: 85,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedMembers.length,
                      itemBuilder: (context, index) {
                        final member = _selectedMembers[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  CircleAvatar(
                                    radius: 26, // Slightly larger
                                    backgroundColor: theme
                                        .colorScheme.surface // Use surface color
                                        .withOpacity(0.2),
                                    child: Icon(Icons.person_rounded,
                                        color: Colors.white70), // White icon
                                  ),
                                  Positioned(
                                    top: -4,
                                    right: -4,
                                    child: GestureDetector(
                                      onTap: () =>
                                          _toggleMemberSelection(member),
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close_rounded,
                                            size: 14, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                width: 60,
                                child: Text(
                                  member.displayName,
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(color: Colors.white70),
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

                // Search Results or Loading/Empty State
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  constraints: BoxConstraints(
                    minHeight: 60, // Ensure space for text/loader
                    maxHeight: _searchResults.isEmpty && !_isSearching
                        ? 60
                        : 250, // More height for results
                  ),
                  child: _isSearching
                      ? const Center(
                      child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(color: Colors.white)))
                      : _searchResults.isEmpty && _searchQuery.isNotEmpty
                      ? Center(
                      child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                              'No students found matching "$_searchQuery".',
                              style: const TextStyle(
                                  color: Colors.white70))))
                      : _searchResults.isEmpty && _searchQuery.isEmpty
                      ? Center(child: Text('Search for students to add.', style: TextStyle(color: Colors.white60))) // Placeholder text
                      : AnimationLimiter(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final user = _searchResults[index];
                        final isSelected = _selectedMembers
                            .any((m) => m.uid == user.uid);
                        // Use GradientCard for results items
                        return StaggeredListItem(
                            index: index,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0), // Add padding here
                              child: UserProfileTile( // UserProfileTile now uses GradientCard
                                user: user,
                                trailing: Checkbox(
                                  value: isSelected,
                                  onChanged: (_) =>
                                      _toggleMemberSelection(user),
                                  shape: const CircleBorder(),
                                  activeColor: theme.colorScheme.primary,
                                  // Adapt checkbox color for dark/light
                                  checkColor: theme.brightness == Brightness.dark ? Colors.black : Colors.white,
                                  side: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                                ),
                                onTap: () =>
                                    _toggleMemberSelection(user),
                              ),
                            )
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
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
                .where((user) =>
            user.role == UserRole.student && // Only show students
                user.uid != _currentUser?.uid && // Exclude self
                !_selectedMembers.any((m) => m.uid == user.uid))
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