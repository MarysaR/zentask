import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/category.dart';
import 'models/task.dart';
import 'providers/task_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'config/theme.dart';
import 'services/notification_service.dart';
import 'services/hive_database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de la localisation
  await initializeDateFormatting('fr_FR', null);

  // Initialisation de Hive (Web + Mobile)
  await Hive.initFlutter();
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(TaskPriorityAdapter());
  Hive.registerAdapter(SubTaskAdapter());
  Hive.registerAdapter(TaskAdapter());

  // Ouverture des boxes
  await Hive.openBox<Category>('categories');
  await Hive.openBox<Task>('tasks');
  await HiveDatabaseService().init();

  // Initialisation du service de notifications
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermissions();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'ZenTask',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getLightTheme(),
          darkTheme: AppTheme.getDarkTheme(),
          themeMode: themeProvider.themeMode,
          home: const HomeScreen(),
          locale: const Locale('fr', 'FR'),
        );
      },
    );
  }
}
