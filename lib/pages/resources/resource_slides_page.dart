import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/resource_slide.dart';
import '../../services/resource_progress_service.dart';

class ResourceSlidesPage extends StatefulWidget {
  final ResourceTopic topic;

  const ResourceSlidesPage({super.key, required this.topic});

  @override
  State<ResourceSlidesPage> createState() => _ResourceSlidesPageState();
}

class _ResourceSlidesPageState extends State<ResourceSlidesPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;
  late AnimationController _slideAnimController;
  late AnimationController _breathController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late Animation<double> _fadeAnimation;
  late AnimationController _galaxyController;
  late AnimationController _cometController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _breathAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    
    _pageController = PageController();
    
    _slideAnimController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _breathController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _galaxyController = AnimationController(
      duration: const Duration(seconds: 40),
      vsync: this,
    );

    _cometController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _slideAnimController, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideAnimController, curve: Curves.easeOut),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _slideAnimController, curve: Curves.easeOut),
    );
    
    _breathAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
    
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _shimmerAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _slideAnimController.forward();
    _pulseController.repeat(reverse: true);
    _galaxyController.repeat();
    _cometController.repeat();
    _shimmerController.repeat();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _pageController.dispose();
    _slideAnimController.dispose();
    _breathController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
    _galaxyController.dispose();
    _cometController.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    _slideAnimController.reset();
    _slideAnimController.forward();
    
    // Start breathing animation for practical slides
    if (widget.topic.slides[index].animationType == 'breathe') {
      _breathController.repeat(reverse: true);
    } else {
      _breathController.stop();
    }
  }

  void _nextSlide() {
    if (_currentIndex < widget.topic.slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousSlide() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: Stack(
        children: [
          // Animated background gradient
          // Multi-layered animated backgrounds
          AnimatedBuilder(
            animation: _galaxyController,
            builder: (context, child) {
              return CustomPaint(
                painter: _GalaxyBackgroundPainter(
                  animation: _galaxyController.value,
                  colors: widget.topic.gradientColors,
                  isDark: isDark,
                ),
                size: Size.infinite,
              );
            },
          ),
          AnimatedBuilder(
            animation: _cometController,
            builder: (context, child) {
              return CustomPaint(
                painter: _CometPainter(
                  animation: _cometController.value,
                  colors: widget.topic.gradientColors,
                  isDark: isDark,
                  reverse: false,
                ),
                size: Size.infinite,
              );
            },
          ),
          AnimatedBuilder(
            animation: _cometController,
            builder: (context, child) {
              return CustomPaint(
                painter: _CometPainter(
                  animation: (_cometController.value + 0.5) % 1.0,
                  colors: widget.topic.gradientColors,
                  isDark: isDark,
                  reverse: true,
                ),
                size: Size.infinite,
              );
            },
          ),
          
          // Main content
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: widget.topic.slides.length,
            itemBuilder: (context, index) {
              return _buildSlide(
                theme,
                isDark,
                widget.topic.slides[index],
                index,
              );
            },
          ),
          
          // Top bar with progress and close
          _buildTopBar(theme, isDark),
          
          // Bottom controls
          _buildBottomControls(theme, isDark),
        ],
      ),
    );
  }

  Widget _buildTopBar(ThemeData theme, bool isDark) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Premium close button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        (isDark ? Colors.white : Colors.black).withValues(alpha: 0.15),
                        (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.25)
                          : Colors.black.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? Colors.black : Colors.grey.shade400)
                            .withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: isDark ? Colors.white : Colors.black87,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Premium progress bars
              Expanded(
                child: Row(
                  children: List.generate(
                    widget.topic.slides.length,
                    (index) => Expanded(
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          gradient: index <= _currentIndex
                              ? LinearGradient(
                                  colors: widget.topic.gradientColors,
                                )
                              : null,
                          color: index > _currentIndex
                              ? (isDark
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : Colors.black.withValues(alpha: 0.15))
                              : null,
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: index <= _currentIndex
                              ? [
                                  BoxShadow(
                                    color: widget.topic.gradientColors[0]
                                        .withValues(alpha: 0.4),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls(ThemeData theme, bool isDark) {
    final isLastSlide = _currentIndex == widget.topic.slides.length - 1;
    
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              if (_currentIndex > 0)
                _buildPremiumButton(
                  theme,
                  isDark,
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: _previousSlide,
                  isPrimary: false,
                ),
              const Spacer(),
              _buildPremiumButton(
                theme,
                isDark,
                label: isLastSlide ? 'Complete' : 'Continue',
                icon: isLastSlide ? Icons.check_rounded : Icons.arrow_forward_ios_rounded,
                onTap: () async {
                  if (isLastSlide) {
                    // Mark as completed
                    await ResourceProgressService.markResourceCompleted(widget.topic.id);
                    
                    // Show success animation
                    _showCompletionDialog(theme, isDark);
                  } else {
                    _nextSlide();
                  }
                },
                isPrimary: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildPremiumButton(
    ThemeData theme,
    bool isDark, {
    String? label,
    required IconData icon,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: label != null 
            ? const EdgeInsets.symmetric(horizontal: 18, vertical: 14)
            : const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: isPrimary 
              ? LinearGradient(
                  colors: widget.topic.gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    (isDark ? Colors.white : Colors.black).withValues(alpha: 0.15),
                    (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                  ],
                ),
          borderRadius: BorderRadius.circular(18),
          border: !isPrimary
              ? Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.2),
                  width: 1.5,
                )
              : null,
          boxShadow: [
            // Main shadow
            BoxShadow(
              color: isPrimary
                  ? widget.topic.gradientColors[0].withValues(alpha: 0.4)
                  : (isDark ? Colors.black : Colors.grey.shade600)
                      .withValues(alpha: 0.25),
              blurRadius: isPrimary ? 20 : 16,
              offset: Offset(0, isPrimary ? 8 : 6),
              spreadRadius: -2,
            ),
            // Inner glow for primary
            if (isPrimary)
              BoxShadow(
                color: widget.topic.gradientColors[1].withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 3),
                spreadRadius: -6,
              ),
            // Highlight
            BoxShadow(
              color: isPrimary
                  ? Colors.white.withValues(alpha: 0.15)
                  : (isDark ? Colors.white : Colors.white)
                      .withValues(alpha: isDark ? 0.08 : 0.5),
              blurRadius: 10,
              offset: const Offset(0, -2),
              spreadRadius: -6,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Shimmer overlay for primary button
            if (isPrimary)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: AnimatedBuilder(
                    animation: _shimmerController,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white.withValues(alpha: 0.15),
                              Colors.transparent,
                            ],
                            stops: const [0.3, 0.5, 0.7],
                            begin: Alignment(_shimmerAnimation.value, -1.0),
                            end: Alignment(_shimmerAnimation.value + 0.5, 1.0),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            
            // Button content
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (label != null) ...[
                  Text(
                    label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: isPrimary ? Colors.white : (isDark ? Colors.white : Colors.black87),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: isPrimary
                        ? Colors.white.withValues(alpha: 0.2)
                        : (isDark ? Colors.white : Colors.black)
                            .withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isPrimary ? Colors.white : (isDark ? Colors.white : Colors.black87),
                    size: label != null ? 16 : 18,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _showCompletionDialog(ThemeData theme, bool isDark) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      const Color(0xFF1a1a2e),
                      const Color(0xFF16213e),
                    ]
                  : [
                      Colors.white,
                      Colors.grey.shade50,
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: widget.topic.gradientColors[0].withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.topic.gradientColors[0].withValues(alpha: 0.3),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated success icon
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 800),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF4CAF50),
                            const Color(0xFF8BC34A),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4CAF50).withValues(alpha: 0.5),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: widget.topic.gradientColors,
                ).createShader(bounds),
                child: Text(
                  'Congratulations!',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              Text(
                'You\'ve completed "${widget.topic.title}"',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              
              // Premium close button
              GestureDetector(
                onTap: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close slides page
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.topic.gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: widget.topic.gradientColors[0].withValues(alpha: 0.5),
                        blurRadius: 28,
                        offset: const Offset(0, 12),
                        spreadRadius: -2,
                      ),
                      BoxShadow(
                        color: widget.topic.gradientColors[1].withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, -2),
                        spreadRadius: -8,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Shimmer effect
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedBuilder(
                            animation: _shimmerController,
                            builder: (context, child) {
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.white.withValues(alpha: 0.25),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.3, 0.5, 0.7],
                                    begin: Alignment(_shimmerAnimation.value, -1.0),
                                    end: Alignment(_shimmerAnimation.value + 0.5, 1.0),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      
                      // Text
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Continue Learning',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ],
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

  Widget _buildSlide(
    ThemeData theme,
    bool isDark,
    ResourceSlide slide,
    int index,
  ) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 100, 32, 100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSlideIcon(slide, isDark),
              const SizedBox(height: 32),
              _buildSlideTitle(theme, slide, isDark),
              const SizedBox(height: 20),
              _buildSlideContent(theme, slide, isDark),
              if (slide.type == SlideType.closing) ...[
                const SizedBox(height: 32),
                _buildClosingActions(theme, isDark),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlideIcon(ResourceSlide slide, bool isDark) {
    Widget iconWidget;
    
    if (slide.animationType == 'breathe') {
      iconWidget = AnimatedBuilder(
        animation: _breathAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _breathAnimation.value,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    slide.gradientColors![0].withValues(alpha: 0.3),
                    slide.gradientColors![1].withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Container(
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: slide.gradientColors!,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: slide.gradientColors![0].withValues(alpha: 0.5),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  slide.icon,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
          );
        },
      );
    } else if (slide.animationType == 'pulse') {
      iconWidget = AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: slide.gradientColors!,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: slide.gradientColors![0].withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                slide.icon,
                size: 44,
                color: Colors.white,
              ),
            ),
          );
        },
      );
    } else {
      iconWidget = ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: slide.gradientColors!,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: slide.gradientColors![0].withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            slide.icon,
            size: 44,
            color: Colors.white,
          ),
        ),
      );
    }
    
    return iconWidget;
  }

  Widget _buildSlideTitle(ThemeData theme, ResourceSlide slide, bool isDark) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: slide.gradientColors!,
      ).createShader(bounds),
      child: Text(
        slide.title,
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSlideContent(ThemeData theme, ResourceSlide slide, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.08),
                  Colors.white.withValues(alpha: 0.04),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.9),
                  slide.gradientColors![0].withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.15)
              : slide.gradientColors![0].withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : slide.gradientColors![0].withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: isDark
                ? Colors.white.withValues(alpha: 0.02)
                : Colors.white.withValues(alpha: 0.8),
            blurRadius: 16,
            offset: const Offset(0, -4),
            spreadRadius: -8,
          ),
        ],
      ),
      child: Column(
        children: [
          // Main content text
          Text(
            slide.content,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: (isDark ? Colors.white : Colors.black87).withValues(alpha: 0.9),
              height: 1.8,
              fontSize: slide.type == SlideType.affirmation ? 20 : 17,
              fontStyle: slide.type == SlideType.affirmation
                  ? FontStyle.italic
                  : FontStyle.normal,
              fontWeight: slide.type == SlideType.affirmation
                  ? FontWeight.w700
                  : FontWeight.w500,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
          
          // Add extra context/tips for practical slides
          if (slide.type == SlideType.practical) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: slide.gradientColors![0].withValues(alpha: isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: slide.gradientColors![0].withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: slide.gradientColors!,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: slide.gradientColors![0].withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.lightbulb_outline_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Practice this technique daily for best results',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: (isDark ? Colors.white : Colors.black87)
                            .withValues(alpha: 0.8),
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Add motivational note for insight slides
          if (slide.type == SlideType.insight) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    slide.gradientColors![0].withValues(alpha: 0.15),
                    slide.gradientColors![1].withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: slide.gradientColors![0].withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: slide.gradientColors![0],
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Knowledge is power',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: slide.gradientColors![0],
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildClosingActions(ThemeData theme, bool isDark) {
    return Column(
      children: [
        // Motivational quote/message
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.topic.gradientColors[0].withValues(alpha: isDark ? 0.15 : 0.1),
                widget.topic.gradientColors[1].withValues(alpha: isDark ? 0.1 : 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.topic.gradientColors[0].withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.topic.gradientColors,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.topic.gradientColors[0].withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.favorite_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'You\'re making amazing progress on your wellness journey!',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: (isDark ? Colors.white : Colors.black87)
                        .withValues(alpha: 0.85),
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Action buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildActionButton(
              theme,
              isDark,
              icon: Icons.bookmark_border_rounded,
              label: 'Save',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 12),
                        Text('Saved to your library!'),
                      ],
                    ),
                    backgroundColor: widget.topic.gradientColors[0],
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.all(20),
                  ),
                );
              },
            ),
            const SizedBox(width: 16),
            _buildActionButton(
              theme,
              isDark,
              icon: Icons.share_rounded,
              label: 'Share',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.white),
                        const SizedBox(width: 12),
                        Text('Share feature coming soon!'),
                      ],
                    ),
                    backgroundColor: widget.topic.gradientColors[0],
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.all(20),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    ThemeData theme,
    bool isDark, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              (isDark ? Colors.white : Colors.black).withValues(alpha: 0.14),
              (isDark ? Colors.white : Colors.black).withValues(alpha: 0.09),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: 0.18),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : Colors.grey.shade500)
                  .withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
              spreadRadius: -4,
            ),
            BoxShadow(
              color: (isDark ? Colors.white : Colors.white)
                  .withValues(alpha: isDark ? 0.05 : 0.5),
              blurRadius: 10,
              offset: const Offset(0, -2),
              spreadRadius: -6,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black)
                    .withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isDark ? Colors.white : Colors.black87,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Premium Galaxy Background Painter
class _GalaxyBackgroundPainter extends CustomPainter {
  final double animation;
  final List<Color> colors;
  final bool isDark;

  _GalaxyBackgroundPainter({
    required this.animation,
    required this.colors,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Create multiple moving gradient orbs
    final orbs = [
      {
        'x': size.width * (0.2 + 0.3 * math.sin(animation * 2 * math.pi)),
        'y': size.height * (0.3 + 0.2 * math.cos(animation * 2 * math.pi)),
        'radius': size.width * 0.4,
        'color': colors[0],
      },
      {
        'x': size.width * (0.8 + 0.2 * math.cos(animation * 2 * math.pi + math.pi / 3)),
        'y': size.height * (0.6 + 0.3 * math.sin(animation * 2 * math.pi + math.pi / 3)),
        'radius': size.width * 0.35,
        'color': colors[1],
      },
      {
        'x': size.width * (0.5 + 0.25 * math.sin(animation * 2 * math.pi + math.pi / 2)),
        'y': size.height * (0.8 + 0.15 * math.cos(animation * 2 * math.pi + math.pi / 2)),
        'radius': size.width * 0.3,
        'color': colors[0],
      },
    ];

    for (var orb in orbs) {
      paint.shader = RadialGradient(
        colors: [
          (orb['color'] as Color).withValues(alpha: isDark ? 0.15 : 0.08),
          (orb['color'] as Color).withValues(alpha: isDark ? 0.05 : 0.02),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(
        center: Offset(orb['x'] as double, orb['y'] as double),
        radius: orb['radius'] as double,
      ));

      canvas.drawCircle(
        Offset(orb['x'] as double, orb['y'] as double),
        orb['radius'] as double,
        paint,
      );
    }

    // Add floating particles with varying sizes
    final particlePaint = Paint();

    // Enhanced particles with 3 different size categories
    for (int i = 0; i < 30; i++) {
      final offset = (animation + i * 0.033) % 1.0;
      final x = size.width * ((i * 0.07 + offset) % 1.0);
      final y = size.height * ((i * 0.11 + math.sin(offset * 2 * math.pi) * 0.3) % 1.0);
      
      // Vary particle sizes more dramatically
      double radius;
      double opacity;
      
      if (i % 3 == 0) {
        // Large bubbles
        radius = 4.0 + math.sin(offset * 4 * math.pi) * 2.0;
        opacity = isDark ? 0.25 : 0.15;
      } else if (i % 3 == 1) {
        // Medium bubbles
        radius = 2.5 + math.cos(offset * 3 * math.pi) * 1.0;
        opacity = isDark ? 0.2 : 0.12;
      } else {
        // Small bubbles
        radius = 1.5 + math.sin(offset * 5 * math.pi) * 0.5;
        opacity = isDark ? 0.15 : 0.08;
      }
      
      // Alternate colors for more variety
      final color = i % 2 == 0 ? colors[0] : colors[1];
      particlePaint.color = color.withValues(alpha: opacity);
      
      canvas.drawCircle(Offset(x, y), radius, particlePaint);
    }
  }

  @override
  bool shouldRepaint(_GalaxyBackgroundPainter oldDelegate) => true;
}

// Premium Comet Painter
class _CometPainter extends CustomPainter {
  final double animation;
  final List<Color> colors;
  final bool isDark;
  final bool reverse;

  _CometPainter({
    required this.animation,
    required this.colors,
    required this.isDark,
    this.reverse = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Comet path (diagonal across screen)
    final progress = animation % 1.0;
    
    // Different paths based on reverse parameter
    final double startX;
    final double startY;
    final double tailDx;
    final double tailDy;
    
    if (reverse) {
      // Top-right to bottom-left
      startX = size.width + 100 - (size.width + 200) * progress;
      startY = -50 + (size.height + 100) * progress * 0.7;
      tailDx = 80;
      tailDy = -40;
    } else {
      // Top-left to bottom-right (original)
      startX = -100 + (size.width + 200) * progress;
      startY = -50 + (size.height + 100) * progress * 0.6;
      tailDx = -80;
      tailDy = -50;
    }

    // Comet head
    final headPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          colors[0].withValues(alpha: isDark ? 0.6 : 0.4),
          colors[1].withValues(alpha: isDark ? 0.3 : 0.2),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(startX, startY),
        radius: 12,
      ));

    canvas.drawCircle(Offset(startX, startY), 12, headPaint);

    // Comet tail (gradient trail)
    final path = Path();
    path.moveTo(startX, startY);
    
    for (int i = 0; i < 8; i++) {
      final t = i / 8.0;
      final x = startX + tailDx * t;
      final y = startY + tailDy * t;
      
      path.lineTo(x, y);
    }

    final tailPaint = Paint()
      ..shader = LinearGradient(
        begin: reverse ? Alignment.topLeft : Alignment.topRight,
        end: reverse ? Alignment.bottomRight : Alignment.bottomLeft,
        colors: [
          colors[0].withValues(alpha: isDark ? 0.4 : 0.25),
          colors[1].withValues(alpha: isDark ? 0.2 : 0.12),
          Colors.transparent,
        ],
      ).createShader(Rect.fromPoints(
        Offset(startX, startY),
        Offset(startX + tailDx, startY + tailDy),
      ))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, tailPaint);
  }

  @override
  bool shouldRepaint(_CometPainter oldDelegate) => true;
}
