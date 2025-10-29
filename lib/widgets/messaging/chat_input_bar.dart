import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import '../../theme/app_theme.dart';
import '../../theme/messaging_theme.dart';
import '../../widgets/gradient_card.dart'; // Using GradientCard style

class ChatInputBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSendPressed;
  final VoidCallback onAttachmentPressed;
  final FocusNode? focusNode;
  final ValueChanged<String>? onTextChanged;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSendPressed,
    required this.onAttachmentPressed,
    this.focusNode,
    this.onTextChanged,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateSendButtonState);
    _updateSendButtonState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateSendButtonState);
    super.dispose();
  }

  void _updateSendButtonState() {
    final canSend = widget.controller.text.trim().isNotEmpty;
    if (canSend != _canSend) {
      setState(() {
        _canSend = canSend;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final msgTheme = context.messagingTheme;
    final bottomInsets = MediaQuery.of(context).viewInsets.bottom;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    final double bottomPadding = bottomInsets > 0 ? bottomInsets : (safeAreaBottom > 0 ? safeAreaBottom : 12.0); // More default padding

    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: bottomPadding,
      ),
      decoration: BoxDecoration(
        color: msgTheme.inputBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Attachment Button (optional: can be moved inside text field)
          // IconButton(
          //   icon: Icon(Icons.add_circle_outline_rounded, color: msgTheme.attachmentButtonColor),
          //   onPressed: widget.onAttachmentPressed,
          //   tooltip: 'Attach file or image',
          //   padding: const EdgeInsets.all(12),
          // ),

          // --- Sleek Text Input ---
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                // Using the GradientCard's visual style
                  gradient: LinearGradient(
                    colors: [
                      (theme.brightness == Brightness.dark ? AppTheme.darkSurface : AppTheme.softBg).withOpacity(0.5),
                      (theme.brightness == Brightness.dark ? AppTheme.darkSurface : AppTheme.softBg).withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: msgTheme.dividerColor, width: 1.0)
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Attachment Button (Inside)
                  IconButton(
                    icon: Icon(Icons.add_circle_outline_rounded, color: msgTheme.attachmentButtonColor),
                    onPressed: widget.onAttachmentPressed,
                    tooltip: 'Attach file or image',
                    padding: const EdgeInsets.all(10),
                  ),
                  // Text Field
                  Expanded(
                    child: TextField(
                      focusNode: widget.focusNode,
                      controller: widget.controller,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(color: msgTheme.inputTextColor),
                      decoration: InputDecoration(
                        hintText: 'Message...',
                        hintStyle: theme.textTheme.bodyLarge?.copyWith(
                          color: msgTheme.inputHintColor,
                        ),
                        border: InputBorder.none, // No border inside
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, // Adjusted padding
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.multiline,
                      onChanged: widget.onTextChanged,
                    ),
                  ),
                  // TODO: Add Emoji Button
                  IconButton(
                    icon: Icon(Icons.emoji_emotions_outlined, color: msgTheme.attachmentButtonColor),
                    onPressed: () {
                      // TODO: Implement emoji picker
                    },
                    padding: const EdgeInsets.all(10),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // --- Animated Send/Attach Button ---
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: _canSend
                ? FloatingActionButton(
              key: const ValueKey('send_button'),
              onPressed: () {
                HapticFeedback.lightImpact();
                widget.onSendPressed();
              },
              backgroundColor: msgTheme.sendButtonColor,
              foregroundColor: msgTheme.sendButtonIconColor,
              elevation: 1,
              mini: true,
              tooltip: 'Send',
              child: const Icon(Icons.send_rounded, size: 20),
            )
                : FloatingActionButton( // Placeholder for Mic or other action
              key: const ValueKey('mic_button'),
              onPressed: () {
                // TODO: Implement Voice Message
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Voice messages TBD'))
                );
              },
              backgroundColor: msgTheme.inputBackgroundColor, // Use background color
              foregroundColor: msgTheme.attachmentButtonColor,
              elevation: 0.5,
              mini: true,
              tooltip: 'Record voice message',
              child: const Icon(Icons.mic_none_rounded, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}