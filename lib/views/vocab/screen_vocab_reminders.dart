import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/vocabulary.dart';
import '../../services/notification_service.dart';
import '../../services/vocab_service.dart';

class ScreenVocabReminders extends StatefulWidget {
  const ScreenVocabReminders({super.key});

  @override
  State<ScreenVocabReminders> createState() => _ScreenVocabRemindersState();
}

class _ScreenVocabRemindersState extends State<ScreenVocabReminders> {
  final VocabService vocabService = VocabService();
  final NotificationService notiService = NotificationService();

  List<ScheduledReminder> reminders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadReminders();
  }

  void loadReminders() async {
    setState(() {
      isLoading = true;
    });

    final list = await vocabService.loadReminders();

    setState(() {
      reminders = list;
      isLoading = false;
    });
  }

  void cancelReminder(ScheduledReminder reminder) async {
    await notiService.cancelNotification(reminder.id);
    await vocabService.removeReminder(reminder.id);
    loadReminders();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Đã hủy lịch nhắc từ: '${reminder.word}'"),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String formatTime(DateTime time) {
    return DateFormat("dd/MM/yyyy HH:mm").format(time);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lịch nhắc"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Làm mới",
            onPressed: loadReminders,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : reminders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off_outlined,
                          size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        "Chưa có lịch nhắc nào đang chờ xử lý",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Hãy vào Trang chính để lên lịch nhắc từ vựng mới!",
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: reminders.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = reminders[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.notifications_active, color: Colors.blue),
                      ),
                      title: const Text(
                        "Ôn từ vựng mới!",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            "${item.word}: ${item.meaning}",
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Thời gian nhắc: ${formatTime(item.scheduledTime)}",
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red, size: 22),
                        tooltip: "Hủy lịch nhắc",
                        onPressed: () => cancelReminder(item),
                      ),
                    );
                  },
                ),
    );
  }
}
