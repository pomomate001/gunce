import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Daily writing reminder: seven weekly notifications, each with its own prompt.
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> init() async {
    if (kIsWeb) return;
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (e) {
      debugPrint('timezone lookup failed: $e');
    }
    await _plugin.initialize(
      settings: const InitializationSettings(android: AndroidInitializationSettings('ic_stat_gunce')),
    );
    _ready = true;
  }

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  /// Android 13+ asks the user; older versions return true.
  Future<bool> requestPermission() async {
    if (!_ready) return false;
    return await _android?.requestNotificationsPermission() ?? true;
  }

  Future<void> scheduleDaily({
    required TimeOfDay time,
    required String channelName,
    required List<(String, String)> messages,
  }) async {
    if (!_ready) return;
    await cancelDaily();
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_reminder',
        channelName,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        color: const Color(0xFFE5705F),
      ),
    );
    final now = tz.TZDateTime.now(tz.local);
    for (var weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++) {
      var at = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);
      while (at.weekday != weekday || !at.isAfter(now)) {
        at = tz.TZDateTime(tz.local, at.year, at.month, at.day + 1, time.hour, time.minute);
      }
      final (title, body) = messages[(weekday - 1) % messages.length];
      await _plugin.zonedSchedule(
        id: 100 + weekday,
        scheduledDate: at,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        title: title,
        body: body,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  Future<void> cancelDaily() async {
    if (!_ready) return;
    for (var weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++) {
      await _plugin.cancel(id: 100 + weekday);
    }
  }
}
