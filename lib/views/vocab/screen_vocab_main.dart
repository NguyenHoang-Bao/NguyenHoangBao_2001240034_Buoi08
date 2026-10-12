import 'package:flutter/material.dart';
import '../../models/vocabulary.dart';
import '../../services/notification_service.dart';
import '../../services/vocab_service.dart';
import 'screen_vocab_learn.dart';
import 'screen_vocab_quiz.dart';
import 'screen_vocab_reminders.dart';

class ScreenVocabMain extends StatefulWidget {
  const ScreenVocabMain({super.key});

  @override
  State<ScreenVocabMain> createState() => _ScreenVocabMainState();
}

class _ScreenVocabMainState extends State<ScreenVocabMain> {
  final TextEditingController wordController = TextEditingController();
  final TextEditingController meaningController = TextEditingController();

  final VocabService vocabService = VocabService();
  final NotificationService notiService = NotificationService();

  @override
  void initState() {
    super.initState();
    notiService.init();
    vocabService.loadVocabularies();
  }

  @override
  void dispose() {
    wordController.dispose();
    meaningController.dispose();
    super.dispose();
  }

  // Xử lý Lưu & Nhắc học sau 10 phút
  Future<void> saveAndScheduleNotification({Duration delay = const Duration(minutes: 10)}) async {
    final word = wordController.text.trim();
    final meaning = meaningController.text.trim();

    if (word.isEmpty || meaning.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập cả Từ và Nghĩa của từ!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 1. Lưu từ vựng vào file
    final vocab = Vocabulary(word: word, meaning: meaning);
    await vocabService.addVocabulary(vocab);

    // 2. Gửi notification tức thì: Đã lưu và hãy ôn tập sau 10 phút
    final notiId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await notiService.showSimpleNotification(
      id: notiId,
      title: 'Đã lưu từ vựng',
      body: 'Đã lưu từ "$word" và hãy ôn tập sau 10 phút',
    );

    // 3. Lên lịch thông báo sau 10 phút (hoặc delay tuỳ chỉnh)
    final reminderId = (notiId + 1) % 100000;
    final scheduledTime = DateTime.now().add(delay);
    await notiService.scheduleNotificationAfter(
      delay: delay,
      channelId: 'vocab_channel',
      channelName: 'Ôn tập từ vựng',
      channelDescription: 'Nhắc nhở ôn tập từ vựng mới học',
      id: reminderId,
      title: 'Ôn từ vựng mới!',
      body: '$word: $meaning',
    );

    // Lưu vào danh sách lịch nhắc để hiển thị ở menu "Lịch nhắc"
    await vocabService.addReminder(
      ScheduledReminder(
        id: reminderId,
        word: word,
        meaning: meaning,
        scheduledTime: scheduledTime,
      ),
    );

    // Xóa nội dung nhập
    wordController.clear();
    meaningController.clear();

    // 4. Hiển thị SnackBar theo đúng yêu cầu PDF:
    // "Đã lưu và lên lịch nhắc học từ sau 10 phút"
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            delay.inMinutes > 0
                ? "Đã lưu và lên lịch nhắc học từ sau ${delay.inMinutes} phút"
                : "Đã lưu và lên lịch nhắc học từ sau ${delay.inSeconds} giây",
          ),
          backgroundColor: Colors.black87,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ứng dụng học từ vựng"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      // Navigation Drawer theo hình ảnh mẫu trong PDF (trang 22)
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.school, size: 42, color: Colors.blue),
              ),
              accountName: const Text(
                "Trợ lý học từ vựng",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              accountEmail: const Text("Học từ vựng mỗi ngày"),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.blue),
              title: const Text("Trang chính"),
              selected: true,
              selectedColor: Colors.blue,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.menu_book, color: Colors.blue),
              title: const Text("Học từ"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScreenVocabLearn()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.quiz, color: Colors.blue),
              title: const Text("Kiểm tra từ"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScreenVocabQuiz()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.alarm, color: Colors.blue),
              title: const Text("Lịch nhắc"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScreenVocabReminders()),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            // Ô nhập "Từ"
            TextField(
              controller: wordController,
              decoration: InputDecoration(
                labelText: "Từ",
                hintText: "Nhập từ tiếng Anh (ví dụ: student)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 20),

            // Ô nhập "Nghĩa"
            TextField(
              controller: meaningController,
              decoration: InputDecoration(
                labelText: "Nghĩa",
                hintText: "Nhập nghĩa tiếng Việt (ví dụ: sinh viên)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 30),

            // Nút "Lưu & Nhắc học sau 10 phút"
            ElevatedButton(
              onPressed: () => saveAndScheduleNotification(delay: const Duration(minutes: 10)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue.shade700,
                side: BorderSide(color: Colors.blue.shade200, width: 1.2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Lưu & Nhắc học sau 10 phút",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),

            // Nút test nhanh 10 giây hỗ trợ người dùng và giáo viên kiểm tra nhanh
            OutlinedButton.icon(
              onPressed: () => saveAndScheduleNotification(delay: const Duration(seconds: 10)),
              icon: const Icon(Icons.timer_outlined, size: 18),
              label: const Text("Thử nghiệm nhanh: Nhắc học sau 10 giây"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
