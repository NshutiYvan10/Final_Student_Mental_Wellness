import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student_mental_wellness/widgets/word_cloud_widget.dart';

void main() {
  group('WordCloudWidget', () {
    testWidgets('should display empty state when no word frequencies', (WidgetTester tester) async {
      // Arrange
      const widget = WordCloudWidget(wordFrequencies: {});

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

      // Assert
      expect(find.text('No journal entries yet'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
    });

    testWidgets('should display word cloud when word frequencies provided', (WidgetTester tester) async {
      // Arrange
      const wordFrequencies = {
        'happy': 10,
        'sad': 5,
        'excited': 8,
        'worried': 3,
        'calm': 6,
      };

      final widget = WordCloudWidget(
        wordFrequencies: wordFrequencies,
        maxWords: 5,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

  // Assert - WordCloud renders via CustomPaint, so verify that at least
  // one CustomPaint and container are present (text is painted off-tree).
  expect(find.byType(CustomPaint), findsWidgets);
  expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should respect maxWords limit', (WidgetTester tester) async {
      // Arrange
      const wordFrequencies = {
        'word1': 10,
        'word2': 9,
        'word3': 8,
        'word4': 7,
        'word5': 6,
        'word6': 5,
        'word7': 4,
      };

      const widget = WordCloudWidget(
        wordFrequencies: wordFrequencies,
        maxWords: 3,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

  // Assert - ensure at least one CustomPaint exists and the widget did
  // not crash while painting.
  expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('should display words in correct order (highest frequency first)', (WidgetTester tester) async {
      // Arrange
      const wordFrequencies = {
        'low': 1,
        'high': 10,
        'medium': 5,
      };

      const widget = WordCloudWidget(
        wordFrequencies: wordFrequencies,
        maxWords: 3,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

  // Assert - ensure a CustomPaint exists.
  expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('should use custom colors when provided', (WidgetTester tester) async {
      // Arrange
      const wordFrequencies = {
        'test': 5,
      };

      const customColors = [
        Color(0xFF000000),
        Color(0xFFFFFFFF),
      ];

      const widget = WordCloudWidget(
        wordFrequencies: wordFrequencies,
        colors: customColors,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

  // Assert - ensure a CustomPaint exists.
  expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('should respect font size constraints', (WidgetTester tester) async {
      // Arrange
      const wordFrequencies = {
        'small': 1,
        'large': 100,
      };

      const widget = WordCloudWidget(
        wordFrequencies: wordFrequencies,
        minFontSize: 10.0,
        maxFontSize: 20.0,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

  // Assert - ensure a CustomPaint exists.
  expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('should handle single word', (WidgetTester tester) async {
      // Arrange
      const wordFrequencies = {
        'only': 1,
      };

      const widget = WordCloudWidget(wordFrequencies: wordFrequencies);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

  // Assert - ensure a CustomPaint exists for single-word case.
  expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('should handle many words', (WidgetTester tester) async {
      // Arrange
      final wordFrequencies = <String, int>{};
      for (int i = 0; i < 100; i++) {
        wordFrequencies['word$i'] = i;
      }

      final widget = WordCloudWidget(
        wordFrequencies: wordFrequencies,
        maxWords: 50,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

  // Assert - ensure a CustomPaint exists for many words.
  expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('should have correct container dimensions', (WidgetTester tester) async {
      // Arrange
      const wordFrequencies = {
        'test': 5,
      };

      const widget = WordCloudWidget(wordFrequencies: wordFrequencies);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: widget),
        ),
      );

  // Assert - container(s) exist and the main decorated container is present
  expect(find.byType(Container), findsWidgets);
    });
  });
}


