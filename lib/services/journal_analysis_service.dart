import 'dart:async';
import '../models/journal_entry.dart';
import '../services/hive_service.dart';

class JournalAnalysisService {
  static final Map<String, int> _wordFrequencies = {};
  static final Set<String> _stopWords = {
    'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for', 'of', 'with',
    'by', 'from', 'up', 'about', 'into', 'through', 'during', 'before', 'after',
    'above', 'below', 'between', 'among', 'is', 'are', 'was', 'were', 'be', 'been',
    'being', 'have', 'has', 'had', 'do', 'does', 'did', 'will', 'would', 'could',
    'should', 'may', 'might', 'must', 'can', 'this', 'that', 'these', 'those',
    'i', 'you', 'he', 'she', 'it', 'we', 'they', 'me', 'him', 'her', 'us', 'them',
    'my', 'your', 'his', 'her', 'its', 'our', 'their', 'mine', 'yours', 'hers',
    'ours', 'theirs', 'am', 'are', 'is', 'was', 'were', 'be', 'been', 'being',
    'have', 'has', 'had', 'do', 'does', 'did', 'will', 'would', 'could', 'should',
    'may', 'might', 'must', 'can', 'shall', 'ought', 'need', 'dare', 'used',
    'very', 'really', 'quite', 'just', 'only', 'also', 'even', 'still', 'yet',
    'already', 'soon', 'now', 'then', 'here', 'there', 'where', 'when', 'why',
    'how', 'what', 'who', 'which', 'whose', 'whom', 'all', 'any', 'both', 'each',
    'few', 'more', 'most', 'other', 'some', 'such', 'no', 'nor', 'not', 'only',
    'own', 'same', 'so', 'than', 'too', 'very', 's', 't', 'can', 'will', 'just',
    'don', 'should', 'now', 'get', 'got', 'getting', 'go', 'going', 'went',
    'come', 'coming', 'came', 'see', 'seeing', 'saw', 'know', 'knowing', 'knew',
    'think', 'thinking', 'thought', 'take', 'taking', 'took', 'make', 'making',
    'made', 'give', 'giving', 'gave', 'say', 'saying', 'said', 'tell', 'telling',
    'told', 'ask', 'asking', 'asked', 'want', 'wanting', 'wanted', 'need',
    'needing', 'needed', 'feel', 'feeling', 'felt', 'try', 'trying', 'tried',
    'work', 'working', 'worked', 'play', 'playing', 'played', 'run', 'running',
    'ran', 'walk', 'walking', 'walked', 'talk', 'talking', 'talked', 'look',
    'looking', 'looked', 'find', 'finding', 'found', 'use', 'using', 'used',
    'help', 'helping', 'helped', 'turn', 'turning', 'turned', 'move', 'moving',
    'moved', 'live', 'living', 'lived', 'believe', 'believing', 'believed',
    'hold', 'holding', 'held', 'bring', 'bringing', 'brought', 'happen',
    'happening', 'happened', 'write', 'writing', 'wrote', 'provide', 'providing',
    'provided', 'sit', 'sitting', 'sat', 'stand', 'standing', 'stood', 'lose',
    'losing', 'lost', 'pay', 'paying', 'paid', 'meet', 'meeting', 'met',
    'include', 'including', 'included', 'continue', 'continuing', 'continued',
    'set', 'setting', 'put', 'putting', 'seem', 'seeming', 'seemed', 'let',
    'letting', 'allow', 'allowing', 'allowed', 'add', 'adding', 'added',
    'change', 'changing', 'changed', 'follow', 'following', 'followed',
    'stop', 'stopping', 'stopped', 'create', 'creating', 'created', 'speak',
    'speaking', 'spoke', 'read', 'reading', 'spend', 'spending', 'spent',
    'grow', 'growing', 'grew', 'open', 'opening', 'opened', 'build', 'building',
    'built', 'stay', 'staying', 'stayed', 'fall', 'falling', 'fell', 'cut',
    'cutting', 'reach', 'reaching', 'reached', 'kill', 'killing', 'killed',
    'remain', 'remaining', 'remained', 'suggest', 'suggesting', 'suggested',
    'raise', 'raising', 'raised', 'pass', 'passing', 'passed', 'sell',
    'selling', 'sold', 'require', 'requiring', 'required', 'report', 'reporting',
    'reported', 'decide', 'deciding', 'decided', 'pull', 'pulling', 'pulled',
  };

  static Future<Map<String, int>> getWordFrequencies() async {
    try {
      final journalEntries = await HiveService.getJournalEntries();
      _wordFrequencies.clear();

      for (final entry in journalEntries) {
        _extractWordsFromText(entry.content);
      }

      // Remove stop words and filter out very short words
      _wordFrequencies.removeWhere((word, count) {
        return _stopWords.contains(word.toLowerCase()) || 
               word.length < 3 || 
               _isNumeric(word);
      });

      return Map.from(_wordFrequencies);
    } catch (e) {
      print('Error analyzing journal entries: $e');
      return {};
    }
  }

  static void _extractWordsFromText(String text) {
    // Simple word extraction - split by whitespace and punctuation
    final words = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ') // Replace punctuation with spaces
        .split(RegExp(r'\s+')) // Split by whitespace
        .where((word) => word.isNotEmpty)
        .toList();

    for (final word in words) {
      _wordFrequencies[word] = (_wordFrequencies[word] ?? 0) + 1;
    }
  }

  static bool _isNumeric(String str) {
    return double.tryParse(str) != null;
  }

  static Future<Map<String, int>> getTopWords({int limit = 50}) async {
    final frequencies = await getWordFrequencies();
    final sortedEntries = frequencies.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Map.fromEntries(sortedEntries.take(limit));
  }

  static Future<List<String>> getSentimentWords() async {
    final frequencies = await getWordFrequencies();
    
    // Define sentiment-related words
    final positiveWords = {
      'happy', 'joy', 'great', 'good', 'excellent', 'amazing', 'wonderful',
      'fantastic', 'love', 'calm', 'peaceful', 'relaxed', 'content', 'grateful',
      'blessed', 'proud', 'confident', 'excited', 'enthusiastic', 'motivated',
      'inspired', 'positive', 'optimistic', 'hopeful', 'cheerful', 'bright',
      'successful', 'achievement', 'accomplished', 'satisfied', 'fulfilled'
    };

    final negativeWords = {
      'sad', 'depressed', 'anxious', 'worried', 'angry', 'frustrated', 'stressed',
      'overwhelmed', 'tired', 'exhausted', 'lonely', 'isolated', 'hopeless',
      'helpless', 'worthless', 'useless', 'terrible', 'awful', 'horrible',
      'disappointed', 'hurt', 'pain', 'suffering', 'struggling', 'negative',
      'pessimistic', 'hopeless', 'fearful', 'scared', 'nervous', 'tense',
      'upset', 'annoyed', 'irritated', 'bothered', 'concerned', 'troubled'
    };

    final sentimentWords = <String>[];
    
    for (final entry in frequencies.entries) {
      final word = entry.key.toLowerCase();
      if (positiveWords.contains(word) || negativeWords.contains(word)) {
        sentimentWords.add(entry.key);
      }
    }

    return sentimentWords;
  }

  static Future<Map<String, dynamic>> getJournalInsights() async {
    try {
      final journalEntries = await HiveService.getJournalEntries();
      final wordFrequencies = await getWordFrequencies();
      final sentimentWords = await getSentimentWords();

      if (journalEntries.isEmpty) {
        return {
          'totalEntries': 0,
          'totalWords': 0,
          'averageWordsPerEntry': 0,
          'mostUsedWords': <String, int>{},
          'sentimentWords': <String>[],
          'writingStreak': 0,
        };
      }

      // Calculate total words
      final totalWords = wordFrequencies.values.fold(0, (sum, count) => sum + count);
      final averageWordsPerEntry = totalWords / journalEntries.length;

      // Get top 10 most used words
      final sortedWords = wordFrequencies.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final mostUsedWords = Map.fromEntries(sortedWords.take(10));

      // Calculate writing streak
      final writingStreak = _calculateWritingStreak(journalEntries);

      return {
        'totalEntries': journalEntries.length,
        'totalWords': totalWords,
        'averageWordsPerEntry': averageWordsPerEntry.round(),
        'mostUsedWords': mostUsedWords,
        'sentimentWords': sentimentWords,
        'writingStreak': writingStreak,
      };
    } catch (e) {
      print('Error getting journal insights: $e');
      return {
        'totalEntries': 0,
        'totalWords': 0,
        'averageWordsPerEntry': 0,
        'mostUsedWords': <String, int>{},
        'sentimentWords': <String>[],
        'writingStreak': 0,
      };
    }
  }

  static int _calculateWritingStreak(List<JournalEntry> entries) {
    if (entries.isEmpty) return 0;

    // Sort entries by date (newest first)
    final sortedEntries = List<JournalEntry>.from(entries)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    int streak = 0;
    DateTime? lastDate;

    for (final entry in sortedEntries) {
      final entryDate = DateTime(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
      );

      if (lastDate == null) {
        // First entry
        lastDate = entryDate;
        streak = 1;
      } else {
        final daysDifference = lastDate.difference(entryDate).inDays;
        
        if (daysDifference == 1) {
          // Consecutive day
          streak++;
          lastDate = entryDate;
        } else if (daysDifference == 0) {
          // Same day, don't increment streak
          continue;
        } else {
          // Streak broken
          break;
        }
      }
    }

    return streak;
  }
}


