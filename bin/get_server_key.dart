// bin/get_server_key.dart
import 'package:sahaaya/serverkey.dart';

void main() async {
  print('Fetching Firebase server key...');
  
  try {
    final serverKey = await GetServerKey().serverToken();
    print('Server Key: $serverKey');
    print('');
    print('Use this key in your fcm_proxy_server.js file:');
    print('const SERVER_KEY = \'$serverKey\';');
  } catch (e) {
    print('Error fetching server key: $e');
  }
}
