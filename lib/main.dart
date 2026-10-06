import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sahaaya/router.dart';
import 'package:sahaaya/firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sahaaya/l10n/app_localizations.dart';
import 'package:sahaaya/locale_controller.dart';
import 'package:sahaaya/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Note: Mapbox Maps SDK only supports Android and iOS
  // For Windows/macOS/Linux/Web, the app uses flutter_map automatically
  if (!kIsWeb) {
    try {
      // Check if running on mobile before initializing Mapbox
      final isMobile =
          defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS;

      if (isMobile) {
        // Only try to initialize Mapbox on mobile
        String accessToken = const String.fromEnvironment("ACCESS_TOKEN");
        if (accessToken.isNotEmpty) {
          debugPrint('✅ Ready for Mapbox on mobile');
        }
      } else {
        debugPrint('ℹ️ Using flutter_map for desktop');
      }
    } catch (e) {
      debugPrint('ℹ️ Platform detection: ${e.toString()}');
    }
  }

  GoRouter appRouter;

  try {
    // Always initialize with options (works for all platforms)
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized successfully with ${DefaultFirebaseOptions.currentPlatform.projectId}');
    
    await LocaleController.initialize();
    
    // Initialize notification service safely
    try {
      await NotificationService().initialize();
    } catch (notifErr) {
      debugPrint('ℹ️ NotificationService initialization info: $notifErr');
    }
    
    appRouter = createRouter();
  } catch (e) {
    debugPrint('⚠️ Firebase.initializeApp error: $e');
    // Fall back to a minimal router so Web doesn't render a blank page
    await LocaleController.initialize();
    appRouter = createRouterWithoutAuth();
  }

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => LocaleController(child: MyApp(router: appRouter)),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: LocaleController.notifier,
      builder: (context, locale, _) {
        return MaterialApp.router(
          routerConfig: router,
          title: 'Sahaaya',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          darkTheme: ThemeData.dark(useMaterial3: true),
          debugShowCheckedModeBanner: false,
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        );
      },
    );
  }
}
