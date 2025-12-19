import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/services/deep_link_service.dart';
import 'core/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp();
    Logger.info('Firebase initialized successfully');

    // Set up background message handler
    // Must be done before any other Firebase Messaging operations
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    Logger.info('Background message handler registered');

    // Initialize Supabase
    await Supabase.initialize(
      url: const String.fromEnvironment('SUPABASE_URL'),
      anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
    );
    Logger.info('Supabase initialized successfully');
  } catch (e, stackTrace) {
    Logger.error('Error during initialization', e, stackTrace);
    // Continue even if initialization fails
  }

  runApp(
    const ProviderScope(
      child: GidyoApp(),
    ),
  );
}

class GidyoApp extends ConsumerStatefulWidget {
  const GidyoApp({super.key});

  @override
  ConsumerState<GidyoApp> createState() => _GidyoAppState();
}

class _GidyoAppState extends ConsumerState<GidyoApp> {
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize notification service
      await NotificationService.instance.initialize(
        onForegroundMessage: (payload) {
          Logger.info('Foreground notification received: ${payload.type.value}');
          // Handle foreground notification here if needed
          // e.g., show in-app notification, update UI, etc.
        },
      );

      // Initialize deep link service (needs context, so do it after first frame)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          DeepLinkService.instance.initialize(context);
        }
      });

      Logger.info('Services initialized successfully');
    } catch (e, stackTrace) {
      Logger.error('Error initializing services', e, stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
