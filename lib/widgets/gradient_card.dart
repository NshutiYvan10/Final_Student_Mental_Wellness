import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/mood_theme_provider.dart';

class GradientCard extends ConsumerWidget {
  final Widget child;
  final List<Color>? colors;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool isElevated;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final bool useMoodTheme;
  
  const GradientCard({
    super.key,
    required this.child,
    this.colors,
    this.padding = const EdgeInsets.all(20),
    this.radius = 16,
    this.isElevated = true,
    this.onTap,
    this.backgroundColor,
    this.useMoodTheme = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    List<Color>? gradientColors = colors;
    if (gradientColors == null && useMoodTheme) {
      final moodTheme = ref.watch(moodThemeProvider);
      gradientColors = moodTheme.primaryGradient;
    }
    
    Widget card = Container(
      decoration: BoxDecoration(
        gradient: gradientColors != null 
            ? LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: backgroundColor ?? (isDark ? const Color(0xFF1E293B) : Colors.white),
        borderRadius: BorderRadius.circular(radius),
        border: isDark 
            ? Border.all(color: const Color(0xFF334155), width: 1)
            : null,
        boxShadow: isElevated ? [
          BoxShadow(
            color: isDark 
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: isDark 
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ] : null,
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: card,
        ),
      );
    }

    return card;
  }
}


