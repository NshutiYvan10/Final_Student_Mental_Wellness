import 'package:flutter/material.dart';
import 'package:student_mental_wellness/widgets/gradient_card.dart';
import '../../models/user_profile.dart';
import '../../theme/app_theme.dart';

class UserProfileTile extends StatelessWidget {
  final UserProfile user;
  final Widget? trailing;
  final VoidCallback? onTap;

  const UserProfileTile({
    super.key,
    required this.user,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: GradientCard(
        onTap: onTap,
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              // TODO: Replace with actual image loading using user.avatarUrl if available
              child: Icon(
                user.role == UserRole.mentor
                    ? Icons.volunteer_activism_rounded
                    : Icons.person_rounded, // Default icon or student icon
                color: theme.colorScheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            // Name, School, Role/Status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName.isEmpty ? 'User' : user.displayName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (user.school.isNotEmpty)
                    Text(
                      user.school,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  // Role Tag and Online Indicator
                  Row(
                    children: [
                      _RoleTag(role: user.role),
                      if (user.isOnline) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.successColor, // Use theme color
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Online',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.successColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ]
                    ],
                  ),
                ],
              ),
            ),
            // Trailing Widget (e.g., Button)
            if (trailing != null) ...[
              const SizedBox(width: 12),
              trailing!,
            ]
          ],
        ),
      ),
    );
  }
}

// Small helper widget for the role tag
class _RoleTag extends StatelessWidget {
  final UserRole role;
  const _RoleTag({required this.role});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMentor = role == UserRole.mentor;
    final color = isMentor ? AppTheme.secondaryColor : AppTheme.accentColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        role.displayName,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}