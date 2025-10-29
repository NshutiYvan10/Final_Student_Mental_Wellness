import 'package:flutter/material.dart';

class AvatarSelector extends StatelessWidget {
  final String? selectedAvatar;
  final Function(String) onAvatarSelected;

  const AvatarSelector({
    super.key,
    this.selectedAvatar,
    required this.onAvatarSelected,
  });

  static const List<String> availableAvatars = [
    '👨‍🎓', '👩‍🎓', '👨‍💼', '👩‍💼', '👨‍⚕️', '👩‍⚕️',
    '👨‍🔬', '👩‍🔬', '👨‍🎨', '👩‍🎨', '👨‍🚀', '👩‍🚀',
    '🧑‍💻', '🧑‍🎤', '🧑‍🎨', '🧑‍🏫', '🧑‍🔬', '🧑‍⚕️',
    '🧑‍💼', '🧑‍🎓', '🧑‍🚀', '🧑‍✈️', '🧑‍🚒', '🧑‍🌾',
    '🧑‍🍳', '🧑‍🔧', '🧑‍🏭',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Make the selector scroll-safe so tests and small screens don't overflow.
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Your Avatar',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: availableAvatars.length,
              itemBuilder: (context, index) {
                final avatar = availableAvatars[index];
                final isSelected = selectedAvatar == avatar;
                
                return GestureDetector(
                  onTap: () => onAvatarSelected(avatar),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? theme.colorScheme.primary.withValues(alpha: 0.1)
                          : theme.colorScheme.surfaceVariant.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected 
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        avatar,
                        style: TextStyle(
                          fontSize: isSelected ? 28 : 24,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}


