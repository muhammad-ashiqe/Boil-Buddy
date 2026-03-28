import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static const int _alarmId = 1001;
  static FlutterLocalNotificationsPlugin? _plugin;

  static Future<void> init(FlutterLocalNotificationsPlugin plugin) async {
    _plugin = plugin;

    if (kIsWeb) return;

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await plugin.initialize(initSettings);

    // Request notification permission (Android 13+)
    final androidPlugin =
        plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
  }

  static Future<void> scheduleAlarm(Duration duration) async {
    if (kIsWeb || _plugin == null) return;

    final scheduledDate =
        tz.TZDateTime.now(tz.local).add(duration);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'egg_timer_channel',
      'Egg Timer',
      channelDescription: 'Notifications for egg timer completion',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
    );

    const NotificationDetails notifDetails = NotificationDetails(
      android: androidDetails,
    );

    try {
      await _plugin!.zonedSchedule(
        _alarmId,
          '🥚 Boil Buddy',
        'Your egg is ready! Come rescue it!',
        scheduledDate,
        notifDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      // Fallback to inexact if exact alarm not permitted
      if (kDebugMode) {
        debugPrint('Exact alarm failed, using inexact: $e');
      }
      try {
        await _plugin!.zonedSchedule(
          _alarmId,
            '🥚 Boil Buddy',
          'Your egg is ready! Come rescue it!',
          scheduledDate,
          notifDetails,
          androidScheduleMode: AndroidScheduleMode.inexact,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } catch (_) {}
    }
  }

  static Future<void> cancelAlarm() async {
    if (kIsWeb) return;
    await _plugin?.cancel(_alarmId);
  }
}
