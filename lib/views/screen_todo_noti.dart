import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';
import '../services/file_services.dart';
import '../services/notification_service.dart';

class ScreenTodoNotification extends StatefulWidget {
  const ScreenTodoNotification({super.key});

  @override
  State<ScreenTodoNotification> createState() => _ScreenTodoNotificationState();
}

class _ScreenTodoNotificationState extends State<ScreenTodoNotification> {
  final TextEditingController controller = TextEditingController();
  final FileService fileService = FileService();
  final NotificationService notiService = NotificationService();

  List<Todo> todos = [];
  DateTime? selectedTime;

  @override
  void initState() {
    super.initState();
    notiService.init();
    loadData();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void loadData() async {
    todos = await fileService.loadTodos();
    setState(() {});
  }

  // Xử lý Bài tập 3: Khi nhấp "Lưu" sẽ:
  // 1. Thêm công việc vào danh sách & lưu file
  // 2. Hiển thị notification thông báo đã thêm lịch cho công việc
  // 3. Thiết lập lịch hẹn notification cho công việc theo thời gian đã chọn
  void addTodoWithNotification() async {
    if (controller.text.trim().isEmpty || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập tên công việc và chọn thời gian!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final title = controller.text.trim();
    final time = selectedTime!;

    final todo = Todo(title: title, time: time);
    todos.add(todo);
    await fileService.saveTodos(todos);

    // 1. Hiển thị notification tức thì báo đã thêm lịch cho công việc
    await notiService.showSimpleNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: "Đã thêm lịch công việc thành công",
      body: "Công việc: '$title' đã được lên lịch nhắc lúc ${formatTime(time)}",
    );

    // 2. Thiết lập lịch hẹn thông báo theo thời gian đã chọn
    final notiId = (time.millisecondsSinceEpoch ~/ 1000).abs() % 100000;
    await notiService.scheduleNotificationAt(
      id: notiId,
      title: "Nhắc việc: $title",
      body: "Đã đến giờ thực hiện công việc: '$title'!",
      scheduledTime: time,
      channelId: 'todo_channel',
      channelName: 'Nhắc nhở công việc',
    );

    controller.clear();
    selectedTime = null;
    setState(() {});

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Đã lưu công việc và đặt lịch nhắc lúc ${formatTime(time)}!",
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Chọn ngày và giờ
  void pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(2100),
      initialDate: now,
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        selectedTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        setState(() {});
      }
    }
  }

  String formatTime(DateTime time) {
    return DateFormat("dd/MM/yyyy HH:mm").format(time);
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = [
      Colors.red.shade100,
      Colors.green.shade100,
      Colors.blue.shade100,
      Colors.yellow.shade100,
      Colors.purple.shade100,
    ];

    Color getTextColor(Color bg) {
      return bg.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bài 3: Nhắc việc & Hẹn thông báo"),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Ô nhập công việc
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: "Tên công việc",
                hintText: "Nhập việc cần làm...",
                prefixIcon: const Icon(Icons.edit_note, color: Colors.indigo),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.indigo, width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.indigo, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Chọn thời gian
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.indigo.shade200),
                borderRadius: BorderRadius.circular(12),
                color: Colors.indigo.shade50.withValues(alpha: 0.3),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.indigo, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedTime == null
                          ? "Chưa chọn thời gian"
                          : formatTime(selectedTime!),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: selectedTime != null
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: selectedTime != null
                            ? Colors.indigo.shade900
                            : Colors.black54,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: pickDateTime,
                    icon: const Icon(Icons.access_time, size: 16),
                    label: const Text("Chọn thời gian"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.indigo,
                      side: const BorderSide(color: Colors.indigo, width: 1.5),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Nút Lưu kết hợp Thông báo
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: addTodoWithNotification,
                icon: const Icon(Icons.notification_add),
                label: const Text(
                  "Lưu & Lên lịch nhắc thông báo",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Tiêu đề danh sách
            Row(
              children: [
                const Icon(Icons.list_alt, color: Colors.indigo),
                const SizedBox(width: 8),
                Text(
                  "Danh sách công việc (${todos.length}):",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Hiển thị danh sách Todo
            Expanded(
              child: todos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_available,
                            size: 60,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Chưa có công việc được lên lịch",
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: todos.length,
                      itemBuilder: (context, index) {
                        final t = todos[index];
                        final Color bgColor = colors[index % colors.length];
                        final textColor = getTextColor(bgColor);
                        return Card(
                          color: bgColor,
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: Icon(Icons.alarm_on, color: textColor),
                            title: Text(
                              t.title,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              "Hẹn giờ: ${formatTime(t.time)}",
                              style: TextStyle(
                                color: textColor.withValues(alpha: 0.8),
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete_outline, color: textColor),
                              tooltip: "Xóa công việc",
                              onPressed: () async {
                                final notiId = (t.time.millisecondsSinceEpoch ~/ 1000).abs() % 100000;
                                await notiService.cancelNotification(notiId);
                                setState(() {
                                  todos.removeAt(index);
                                });
                                await fileService.saveTodos(todos);
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
