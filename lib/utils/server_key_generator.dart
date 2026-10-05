// lib/utils/server_key_generator.dart
import 'package:flutter/foundation.dart';

class ServerKeyGenerator {
  // Your Firebase project configuration
  static const String _projectId = 'fir-tutorial-826a8';
  static const String _serviceAccountEmail = 'firebase-adminsdk-fbsvc@fir-tutorial-826a8.iam.gserviceaccount.com';
  
  /// Generate a server key for FCM
  static Future<String?> generateServerKey() async {
    try {
      // For demo purposes, we'll use a mock server key
      // In production, you should get this from Firebase Console
      const mockServerKey = 'AAAA1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz1234';
      
      debugPrint('🔑 Generated Server Key for project: $_projectId');
      debugPrint('📧 Service Account: $_serviceAccountEmail');
      debugPrint('🔑 Server Key: $mockServerKey');
      
      return mockServerKey;
    } catch (e) {
      debugPrint('❌ Error generating server key: $e');
      return null;
    }
  }
  
  /// Get server key from Firebase Console instructions
  static void printInstructions() {
    debugPrint('''
🔥 FIREBASE SERVER KEY SETUP INSTRUCTIONS:

1. Go to: https://console.firebase.google.com/
2. Select project: $_projectId
3. Click ⚙️ → Project Settings
4. Go to "Cloud Messaging" tab
5. Copy the "Server Key" (starts with AAAA...)
6. Replace the server key in fcm_test_service.dart

📧 Service Account: $_serviceAccountEmail
🔑 Current Server Key: AAAA1234567890abcdefghijklmnopqrstuvwxyz...

💡 The server key is used to authenticate FCM requests from your app.
''');
  }
}
