import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../services/hive_service.dart';
import '../../services/journal_analysis_service.dart';
import '../../widgets/gradient_card.dart';
import '../../widgets/word_cloud_widget.dart';
import '../../providers/mood_theme_provider.dart';

class AnalyticsPage extends ConsumerStatefulWidget {
  const AnalyticsPage({super.key});

  @override
  ConsumerState<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends ConsumerState<AnalyticsPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _floatController;
  late AnimationController _breatheController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _breatheAnimation;
  String _selectedPeriod = '7d';

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _floatController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);
    _breatheController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _floatAnimation = Tween<double>(begin: -20.0, end: 20.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final box = Hive.box(HiveService.moodsBox);
    final entries = box.values.toList().cast<Map>();
    entries.sort(
      (a, b) => (DateTime.parse(
        a['date'] as String,
      )).compareTo(DateTime.parse(b['date'] as String)),
    );

    final filteredEntries = _filterEntriesByPeriod(entries);
    final spots = _generateChartSpots(filteredEntries);
    final stats = _calculateStats(filteredEntries);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Animated background with floating orbs
          AnimatedBuilder(
            animation: Listenable.merge([_floatController, _breatheController]),
            builder: (context, child) {
              return CustomPaint(
                painter: _BackgroundPainter(
                  animation: _floatController.value,
                  breathe: _breatheAnimation.value,
                  isDark: isDark,
                ),
                child: Container(),
              );
            },
          ),
          // Content
          CustomScrollView(
            slivers: [
              // Standard AppBar matching other pages
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: false,
                toolbarHeight: 56,
                title: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ).createShader(bounds),
                  child: Text(
                    'Analytics',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                centerTitle: true,
              ),
              // Content
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildStatsCards(theme, stats, isDark),
                    ),
                    const SizedBox(height: 24),
                    _buildPeriodSelector(theme, isDark),
                    const SizedBox(height: 24),
                    _buildMoodChart(theme, spots, filteredEntries, isDark),
                    const SizedBox(height: 24),
                    _buildInsights(theme, filteredEntries, isDark),
                    const SizedBox(height: 24),
                    _buildWordCloud(theme, isDark),
                    const SizedBox(height: 24),
                    _buildMoodDistribution(theme, filteredEntries, isDark),
                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(
    ThemeData theme,
    Map<String, dynamic> stats,
    bool isDark,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildPremiumStatCard(
            theme: theme,
            isDark: isDark,
            icon: Icons.psychology_alt_rounded,
            title: 'Average',
            value: stats['average'].toStringAsFixed(1),
            subtitle: 'Mood score',
            gradientColors: [
              const Color(0xFF6366F1),
              const Color(0xFF8B5CF6),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildPremiumStatCard(
            theme: theme,
            isDark: isDark,
            icon: Icons.insert_chart_rounded,
            title: 'Entries',
            value: stats['count'].toString(),
            subtitle: 'Total logged',
            gradientColors: [
              const Color(0xFF8B5CF6),
              const Color(0xFF6366F1),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumStatCard({
    required ThemeData theme,
    required bool isDark,
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required List<Color> gradientColors,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.white.withValues(alpha: 0.08),
                      Colors.white.withValues(alpha: 0.05),
                    ]
                  : [
                      gradientColors[0].withOpacity(0.9),
                      gradientColors[1].withOpacity(0.8),
                    ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.3),
              width: isDark ? 1.5 : 2,
            ),
            boxShadow: isDark
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 25,
                      offset: const Offset(0, 12),
                      spreadRadius: -5,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: gradientColors[0].withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: -2,
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? gradientColors[0].withOpacity(0.8)
                      : Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.white.withValues(alpha: isDark ? 0.6 : 0.9),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 36,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: isDark ? 0.5 : 0.85),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(ThemeData theme, bool isDark) {
    final periods = [
      {'key': '7d', 'label': '7 Days', 'icon': Icons.calendar_today_rounded},
      {'key': '30d', 'label': '30 Days', 'icon': Icons.calendar_month_rounded},
      {
        'key': 'all',
        'label': 'All Time',
        'icon': Icons.calendar_view_month_rounded,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Row(
            children: [
              Icon(
                Icons.date_range_rounded,
                size: 20,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.8)
                    : const Color(0xFF64748B),
              ),
              const SizedBox(width: 8),
              Text(
                'Time Period',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : Colors.grey.shade900,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: periods.map((period) {
            final isSelected = _selectedPeriod == period['key'];
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => setState(
                      () => _selectedPeriod = period['key'] as String,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF6366F1),
                                  const Color(0xFF8B5CF6),
                                ],
                              )
                            : null,
                        color: !isSelected
                            ? (isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.white.withValues(alpha: 0.7))
                            : null,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : (isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.white.withValues(alpha: 0.5)),
                          width: 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFF6366F1,
                                  ).withOpacity(0.4),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            period['icon'] as IconData,
                            size: 22,
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                      ? Colors.white.withValues(alpha: 0.7)
                                      : const Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            period['label'] as String,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : (isDark
                                        ? Colors.white.withValues(alpha: 0.7)
                                        : Colors.grey.shade600),
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
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

  Widget _buildMoodChart(
    ThemeData theme,
    List<FlSpot> spots,
    List<Map> entries,
    bool isDark,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : Colors.grey.shade300)
                    .withValues(alpha: 0.3),
                blurRadius: 25,
                offset: const Offset(0, 12),
                spreadRadius: -5,
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: isDark ? 0.03 : 0.6),
                blurRadius: 20,
                offset: const Offset(0, -5),
                spreadRadius: -10,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.trending_up_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Mood Trend',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : Colors.grey.shade900,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 220,
                child: spots.isEmpty
                    ? _buildEmptyChart(theme, isDark)
                    : LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 1,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : const Color(0xFFE2E8F0),
                                strokeWidth: 1,
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() < entries.length) {
                                    final date = DateTime.parse(
                                      entries[value.toInt()]['date'],
                                    );
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        '${date.day}/${date.month}',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: isDark
                                                  ? Colors.white.withValues(
                                                      alpha: 0.6,
                                                    )
                                                  : const Color(0xFF94A3B8),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
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
                                  const labels = [
                                    '',
                                    '😢',
                                    '🙁',
                                    '😐',
                                    '🙂',
                                    '😀',
                                  ];
                                  if (value.toInt() >= 1 &&
                                      value.toInt() <= 5) {
                                    return Text(
                                      labels[value.toInt()],
                                      style: const TextStyle(fontSize: 18),
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
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : const Color(0xFFE2E8F0),
                              width: 1.5,
                            ),
                          ),
                          minY: 0.5,
                          maxY: 5.5,
                          lineBarsData: [
                            LineChartBarData(
                              isCurved: true,
                              curveSmoothness: 0.4,
                              spots: spots,
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF6366F1),
                                  Color(0xFF8B5CF6),
                                  Color(0xFFEC4899),
                                ],
                              ),
                              barWidth: 4,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 6,
                                    color: Colors.white,
                                    strokeWidth: 3,
                                    strokeColor: const Color(0xFF6366F1),
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF6366F1).withOpacity(0.3),
                                    const Color(0xFF8B5CF6).withOpacity(0.15),
                                    const Color(0xFFEC4899).withOpacity(0.05),
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
        ),
      ),
    );
  }

  Widget _buildEmptyChart(ThemeData theme, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.insights_rounded,
              size: 48,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.4)
                  : const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No data available',
            style: theme.textTheme.titleMedium?.copyWith(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.8)
                  : const Color(0xFF64748B),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Log some moods to see your trend',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.6)
                  : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsights(ThemeData theme, List<Map> entries, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : Colors.grey.shade300)
                    .withValues(alpha: 0.3),
                blurRadius: 25,
                offset: const Offset(0, 12),
                spreadRadius: -5,
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: isDark ? 0.03 : 0.6),
                blurRadius: 20,
                offset: const Offset(0, -5),
                spreadRadius: -10,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AI Insights',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : Colors.grey.shade900,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : const Color(0xFF8B5CF6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.stars_rounded,
                          size: 14,
                          color: isDark
                              ? const Color(0xFFEC4899)
                              : const Color(0xFF8B5CF6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'AI',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? const Color(0xFFEC4899)
                                : const Color(0xFF8B5CF6),
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.white.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF8B5CF6).withOpacity(0.2)
                            : const Color(0xFF8B5CF6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.lightbulb_rounded,
                        size: 18,
                        color: isDark
                            ? const Color(0xFFEC4899)
                            : const Color(0xFF8B5CF6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _generateInsight(entries),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.9)
                              : Colors.grey.shade700,
                          height: 1.6,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWordCloud(ThemeData theme, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : Colors.grey.shade300)
                    .withValues(alpha: 0.3),
                blurRadius: 25,
                offset: const Offset(0, 12),
                spreadRadius: -5,
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: isDark ? 0.03 : 0.6),
                blurRadius: 20,
                offset: const Offset(0, -5),
                spreadRadius: -10,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF06B6D4).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.cloud_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Journal Word Cloud',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : Colors.grey.shade900,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Most frequently used words',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.6)
                                : Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FutureBuilder<Map<String, int>>(
                future: JournalAnalysisService.getTopWords(limit: 30),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark
                                ? const Color(0xFF06B6D4)
                                : const Color(0xFF3B82F6),
                          ),
                        ),
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
        ),
      ),
    );
  }

  Widget _buildMoodDistribution(
    ThemeData theme,
    List<Map> entries,
    bool isDark,
  ) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final distribution = <int, int>{};
    for (final entry in entries) {
      final mood = entry['mood'] as int;
      distribution[mood] = (distribution[mood] ?? 0) + 1;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : Colors.grey.shade300)
                    .withValues(alpha: 0.3),
                blurRadius: 25,
                offset: const Offset(0, 12),
                spreadRadius: -5,
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: isDark ? 0.03 : 0.6),
                blurRadius: 20,
                offset: const Offset(0, -5),
                spreadRadius: -10,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEC4899), Color(0xFFF59E0B)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEC4899).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.donut_small_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Mood Distribution',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : Colors.grey.shade900,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              for (final entry in distribution.entries) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _buildMoodDistributionItem(
                    theme,
                    entry,
                    entries.length,
                    isDark,
                  ),
                ),
              ],
            ],
          ),
        ),
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

    final sum = entries.fold<double>(
      0,
      (sum, entry) => sum + (entry['mood'] as int),
    );
    return {'average': sum / entries.length, 'count': entries.length};
  }

  String _generateInsight(List<Map> entries) {
    if (entries.length < 3) {
      return 'Log more moods to unlock personalized insights about your emotional patterns and trends.';
    }

    final recent = entries.length >= 3
        ? entries
              .sublist(entries.length - 3)
              .map((e) => e['mood'] as int)
              .toList()
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

  Widget _buildMoodDistributionItem(
    ThemeData theme,
    MapEntry<int, int> entry,
    int totalEntries,
    bool isDark,
  ) {
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : colors[mood - 1].withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? colors[mood - 1].withOpacity(0.3)
              : colors[mood - 1].withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: colors[mood - 1].withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colors[mood - 1].withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(emojis[mood], style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 16),
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
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                        fontSize: 15,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colors[mood - 1].withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$percentage%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors[mood - 1],
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: count / totalEntries,
                          backgroundColor: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : colors[mood - 1].withOpacity(0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colors[mood - 1],
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$count',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.7)
                            : const Color(0xFF64748B),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMoodLabel(int mood) {
    switch (mood) {
      case 1:
        return 'Very Low';
      case 2:
        return 'Low';
      case 3:
        return 'Neutral';
      case 4:
        return 'Good';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }
}

// Background painter for animated gradient orbs
class _BackgroundPainter extends CustomPainter {
  final double animation;
  final double breathe;
  final bool isDark;

  _BackgroundPainter({
    required this.animation,
    required this.breathe,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Orb 1 - Purple/Indigo gradient (top left)
    final orb1Center = Offset(
      size.width * 0.2 + (animation * 30),
      size.height * 0.15 - (animation * 20),
    );
    final orb1Gradient = RadialGradient(
      colors: isDark
          ? [
              const Color(0xFF6366F1).withOpacity(0.15 * breathe),
              const Color(0xFF8B5CF6).withOpacity(0.08 * breathe),
              Colors.transparent,
            ]
          : [
              const Color(0xFF6366F1).withOpacity(0.12 * breathe),
              const Color(0xFF8B5CF6).withOpacity(0.06 * breathe),
              Colors.transparent,
            ],
    );
    paint.shader = orb1Gradient.createShader(
      Rect.fromCircle(center: orb1Center, radius: 200 * breathe),
    );
    canvas.drawCircle(orb1Center, 200 * breathe, paint);

    // Orb 2 - Pink/Purple gradient (top right)
    final orb2Center = Offset(
      size.width * 0.8 - (animation * 25),
      size.height * 0.25 + (animation * 15),
    );
    final orb2Gradient = RadialGradient(
      colors: isDark
          ? [
              const Color(0xFFEC4899).withOpacity(0.12 * breathe),
              const Color(0xFF8B5CF6).withOpacity(0.06 * breathe),
              Colors.transparent,
            ]
          : [
              const Color(0xFFEC4899).withOpacity(0.10 * breathe),
              const Color(0xFF8B5CF6).withOpacity(0.05 * breathe),
              Colors.transparent,
            ],
    );
    paint.shader = orb2Gradient.createShader(
      Rect.fromCircle(center: orb2Center, radius: 180 * breathe),
    );
    canvas.drawCircle(orb2Center, 180 * breathe, paint);

    // Orb 3 - Cyan/Blue gradient (bottom left)
    final orb3Center = Offset(
      size.width * 0.15 - (animation * 20),
      size.height * 0.7 + (animation * 25),
    );
    final orb3Gradient = RadialGradient(
      colors: isDark
          ? [
              const Color(0xFF06B6D4).withOpacity(0.10 * breathe),
              const Color(0xFF3B82F6).withOpacity(0.05 * breathe),
              Colors.transparent,
            ]
          : [
              const Color(0xFF06B6D4).withOpacity(0.08 * breathe),
              const Color(0xFF3B82F6).withOpacity(0.04 * breathe),
              Colors.transparent,
            ],
    );
    paint.shader = orb3Gradient.createShader(
      Rect.fromCircle(center: orb3Center, radius: 160 * breathe),
    );
    canvas.drawCircle(orb3Center, 160 * breathe, paint);

    // Orb 4 - Orange/Yellow gradient (bottom right)
    final orb4Center = Offset(
      size.width * 0.85 + (animation * 30),
      size.height * 0.8 - (animation * 20),
    );
    final orb4Gradient = RadialGradient(
      colors: isDark
          ? [
              const Color(0xFFF59E0B).withOpacity(0.08 * breathe),
              const Color(0xFFEC4899).withOpacity(0.04 * breathe),
              Colors.transparent,
            ]
          : [
              const Color(0xFFF59E0B).withOpacity(0.06 * breathe),
              const Color(0xFFEC4899).withOpacity(0.03 * breathe),
              Colors.transparent,
            ],
    );
    paint.shader = orb4Gradient.createShader(
      Rect.fromCircle(center: orb4Center, radius: 150 * breathe),
    );
    canvas.drawCircle(orb4Center, 150 * breathe, paint);
  }

  @override
  bool shouldRepaint(_BackgroundPainter oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.breathe != breathe ||
        oldDelegate.isDark != isDark;
  }
}
