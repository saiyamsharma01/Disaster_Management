import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sahaaya/pages/dashboard_page_needy.dart';
import 'package:sahaaya/pages/sos_page.dart';
import 'pages/splash_page.dart';
import 'pages/nearby_shelter_page.dart';
import 'pages/ivr_demo_page.dart';
import 'pages/ivr_outcome_page.dart';
import 'pages/needy_view_page.dart';
import 'pages/report_map_page.dart';
import 'pages/chatbot_care_page.dart';
import 'pages/flood_alert_page.dart';
import 'pages/earthquake_alert_page.dart';
import 'pages/earthquake_map_page.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';

GoRouter createRouter() {
  return GoRouter(
    observers: [NavigatorObserver()],
    redirect: (context, state) {
      // Requires Firebase to be initialized before calling createRouter()
      final loggedIn = FirebaseAuth.instance.currentUser != null;
      final loggingIn =
          state.fullPath == '/login' || state.fullPath == '/signup';

      // Protect dashboard by auth
      if (!loggedIn && state.fullPath == '/dashboard') return '/login';

      // If logged in, keep them out of auth screens
      if (loggedIn && loggingIn) {
        return '/dashboard';
      }

      return null;
    },
    refreshListenable: GoRouterRefreshStream(
      FirebaseAuth.instance.authStateChanges(),
    ),
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashPage()),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardPageNeedy(),
      ),
      GoRoute(
        path: '/sos_page',
        name: 'sos_page',
        builder: (context, state) => const SosPage(),
      ),
      GoRoute(
        path: '/nearby_shelters',
        name: 'nearby_shelters',
        builder: (context, state) => const NearbyShelterPage(),
      ),
      GoRoute(
        path: '/ivr_demo',
        name: 'ivr_demo',
        builder: (context, state) => const IVRDemoPage(),
      ),
      GoRoute(
        path: '/ivr_outcome/:choice',
        name: 'ivr_outcome',
        builder: (context, state) {
          final choice = int.tryParse(state.pathParameters['choice'] ?? '0') ?? 0;
          return IVROutcomePage(choice: choice);
        },
      ),
      GoRoute(
        path: '/needy_view',
        name: 'needy_view',
        builder: (context, state) => const NeedyViewPage(),
      ),
      GoRoute(
        path: '/report_map/:choice',
        name: 'report_map',
        builder: (context, state) {
          final choice = int.tryParse(state.pathParameters['choice'] ?? '0') ?? 0;
          return ReportMapPage(choice: choice);
        },
      ),
      GoRoute(
        path: '/chatbot_care',
        name: 'chatbot_care',
        builder: (context, state) => const ChatbotCarePage(),
      ),
      GoRoute(
        path: '/flood_alerts',
        name: 'flood_alerts',
        builder: (context, state) => const FloodAlertPage(),
      ),
      GoRoute(
        path: '/earthquake_alerts',
        name: 'earthquake_alerts',
        builder: (context, state) => const EarthquakeAlertPage(),
      ),
      GoRoute(
        path: '/earthquake_map',
        name: 'earthquake_map',
        builder: (context, state) => const EarthquakeMapPage(),
      ),
    ],
  );
}

GoRouter createRouterWithoutAuth() {
  return GoRouter(
    observers: [NavigatorObserver()],
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashPage()),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardPageNeedy(),
      ),
      GoRoute(
        path: '/sos_page',
        name: 'sos_page',
        builder: (context, state) => const SosPage(),
      ),
      GoRoute(
        path: '/nearby_shelters',
        name: 'nearby_shelters',
        builder: (context, state) => const NearbyShelterPage(),
      ),
      GoRoute(
        path: '/ivr_demo',
        name: 'ivr_demo',
        builder: (context, state) => const IVRDemoPage(),
      ),
      GoRoute(
        path: '/ivr_outcome/:choice',
        name: 'ivr_outcome',
        builder: (context, state) {
          final choice = int.tryParse(state.pathParameters['choice'] ?? '0') ?? 0;
          return IVROutcomePage(choice: choice);
        },
      ),
      GoRoute(
        path: '/needy_view',
        name: 'needy_view',
        builder: (context, state) => const NeedyViewPage(),
      ),
      GoRoute(
        path: '/report_map/:choice',
        name: 'report_map',
        builder: (context, state) {
          final choice = int.tryParse(state.pathParameters['choice'] ?? '0') ?? 0;
          return ReportMapPage(choice: choice);
        },
      ),
      GoRoute(
        path: '/chatbot_care',
        name: 'chatbot_care',
        builder: (context, state) => const ChatbotCarePage(),
      ),
      GoRoute(
        path: '/flood_alerts',
        name: 'flood_alerts',
        builder: (context, state) => const FloodAlertPage(),
      ),
      GoRoute(
        path: '/earthquake_alerts',
        name: 'earthquake_alerts',
        builder: (context, state) => const EarthquakeAlertPage(),
      ),
      GoRoute(
        path: '/earthquake_map',
        name: 'earthquake_map',
        builder: (context, state) => const EarthquakeMapPage(),
      ),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListener = () => notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListener());
  }

  late final VoidCallback notifyListener;
  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
