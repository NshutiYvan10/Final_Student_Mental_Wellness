import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/app_router.dart';
import 'theme/app_theme.dart';
import 'providers/app_providers.dart';
import 'services/firebase_service.dart';
import 'services/hive_service.dart';
import 'services/ml_service.dart';
import 'services/notifications_service.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive (offline storage)
  await Hive.initFlutter();
  await HiveService.initialize();

  // Initialize Firebase (safe no-op if not configured yet)
  await FirebaseService.tryInitializeFirebase();

  // Initialize ML (TFLite) and notifications
  await MlService().initialize();
  await NotificationsService.initialize();
  // Android 13+ notifications permission
  try {
    await Permission.notification.request();
  } catch (_) {}

  runApp(const ProviderScope(child: StudentMentalWellnessApp()));
}

class StudentMentalWellnessApp extends ConsumerWidget {
  const StudentMentalWellnessApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Mental Wellness & Peer Support',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRouter.initialRoute,
    );
  }
}
