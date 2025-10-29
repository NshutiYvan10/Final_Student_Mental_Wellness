import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../services/notifications_service.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(DateTime.now().timeZoneName));
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.alarm),
            title: const Text('Daily Reminder'),
            subtitle: const Text('Tap to test a notification'),
            onTap: () async {
              await NotificationsService.initialize();
              await NotificationsService.showSimple(1, 'Time to reflect', 'Log your mood or write a journal');
            },
          ),
          ListTile(
            leading: const Icon(Icons.schedule_outlined),
            title: const Text('Schedule 8 PM reminder'),
            onTap: () async {
              await NotificationsService.initialize();
              final now = tz.TZDateTime.now(tz.local);
              var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, 20);
              if (scheduled.isBefore(now)) {
                scheduled = scheduled.add(const Duration(days: 1));
              }
              await NotificationsService.scheduleDaily(2, 'Evening check-in', 'How was your day?', scheduled);
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Scheduled at 8 PM')));
            },
          )
        ],
      ),
    );
  }
}


