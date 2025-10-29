import 'package:flutter/material.dart';
import 'dart:math' as math;

class WordCloudWidget extends StatelessWidget {
  final Map<String, int> wordFrequencies;
  final int maxWords;
  final double minFontSize;
  final double maxFontSize;
  final List<Color> colors;

  const WordCloudWidget({
    super.key,
    required this.wordFrequencies,
    this.maxWords = 50,
    this.minFontSize = 12.0,
    this.maxFontSize = 32.0,
    this.colors = const [
      Color(0xFF2196F3),
      Color(0xFF4CAF50),
      Color(0xFFFF9800),
      Color(0xFF9C27B0),
      Color(0xFFF44336),
      Color(0xFF00BCD4),
      Color(0xFFFFC107),
      Color(0xFF795548),
    ],
  });

  @override
  Widget build(BuildContext context) {
    if (wordFrequencies.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 48,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 8),
              Text(
                'No journal entries yet',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final sortedWords = _getSortedWords();
    final positionedWords = _generateWordPositions(sortedWords);

    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CustomPaint(
          painter: WordCloudPainter(
            positionedWords: positionedWords,
            colors: colors,
          ),
          child: Container(),
        ),
      ),
    );
  }

  List<MapEntry<String, int>> _getSortedWords() {
    final entries = wordFrequencies.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries.take(maxWords).toList();
  }

  List<PositionedWord> _generateWordPositions(List<MapEntry<String, int>> words) {
    final positionedWords = <PositionedWord>[];
    final random = math.Random(42); // Fixed seed for consistent positioning
    final maxAttempts = 100;

    for (final entry in words) {
      final word = entry.key;
      final frequency = entry.value;
      final fontSize = _calculateFontSize(frequency);
      
      // Calculate word dimensions (approximate)
      final wordWidth = word.length * fontSize * 0.6;
      final wordHeight = fontSize * 1.2;

      PositionedWord? positionedWord;
      int attempts = 0;

      while (positionedWord == null && attempts < maxAttempts) {
        final x = random.nextDouble() * (300 - wordWidth);
        final y = random.nextDouble() * (300 - wordHeight);
        
        final candidate = PositionedWord(
          word: word,
          x: x,
          y: y,
          fontSize: fontSize,
          color: colors[random.nextInt(colors.length)],
          frequency: frequency,
        );

        // Check for collisions
        bool hasCollision = false;
        for (final existing in positionedWords) {
          if (_wordsCollide(candidate, existing)) {
            hasCollision = true;
            break;
          }
        }

        if (!hasCollision) {
          positionedWord = candidate;
        }

        attempts++;
      }

      if (positionedWord != null) {
        positionedWords.add(positionedWord);
      }
    }

    return positionedWords;
  }

  double _calculateFontSize(int frequency) {
    if (wordFrequencies.isEmpty) return minFontSize;
    
    final maxFreq = wordFrequencies.values.reduce(math.max);
    final minFreq = wordFrequencies.values.reduce(math.min);
    
    if (maxFreq == minFreq) return (minFontSize + maxFontSize) / 2;
    
    final normalizedFreq = (frequency - minFreq) / (maxFreq - minFreq);
    return minFontSize + (maxFontSize - minFontSize) * normalizedFreq;
  }

  bool _wordsCollide(PositionedWord word1, PositionedWord word2) {
    final margin = 5.0; // Minimum margin between words
    
    return !(word1.x + word1.width + margin < word2.x ||
             word2.x + word2.width + margin < word1.x ||
             word1.y + word1.height + margin < word2.y ||
             word2.y + word2.height + margin < word1.y);
  }
}

class PositionedWord {
  final String word;
  final double x;
  final double y;
  final double fontSize;
  final Color color;
  final int frequency;

  PositionedWord({
    required this.word,
    required this.x,
    required this.y,
    required this.fontSize,
    required this.color,
    required this.frequency,
  });

  double get width => word.length * fontSize * 0.6;
  double get height => fontSize * 1.2;
}

class WordCloudPainter extends CustomPainter {
  final List<PositionedWord> positionedWords;

  WordCloudPainter({
    required this.positionedWords,
    required this.colors,
  });

  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    for (final word in positionedWords) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: word.word,
          style: TextStyle(
            fontSize: word.fontSize,
            color: word.color,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(word.x, word.y),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}


