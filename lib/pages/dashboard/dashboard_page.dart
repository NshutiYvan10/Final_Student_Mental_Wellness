import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../widgets/gradient_card.dart';
import '../../services/hive_service.dart';
import '../../services/auth_service.dart';
import '../../models/user_profile.dart';
import '../../models/mood_entry.dart';
import '../../models/journal_entry.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  UserProfile? _currentUser;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final user = await AuthService.getCurrentUserProfile();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeHeader(theme),
              const SizedBox(height: 24),
              _buildMoodCard(theme),
              const SizedBox(height: 24),
              _buildStatsRow(theme),
              const SizedBox(height: 24),
              _buildQuickActions(theme),
              const SizedBox(height: 24),
              _buildRecentActivity(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back!',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _currentUser?.displayName ?? 'User',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'How are you feeling today?',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildMoodCard(ThemeData theme) {
    return FutureBuilder<MoodEntry?>(
      future: _getTodaysMood(),
      builder: (context, snapshot) {
        final todaysMood = snapshot.data;
        final moodEmoji = _getMoodEmoji(todaysMood?.moodType);
        final moodDescription = _getMoodDescription(todaysMood?.moodType);
        
        return GradientCard(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Mood',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      moodEmoji,
                      style: const TextStyle(fontSize: 48),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      moodDescription,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/mood/logger');
                },
                icon: const Icon(
                  Icons.add_circle_outline_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsRow(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: FutureBuilder<int>(
            future: _getMoodStreak(),
            builder: (context, snapshot) {
              final streak = snapshot.data ?? 0;
              return GradientCard(
                colors: [theme.colorScheme.tertiary, theme.colorScheme.primary],
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Streak',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$streak ${streak == 1 ? 'day' : 'days'}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Mood streak',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FutureBuilder<double>(
            future: _getAverageMood(),
            builder: (context, snapshot) {
              final averageMood = snapshot.data ?? 0.0;
              return GradientCard(
                colors: [theme.colorScheme.secondary, theme.colorScheme.tertiary],
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.psychology_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Mood',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      averageMood > 0 ? averageMood.toStringAsFixed(1) : '--',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Average overall',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                theme,
                'Journal',
                Icons.edit_rounded,
                () => Navigator.pushNamed(context, '/journal'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                theme,
                'Mood',
                Icons.psychology_rounded,
                () => Navigator.pushNamed(context, '/mood/logger'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                theme,
                'Analytics',
                Icons.analytics_rounded,
                () => Navigator.pushNamed(context, '/analytics'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    ThemeData theme,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        _buildActivityItem(
          theme,
          'Last journal entry',
          Icons.edit_rounded,
          () => Navigator.pushNamed(context, '/journal'),
        ),
        const SizedBox(height: 12),
        _buildActivityItem(
          theme,
          'View analytics',
          Icons.analytics_rounded,
          () => Navigator.pushNamed(context, '/analytics'),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    ThemeData theme,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  Future<MoodEntry?> _getTodaysMood() async {
    try {
      final moodEntries = await HiveService.getMoodEntries();
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final todayEnd = todayStart.add(const Duration(days: 1));
      
      for (final entry in moodEntries) {
        if (entry.date.isAfter(todayStart) && entry.date.isBefore(todayEnd)) {
          return entry;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  String _getMoodEmoji(MoodType? mood) {
    switch (mood) {
      case MoodType.veryHappy:
        return '😀';
      case MoodType.happy:
        return '🙂';
      case MoodType.neutral:
        return '😐';
      case MoodType.sad:
        return '🙁';
      case MoodType.verySad:
        return '😢';
      case MoodType.anxious:
        return '😰';
      case MoodType.angry:
        return '😠';
      case MoodType.stressed:
        return '😫';
      case MoodType.calm:
        return '😌';
      case MoodType.energetic:
        return '🤩';
      default:
        return '😊';
    }
  }

  String _getMoodDescription(MoodType? mood) {
    switch (mood) {
      case MoodType.veryHappy:
        return 'Feeling amazing and energetic!';
      case MoodType.happy:
        return 'Feeling good and optimistic';
      case MoodType.neutral:
        return 'Feeling balanced and steady';
      case MoodType.sad:
        return 'Feeling a bit down today';
      case MoodType.verySad:
        return 'Having a tough day';
      case MoodType.anxious:
        return 'Feeling worried or anxious';
      case MoodType.angry:
        return 'Feeling frustrated or angry';
      case MoodType.stressed:
        return 'Feeling overwhelmed';
      case MoodType.calm:
        return 'Feeling peaceful and relaxed';
      case MoodType.energetic:
        return 'Feeling motivated and active';
      default:
        return 'Log your mood to see how you\'re feeling';
    }
  }

  Future<int> _getMoodStreak() async {
    try {
      final moodEntries = await HiveService.getMoodEntries();
      if (moodEntries.isEmpty) return 0;
      
      // Sort by date (newest first)
      moodEntries.sort((a, b) => b.date.compareTo(a.date));
      
      int streak = 0;
      DateTime? lastDate;
      
      for (final entry in moodEntries) {
        final entryDate = DateTime(
          entry.date.year,
          entry.date.month,
          entry.date.day,
        );
        
        if (lastDate == null) {
          // First entry
          lastDate = entryDate;
          streak = 1;
        } else {
          final daysDifference = lastDate.difference(entryDate).inDays;
          
          if (daysDifference == 1) {
            // Consecutive day
            streak++;
            lastDate = entryDate;
          } else if (daysDifference == 0) {
            // Same day, don't increment streak
            continue;
          } else {
            // Streak broken
            break;
          }
        }
      }
      
      return streak;
    } catch (e) {
      return 0;
    }
  }

  Future<double> _getAverageMood() async {
    try {
      final moodEntries = await HiveService.getMoodEntries();
      if (moodEntries.isEmpty) return 0.0;
      
      final total = moodEntries.fold<double>(0, (sum, entry) => sum + entry.mood);
      return total / moodEntries.length;
    } catch (e) {
      return 0.0;
    }
  }
}