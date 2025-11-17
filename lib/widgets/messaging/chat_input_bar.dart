import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import '../../theme/app_theme.dart';
import '../../theme/messaging_theme.dart';
import 'dart:ui';

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
    final double bottomPadding = bottomInsets > 0 ? bottomInsets : (safeAreaBottom > 0 ? safeAreaBottom : 12.0);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(left: 12, right: 12, top: 12, bottom: bottomPadding + 4),
      decoration: BoxDecoration(
        color: msgTheme.inputBackgroundColor,
        border: Border(top: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.06))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Attach button (moved to left)
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: widget.onAttachmentPressed,
                child: Icon(
                  Icons.attach_file_rounded,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  size: 24,
                ),
              ),
            ),
          ),

          // Text field container
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 44, maxHeight: 120),
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.surface.withOpacity(0.4)
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: theme.colorScheme.onSurface.withOpacity(0.08),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 16),
                  
                  // Text field
                  Expanded(
                    child: TextField(
                      focusNode: widget.focusNode,
                      controller: widget.controller,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Message...',
                        hintStyle: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                          fontSize: 15,
                        ),
                        filled: false,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 11, horizontal: 0),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.multiline,
                      onChanged: widget.onTextChanged,
                      cursorColor: theme.colorScheme.primary,
                    ),
                  ),
                  
                  // Emoji button inside field (moved to right)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        // TODO: hook up emoji picker
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.emoji_emotions_outlined,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Send / Mic button
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
            child: _canSend
                ? Material(
                    key: const ValueKey('send_button'),
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        widget.onSendPressed();
                      },
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  )
                : Material(
                    key: const ValueKey('mic_button'),
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Voice messages coming soon')),
                        );
                      },
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Icon(
                          Icons.mic_none_rounded,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                          size: 22,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}