import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../services/hive_service.dart';
import '../../widgets/gradient_card.dart';

class MoodLoggerPage extends StatefulWidget {
  const MoodLoggerPage({super.key});

  @override
  State<MoodLoggerPage> createState() => _MoodLoggerPageState();
}

class _MoodLoggerPageState extends State<MoodLoggerPage> 
    with TickerProviderStateMixin {
  int _selected = 3; // 1..5
  final _noteCtrl = TextEditingController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

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
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final box = Hive.box(HiveService.moodsBox);
    await box.add({
      'date': DateTime.now().toIso8601String(),
      'mood': _selected,
      'note': _noteCtrl.text,
    });
    if (!mounted) return;
    
    // Show success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Mood logged successfully!'),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Log Your Mood',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildMoodSelector(theme),
                ),
                const SizedBox(height: 32),
                _buildNoteSection(theme),
                const SizedBox(height: 32),
                _buildActionButtons(theme),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSelector(ThemeData theme) {
    return GradientCard(
      colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'How are you feeling right now?',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _EmojiWheel(
            selected: _selected,
            onSelect: (v) => setState(() => _selected = v),
          ),
          const SizedBox(height: 16),
          Text(
            _getMoodDescription(_selected),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoteSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add a Note (Optional)',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _noteCtrl,
            decoration: InputDecoration(
              hintText: 'Share what\'s on your mind...',
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
            ),
            style: theme.textTheme.bodyLarge,
            minLines: 3,
            maxLines: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check_rounded, size: 24),
            label: const Text('Save Mood'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/mood/list'),
            icon: const Icon(Icons.history_rounded, size: 24),
            label: const Text('History'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              side: BorderSide(color: theme.colorScheme.primary),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getMoodDescription(int mood) {
    switch (mood) {
      case 1: return 'Very Low - Take care of yourself';
      case 2: return 'Low - Consider reaching out for support';
      case 3: return 'Neutral - A balanced day';
      case 4: return 'Good - Feeling positive';
      case 5: return 'Excellent - Having a great day!';
      default: return '';
    }
  }
}

class _EmojiWheel extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;
  const _EmojiWheel({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final emojis = ['', '😢', '🙁', '😐', '🙂', '😀'];
    final colors = [
      const Color(0xFFEF4444), // Red for very low
      const Color(0xFFF97316), // Orange for low
      const Color(0xFFEAB308), // Yellow for neutral
      const Color(0xFF22C55E), // Green for good
      const Color(0xFF10B981), // Emerald for excellent
    ];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (int i = 1; i <= 5; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: InkWell(
                onTap: () => onSelect(i),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: i == selected 
                        ? colors[i - 1].withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: i == selected 
                          ? colors[i - 1]
                          : Colors.white.withValues(alpha: 0.3),
                      width: i == selected ? 2 : 1,
                    ),
                    boxShadow: [
                      if (i == selected)
                        BoxShadow(
                          color: colors[i - 1].withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        emojis[i], 
                        style: TextStyle(
                          fontSize: i == selected ? 36 : 32,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == selected ? colors[i - 1] : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}


