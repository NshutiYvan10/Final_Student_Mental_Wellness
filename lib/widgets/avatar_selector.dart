import 'package:flutter/material.dart';

class AvatarSelector extends StatefulWidget {
  final String? selectedAvatar;
  final Function(String) onAvatarSelected;

  const AvatarSelector({
    super.key,
    this.selectedAvatar,
    required this.onAvatarSelected,
  });

  @override
  State<AvatarSelector> createState() => _AvatarSelectorState();
}

class _AvatarSelectorState extends State<AvatarSelector> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  static final List<Map<String, dynamic>> availableAvatars = [
    {
      'id': 'gradient_1',
      'icon': Icons.person_rounded,
      'colors': [Color(0xFF6366F1), Color(0xFF8B5CF6)],
      'name': 'Purple Dream'
    },
    {
      'id': 'gradient_2',
      'icon': Icons.face_rounded,
      'colors': [Color(0xFFEC4899), Color(0xFFF472B6)],
      'name': 'Pink Blossom'
    },
    {
      'id': 'gradient_3',
      'icon': Icons.emoji_emotions_rounded,
      'colors': [Color(0xFF10B981), Color(0xFF34D399)],
      'name': 'Green Energy'
    },
    {
      'id': 'gradient_4',
      'icon': Icons.sentiment_very_satisfied_rounded,
      'colors': [Color(0xFFF59E0B), Color(0xFFFBBF24)],
      'name': 'Golden Sun'
    },
    {
      'id': 'gradient_5',
      'icon': Icons.star_rounded,
      'colors': [Color(0xFF3B82F6), Color(0xFF60A5FA)],
      'name': 'Ocean Blue'
    },
    {
      'id': 'gradient_6',
      'icon': Icons.favorite_rounded,
      'colors': [Color(0xFFEF4444), Color(0xFFF87171)],
      'name': 'Red Passion'
    },
    {
      'id': 'gradient_7',
      'icon': Icons.psychology_rounded,
      'colors': [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
      'name': 'Violet Mind'
    },
    {
      'id': 'gradient_8',
      'icon': Icons.wb_sunny_rounded,
      'colors': [Color(0xFFF59E0B), Color(0xFFEF4444)],
      'name': 'Sunset Glow'
    },
    {
      'id': 'gradient_9',
      'icon': Icons.auto_awesome_rounded,
      'colors': [Color(0xFF06B6D4), Color(0xFF3B82F6)],
      'name': 'Cyan Wave'
    },
    {
      'id': 'gradient_10',
      'icon': Icons.spa_rounded,
      'colors': [Color(0xFF10B981), Color(0xFF06B6D4)],
      'name': 'Mint Fresh'
    },
    {
      'id': 'gradient_11',
      'icon': Icons.diamond_rounded,
      'colors': [Color(0xFFEC4899), Color(0xFF8B5CF6)],
      'name': 'Purple Pink'
    },
    {
      'id': 'gradient_12',
      'icon': Icons.palette_rounded,
      'colors': [Color(0xFFF59E0B), Color(0xFF10B981)],
      'name': 'Rainbow Mix'
    },
  ];

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _shimmerAnimation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.08),
            theme.colorScheme.secondary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
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
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.face_retouching_natural_rounded,
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
                      'Choose Your Avatar',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Select a style that represents you',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemCount: availableAvatars.length,
            itemBuilder: (context, index) {
              final avatar = availableAvatars[index];
              final isSelected = widget.selectedAvatar == avatar['id'];
              
              return GestureDetector(
                onTap: () => widget.onAvatarSelected(avatar['id']),
                child: TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 200 + (index * 30)),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.8 + (0.2 * value),
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isSelected 
                            ? avatar['colors']
                            : [
                                (avatar['colors'][0] as Color).withValues(alpha: 0.3),
                                (avatar['colors'][1] as Color).withValues(alpha: 0.2),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected 
                            ? avatar['colors'][0].withValues(alpha: 0.6)
                            : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: avatar['colors'][0].withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                                spreadRadius: -2,
                              ),
                              BoxShadow(
                                color: avatar['colors'][1].withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: (isDark ? Colors.black : Colors.grey.shade400)
                                    .withValues(alpha: 0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                                spreadRadius: -2,
                              ),
                            ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Icon
                        Icon(
                          avatar['icon'],
                          size: isSelected ? 24 : 22,
                          color: isSelected 
                              ? Colors.white 
                              : (isDark ? Colors.white70 : Colors.white.withValues(alpha: 0.9)),
                        ),
                        
                        // Check mark for selected - positioned at top right corner
                        if (isSelected)
                          Positioned(
                            top: -8,
                            right: -8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.check_rounded,
                                size: 10,
                                color: avatar['colors'][0],
                              ),
                            ),
                          ),
                      ],
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
}

