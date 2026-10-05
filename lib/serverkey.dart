// lib/serverkey.dart
import 'package:googleapis_auth/auth_io.dart';
import 'package:sahaaya/services/notification_service.dart';

class GetServerKey {
  Future<String> serverToken() async {
    final scopes = [
      'https://www.googleapis.com/auth/firebase.messaging',
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.database',
    ];

    // Create the service account credentials
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "YOUR_PROJECT_ID",
      "private_key_id": "YOUR_PRIVATE_KEY_ID",
      "private_key": "-----BEGIN PRIVATE KEY-----\nYOUR_PRIVATE_KEY\n-----END PRIVATE KEY-----\n",
      "client_email": "firebase-adminsdk-fbsvc@YOUR_PROJECT_ID.iam.gserviceaccount.com",
      "client_id": "YOUR_CLIENT_ID",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40YOUR_PROJECT_ID.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    // Create credentials
    final credentials = ServiceAccountCredentials.fromJson(serviceAccountJson);

    // Get the client
    final client = await clientViaServiceAccount(credentials, scopes);

    // Get the access token
    final accessToken = client.credentials.accessToken.data;
    client.close();
    return accessToken;
  }
}

const serverKey = '';
Future<void> printFCMToken() async {
  String? token = await NotificationService().getFCMToken();
  // ignore: avoid_print
  print('FCM Token: $token');
}

const port = 3002;
