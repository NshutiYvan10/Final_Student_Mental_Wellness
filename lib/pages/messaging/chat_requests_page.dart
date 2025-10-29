import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'dart:ui';
import '../../models/chat_models.dart';
import '../../services/messaging_service.dart';
import '../../theme/messaging_theme.dart';
import '../../widgets/animations/staggered_list_item.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/messaging/request_tile.dart';
import '../../widgets/messaging/empty_state_widget.dart';

class ChatRequestsPage extends ConsumerWidget {
  const ChatRequestsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final msgTheme = context.messagingTheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Pending Chat Requests'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              color: msgTheme.inputBackgroundColor.withOpacity(0.7),
              decoration: BoxDecoration(
                  border: Border(
                      bottom:
                      BorderSide(color: Colors.white.withOpacity(0.1), width: 1))),
            ),
          ),
        ),
      ),
      body: GradientBackground(
        child: SafeArea(
          bottom: false,
          child: StreamBuilder<List<ChatRequest>>(
            stream: MessagingService.getChatRequests(),
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
              final requests = snapshot.data ?? [];

              if (requests.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.person_add_disabled_rounded,
                  title: 'No Pending Requests',
                  message: 'You have no incoming chat requests.',
                );
              }

              return AnimationLimiter(
                child: ListView.builder(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          ),
        ),
      ),
    );
  }
}