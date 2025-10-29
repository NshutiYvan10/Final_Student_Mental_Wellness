import 'package:flutter/material.dart';
import '../services/messaging_service.dart';

/// A modern chat input widget with attachment and emoji affordances.
class ChatInput extends StatefulWidget {
  final Future<void> Function(String text) onSend;
  final String chatRoomId;
  final String? initialText;
  final String? replyToPreview;
  final VoidCallback? onCancelReply;

  const ChatInput({
    super.key,
    required this.onSend,
    required this.chatRoomId,
    this.initialText,
    this.replyToPreview,
    this.onCancelReply,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialText != null && widget.initialText!.isNotEmpty) {
      _controller.text = widget.initialText!;
    }
    _controller.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(covariant ChatInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialText != oldWidget.initialText && widget.initialText != null) {
      _controller.text = widget.initialText!;
      _controller.selection = TextSelection.fromPosition(TextPosition(offset: _controller.text.length));
    }
  }

  void _onChanged(String v) {
    MessagingService.setTyping(chatRoomId: widget.chatRoomId, isTyping: v.isNotEmpty);
    setState(() {});
  }

  Future<void> _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _isSending = true);
    try {
      await widget.onSend(text);
      _controller.clear();
      MessagingService.setTyping(chatRoomId: widget.chatRoomId, isTyping: false);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Attachment / emoji cluster
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      // TODO: implement attachments
                    },
                    icon: Icon(Icons.attach_file_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.8)),
                  ),
                  IconButton(
                    onPressed: () {
                      // TODO: open emoji picker
                    },
                    icon: Icon(Icons.emoji_emotions_outlined, color: theme.colorScheme.onSurface.withValues(alpha: 0.8)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Input + optional reply preview
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.replyToPreview != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: Text(widget.replyToPreview!, maxLines: 2, overflow: TextOverflow.ellipsis)),
                          IconButton(
                            onPressed: widget.onCancelReply,
                            icon: Icon(Icons.close_rounded, size: 18, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                          ),
                        ],
                      ),
                    ),
                  ],

                  TextField(
                    controller: _controller,
                    onChanged: _onChanged,
                    minLines: 1,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Send button
            Container(
              decoration: BoxDecoration(
                color: _controller.text.trim().isEmpty ? theme.colorScheme.onSurface.withValues(alpha: 0.08) : theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _isSending || _controller.text.trim().isEmpty ? null : _handleSend,
                icon: _isSending
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : Icon(
                        Icons.send_rounded,
                        color: _controller.text.trim().isEmpty ? theme.colorScheme.onSurface.withValues(alpha: 0.5) : Colors.white,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
