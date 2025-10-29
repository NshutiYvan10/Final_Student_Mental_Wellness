import 'dart:typed_data';
import 'dart:io';

import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'firebase_service.dart';

class MlService {
  tfl.Interpreter? _interpreter;
  bool _isInitialized = false;
  static const String _remoteModelName = 'sentiment_analysis_model';

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // First try to load from Firebase ML Model Downloader
      if (FirebaseService.isInitialized) {
        try {
          final model = await FirebaseModelDownloader.instance.getModel(
            _remoteModelName,
            FirebaseModelDownloadType.localModelUpdateInBackground,
          );
          final file = model.file;
          if (await file.exists()) {
            _interpreter = tfl.Interpreter.fromFile(file);
            _isInitialized = true;
            print('ML Model loaded from Firebase ML Model Downloader');
            return;
          }
        } catch (e) {
          print('Failed to load model from Firebase ML: $e');
        }
      }

      // Try to load from local assets
      try {
        _interpreter = await tfl.Interpreter.fromAsset('assets/models/sentiment.tflite');
        _isInitialized = true;
        print('ML Model loaded from local assets');
        return;
      } catch (e) {
        print('Failed to load model from assets: $e');
      }

      // If Firebase is configured but neither remote nor asset model loaded, fail hard
      if (FirebaseService.isInitialized) {
        throw StateError('TFLite sentiment model not available. Ensure Firebase ML model or assets/models/sentiment.tflite is configured.');
      }

      // If Firebase is not configured, allow heuristic fallback
      _interpreter = null;
      _isInitialized = true;
      print('Firebase not configured; using heuristic sentiment analysis fallback');
    } catch (e) {
      print('Error initializing ML service: $e');
      _interpreter = null;
      _isInitialized = true;
    }
  }

  // Returns sentiment score in [-1, 1]
  Future<double> analyzeSentiment(String text) async {
    if (text.trim().isEmpty) return 0;
    
    // Ensure ML service is initialized
    if (!_isInitialized) {
      await initialize();
    }
    
    if (_interpreter == null) {
      // If Firebase is configured but no model, surface error instead of silent fallback
      if (FirebaseService.isInitialized) {
        throw StateError('Sentiment model unavailable while Firebase is initialized.');
      }
      return _heuristicSentimentAnalysis(text);
    }

    try {
      // This is a simplified implementation
      // In a real app, you would need proper tokenization and preprocessing
      // that matches your specific model's requirements
      
      // For now, we'll use a simple character-based approach
      final input = _preprocessText(text);
      final output = List.filled(1, 0.0).reshape([1, 1]);
      
      _interpreter!.run(input, output);
      final raw = (output[0][0] as num).toDouble();
      
      // Normalize to [-1, 1] range
      return (raw * 2) - 1;
    } catch (e) {
      print('Error in ML sentiment analysis: $e');
      return _heuristicSentimentAnalysis(text);
    }
  }

  Uint8List _preprocessText(String text) {
    // Simple preprocessing - convert text to bytes
    // In a real implementation, you would need proper tokenization
    final bytes = text.toLowerCase().codeUnits;
    final input = Uint8List(256); // Fixed input size
    
    for (int i = 0; i < bytes.length && i < 256; i++) {
      input[i] = bytes[i] % 256;
    }
    
    return input;
  }

  double _heuristicSentimentAnalysis(String text) {
    final lower = text.toLowerCase();
    double score = 0;
    
    // Positive words with weights
    final positiveWords = {
      'happy': 1.0, 'joy': 1.0, 'great': 0.8, 'good': 0.7, 'excellent': 1.2,
      'amazing': 1.1, 'wonderful': 1.0, 'fantastic': 1.1, 'love': 1.0,
      'calm': 0.6, 'peaceful': 0.8, 'relaxed': 0.7, 'content': 0.8,
      'grateful': 0.9, 'blessed': 0.9, 'proud': 0.8, 'confident': 0.7,
      'excited': 0.8, 'enthusiastic': 0.9, 'motivated': 0.8, 'inspired': 0.9,
    };
    
    // Negative words with weights
    final negativeWords = {
      'sad': -1.0, 'depressed': -1.2, 'anxious': -0.9, 'worried': -0.8,
      'angry': -1.0, 'frustrated': -0.9, 'stressed': -1.0, 'overwhelmed': -1.1,
      'tired': -0.6, 'exhausted': -0.8, 'lonely': -1.0, 'isolated': -1.0,
      'hopeless': -1.2, 'helpless': -1.1, 'worthless': -1.2, 'useless': -1.1,
      'terrible': -1.0, 'awful': -1.0, 'horrible': -1.1, 'disappointed': -0.8,
      'hurt': -0.9, 'pain': -0.8, 'suffering': -1.1, 'struggling': -0.9,
    };
    
    // Count positive words
    for (final entry in positiveWords.entries) {
      if (lower.contains(entry.key)) {
        score += entry.value;
      }
    }
    
    // Count negative words
    for (final entry in negativeWords.entries) {
      if (lower.contains(entry.key)) {
        score += entry.value;
      }
    }
    
    // Normalize score to [-1, 1] range
    final maxScore = 5.0; // Maximum possible score
    return (score / maxScore).clamp(-1.0, 1.0);
  }

  bool get isModelLoaded => _interpreter != null;
  bool get isInitialized => _isInitialized;
}


