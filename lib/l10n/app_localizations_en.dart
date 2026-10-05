// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Sahaaya';

  @override
  String get welcomeTitle => 'Welcome to Sahaaya!';

  @override
  String get welcomeSubtitle =>
      'Your journey to help and support starts here.\nLogin or Sign up to continue.';

  @override
  String get login => 'Login';

  @override
  String get signUp => 'Sign Up';

  @override
  String get welcomeBack => 'Welcome Back!';

  @override
  String get email => 'Email';

  @override
  String get enterValidEmail => 'Enter valid email';

  @override
  String get password => 'Password';

  @override
  String get min6Chars => 'Min 6 characters';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get signIn => 'Sign In';

  @override
  String get signInWithGoogle => 'Sign In with Google';

  @override
  String get noAccount => 'Don\'t have an account? ';

  @override
  String get registerNow => 'Register now';

  @override
  String get pleaseEnterEmailFirst => 'Please enter your email first.';

  @override
  String get resetEmailSent => 'Password reset email sent. Check your inbox.';

  @override
  String get resetEmailFailed => 'Failed to send reset email';

  @override
  String get userNotFound => 'No user found for that email.';

  @override
  String get wrongPassword => 'Incorrect password. Please try again.';

  @override
  String get invalidEmail => 'Invalid email format.';

  @override
  String get loginFailed => 'Login failed. Please try again.';

  @override
  String get createAccount => 'Create Account';

  @override
  String get username => 'Username';

  @override
  String get enterUsername => 'Enter username';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get passwordsMismatch => 'Passwords do not match';

  @override
  String get signUpWithGoogle => 'Sign Up with Google';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get signInCta => 'Sign In';

  @override
  String get getStarted => 'Get Started';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get assistQuestion => 'How can we assist you today?';

  @override
  String get ivrDemo => 'IVR Demo';

  @override
  String get nearbyShelters => 'Nearby Shelters';

  @override
  String get emergencySos => 'Emergency (SOS)';

  @override
  String get askForSupport => 'Ask for Support';

  @override
  String get chatbotCare => 'Chatbot Care';

  @override
  String get floodAlerts => 'Flood Alerts';

  @override
  String get quickViewIVROutcomes => 'Quick View (IVR outcomes)';

  @override
  String get emergencies1 => 'Emergencies (1)';

  @override
  String get foodShelter2 => 'Food/Shelter (2)';

  @override
  String get volunteers3 => 'Volunteers (3)';

  @override
  String get actions => 'Actions';

  @override
  String get openIVRKeypad => 'Open IVR Keypad';

  @override
  String get recordFreshResponse => 'Record a fresh response (1/2/3)';

  @override
  String get safetyTip => 'Safety Tip:';

  @override
  String get safetyTipContent =>
      'Always keep a bag ready with water, non-perishable food, and essential documents.';

  @override
  String get appInfo => 'App Info';

  @override
  String get signOut => 'Sign out';

  @override
  String get sosEmergency => 'SOS Emergency';

  @override
  String get sendLiveSos => 'Send Live SOS Alert';

  @override
  String get liveSosSent => 'Live SOS alert sent successfully!';

  @override
  String get failedToSendSos => 'Failed to send SOS';

  @override
  String get sosAlertsOverview => 'SOS Alerts Overview';

  @override
  String get liveReportsDemo => 'Live reports with demo data for showcase.';

  @override
  String get highRiskZones => 'High-Risk Zones';

  @override
  String get noHighRiskZones => 'No high-risk zones detected yet';

  @override
  String get zonesAppearAuto =>
      'Zones appear automatically after three nearby alerts.';

  @override
  String get allAlerts => 'All Alerts';

  @override
  String get noSosAlertsYet => 'No SOS alerts yet';

  @override
  String get pressSosToSend => 'Press the SOS button to send a live alert.';

  @override
  String clusterOfAlerts(Object count) {
    return 'Cluster of $count alerts';
  }

  @override
  String get demoData => 'Demo data';

  @override
  String get liveData => 'Live data';

  @override
  String alertsCountLabel(Object count) {
    return '$count alerts';
  }
}
