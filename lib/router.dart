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

/// Ultra-fast custom page transition for smooth, instantaneous route switching
CustomTransitionPage<void> _buildSmoothPage(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 180),
    reverseTransitionDuration: const Duration(milliseconds: 160),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curved),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.04, 0.0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

GoRouter createRouter() {
  return GoRouter(
    observers: [NavigatorObserver()],
    redirect: (context, state) {
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
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => _buildSmoothPage(context, state, const SplashPage()),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => _buildSmoothPage(context, state, const LoginPage()),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        pageBuilder: (context, state) => _buildSmoothPage(context, state, const SignupPage()),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        pageBuilder: (context, state) => _buildSmoothPage(context, state, const DashboardPageNeedy()),
      ),
      GoRoute(
        path: '/sos_page',
        name: 'sos_page',
        pageBuilder: (context, state) => _buildSmoothPage(context, state, const SosPage()),
      ),
      GoRoute(
        path: '/nearby_shelters',
        name: 'nearby_shelters',
        pageBuilder: (context, state) => _buildSmoothPage(context, state, const NearbyShelterPage()),
      ),
      GoRoute(
        path: '/ivr_demo',
        name: 'ivr_demo',
        pageBuilder: (context, state) => _buildSmoothPage(context, state, const IVRDemoPage()),
      ),
      GoRoute(
        path: '/ivr_outcome/:choice',
        name: 'ivr_outcome',
        pageBuilder: (context, state) {
          final choice = int.tryParse(state.pathParameters['choice'] ?? '0') ?? 0;
          return _buildSmoothPage(context, state, IVROutcomePage(choice: choice));
        },
      ),
      GoRoute(
        path: '/needy_view',
        name: 'needy_view',
        pageBuilder: (context, state) => _buildSmoothPage(context, state, const NeedyViewPage()),
      ),
      GoRoute(
        path: '/report_map/:choice',
        name: 'report_map',
        pageBuilder: (context, state) {
          final choice = int.tryParse(state.pathParameters['choice'] ?? '0') ?? 0;
          return _buildSmoothPage(context, state, ReportMapPage(choice: choice));
        },
      ),
      GoRoute(
        path: '/chatbot_care',
        name: 'chatbot_care',
        pageBuilder: (context, state) => _buildSmoothPage(context, state, const ChatbotCarePage()),
      ),
      GoRoute(
        path: '/flood_alerts',
        name: 'flood_alerts',
        pageBuilder: (context, state) => _buildSmoothPage(context, state, const FloodAlertPage()),
      ),
      GoRoute(
        path: '/earthquake_alerts',
        name: 'earthquake_alerts',
        pageBuilder: (context, state) => _buildSmoothPage(context, state, const EarthquakeAlertPage()),
      ),
      GoRoute(
        path: '/earthquake_map',
        name: 'earthquake_map',
        pageBuilder: (context, state) => _buildSmoothPage(context, state, const EarthquakeMapPage()),
      ),
    ],
  );
}

GoRouter createRouterWithoutAuth() {
  return GoRouter(
    observers: [NavigatorObserver()],
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => _buildSmoothPage(context, state, const SplashPage()),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => _buildSmoothPage(context, state, const LoginPage()),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        pageBuilder: (context, state) => _buildSmoothPage(context, state, const SignupPage()),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        pageBuilder: (context, state) => _buildSmoothPage(context, state, const DashboardPageNeedy()),
      ),
      GoRoute(
        path: '/sos_page',
        name: 'sos_page',
        pageBuilder: (context, state) => _buildSmoothPage(context, state, const SosPage()),
      ),
      GoRoute(
        path: '/nearby_shelters',
        name: 'nearby_shelters',
        pageBuilder: (context, state) => _buildSmoothPage(context, state, const NearbyShelterPage()),
      ),
      GoRoute(
        path: '/ivr_demo',
        name: 'ivr_demo',
        pageBuilder: (context, state) => _buildSmoothPage(context, state, const IVRDemoPage()),
      ),
      GoRoute(
        path: '/ivr_outcome/:choice',
        name: 'ivr_outcome',
        pageBuilder: (context, state) {
          final choice = int.tryParse(state.pathParameters['choice'] ?? '0') ?? 0;
          return _buildSmoothPage(context, state, IVROutcomePage(choice: choice));
        },
      ),
      GoRoute(
        path: '/needy_view',
        name: 'needy_view',
        pageBuilder: (context, state) => _buildSmoothPage(context, state, const NeedyViewPage()),
      ),
      GoRoute(
        path: '/report_map/:choice',
        name: 'report_map',
        pageBuilder: (context, state) {
          final choice = int.tryParse(state.pathParameters['choice'] ?? '0') ?? 0;
          return _buildSmoothPage(context, state, ReportMapPage(choice: choice));
        },
      ),
      GoRoute(
        path: '/chatbot_care',
        name: 'chatbot_care',
        pageBuilder: (context, state) => _buildSmoothPage(context, state, const ChatbotCarePage()),
      ),
      GoRoute(
        path: '/flood_alerts',
        name: 'flood_alerts',
        pageBuilder: (context, state) => _buildSmoothPage(context, state, const FloodAlertPage()),
      ),
      GoRoute(
        path: '/earthquake_alerts',
        name: 'earthquake_alerts',
        pageBuilder: (context, state) => _buildSmoothPage(context, state, const EarthquakeAlertPage()),
      ),
      GoRoute(
        path: '/earthquake_map',
        name: 'earthquake_map',
        pageBuilder: (context, state) => _buildSmoothPage(context, state, const EarthquakeMapPage()),
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
