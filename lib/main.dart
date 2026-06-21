import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase for Push Notifications
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Silently ignore if not configured
  }

  // Initialize Supabase
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox(AppConfig.hiveDeliveriesBox);
  await Hive.openBox(AppConfig.hiveCustomersBox);
  await Hive.openBox(AppConfig.hiveSettingsBox);

  // Firebase Initialization will go here

  runApp(
    const ProviderScope(
      child: VanthendaPaalkaranApp(),
    ),
  );
}

class VanthendaPaalkaranApp extends ConsumerWidget {
  const VanthendaPaalkaranApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: AppConfig.appName,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
