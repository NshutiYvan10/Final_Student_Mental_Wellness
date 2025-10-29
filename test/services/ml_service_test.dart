import 'package:flutter_test/flutter_test.dart';
import 'package:student_mental_wellness/services/ml_service.dart';

void main() {
  // Ensure the Flutter testing binding is initialized for services that
  // rely on Widgets/ServicesBinding (model loading, asset access, etc.).
  TestWidgetsFlutterBinding.ensureInitialized();
  group('MlService', () {
    late MlService mlService;

    setUp(() {
      mlService = MlService();
    });

    group('analyzeSentiment', () {
      test('should return 0 for empty text', () async {
        // Act
        final result = await mlService.analyzeSentiment('');

        // Assert
        expect(result, equals(0.0));
      });

      test('should return 0 for whitespace-only text', () async {
        // Act
        final result = await mlService.analyzeSentiment('   \n\t  ');

        // Assert
        expect(result, equals(0.0));
      });

      test('should return positive sentiment for positive words', () async {
        // Act
        final result = await mlService.analyzeSentiment('I am happy and excited today!');

        // Assert
        expect(result, greaterThan(0.0));
        expect(result, lessThanOrEqualTo(1.0));
      });

      test('should return negative sentiment for negative words', () async {
        // Act
        final result = await mlService.analyzeSentiment('I am sad and depressed today');

        // Assert
        expect(result, lessThan(0.0));
        expect(result, greaterThanOrEqualTo(-1.0));
      });

      test('should return neutral sentiment for neutral text', () async {
        // Act
        final result = await mlService.analyzeSentiment('The weather is okay today');

        // Assert
        expect(result, greaterThanOrEqualTo(-1.0));
        expect(result, lessThanOrEqualTo(1.0));
      });

      test('should handle mixed sentiment text', () async {
        // Act
        final result = await mlService.analyzeSentiment('I am happy but also worried about the exam');

        // Assert
        expect(result, greaterThanOrEqualTo(-1.0));
        expect(result, lessThanOrEqualTo(1.0));
      });

      test('should return values in correct range [-1, 1]', () async {
        // Test various inputs
        final testCases = [
          'I love this amazing wonderful fantastic day!',
          'I hate this terrible awful horrible situation',
          'Today is a normal day with nothing special',
          'I am extremely happy and joyful',
          'I feel completely hopeless and worthless',
        ];

        for (final text in testCases) {
          final result = await mlService.analyzeSentiment(text);
          expect(result, greaterThanOrEqualTo(-1.0), reason: 'Result should be >= -1 for text: $text');
          expect(result, lessThanOrEqualTo(1.0), reason: 'Result should be <= 1 for text: $text');
        }
      });

      test('should be case insensitive', () async {
        // Act
        final result1 = await mlService.analyzeSentiment('I am HAPPY');
        final result2 = await mlService.analyzeSentiment('i am happy');
        final result3 = await mlService.analyzeSentiment('I Am Happy');

        // Assert
        expect(result1, equals(result2));
        expect(result2, equals(result3));
      });

      test('should handle long text', () async {
        // Arrange
        final longText = 'I am feeling ' + 'happy ' * 100 + 'today!';

        // Act
        final result = await mlService.analyzeSentiment(longText);

        // Assert
        expect(result, greaterThan(0.0));
        expect(result, lessThanOrEqualTo(1.0));
      });

      test('should handle special characters and punctuation', () async {
        // Act
        final result = await mlService.analyzeSentiment('I am happy!!! 😊 🎉');

        // Assert
        expect(result, greaterThanOrEqualTo(-1.0));
        expect(result, lessThanOrEqualTo(1.0));
      });
    });

    group('initialization', () {
      test('should initialize without errors', () async {
        // Act & Assert
        expect(() => mlService.initialize(), returnsNormally);
      });

      test('should handle multiple initialization calls', () async {
        // Act
        await mlService.initialize();
        await mlService.initialize();
        await mlService.initialize();

        // Assert - should not throw
        expect(true, isTrue);
      });
    });

    group('properties', () {
      test('should have correct initial state', () {
        // Assert
        expect(mlService.isInitialized, isFalse);
        expect(mlService.isModelLoaded, isFalse);
      });

      test('should update state after initialization', () async {
        // Act
        await mlService.initialize();

        // Assert
        expect(mlService.isInitialized, isTrue);
        // isModelLoaded depends on whether the model was successfully loaded
      });
    });

    group('heuristic sentiment analysis', () {
      test('should identify positive words correctly', () async {
        final positiveWords = [
          'happy', 'great', 'good', 'calm', 'love',
          'amazing', 'wonderful', 'fantastic', 'excellent',
          'grateful', 'blessed', 'proud', 'confident',
          'excited', 'enthusiastic', 'motivated', 'inspired'
        ];

        for (final word in positiveWords) {
          final result = await mlService.analyzeSentiment('I am $word today');
          expect(result, greaterThan(0.0), reason: 'Word "$word" should be positive');
        }
      });

      test('should identify negative words correctly', () async {
        final negativeWords = [
          'sad', 'depressed', 'anxious', 'worried', 'angry',
          'frustrated', 'stressed', 'overwhelmed', 'tired',
          'exhausted', 'lonely', 'isolated', 'hopeless',
          'helpless', 'worthless', 'useless', 'terrible',
          'awful', 'horrible', 'disappointed', 'hurt'
        ];

        for (final word in negativeWords) {
          final result = await mlService.analyzeSentiment('I am $word today');
          expect(result, lessThan(0.0), reason: 'Word "$word" should be negative');
        }
      });

      test('should handle multiple positive words', () async {
        // Act
        final result = await mlService.analyzeSentiment('I am happy and excited and grateful today');

        // Assert
        expect(result, greaterThan(0.0));
      });

      test('should handle multiple negative words', () async {
        // Act
        final result = await mlService.analyzeSentiment('I am sad and anxious and worried today');

        // Assert
        expect(result, lessThan(0.0));
      });

      test('should handle mixed positive and negative words', () async {
        // Act
        final result = await mlService.analyzeSentiment('I am happy but also sad today');

        // Assert
        expect(result, greaterThanOrEqualTo(-1.0));
        expect(result, lessThanOrEqualTo(1.0));
      });
    });
  });
}


