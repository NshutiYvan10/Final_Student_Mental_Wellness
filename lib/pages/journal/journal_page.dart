import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../services/hive_service.dart';
import '../../services/ml_service.dart';
import '../../models/journal_entry.dart';
import '../../widgets/gradient_card.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> 
    with TickerProviderStateMixin {
  final _ctrl = TextEditingController();
  final _focusNode = FocusNode();
  final _ml = MlService();
  bool _saving = false;
  String? _currentPrompt;
  late AnimationController _fadeController;
  late AnimationController _floatController;
  late AnimationController _breatheController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _breatheAnimation;
  
  final _prompts = const [
    'What went well today and why?',
    'What is one thing you can let go of?',
    'Who supported you recently and how?',
    'What are you grateful for today?',
    'How did you grow or learn something new?',
  ];

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    
    _breatheController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    _breatheAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );
    
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _floatController.dispose();
    _breatheController.dispose();
    _focusNode.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  void _insertPrompt(String prompt) {
    setState(() {
      _currentPrompt = prompt;
      if (_ctrl.text.isEmpty) {
        _ctrl.text = prompt;
      } else {
        _ctrl.text = '$prompt\n\n${_ctrl.text}';
      }
    });
  }

  Future<void> _save() async {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    
    try {
      // Analyze sentiment with timeout
      final sentiment = await _ml.analyzeSentiment(_ctrl.text).timeout(
        const Duration(seconds: 10),
        onTimeout: () => 0.0, // Default neutral sentiment on timeout
      );
      
      final journalEntry = JournalEntry(
        id: const Uuid().v4(),
        createdAt: DateTime.now(),
        text: _ctrl.text,
        sentiment: sentiment,
      );
      
      await HiveService.saveJournalEntry(journalEntry);
      
      _ctrl.clear();
      _currentPrompt = null;
      
      // Show success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Journal entry saved!'),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      print('Error saving journal: $e');
      // Save without sentiment if analysis fails
      final journalEntry = JournalEntry(
        id: const Uuid().v4(),
        createdAt: DateTime.now(),
        text: _ctrl.text,
        sentiment: 0.0, // Neutral sentiment as fallback
      );
      
      await HiveService.saveJournalEntry(journalEntry);
      
      _ctrl.clear();
      _currentPrompt = null;
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Journal entry saved!'),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Journal',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Animated background
          Positioned.fill(
            child: CustomPaint(
              painter: _BackgroundPainter(
                animation: _floatAnimation,
                isDark: isDark,
              ),
            ),
          ),
          // Content
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPremiumWritingSection(theme, isDark),
                const SizedBox(height: 24),
                _buildPromptsSection(theme, isDark),
                const SizedBox(height: 32),
                FutureBuilder<List<JournalEntry>>(
                  future: HiveService.getJournalEntries(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    final journalEntries = snapshot.data ?? [];
                    // Sort entries by date (newest first)
                    journalEntries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                    
                    return _buildEntriesSection(theme, journalEntries, isDark);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumWritingSection(ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey.shade900.withValues(alpha: 0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey.shade300)
                .withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top metadata bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 8),
                Text(
                  _getFormattedDate(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.more_horiz_rounded,
                  size: 20,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
          // Clean, open text input area (like iPhone Journal) - NO FILL COLOR
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Stack(
              children: [
                // Invisible TextField for actual input
                TextField(
                  controller: _ctrl,
                  focusNode: _focusNode,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: _currentPrompt != null && _ctrl.text.startsWith(_currentPrompt!)
                        ? Colors.transparent
                        : theme.colorScheme.onSurface,
                    height: 1.6,
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.2,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Start writing...',
                    hintStyle: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                      height: 1.6,
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.2,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    filled: false,
                    fillColor: Colors.transparent,
                  ),
                  minLines: 8,
                  maxLines: 15,
                  cursorColor: theme.colorScheme.primary,
                  cursorWidth: 2,
                  cursorHeight: 22,
                  onChanged: (text) {
                    setState(() {
                      // Update to re-render styled text
                    });
                  },
                ),
                // Styled text overlay (non-interactive)
                if (_currentPrompt != null && _ctrl.text.startsWith(_currentPrompt!))
                  IgnorePointer(
                    child: RichText(
                      text: TextSpan(
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                          height: 1.6,
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.2,
                        ),
                        children: [
                          TextSpan(
                            text: _currentPrompt,
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              decorationColor: theme.colorScheme.primary.withValues(alpha: 0.6),
                              decorationThickness: 1.5,
                            ),
                          ),
                          TextSpan(
                            text: _ctrl.text.substring(_currentPrompt!.length),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Bottom action bar with divider
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Prompt suggestion button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      final randomPrompt = _prompts[DateTime.now().second % _prompts.length];
                      _insertPrompt(randomPrompt);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lightbulb_outline_rounded,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Prompt',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                // Save button (minimal)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _saving ? null : _save,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _saving
                            ? theme.colorScheme.primary.withValues(alpha: 0.5)
                            : theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _saving
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Saving',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.arrow_upward_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Save',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  Widget _buildPromptsSection(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.tertiary,
                      theme.colorScheme.tertiary.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Writing Prompts',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemBuilder: (_, i) => TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 400 + (i * 100)),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(20 * (1 - value), 0),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: InkWell(
                onTap: () => _insertPrompt(_prompts[i]),
                borderRadius: BorderRadius.circular(26),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.15),
                        theme.colorScheme.secondary.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.auto_fix_high_rounded,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _prompts[i],
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemCount: _prompts.length,
          ),
        ),
      ],
    );
  }

  Widget _buildEntriesSection(ThemeData theme, List<JournalEntry> entries, bool isDark) {
    if (entries.isEmpty) {
      return _buildEmptyState(theme, isDark);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.secondary,
                      theme.colorScheme.secondary.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Recent Entries',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...entries.take(5).map((entry) {
          final index = entries.indexOf(entry);
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 500 + (index * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildPremiumJournalEntry(theme, entry, isDark),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatAnimation.value),
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withValues(alpha: 0.2),
                          theme.colorScheme.secondary.withValues(alpha: 0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.2),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.auto_stories_outlined,
                      size: 70,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Text(
              'Start Your Journey',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onSurface,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your journal is your safe space to express yourself freely. Write your thoughts, track your emotions, and discover patterns in your mental wellness journey.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumJournalEntry(ThemeData theme, JournalEntry entry, bool isDark) {
    final sentiment = entry.sentiment;
    final date = entry.createdAt;
    final text = entry.text;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey.shade300).withValues(alpha: 0.3),
            blurRadius: 25,
            offset: const Offset(0, 12),
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.2),
                            theme.colorScheme.secondary.withValues(alpha: 0.15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.calendar_today_rounded,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _formatDate(date),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    _PremiumSentimentBadge(score: sentiment, theme: theme),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.03)
                        : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    text,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                      height: 1.6,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDate = DateTime(date.year, date.month, date.day);
    
    if (entryDate == today) {
      return 'Today, ${_formatTime(date)}';
    } else if (entryDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, ${_formatTime(date)}';
    } else {
      return '${date.day}/${date.month}/${date.year}, ${_formatTime(date)}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _PremiumSentimentBadge extends StatelessWidget {
  final double score; // -1..1
  final ThemeData theme;
  const _PremiumSentimentBadge({required this.score, required this.theme});

  @override
  Widget build(BuildContext context) {
    final label = score > 0.2 ? 'Positive' : (score < -0.2 ? 'Negative' : 'Neutral');
    final color = score > 0.2
        ? const Color(0xFF10B981) // Emerald
        : (score < -0.2 ? const Color(0xFFEF4444) : const Color(0xFFF59E0B)); // Red : Amber
    final icon = score > 0.2 
        ? Icons.sentiment_satisfied_rounded
        : (score < -0.2 ? Icons.sentiment_dissatisfied_rounded : Icons.sentiment_neutral_rounded);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final Animation<double> animation;
  final bool isDark;

  _BackgroundPainter({required this.animation, required this.isDark})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Animated gradient orbs
    final colors = [
      isDark ? const Color(0xFF6366F1).withValues(alpha: 0.08) : const Color(0xFF6366F1).withValues(alpha: 0.05),
      isDark ? const Color(0xFFEC4899).withValues(alpha: 0.08) : const Color(0xFFEC4899).withValues(alpha: 0.05),
      isDark ? const Color(0xFF8B5CF6).withValues(alpha: 0.08) : const Color(0xFF8B5CF6).withValues(alpha: 0.05),
    ];

    // Orb 1
    final center1 = Offset(
      size.width * 0.2 + animation.value * 2,
      size.height * 0.3 + math.sin(animation.value * 0.5) * 20,
    );
    paint.color = colors[0];
    canvas.drawCircle(center1, 150, paint);

    // Orb 2
    final center2 = Offset(
      size.width * 0.8 - animation.value * 1.5,
      size.height * 0.6 + math.cos(animation.value * 0.3) * 30,
    );
    paint.color = colors[1];
    canvas.drawCircle(center2, 200, paint);

    // Orb 3
    final center3 = Offset(
      size.width * 0.5 + math.sin(animation.value * 0.2) * 40,
      size.height * 0.8 - animation.value,
    );
    paint.color = colors[2];
    canvas.drawCircle(center3, 120, paint);
  }

  @override
  bool shouldRepaint(_BackgroundPainter oldDelegate) => true;
}