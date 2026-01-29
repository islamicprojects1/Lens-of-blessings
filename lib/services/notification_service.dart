import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../core/constants/app_constants.dart';
import 'storage_service.dart';

/// NotificationService - Handles daily reminder notifications
class NotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final StorageService _storageService = Get.find<StorageService>();

  static const String _channelId = 'daily_reminder';
  static const String _channelName = 'Daily Reminder';
  static const int _notificationId = 1;

  Future<NotificationService> init() async {
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Schedule if enabled
    if (_storageService.isNotificationEnabled()) {
      await scheduleDailyReminder();
    }

    return this;
  }

  void _onNotificationTap(NotificationResponse response) {
    // App opens to camera screen by default
    // Future: Could deep link to specific screen
  }

  /// Schedule daily reminder notification
  Future<void> scheduleDailyReminder() async {
    await cancelDailyReminder();

    final language = _storageService.getLanguage();
    final title = language == 'ar'
        ? 'حان وقت رؤية النعم ✨'
        : 'Time to see blessings ✨';
    final body = language == 'ar'
        ? 'خذ لحظة لتلاحظ شيئاً جميلاً اليوم'
        : 'Take a moment to notice something beautiful today';

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Daily reminder to see blessings',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      styleInformation: BigTextStyleInformation(body),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      _notificationId,
      title,
      body,
      _nextNotificationTime(),
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    print(
      'NotificationService: Daily reminder scheduled for ${AppConstants.dailyReminderHour}:${AppConstants.dailyReminderMinute.toString().padLeft(2, '0')}',
    );
  }

  tz.TZDateTime _nextNotificationTime() {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      AppConstants.dailyReminderHour,
      AppConstants.dailyReminderMinute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    return scheduledTime;
  }

  /// Cancel daily reminder
  Future<void> cancelDailyReminder() async {
    await _notifications.cancel(_notificationId);
  }

  /// Toggle notification enabled/disabled
  Future<void> setEnabled(bool enabled) async {
    await _storageService.setNotificationEnabled(enabled);

    if (enabled) {
      await scheduleDailyReminder();
    } else {
      await cancelDailyReminder();
    }
  }

  /// Request notification permissions (iOS)
  Future<bool> requestPermissions() async {
    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final ios = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    bool? granted;

    if (android != null) {
      granted = await android.requestNotificationsPermission();
    }

    if (ios != null) {
      granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    return granted ?? false;
  }
}
