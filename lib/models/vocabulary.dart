class Vocabulary {
  final String word;
  final String meaning;

  Vocabulary({required this.word, required this.meaning});

  // Convert to String for file storage
  String toFileString() {
    return '$word|$meaning';
  }

  // Parse from String
  factory Vocabulary.fromString(String line) {
    final parts = line.split('|');
    if (parts.length >= 2) {
      return Vocabulary(
        word: parts[0].trim(),
        meaning: parts[1].trim(),
      );
    }
    return Vocabulary(word: line.trim(), meaning: '');
  }
}

class ScheduledReminder {
  final int id;
  final String word;
  final String meaning;
  final DateTime scheduledTime;

  ScheduledReminder({
    required this.id,
    required this.word,
    required this.meaning,
    required this.scheduledTime,
  });

  String toFileString() {
    return '$id|$word|$meaning|${scheduledTime.toIso8601String()}';
  }

  factory ScheduledReminder.fromString(String line) {
    final parts = line.split('|');
    return ScheduledReminder(
      id: int.tryParse(parts[0]) ?? 0,
      word: parts[1],
      meaning: parts[2],
      scheduledTime: DateTime.tryParse(parts[3]) ?? DateTime.now(),
    );
  }
}
