


import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sqflite/sqflite.dart';
import '../core/db/database_helper.dart';
import '../core/models/user_model.dart';
import '../core/utils/notification_service.dart';

class ProfileProvider extends ChangeNotifier {
  String? avatarPath;
  final ImagePicker _picker = ImagePicker();
  bool notificationsEnabled = false;
  TimeOfDay remindTime = const TimeOfDay(hour: 20, minute: 0);

  Future<Database> get _db async => (await DatabaseHelper.instance.database);

  Future<void> pickImage() async {
    final XFile? file =
    await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (file != null) {
      avatarPath = file.path;
      notifyListeners();
    }
  }

  Future<void> saveAvatarToUser(UserModel user) async {
    if (avatarPath == null) return;
    final db = await _db;
    user.avatar = avatarPath;
    await db.update('users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
    notifyListeners();
  }

  Future<String> changePassword({
    required UserModel user,
    required String oldPassword,
    required String newPassword,
  }) async {
    final db = await _db;

    if (oldPassword != user.password) {
      return 'Old password is incorrect';
    }

    user.password = newPassword;
    await db.update('users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
    notifyListeners();
    return 'Password updated successfully';
  }

  Future<void> toggleNotifications(BuildContext context, bool value) async {
    notificationsEnabled = value;

    await NotificationService().init();

    if (value) {
      try {
        await NotificationService().scheduleDaily(
          0,
          'Expense Reminder',
          "Don't forget to add your expenses today!",
          remindTime.hour,
          remindTime.minute,
        );

        await NotificationService().showNotification(
          'Notifications Enabled',
          'Reminder set at ${remindTime.format(context)}',
        );
      } catch (e) {
        debugPrint('⚠️ Failed to schedule notification: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to schedule notification')),
        );
      }
    } else {
      await NotificationService().cancel(0);
    }

    notifyListeners();
  }

  Future<void> pickReminderTime(BuildContext context) async {
    final t = await showTimePicker(context: context, initialTime: remindTime);
    if (t != null) {
      remindTime = t;

      if (notificationsEnabled) {
        await NotificationService().scheduleDaily(
          0,
          'Expense Reminder',
          "Don't forget to add your expenses today!",
          remindTime.hour,
          remindTime.minute,
        );
      }

      notifyListeners();
    }
  }
}
