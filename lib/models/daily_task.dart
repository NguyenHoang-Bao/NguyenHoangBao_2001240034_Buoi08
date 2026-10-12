class DailyTask {
  final int id;
  String title;
  DateTime reminderTime;
  bool isCompleted;

  DailyTask({
    required this.id,
    required this.title,
    required this.reminderTime,
    this.isCompleted = false,
  });

  // Convert to String for file storage: id|title|reminderTime|isCompleted
  String toFileString() {
    return '$id|$title|${reminderTime.toIso8601String()}|$isCompleted';
  }

  // Parse from String
  factory DailyTask.fromString(String line) {
    final parts = line.split('|');
    return DailyTask(
      id: int.tryParse(parts[0]) ?? DateTime.now().millisecondsSinceEpoch % 100000,
      title: parts.length > 1 ? parts[1] : '',
      reminderTime: parts.length > 2
          ? DateTime.tryParse(parts[2]) ?? DateTime.now()
          : DateTime.now(),
      isCompleted: parts.length > 3 ? parts[3].toLowerCase() == 'true' : false,
    );
  }
}
