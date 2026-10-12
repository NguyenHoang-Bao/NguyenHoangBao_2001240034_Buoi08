import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ================= INIT =================
  Future<void> init() async {
    if (_initialized) return;

    // 1. Init timezone
    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
    } catch (e) {
      // Fallback
    }

    // 2. Android & iOS settings
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: android, iOS: darwin);

    // 3. Init plugin
    await _plugin.initialize(settings);

    // 4. Xin quyền notification
    await requestPermission();

    _initialized = true;
  }

  // ================= REQUEST PERMISSION =================
  Future<void> requestPermission() async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      final status = await Permission.notification.status;
      if (status.isDenied) {
        await Permission.notification.request();
      }
      if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
    }
  }

  // Chi tiết cài đặt thông báo Android
  static AndroidNotificationDetails _createAndroidDetails({
    required String channelId,
    required String channelName,
    String? channelDescription,
  }) {
    return AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      visibility: NotificationVisibility.public,
      playSound: true,
      enableVibration: true,
      showWhen: true,
    );
  }

  // Hàm tái sử dụng cho thiết lập thời gian để bật notification zonedSchedule
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required AndroidNotificationDetails androidDetails,
  }) async {
    var scheduledTzTime = tz.TZDateTime.from(scheduledTime, tz.local);
    // Nếu thời gian đã qua thì cộng thêm 1 ngày
    if (scheduledTzTime.isBefore(tz.TZDateTime.now(tz.local))) {
      scheduledTzTime = scheduledTzTime.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTzTime,
      NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // /// Hàm gửi thông báo tức thì
  Future<void> showSimpleNotification({
    int id = 0,
    String title = 'Nhắc học từ vựng',
    String body = 'Bạn đã học 5 từ mới hôm nay chưa?',
  }) async {
    final details = _createAndroidDetails(
      channelId: 'learn_english_channel',
      channelName: 'Học Anh Văn',
      channelDescription: 'Kênh thông báo học tiếng Anh',
    );
    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(android: details),
    );
  }

  // /// Đặt lịch sau 1 khoảng thời gian delay (Bài tập 1: 2 phút, 10 phút)
  Future<void> scheduleNotificationAfter({
    required Duration delay,
    required String channelId,
    required String channelName,
    required String channelDescription,
    int id = 1,
    String? title,
    String? body,
  }) async {
    final details = _createAndroidDetails(
      channelId: channelId,
      channelName: channelName,
      channelDescription: channelDescription,
    );

    final scheduledTime = tz.TZDateTime.now(tz.local).add(delay);

    await _scheduleNotification(
      id: id,
      title: title ?? channelName,
      body: body ?? channelDescription,
      scheduledTime: scheduledTime,
      androidDetails: details,
    );
  }

  // /// Đặt lịch theo thời gian cụ thể (DateTime)
  Future<void> scheduleNotificationAt({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String channelId = 'todo_reminder_channel',
    String channelName = 'Nhắc việc Todo',
  }) async {
    final details = _createAndroidDetails(
      channelId: channelId,
      channelName: channelName,
      channelDescription: 'Kênh thông báo hẹn giờ',
    );

    await _scheduleNotification(
      id: id,
      title: title,
      body: body,
      scheduledTime: scheduledTime,
      androidDetails: details,
    );
  }

  // Lấy danh sách các thông báo đang chờ xử lý
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _plugin.pendingNotificationRequests();
  }

  // Hủy thông báo theo ID
  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  // Hủy tất cả thông báo
  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }
}
