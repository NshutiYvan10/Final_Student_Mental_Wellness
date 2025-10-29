import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../services/hive_service.dart';
import '../../services/journal_analysis_service.dart';
import '../../widgets/gradient_card.dart';
import '../../widgets/word_cloud_widget.dart';

class AnalyticsPage extends ConsumerStatefulWidget {
  const AnalyticsPage({super.key});

  @override
  ConsumerState<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends ConsumerState<AnalyticsPage> 
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  String _selectedPeriod = '7d';

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final box = Hive.box(HiveService.moodsBox);
    final entries = box.values.toList().cast<Map>();
    entries.sort((a, b) => (DateTime.parse(a['date'] as String))
        .compareTo(DateTime.parse(b['date'] as String)));
    
    final filteredEntries = _filterEntriesByPeriod(entries);
    final spots = _generateChartSpots(filteredEntries);
    final stats = _calculateStats(filteredEntries);

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
                'Analytics',
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
                  child: _buildStatsCards(theme, stats),
                ),
                const SizedBox(height: 24),
                _buildPeriodSelector(theme),
                const SizedBox(height: 24),
                _buildMoodChart(theme, spots, filteredEntries),
                const SizedBox(height: 24),
                _buildInsights(theme, filteredEntries),
                const SizedBox(height: 24),
                _buildWordCloud(theme),
                const SizedBox(height: 24),
                _buildMoodDistribution(theme, filteredEntries),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(ThemeData theme, Map<String, dynamic> stats) {
    return Row(
      children: [
        Expanded(
          child: GradientCard(
            colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Average',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  stats['average'].toStringAsFixed(1),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Mood score',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GradientCard(
            colors: [theme.colorScheme.tertiary, theme.colorScheme.primary],
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.analytics_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Entries',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  stats['count'].toString(),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Total logged',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector(ThemeData theme) {
    final periods = [
      {'key': '7d', 'label': '7 Days'},
      {'key': '30d', 'label': '30 Days'},
      {'key': 'all', 'label': 'All Time'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time Period',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: periods.map((period) {
            final isSelected = _selectedPeriod == period['key'];
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: () => setState(() => _selectedPeriod = period['key']!),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected 
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      period['label']!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isSelected 
                            ? Colors.white
                            : theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMoodChart(ThemeData theme, List<FlSpot> spots, List<Map> entries) {
    return GradientCard(
      backgroundColor: theme.colorScheme.surface,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.show_chart_rounded,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Mood Trend',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: spots.isEmpty 
                ? _buildEmptyChart(theme)
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 1,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: theme.colorScheme.outline.withValues(alpha: 0.1),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() < entries.length) {
                                final date = DateTime.parse(entries[value.toInt()]['date']);
                                return Text(
                                  '${date.day}/${date.month}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              const labels = ['', '😢', '🙁', '😐', '🙂', '😀'];
                              if (value.toInt() >= 1 && value.toInt() <= 5) {
                                return Text(
                                  labels[value.toInt()],
                                  style: theme.textTheme.bodySmall,
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(alpha: 0.1),
                        ),
                      ),
                      minY: 0.5,
                      maxY: 5.5,
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: true,
                          curveSmoothness: 0.35,
                          spots: spots,
                          gradient: LinearGradient(
                            colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                          ),
                          barWidth: 3,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: theme.colorScheme.primary,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary.withValues(alpha: 0.2),
                                theme.colorScheme.primary.withValues(alpha: 0.05),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChart(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 48,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No data available',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Log some moods to see your trend',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsights(ThemeData theme, List<Map> entries) {
    return GradientCard(
      colors: [
        theme.colorScheme.primary.withValues(alpha: 0.1),
        theme.colorScheme.secondary.withValues(alpha: 0.05),
      ],
      backgroundColor: theme.colorScheme.surface,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology_rounded,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'AI Insights',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _generateInsight(entries),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordCloud(ThemeData theme) {
    return GradientCard(
      backgroundColor: theme.colorScheme.surface,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.cloud_rounded,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Journal Word Cloud',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Most frequently used words in your journal entries',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<Map<String, int>>(
            future: JournalAnalysisService.getTopWords(limit: 30),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Text(
                      'Error loading word cloud: ${snapshot.error}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                );
              }

              final wordFrequencies = snapshot.data ?? {};
              return WordCloudWidget(
                wordFrequencies: wordFrequencies,
                maxWords: 30,
                minFontSize: 12.0,
                maxFontSize: 28.0,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMoodDistribution(ThemeData theme, List<Map> entries) {
    if (entries.isEmpty) return const SizedBox.shrink();
    
    final distribution = <int, int>{};
    for (final entry in entries) {
      final mood = entry['mood'] as int;
      distribution[mood] = (distribution[mood] ?? 0) + 1;
    }

    return GradientCard(
      backgroundColor: theme.colorScheme.surface,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.pie_chart_rounded,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Mood Distribution',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          for (final entry in distribution.entries) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildMoodDistributionItem(theme, entry, entries.length),
            ),
          ],
        ],
      ),
    );
  }

  List<Map> _filterEntriesByPeriod(List<Map> entries) {
    if (_selectedPeriod == 'all') return entries;
    
    final now = DateTime.now();
    final cutoff = _selectedPeriod == '7d' 
        ? now.subtract(const Duration(days: 7))
        : now.subtract(const Duration(days: 30));
    
    return entries.where((entry) {
      final date = DateTime.parse(entry['date']);
      return date.isAfter(cutoff);
    }).toList();
  }

  List<FlSpot> _generateChartSpots(List<Map> entries) {
    final spots = <FlSpot>[];
    for (int i = 0; i < entries.length; i++) {
      final mood = (entries[i]['mood'] as int).toDouble();
      spots.add(FlSpot(i.toDouble(), mood));
    }
    return spots;
  }

  Map<String, dynamic> _calculateStats(List<Map> entries) {
    if (entries.isEmpty) {
      return {'average': 0.0, 'count': 0};
    }
    
    final sum = entries.fold<double>(0, (sum, entry) => sum + (entry['mood'] as int));
    return {
      'average': sum / entries.length,
      'count': entries.length,
    };
  }

  String _generateInsight(List<Map> entries) {
    if (entries.length < 3) {
      return 'Log more moods to unlock personalized insights about your emotional patterns and trends.';
    }
    
    final recent = entries.length >= 3 
        ? entries.sublist(entries.length - 3).map((e) => e['mood'] as int).toList()
        : entries.map((e) => e['mood'] as int).toList();
    final average = recent.reduce((a, b) => a + b) / recent.length;
    
    if (average >= 4.0) {
      return 'Great job! Your recent mood has been consistently positive. Keep up the good habits that are working for you.';
    } else if (average <= 2.0) {
      return 'I notice you\'ve been feeling low recently. Consider trying some meditation or reaching out to your support network.';
    } else if (recent.last > recent.first) {
      return 'Your mood is trending upward! Whatever you\'re doing is working - keep it up!';
    } else if (recent.last < recent.first) {
      return 'Your mood has been declining. Try some self-care activities or journaling to process what\'s happening.';
    } else {
      return 'Your mood has been stable. Consider exploring new activities or habits to enhance your wellbeing.';
    }
  }

  Widget _buildMoodDistributionItem(ThemeData theme, MapEntry<int, int> entry, int totalEntries) {
    final mood = entry.key;
    final count = entry.value;
    final percentage = (count / totalEntries * 100).round();
    final emojis = ['', '😢', '🙁', '😐', '🙂', '😀'];
    final colors = [
      const Color(0xFFEF4444), // Red for very low
      const Color(0xFFF97316), // Orange for low
      const Color(0xFFEAB308), // Yellow for neutral
      const Color(0xFF22C55E), // Green for good
      const Color(0xFF10B981), // Emerald for excellent
    ];
    
    return Row(
      children: [
        Text(emojis[mood], style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getMoodLabel(mood),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '$count entries ($percentage%)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: count / totalEntries,
                backgroundColor: colors[mood - 1].withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(colors[mood - 1]),
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getMoodLabel(int mood) {
    switch (mood) {
      case 1: return 'Very Low';
      case 2: return 'Low';
      case 3: return 'Neutral';
      case 4: return 'Good';
      case 5: return 'Excellent';
      default: return '';
    }
  }
}


