import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'core/theme/app_theme.dart';
import 'features/timer/screens/home_screen.dart';
import 'services/hive_service.dart';
import 'services/notification_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Timezone
  tz.initializeTimeZones();

  // Hive
  await Hive.initFlutter();
  await HiveService.init();

  // Notifications
  await NotificationService.init(flutterLocalNotificationsPlugin);

  runApp(
    const ProviderScope(
      child: YolkHeroApp(),
    ),
  );
}

class YolkHeroApp extends StatelessWidget {
  const YolkHeroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Boil Buddy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
