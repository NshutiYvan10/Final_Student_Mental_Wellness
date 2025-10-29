import 'package:flutter_test/flutter_test.dart';
import 'package:student_mental_wellness/services/ml_service.dart';

void main() {
  // Ensure the Flutter testing binding is initialized for services that
  // rely on Widgets/ServicesBinding (model loading, asset access, etc.).
  TestWidgetsFlutterBinding.ensureInitialized();
  group('MlService', () {
    test('analyzeSentiment returns positive score for positive text', () async {
      final ml = MlService();
      final score = await ml.analyzeSentiment('I am very happy and grateful. This is amazing!');
      expect(score, greaterThan(0));
    });

    test('analyzeSentiment returns negative score for negative text', () async {
      final ml = MlService();
      final score = await ml.analyzeSentiment('I feel sad, stressed, and overwhelmed.');
      expect(score, lessThan(0));
    });
  });
}



