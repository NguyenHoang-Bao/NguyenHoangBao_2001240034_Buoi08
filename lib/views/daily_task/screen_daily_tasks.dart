import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/daily_task.dart';
import '../../services/notification_service.dart';

class ScreenDailyTasks extends StatefulWidget {
  const ScreenDailyTasks({super.key});

  @override
  State<ScreenDailyTasks> createState() => _ScreenDailyTasksState();
}

class _ScreenDailyTasksState extends State<ScreenDailyTasks> {
  final NotificationService notiService = NotificationService();
  List<DailyTask> tasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    notiService.init();
    loadTasks();
  }

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/daily_tasks.txt');
  }

  Future<void> loadTasks() async {
    setState(() => isLoading = true);
    try {
      final file = await _getFile();
      if (!await file.exists()) {
        // Tạo một số nhiệm vụ mẫu ban đầu theo hình minh họa PDF (trang 25)
        final defaultTasks = [
          DailyTask(
            id: 1,
            title: "Học bài chương 4",
            reminderTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 20, 0),
          ),
          DailyTask(
            id: 2,
            title: "Làm bài tập Flutter",
            reminderTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 21, 30),
          ),
          DailyTask(
            id: 3,
            title: "Ôn tập từ vựng tiếng Anh",
            reminderTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 22, 0),
          ),
        ];
        await saveTasksToFile(defaultTasks);
        tasks = defaultTasks;
      } else {
        final content = await file.readAsString();
        tasks = content
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .map((line) => DailyTask.fromString(line))
            .toList();
      }
    } catch (e) {
      tasks = [];
    }
    setState(() => isLoading = false);
  }

  Future<void> saveTasksToFile(List<DailyTask> list) async {
    final file = await _getFile();
    final data = list.map((e) => e.toFileString()).join('\n');
    await file.writeAsString(data);
  }

  // Xử lý khi người dùng chọn checkbox đánh dấu nhiệm vụ hoàn thành
  void onTaskChecked(DailyTask task, bool? newValue) async {
    if (newValue == true && !task.isCompleted) {
      // Hiển thị hộp thoại hỏi xác nhận hoàn thành theo đúng mô tả PDF:
      // "Khi chọn một nhiệm vụ (đánh dấu ) sẽ hiển thị một hộp thoại hỏi người dùng
      // có xác nhận nhiệm vụ này đã hoàn thành ? Nếu có sẽ thông báo trên khay
      // thông báo của hệ thống số lượng nhiệm vụ đã hoàn thành."
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            "Xác nhận hoàn thành",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text("Bạn có xác nhận nhiệm vụ '${task.title}' đã hoàn thành?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text("Xác nhận", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        setState(() {
          task.isCompleted = true;
        });
        await saveTasksToFile(tasks);

        // Đếm số lượng nhiệm vụ đã hoàn thành
        final completedCount = tasks.where((t) => t.isCompleted).length;

        // Bắn Notification thông báo số lượng nhiệm vụ đã hoàn thành
        await notiService.showSimpleNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: "Hoàn thành nhiệm vụ! 🎉",
          body: "Bạn đã hoàn thành $completedCount nhiệm vụ!",
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Chúc mừng! Đã hoàn thành $completedCount nhiệm vụ."),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } else if (newValue == false) {
      setState(() {
        task.isCompleted = false;
      });
      await saveTasksToFile(tasks);
    }
  }

  // Thiết lập lại thời gian thông báo cho nhiệm vụ khi bấm vào icon chuông
  void editNotificationTime(DailyTask task) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(task.reminderTime),
    );

    if (pickedTime != null) {
      final now = DateTime.now();
      var newDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      if (newDateTime.isBefore(now)) {
        newDateTime = newDateTime.add(const Duration(days: 1));
      }

      setState(() {
        task.reminderTime = newDateTime;
      });
      await saveTasksToFile(tasks);

      // Đặt lại notification
      await notiService.scheduleNotificationAt(
        id: task.id,
        title: "Nhắc việc: ${task.title}",
        body: "Đã đến giờ: ${task.title}",
        scheduledTime: newDateTime,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Đã cập nhật giờ nhắc cho '${task.title}' lúc ${DateFormat('HH:mm').format(newDateTime)}!",
            ),
            backgroundColor: Colors.blue,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Nhiệm vụ mỗi ngày",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tasks.isEmpty
              ? Center(
                  child: Text(
                    "Chưa có nhiệm vụ nào",
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: tasks.length,
                  separatorBuilder: (context, index) => Divider(color: Colors.grey.shade200),
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final timeStr = DateFormat("HH:mm").format(task.reminderTime);

                    return Dismissible(
                      key: Key('task_${task.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.redAccent,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) async {
                        await notiService.cancelNotification(task.id);
                        setState(() {
                          tasks.removeAt(index);
                        });
                        await saveTasksToFile(tasks);
                      },
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Checkbox(
                          value: task.isCompleted,
                          activeColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: (val) => onTaskChecked(task, val),
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: task.isCompleted
                                ? Colors.grey
                                : Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          "Nhắc lúc $timeStr",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.notifications_none,
                            color: Colors.grey.shade600,
                          ),
                          tooltip: "Thiết lập thời gian thông báo",
                          onPressed: () => editNotificationTime(task),
                        ),
                      ),
                    );
                  },
                ),
      // FloatingActionButton (+) mở màn hình thêm nhiệm vụ mới theo PDF (trang 25)
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => ScreenAddTask(
                onSave: (newTask) async {
                  tasks.add(newTask);
                  await saveTasksToFile(tasks);

                  // Hẹn giờ thông báo
                  await notiService.scheduleNotificationAt(
                    id: newTask.id,
                    title: "Nhắc việc: ${newTask.title}",
                    body: "Đã đến giờ: ${newTask.title}",
                    scheduledTime: newTask.reminderTime,
                  );
                },
              ),
            ),
          );
          if (result == true) {
            loadTasks();
          }
        },
        backgroundColor: Colors.blue.shade100,
        foregroundColor: Colors.blue.shade800,
        elevation: 1,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}

// Màn hình Thêm nhiệm vụ mới (PDF trang 25)
class ScreenAddTask extends StatefulWidget {
  final Future<void> Function(DailyTask newTask) onSave;

  const ScreenAddTask({super.key, required this.onSave});

  @override
  State<ScreenAddTask> createState() => _ScreenAddTaskState();
}

class _ScreenAddTaskState extends State<ScreenAddTask> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  TimeOfDay? selectedTimeOfDay;

  @override
  void dispose() {
    titleController.dispose();
    timeController.dispose();
    super.dispose();
  }

  void pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTimeOfDay ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        selectedTimeOfDay = picked;
        final hour = picked.hour.toString().padLeft(2, '0');
        final minute = picked.minute.toString().padLeft(2, '0');
        timeController.text = "$hour:$minute";
      });
    }
  }

  void saveTask() async {
    final title = titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập tên nhiệm vụ!")),
      );
      return;
    }

    final now = DateTime.now();
    DateTime reminderDateTime;

    if (selectedTimeOfDay != null) {
      reminderDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        selectedTimeOfDay!.hour,
        selectedTimeOfDay!.minute,
      );
      if (reminderDateTime.isBefore(now)) {
        reminderDateTime = reminderDateTime.add(const Duration(days: 1));
      }
    } else {
      reminderDateTime = now.add(const Duration(hours: 1));
    }

    final newTask = DailyTask(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: title,
      reminderTime: reminderDateTime,
      isCompleted: false,
    );

    await widget.onSave(newTask);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Thêm nhiệm vụ mới",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          children: [
            // Ô Tên nhiệm vụ
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Tên nhiệm vụ",
                hintText: "Ví dụ: Học bài chương 4",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 20),

            // Ô Giờ nhắc
            TextField(
              controller: timeController,
              readOnly: true,
              onTap: pickTime,
              decoration: InputDecoration(
                labelText: "Giờ nhắc",
                hintText: "Chọn giờ nhắc...",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: pickTime,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 30),

            // Nút Lưu nhiệm vụ theo hình mẫu PDF (trang 25)
            SizedBox(
              width: 160,
              child: ElevatedButton(
                onPressed: saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade50,
                  foregroundColor: Colors.blue.shade800,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Colors.blue.shade200),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Lưu nhiệm vụ",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
