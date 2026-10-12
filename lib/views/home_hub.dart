import 'package:flutter/material.dart';
import 'scren_noti_ex.dart';
import 'screen_todo.dart';
import 'screen_todo_noti.dart';
import 'vocab/screen_vocab_main.dart';
import 'daily_task/screen_daily_tasks.dart';

class HomeHub extends StatelessWidget {
  const HomeHub({super.key});

  @override
  Widget build(BuildContext context) {
    final exercises = [
      _ExerciseItem(
        title: "Bài tập 1: Notification cơ bản",
        subtitle: "Thông báo tức thì, Hẹn giờ 2 phút & 10 phút",
        icon: Icons.notifications_active,
        color: Colors.blue,
        targetScreen: const ScreenNotiEx(),
      ),
      _ExerciseItem(
        title: "Bài tập 2: Quản lý Todo (Lưu File)",
        subtitle: "Nhập công việc, chọn ngày giờ, lưu file todo.txt & đổi màu",
        icon: Icons.note_alt,
        color: Colors.teal,
        targetScreen: const ScreenTodo(),
      ),
      _ExerciseItem(
        title: "Bài tập 3: Nhắc việc & Hẹn thông báo",
        subtitle: "Khi Lưu: Bắn notification tức thì + Hẹn lịch theo thời gian chọn",
        icon: Icons.alarm_add,
        color: Colors.indigo,
        targetScreen: const ScreenTodoNotification(),
      ),
      _ExerciseItem(
        title: "Bài tập 4: Ứng dụng học từ vựng",
        subtitle: "Drawer: Trang chính, Học từ (bội số 3 thông báo), Trắc nghiệm, Lịch nhắc",
        icon: Icons.school,
        color: Colors.deepPurple,
        targetScreen: const ScreenVocabMain(),
      ),
      _ExerciseItem(
        title: "Bài tập về nhà: Nhiệm vụ mỗi ngày",
        subtitle: "Todo lưu file, Hẹn giờ chuông, Checkbox xác nhận -> Báo hoàn thành",
        icon: Icons.checklist_rtl,
        color: Colors.green.shade700,
        targetScreen: const ScreenDailyTasks(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bài 08: NOTIFICATION & FILE"),
        centerTitle: true,
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: Container(
        color: Colors.grey.shade50,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          itemCount: exercises.length,
          itemBuilder: (context, index) {
            final item = exercises[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => item.targetScreen),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(item.icon, color: item.color, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.subtitle,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ExerciseItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget targetScreen;

  _ExerciseItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.targetScreen,
  });
}
