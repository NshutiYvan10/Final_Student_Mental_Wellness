import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:hive_flutter/hive_flutter.dart';
import '../../widgets/gradient_card.dart';
import '../../services/hive_service.dart';

class MeditationPage extends StatefulWidget {
  final Map<String, dynamic>? arguments;
  
  const MeditationPage({super.key, this.arguments});

  @override
  State<MeditationPage> createState() => _MeditationPageState();
}

class _MeditationPageState extends State<MeditationPage> 
    with TickerProviderStateMixin {
  int _streak = 0;
  final List<int> _durations = [300, 600, 900, 1200]; // 5, 10, 15, 20 min
  int _selected = 600;
  int _remaining = 0;
  bool _running = false;
  Timer? _timer;
  late AnimationController _pulseController;
  late AnimationController _breathController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _breathAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  String _meditationType = 'Sleep Meditation';
  IconData _meditationIcon = Icons.nightlight_round;
  List<Color> _gradientColors = [const Color(0xFF667eea), const Color(0xFF764ba2)];
  
  bool _isInhaling = true;
  int _breathCycle = 0;

  @override
  void initState() {
    super.initState();
    final box = Hive.box(HiveService.settingsBox);
    _streak = (box.get(HiveService.keyMeditationStreak) as int?) ?? 0;
    
    // Get meditation type from arguments
    if (widget.arguments != null) {
      _meditationType = widget.arguments!['type'] ?? 'Sleep Meditation';
      _meditationIcon = widget.arguments!['icon'] ?? Icons.nightlight_round;
      _gradientColors = widget.arguments!['colors'] ?? [const Color(0xFF667eea), const Color(0xFF764ba2)];
    }
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _breathController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _breathAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
    
    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _breathController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _completeSession() async {
    final box = Hive.box(HiveService.settingsBox);
    final last = box.get(HiveService.keyMeditationLastDate) as String?;
    final today = DateTime.now();
    bool increment = true;
    if (last != null) {
      final lastDt = DateTime.parse(last);
      final diff = today.difference(DateTime(lastDt.year, lastDt.month, lastDt.day)).inDays;
      if (diff == 0) increment = false; // same day, don’t increment
      if (diff > 1) _streak = 0; // broken streak
    }
    if (increment) _streak += 1;
    await box.put(HiveService.keyMeditationStreak, _streak);
    await box.put(HiveService.keyMeditationLastDate, today.toIso8601String());
    if (!mounted) return;
    setState(() {});
    // Optional feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session completed!')));
    }
  }

  void _start() {
    if (_running) return;
    setState(() {
      _remaining = _selected;
      _running = true;
      _breathCycle = 0;
      _isInhaling = true;
    });
    _pulseController.repeat(reverse: true);
    _breathController.repeat(reverse: true);
    
    // Update breath state every 4 seconds
    Timer.periodic(const Duration(seconds: 4), (t) {
      if (!_running) {
        t.cancel();
        return;
      }
      setState(() {
        _isInhaling = !_isInhaling;
        _breathCycle++;
      });
    });
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_running) return;
      final newRemaining = (_remaining - 1).clamp(0, _selected);
      if (newRemaining != _remaining) {
        setState(() => _remaining = newRemaining);
      }
      if (_remaining == 0) {
        _running = false;
        _timer?.cancel();
        _pulseController.stop();
        _breathController.stop();
        _completeSession();
      }
    });
  }

  void _stop() {
    setState(() {
      _running = false;
      _isInhaling = true;
      _breathCycle = 0;
    });
    _timer?.cancel();
    _pulseController.stop();
    _breathController.stop();
  }

  void _pause() {
    setState(() => _running = !_running);
    if (_running) {
      _pulseController.repeat(reverse: true);
      _breathController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _breathController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : _gradientColors[0].withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : _gradientColors[0].withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: _gradientColors[0],
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                children: [
                  _buildPremiumHeader(theme, isDark),
                  const SizedBox(height: 24),
                  _buildStreakCard(theme, isDark),
                  const SizedBox(height: 32),
                  _buildBreathingCircle(theme, isDark),
                  const SizedBox(height: 32),
                  _buildDurationSelector(theme, isDark),
                  const SizedBox(height: 24),
                  _buildTimerDisplay(theme, isDark),
                  const SizedBox(height: 32),
                  _buildControlButtons(theme, isDark),
                  const SizedBox(height: 24),
                  _buildGuidanceText(theme, isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(ThemeData theme, bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: _gradientColors[0].withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            _meditationIcon,
            size: 48,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: _gradientColors,
          ).createShader(bounds),
          child: Text(
            _meditationType,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _getSubtitle(),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
            fontStyle: FontStyle.italic,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _getSubtitle() {
    if (_meditationType.contains('Sleep')) {
      return 'Drift into peaceful rest with calming meditation';
    } else if (_meditationType.contains('Stress')) {
      return 'Release tension and find your inner calm';
    } else {
      return 'Sharpen your mind and enhance clarity';
    }
  }

  Widget _buildStreakCard(ThemeData theme, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: isDark ? 10 : 0, sigmaY: isDark ? 10 : 0),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: isDark
                ? null
                : LinearGradient(
                    colors: [
                      _gradientColors[0].withValues(alpha: 0.12),
                      _gradientColors[1].withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            color: isDark ? Colors.white.withValues(alpha: 0.05) : null,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : _gradientColors[0].withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: _gradientColors[0].withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: _gradientColors[0].withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.local_fire_department_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meditation Streak',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$_streak day${_streak == 1 ? '' : 's'} in a row 🔥',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
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

  Widget _buildBreathingCircle(ThemeData theme, bool isDark) {
    final progress = _remaining > 0 ? 1 - (_remaining / _selected) : 0.0;
    
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow rings
          ...List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                final scale = _running ? _pulseAnimation.value : 1.0;
                final ringScale = scale + (index * 0.15);
                final opacity = _running ? (0.15 - (index * 0.04)) : 0.05;
                
                return Transform.scale(
                  scale: ringScale,
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _gradientColors[0].withValues(alpha: opacity),
                        width: 2,
                      ),
                    ),
                  ),
                );
              },
            );
          }),
          
          // Progress circle
          SizedBox(
            width: 260,
            height: 260,
            child: CustomPaint(
              painter: _ProgressRingPainter(
                progress: progress,
                color: _gradientColors[0],
                backgroundColor: _gradientColors[0].withValues(alpha: 0.1),
              ),
            ),
          ),
          
          // Main breathing circle
          AnimatedBuilder(
            animation: Listenable.merge([_pulseAnimation, _breathAnimation]),
            builder: (context, child) {
              final scale = _running ? _breathAnimation.value : 1.0;
              
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _gradientColors[0].withValues(alpha: 0.3),
                        _gradientColors[1].withValues(alpha: 0.15),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: _gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _gradientColors[0].withValues(alpha: _running ? 0.5 : 0.3),
                          blurRadius: _running ? 40 : 24,
                          spreadRadius: _running ? 4 : 0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _meditationIcon,
                            size: 48,
                            color: Colors.white,
                          ),
                          if (_running) ...[
                            const SizedBox(height: 8),
                            Text(
                              _isInhaling ? 'Inhale' : 'Exhale',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDurationSelector(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Session Duration',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _durations.map((duration) {
            final isSelected = duration == _selected;
            return InkWell(
              onTap: _running ? null : () => setState(() => _selected = duration),
              borderRadius: BorderRadius.circular(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: isDark && isSelected ? 10 : 0,
                    sigmaY: isDark && isSelected ? 10 : 0,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: _gradientColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected
                          ? null
                          : isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? _gradientColors[0].withValues(alpha: 0.5)
                            : isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : theme.colorScheme.outline.withValues(alpha: 0.15),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: _gradientColors[0].withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                      ],
                    ),
                    child: Text(
                      '${(duration / 60).round()} min',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isSelected
                            ? Colors.white
                            : theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
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

  Widget _buildTimerDisplay(ThemeData theme, bool isDark) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: isDark ? 10 : 0, sigmaY: isDark ? 10 : 0),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 48),
            decoration: BoxDecoration(
              gradient: isDark
                  ? null
                  : LinearGradient(
                      colors: [
                        _gradientColors[0].withValues(alpha: 0.08),
                        _gradientColors[1].withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              color: isDark ? Colors.white.withValues(alpha: 0.05) : null,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : _gradientColors[0].withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: _gradientColors[0].withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
              ],
            ),
            child: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: _gradientColors,
              ).createShader(bounds),
              child: Text(
                _running ? _format(_remaining) : _format(_selected),
                style: theme.textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontFeatures: [const FontFeature.tabularFigures()],
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButtons(ThemeData theme, bool isDark) {
    return Column(
      children: [
        // Start/Pause Button
        Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _gradientColors[0].withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _remaining > 0 ? (_running ? _pause : _start) : _start,
              borderRadius: BorderRadius.circular(20),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _running ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _remaining > 0 && _remaining < _selected
                          ? (_running ? 'Pause' : 'Resume')
                          : 'Start Session',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 14),
        
        // Stop Button
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _remaining > 0 && _remaining < _selected
                  ? theme.colorScheme.error.withValues(alpha: 0.3)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : theme.colorScheme.outline.withValues(alpha: 0.2)),
              width: 1.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _remaining > 0 && _remaining < _selected ? _stop : null,
              borderRadius: BorderRadius.circular(18),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.stop_rounded,
                      color: _remaining > 0 && _remaining < _selected
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Stop Session',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: _remaining > 0 && _remaining < _selected
                            ? theme.colorScheme.error
                            : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
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

  Widget _buildGuidanceText(ThemeData theme, bool isDark) {
    String guidance = '';
    if (_running) {
      guidance = _getRunningGuidance();
    } else {
      guidance = 'Select your duration and begin your journey to inner peace';
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : _gradientColors[0].withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : _gradientColors[0].withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: _gradientColors[0],
            size: 28,
          ),
          const SizedBox(height: 12),
          Text(
            guidance,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getRunningGuidance() {
    if (_meditationType.contains('Sleep')) {
      return 'Let go of the day... Feel your body relax with each breath... Drift into peaceful rest';
    } else if (_meditationType.contains('Stress')) {
      return 'Release tension with each exhale... Feel calm wash over you... You are safe and at peace';
    } else {
      return 'Focus on this moment... Clear your mind... Sharpen your awareness with each breath';
    }
  }

  String _format(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$m:$ss';
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 6.0;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..shader = LinearGradient(
          colors: [color, color.withValues(alpha: 0.6)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      const startAngle = -math.pi / 2;
      final sweepAngle = 2 * math.pi * progress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}


