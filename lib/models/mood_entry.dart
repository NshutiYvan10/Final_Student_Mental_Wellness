enum MoodType {
  veryHappy,
  happy,
  neutral,
  sad,
  verySad,
  anxious,
  angry,
  stressed,
  calm,
  energetic,
}

class MoodEntry {
  final DateTime date;
  final int mood; // 1-5
  final String note;

  MoodEntry({required this.date, required this.mood, this.note = ''});

  // Alias for date to match the expected field name
  DateTime get timestamp => date;

  MoodType get moodType {
    switch (mood) {
      case 1:
        return MoodType.verySad;
      case 2:
        return MoodType.sad;
      case 3:
        return MoodType.neutral;
      case 4:
        return MoodType.happy;
      case 5:
        return MoodType.veryHappy;
      default:
        return MoodType.neutral;
    }
  }

  Map<String, dynamic> toMap() => {
        'date': date.toIso8601String(),
        'mood': mood,
        'note': note,
      };

  factory MoodEntry.fromMap(Map<String, dynamic> map) => MoodEntry(
        date: DateTime.parse(map['date'] as String),
        mood: map['mood'] as int,
        note: (map['note'] as String?) ?? '',
      );
}



