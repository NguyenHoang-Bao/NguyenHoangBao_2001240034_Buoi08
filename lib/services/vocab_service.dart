import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/vocabulary.dart';

class VocabService {
  static final VocabService _instance = VocabService._internal();
  factory VocabService() => _instance;
  VocabService._internal();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _vocabFile async {
    final path = await _localPath;
    return File('$path/vocab.txt');
  }

  Future<File> get _remindersFile async {
    final path = await _localPath;
    return File('$path/vocab_reminders.txt');
  }

  // Danh sách từ mặc định nếu file chưa có
  final List<Vocabulary> _defaultVocab = [
    Vocabulary(word: 'subject', meaning: 'môn học'),
    Vocabulary(word: 'student', meaning: 'sinh viên'),
    Vocabulary(word: 'teacher', meaning: 'giáo viên'),
    Vocabulary(word: 'computer', meaning: 'máy tính'),
    Vocabulary(word: 'notification', meaning: 'thông báo'),
    Vocabulary(word: 'application', meaning: 'ứng dụng'),
  ];

  // Tải danh sách từ vựng từ file
  Future<List<Vocabulary>> loadVocabularies() async {
    try {
      final file = await _vocabFile;
      if (!await file.exists()) {
        // Khởi tạo file với một số từ mẫu ban đầu
        await saveVocabularies(_defaultVocab);
        return List.from(_defaultVocab);
      }
      final content = await file.readAsString();
      final list = content
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map((line) => Vocabulary.fromString(line))
          .toList();

      if (list.isEmpty) {
        await saveVocabularies(_defaultVocab);
        return List.from(_defaultVocab);
      }
      return list;
    } catch (e) {
      return List.from(_defaultVocab);
    }
  }

  // Lưu toàn bộ danh sách từ
  Future<void> saveVocabularies(List<Vocabulary> list) async {
    final file = await _vocabFile;
    final content = list.map((e) => e.toFileString()).join('\n');
    await file.writeAsString(content);
  }

  // Thêm một từ vựng mới vào file
  Future<void> addVocabulary(Vocabulary vocab) async {
    final list = await loadVocabularies();
    list.removeWhere((v) => v.word.toLowerCase() == vocab.word.toLowerCase());
    list.add(vocab);
    await saveVocabularies(list);
  }

  // Tải danh sách lịch nhắc
  Future<List<ScheduledReminder>> loadReminders() async {
    try {
      final file = await _remindersFile;
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      final now = DateTime.now();
      // Chỉ giữ lại các lịch còn trong tương lai (chưa hiển thị)
      final list = content
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map((line) => ScheduledReminder.fromString(line))
          .where((r) => r.scheduledTime.isAfter(now))
          .toList();
      return list;
    } catch (e) {
      return [];
    }
  }

  // Lưu danh sách lịch nhắc
  Future<void> saveReminders(List<ScheduledReminder> list) async {
    final file = await _remindersFile;
    final content = list.map((e) => e.toFileString()).join('\n');
    await file.writeAsString(content);
  }

  // Thêm một lịch nhắc
  Future<void> addReminder(ScheduledReminder reminder) async {
    final list = await loadReminders();
    list.add(reminder);
    await saveReminders(list);
  }

  // Xóa một lịch nhắc theo id
  Future<void> removeReminder(int id) async {
    final list = await loadReminders();
    list.removeWhere((r) => r.id == id);
    await saveReminders(list);
  }
}
