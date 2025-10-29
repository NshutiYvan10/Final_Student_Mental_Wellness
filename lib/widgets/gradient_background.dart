import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/mood_theme_provider.dart';

class GradientBackground extends ConsumerWidget {
  final Widget child;
  final List<Color>? colors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final bool isAnimated;
  final bool useMoodTheme;
  
  const GradientBackground({
    super.key,
    required this.child,
    this.colors,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.isAnimated = false,
    this.useMoodTheme = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    List<Color> gradientColors;
    
    if (colors != null) {
      gradientColors = colors!;
    } else if (useMoodTheme) {
      final moodTheme = ref.watch(moodThemeProvider);
      gradientColors = [
        moodTheme.primaryGradient[0].withValues(alpha: 0.1),
        moodTheme.primaryGradient[1].withValues(alpha: 0.05),
        theme.scaffoldBackgroundColor,
      ];
    } else {
      gradientColors = isDark 
          ? [
              const Color(0xFF0F172A),
              const Color(0xFF1E293B),
              const Color(0xFF334155),
            ]
          : [
              const Color(0xFFF8FAFC),
              const Color(0xFFF1F5F9),
              const Color(0xFFE2E8F0),
            ];
    }

    Widget background = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: begin,
          end: end,
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: child,
    );

    if (isAnimated) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: background,
      );
    }

    return background;
  }
}


