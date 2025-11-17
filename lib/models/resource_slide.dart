import 'package:flutter/material.dart';

enum SlideType {
  intro,
  insight,
  practical,
  affirmation,
  closing,
}

class ResourceSlide {
  final SlideType type;
  final String title;
  final String content;
  final IconData? icon;
  final String? animationType; // 'pulse', 'breathe', 'fade', 'scale'
  final List<Color>? gradientColors;

  const ResourceSlide({
    required this.type,
    required this.title,
    required this.content,
    this.icon,
    this.animationType,
    this.gradientColors,
  });
}

class ResourceTopic {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final String category;
  final int estimatedMinutes;
  final List<ResourceSlide> slides;

  const ResourceTopic({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.gradientColors,
    required this.category,
    required this.estimatedMinutes,
    required this.slides,
  });
}

class ResourceData {
  static final List<ResourceTopic> topics = [
    ResourceTopic(
      id: 'anxiety-stress',
      title: 'Anxiety & Stress Management',
      subtitle: 'Find Your Calm',
      description: 'Discover powerful techniques to reduce anxiety and manage stress effectively',
      icon: Icons.spa_rounded,
      gradientColors: [const Color(0xFF667eea), const Color(0xFF764ba2)],
      category: 'Mental Wellness',
      estimatedMinutes: 5,
      slides: [
        ResourceSlide(
          type: SlideType.intro,
          title: 'Welcome to Inner Peace',
          content: 'Anxiety affects millions of students worldwide, but you have the power to manage it. You\'ll learn evidence-based techniques used by therapists to reduce anxiety and build lasting calm.',
          icon: Icons.spa_rounded,
          animationType: 'pulse',
          gradientColors: [const Color(0xFF667eea), const Color(0xFF764ba2)],
        ),
        ResourceSlide(
          type: SlideType.insight,
          title: 'Understanding Anxiety',
          content: 'Anxiety is your body\'s natural alarm system—it prepares you for action when danger appears. Your heart races, breathing quickens, and muscles tense.\n\nWhile helpful in emergencies, this response can be triggered by exams or social situations. The good news? You can retrain your nervous system.',
          icon: Icons.lightbulb_outline_rounded,
          animationType: 'fade',
          gradientColors: [const Color(0xFF667eea), const Color(0xFF764ba2)],
        ),
        ResourceSlide(
          type: SlideType.practical,
          title: 'The 4-7-8 Breathing Technique',
          content: 'This activates your relaxation response:\n\n1. Inhale through your nose for 4 counts\n2. Hold your breath for 7 counts\n3. Exhale through your mouth for 8 counts\n\nRepeat 3-4 cycles when anxiety strikes. You\'ll feel calmer within 60 seconds.',
          icon: Icons.air_rounded,
          animationType: 'breathe',
          gradientColors: [const Color(0xFF667eea), const Color(0xFF764ba2)],
        ),
        ResourceSlide(
          type: SlideType.affirmation,
          title: 'Your Daily Mantra',
          content: '"I am calm, I am centered, and I trust in my ability to handle whatever comes my way. My breath is my anchor."',
          icon: Icons.favorite_rounded,
          animationType: 'scale',
          gradientColors: [const Color(0xFF667eea), const Color(0xFF764ba2)],
        ),
        ResourceSlide(
          type: SlideType.closing,
          title: 'Your Journey Forward',
          content: 'Managing anxiety is a skill that improves with practice. Start with just 2 minutes of breathing exercises daily. Track your progress and be patient with yourself.\n\nYou\'re building resilience for life.',
          icon: Icons.celebration_rounded,
          animationType: 'pulse',
          gradientColors: [const Color(0xFF667eea), const Color(0xFF764ba2)],
        ),
      ],
    ),
    ResourceTopic(
      id: 'self-esteem',
      title: 'Self-Esteem & Positive Thinking',
      subtitle: 'Embrace Your Worth',
      description: 'Build confidence and cultivate a positive mindset that empowers you',
      icon: Icons.emoji_emotions_rounded,
      gradientColors: [const Color(0xFFf093fb), const Color(0xFFf5576c)],
      category: 'Personal Growth',
      estimatedMinutes: 6,
      slides: [
        ResourceSlide(
          type: SlideType.intro,
          title: 'Discover Your Inner Strength',
          content: 'Self-esteem isn\'t about being perfect—it\'s about accepting yourself while striving to grow. Research shows healthy self-esteem improves relationships, academic performance, and happiness.\n\nYou\'re about to learn practices that transform how you see yourself.',
          icon: Icons.emoji_emotions_rounded,
          animationType: 'pulse',
          gradientColors: [const Color(0xFFf093fb), const Color(0xFFf5576c)],
        ),
        ResourceSlide(
          type: SlideType.insight,
          title: 'The Science of Self-Talk',
          content: 'Your brain believes what you tell it repeatedly. Neuroscience reveals that positive self-talk rewires neural pathways, creating new thinking patterns.\n\nStudies show it reduces stress hormones, improves problem-solving, and increases resilience.',
          icon: Icons.psychology_rounded,
          animationType: 'fade',
          gradientColors: [const Color(0xFFf093fb), const Color(0xFFf5576c)],
        ),
        ResourceSlide(
          type: SlideType.practical,
          title: 'Daily Mirror Exercise',
          content: 'Stand before a mirror, make eye contact with yourself, and say with conviction:\n\n"I am enough, exactly as I am."\n"I am capable of amazing things."\n"I deserve love and respect."\n\nSmile genuinely. Feel it. This rewires negative patterns.',
          icon: Icons.auto_awesome_rounded,
          animationType: 'scale',
          gradientColors: [const Color(0xFFf093fb), const Color(0xFFf5576c)],
        ),
        ResourceSlide(
          type: SlideType.affirmation,
          title: 'Your Truth Statement',
          content: '"I honor my uniqueness and celebrate my progress. I am becoming the best version of myself, one choice at a time. My worth is inherent."',
          icon: Icons.favorite_rounded,
          animationType: 'pulse',
          gradientColors: [const Color(0xFFf093fb), const Color(0xFFf5576c)],
        ),
        ResourceSlide(
          type: SlideType.closing,
          title: 'Your Ongoing Journey',
          content: 'Building self-esteem takes consistent practice. Set a phone reminder for your daily mirror exercise. Journal three things you appreciate about yourself each night.\n\nWatch your self-perception transform over 30 days.',
          icon: Icons.stars_rounded,
          animationType: 'scale',
          gradientColors: [const Color(0xFFf093fb), const Color(0xFFf5576c)],
        ),
      ],
    ),
    ResourceTopic(
      id: 'relationships',
      title: 'Relationships & Communication',
      subtitle: 'Connect Authentically',
      description: 'Strengthen bonds and communicate with clarity, empathy, and confidence',
      icon: Icons.people_rounded,
      gradientColors: [const Color(0xFF56ab2f), const Color(0xFFa8e063)],
      category: 'Social Wellness',
      estimatedMinutes: 5,
      slides: [
        ResourceSlide(
          type: SlideType.intro,
          title: 'The Art of Connection',
          content: 'Strong relationships are the #1 predictor of happiness and longevity. Yet many struggle with communication.\n\nYou\'ll learn practical skills that transform how you connect with friends, family, and partners.',
          icon: Icons.people_rounded,
          animationType: 'pulse',
          gradientColors: [const Color(0xFF56ab2f), const Color(0xFFa8e063)],
        ),
        ResourceSlide(
          type: SlideType.insight,
          title: 'Active Listening Mastery',
          content: 'Most conversations are just people waiting to talk. True active listening means:\n\n• Focus fully without distraction\n• Notice body language\n• Suspend judgment\n• Ask clarifying questions\n\nWhen people feel truly heard, trust deepens instantly.',
          icon: Icons.hearing_rounded,
          animationType: 'fade',
          gradientColors: [const Color(0xFF56ab2f), const Color(0xFFa8e063)],
        ),
        ResourceSlide(
          type: SlideType.practical,
          title: '3-Step Response Framework',
          content: 'When emotions run high:\n\n1. PAUSE: Take 3 deep breaths\n2. VALIDATE: "I hear that you\'re feeling..."\n3. SHARE: Use "I feel..." not "You always..."\n\nThis de-escalates conflict and builds understanding.',
          icon: Icons.chat_bubble_outline_rounded,
          animationType: 'scale',
          gradientColors: [const Color(0xFF56ab2f), const Color(0xFFa8e063)],
        ),
        ResourceSlide(
          type: SlideType.affirmation,
          title: 'Communication Commitment',
          content: '"I communicate with kindness, clarity, and courage. I listen to understand. I build relationships rooted in authenticity and respect."',
          icon: Icons.favorite_rounded,
          animationType: 'pulse',
          gradientColors: [const Color(0xFF56ab2f), const Color(0xFFa8e063)],
        ),
        ResourceSlide(
          type: SlideType.closing,
          title: 'Practice Makes Progress',
          content: 'Choose one relationship to focus on this week. Before your next conversation, set an intention to truly listen. Notice how it changes the dynamic.\n\nHealthy communication transforms every area of life.',
          icon: Icons.favorite_border_rounded,
          animationType: 'scale',
          gradientColors: [const Color(0xFF56ab2f), const Color(0xFFa8e063)],
        ),
      ],
    ),
    ResourceTopic(
      id: 'physical-wellness',
      title: 'Physical Wellness & Nutrition',
      subtitle: 'Nourish Your Body',
      description: 'Learn simple habits for better health, energy, and vitality',
      icon: Icons.fitness_center_rounded,
      gradientColors: [const Color(0xFFFF6B6B), const Color(0xFFFFE66D)],
      category: 'Physical Health',
      estimatedMinutes: 5,
      slides: [
        ResourceSlide(
          type: SlideType.intro,
          title: 'Your Body Is Your Foundation',
          content: 'Physical wellness directly impacts mental health, academic performance, and life satisfaction. When you feel good physically, everything else becomes easier.\n\nThese are proven strategies used by peak performers.',
          icon: Icons.fitness_center_rounded,
          animationType: 'pulse',
          gradientColors: [const Color(0xFFFF6B6B), const Color(0xFFFFE66D)],
        ),
        ResourceSlide(
          type: SlideType.insight,
          title: 'The Mind-Body Connection',
          content: 'Exercise releases endorphins, dopamine, and serotonin—natural antidepressants. Just 20 minutes of movement:\n\n• Reduces anxiety by 40%\n• Improves focus for 2-3 hours\n• Enhances sleep quality\n• Boosts confidence',
          icon: Icons.psychology_alt_rounded,
          animationType: 'fade',
          gradientColors: [const Color(0xFFFF6B6B), const Color(0xFFFFE66D)],
        ),
        ResourceSlide(
          type: SlideType.practical,
          title: 'Daily Wellness Checklist',
          content: 'Start with ONE habit this week:\n\n✓ Hydrate: 8 glasses of water\n✓ Breathe: 3 deep breaths hourly\n✓ Stretch: 5-minute morning routine\n✓ Nourish: Add colorful vegetables\n✓ Move: 20-minute activity\n\nTrack for 7 days.',
          icon: Icons.check_circle_outline_rounded,
          animationType: 'scale',
          gradientColors: [const Color(0xFFFF6B6B), const Color(0xFFFFE66D)],
        ),
        ResourceSlide(
          type: SlideType.affirmation,
          title: 'Your Wellness Vow',
          content: '"I honor my body with intentional movement, nourishing food, and rest. I am grateful for my health and treat my body with love."',
          icon: Icons.favorite_rounded,
          animationType: 'pulse',
          gradientColors: [const Color(0xFFFF6B6B), const Color(0xFFFFE66D)],
        ),
        ResourceSlide(
          type: SlideType.closing,
          title: 'Small Steps, Big Results',
          content: 'Pick ONE habit from the checklist. Set a daily reminder. Track your progress for 21 days.\n\nConsistent small actions compound into remarkable results. Your future self will thank you.',
          icon: Icons.emoji_events_rounded,
          animationType: 'scale',
          gradientColors: [const Color(0xFFFF6B6B), const Color(0xFFFFE66D)],
        ),
      ],
    ),
  ];
}
