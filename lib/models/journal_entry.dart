class JournalEntry {
  final String id;
  final DateTime createdAt;
  final String text;
  final double sentiment; // -1..1

  JournalEntry({
    required this.id,
    required this.createdAt,
    required this.text,
    required this.sentiment,
  });

  // Alias for createdAt to match the expected field name
  DateTime get timestamp => createdAt;
  
  // Alias for text to match the expected field name
  String get content => text;

  Map<String, dynamic> toMap() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'text': text,
        'sentiment': sentiment,
      };

  factory JournalEntry.fromMap(Map<String, dynamic> map) => JournalEntry(
        id: map['id'] as String,
        createdAt: DateTime.parse(map['createdAt'] as String),
        text: map['text'] as String,
        sentiment: (map['sentiment'] as num).toDouble(),
      );
}



