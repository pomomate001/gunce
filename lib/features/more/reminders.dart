import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets.dart';
import '../../data/settings.dart';
import '../../services/notification_service.dart';

/// Applies the saved reminder settings (re-run after language changes).
Future<void> syncReminders(BuildContext context) async {
  final s = context.read<SettingsController>();
  final l = context.l;
  if (!s.reminderOn) {
    await NotificationService.instance.cancelDaily();
    return;
  }
  await NotificationService.instance.scheduleDaily(
    time: s.reminderTime,
    channelName: l.reminderChannel,
    messages: [for (final body in l.reminderBodies.split('|')) (l.reminderTitle, body)],
  );
}

/// Asks for permission and a time, then turns the reminder on. Returns false if the user backed out.
Future<bool> enableReminder(BuildContext context, {bool pickTime = true}) async {
  final s = context.read<SettingsController>();
  var time = s.reminderTime;
  if (pickTime) {
    final picked = await showTimePicker(context: context, initialTime: time, helpText: context.l.reminderTime);
    if (picked == null) return false;
    time = picked;
  }
  final granted = await NotificationService.instance.requestPermission();
  if (!context.mounted) return false;
  if (!granted) {
    toast(context, context.l.notificationsDenied);
    return false;
  }
  await s.setReminder(on: true, time: time);
  if (context.mounted) await syncReminders(context);
  return true;
}
