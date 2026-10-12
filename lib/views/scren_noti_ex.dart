import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class ScreenNotiEx extends StatelessWidget {
  const ScreenNotiEx({super.key});

  @override
  Widget build(BuildContext context) {
    NotificationService notificatiosnservice = NotificationService();
    notificatiosnservice.init();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Screen Noti Example"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Nút lệnh 1: Gửi thông báo tức thì
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade50,
                    foregroundColor: Colors.blue.shade800,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.blue.shade300),
                    ),
                  ),
                  onPressed: () async {
                    await notificatiosnservice.showSimpleNotification(
                      id: 0,
                      title: 'Nhắc học Ngoại ngữ',
                      body: 'Bạn đã học từ vựng hôm nay chưa? Vào học ngay nào!',
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Đã gửi thông báo nhắc học Ngoại ngữ!"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    "Gửi thông báo nhắc học Ngoại ngữ",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Nút lệnh 2: Gửi thông báo nhắc uống nước sau 2 phút
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade50,
                    foregroundColor: Colors.blue.shade800,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.blue.shade300),
                    ),
                  ),
                  onPressed: () async {
                    await notificatiosnservice.scheduleNotificationAfter(
                      delay: const Duration(minutes: 2),
                      channelId: 'drink_water_channel',
                      channelName: 'Uống nước',
                      channelDescription: 'Nhắc uống nước đúng giờ',
                      id: 1,
                      title: 'Uống nước',
                      body: 'Đã đến giờ uống nước rồi, hãy uống 1 cốc nước nhé!',
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Đã lên lịch thông báo uống nước sau 2 phút!"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    "Gửi thông báo nhắc uống nước sau 2 phút",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Nút lệnh 3: Hẹn giờ nhắc học Ngoại ngữ sau 10 phút (Sinh viên tự viết code)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade50,
                    foregroundColor: Colors.blue.shade800,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.blue.shade300),
                    ),
                  ),
                  onPressed: () async {
                    // Code hoàn thiện yêu cầu sinh viên tự viết code: Hẹn giờ nhắc học Ngoại ngữ sau 10 phút
                    await notificatiosnservice.scheduleNotificationAfter(
                      delay: const Duration(minutes: 10),
                      channelId: 'learn_english_channel',
                      channelName: 'Học Ngoại ngữ',
                      channelDescription: 'Nhắc nhở học Ngoại ngữ sau 10 phút',
                      id: 2,
                      title: 'Học Ngoại ngữ',
                      body: 'Đã hết 10 phút, bạn hãy tiếp tục bài học Ngoại ngữ nhé!',
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Đã hẹn giờ gửi thông báo học Ngoại ngữ sau 10 phút!"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    "Hẹn giờ gửi thông báo học Ngoại ngữ sau 10 phút",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
