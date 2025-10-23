import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize notifications & timezone
  Future<void> init() async {
    if (_initialized) return;

    // Initialize timezone database
    tzdata.initializeTimeZones();

    // Set local timezone
    final String timeZoneName = tz.local.name;
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // Initialize Flutter Local Notifications
    const AndroidInitializationSettings androidInit =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
    InitializationSettings(android: androidInit);

    await flutterLocalNotificationsPlugin.initialize(initSettings);

    _initialized = true;
  }

  /// Show immediate notification
  Future<void> showNotification(String title, String body) async {
    if (!_initialized) await init();

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'channel_id',
      'General',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(0, title, body, platformDetails);
  }

  /// Schedule daily notification (approximate for Android 13+)
  Future<void> scheduleDaily(
      int id, String title, String body, int hour, int minute) async {
    if (!_initialized) await init();

    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
    tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduled.isBefore(now)) scheduled = scheduled.add(const Duration(days: 1));

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_channel',
            'Daily Reminders',
            importance: Importance.high,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        // No exact alarm: avoids Android 13+ exception
      );
    } on Exception catch (e) {
      debugPrint('⚠️ Could not schedule daily notification: $e');

      // Fallback: show immediate notification
      await showNotification(title, body);
    }
  }

  /// Cancel a scheduled notification
  Future<void> cancel(int id) async {
    if (!_initialized) await init();
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    if (!_initialized) await init();
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
