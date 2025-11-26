import 'package:flutter/material.dart';
import '../models/user_profile.dart';

/// A reusable widget that displays a user's avatar with proper fallbacks
class UserAvatar extends StatelessWidget {
  final UserProfile? user;
  final double size;
  final bool showGradientBorder;

  const UserAvatar({
    super.key,
    required this.user,
    this.size = 48,
    this.showGradientBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget avatarContent;

    if (user?.avatarUrl != null && user!.avatarUrl.isNotEmpty) {
      avatarContent = _buildAvatarFromUrl(user!.avatarUrl, theme, isDark);
    } else {
      avatarContent = _buildDefaultAvatar(theme);
    }

    if (showGradientBorder) {
      return Container(
        width: size,
        height: size,
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
          child: avatarContent,
        ),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? theme.colorScheme.surface : Colors.white,
          shape: BoxShape.circle,
        ),
        child: avatarContent,
      ),
    );
  }

  Widget _buildAvatarFromUrl(String avatarUrl, ThemeData theme, bool isDark) {
    // Check if it's a gradient avatar ID
    if (avatarUrl.startsWith('gradient_')) {
      return _buildGradientAvatar(avatarUrl, theme);
    }

    // Check if it's an asset path
    if (avatarUrl.startsWith('assets/')) {
      return ClipOval(
        child: Image.asset(
          avatarUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(theme),
        ),
      );
    }

    // Otherwise, treat as network URL
    return ClipOval(
      child: Image.network(
        avatarUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: size * 0.4,
              height: size * 0.4,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(theme),
      ),
    );
  }

  Widget _buildGradientAvatar(String avatarId, ThemeData theme) {
    final avatarData = {
      'gradient_1': {
        'icon': Icons.person_rounded,
        'colors': [Color(0xFF6366F1), Color(0xFF8B5CF6)]
      },
      'gradient_2': {
        'icon': Icons.face_rounded,
        'colors': [Color(0xFFEC4899), Color(0xFFF472B6)]
      },
      'gradient_3': {
        'icon': Icons.emoji_emotions_rounded,
        'colors': [Color(0xFF10B981), Color(0xFF34D399)]
      },
      'gradient_4': {
        'icon': Icons.sentiment_very_satisfied_rounded,
        'colors': [Color(0xFFF59E0B), Color(0xFFFBBF24)]
      },
      'gradient_5': {
        'icon': Icons.star_rounded,
        'colors': [Color(0xFF3B82F6), Color(0xFF60A5FA)]
      },
      'gradient_6': {
        'icon': Icons.favorite_rounded,
        'colors': [Color(0xFFEF4444), Color(0xFFF87171)]
      },
      'gradient_7': {
        'icon': Icons.psychology_rounded,
        'colors': [Color(0xFF8B5CF6), Color(0xFFA78BFA)]
      },
      'gradient_8': {
        'icon': Icons.wb_sunny_rounded,
        'colors': [Color(0xFFF59E0B), Color(0xFFEF4444)]
      },
      'gradient_9': {
        'icon': Icons.auto_awesome_rounded,
        'colors': [Color(0xFF06B6D4), Color(0xFF3B82F6)]
      },
      'gradient_10': {
        'icon': Icons.spa_rounded,
        'colors': [Color(0xFF10B981), Color(0xFF06B6D4)]
      },
      'gradient_11': {
        'icon': Icons.diamond_rounded,
        'colors': [Color(0xFFEC4899), Color(0xFF8B5CF6)]
      },
      'gradient_12': {
        'icon': Icons.palette_rounded,
        'colors': [Color(0xFFF59E0B), Color(0xFF10B981)]
      },
    };

    final data = avatarData[avatarId];
    if (data == null) {
      return _buildDefaultAvatar(theme);
    }

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: data['colors'] as List<Color>,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        data['icon'] as IconData,
        size: size * 0.5,
        color: Colors.white,
      ),
    );
  }

  Widget _buildDefaultAvatar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.3),
            theme.colorScheme.secondary.withOpacity(0.2),
          ],
        ),
      ),
      child: Icon(
        Icons.person_rounded,
        size: size * 0.5,
        color: theme.colorScheme.primary,
      ),
    );
  }
}
