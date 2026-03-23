import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static late final String apiKey;
  static late final String appId;
  static late final String projectId;
  static late final String messagingSenderId;
  static late final String storageBucket;
  
  static late final String customApiKey;
  static late final String customApiUrl;
  
  static late final String environment;
  static late final String logLevel;

  static void loadConfig() async {
    await dotenv.load();
    apiKey = dotenv.env['FIREBASE_API_KEY'] ?? '';
    appId = dotenv.env['FIREBASE_APP_ID'] ?? '';
    projectId = dotenv.env['FIREBASE_PROJECT_ID'] ?? '';
    messagingSenderId = dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';
    storageBucket = dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '';
    
    customApiKey = dotenv.env['CUSTOM_API_KEY'] ?? '';
    customApiUrl = dotenv.env['CUSTOM_API_URL'] ?? '';
    
    environment = dotenv.env['ENVIRONMENT'] ?? '';
    logLevel = dotenv.env['LOG_LEVEL'] ?? '';
  }

  static bool isProduction() {
    return environment == 'production';
  }

  static bool isDevelopment() {
    return environment == 'development';
  }

  static void validateConfig() {
    assert(apiKey.isNotEmpty, 'API Key cannot be empty!');
    assert(appId.isNotEmpty, 'App ID cannot be empty!');
    assert(projectId.isNotEmpty, 'Project ID cannot be empty!');
    assert(messagingSenderId.isNotEmpty, 'Messaging Sender ID cannot be empty!');
    assert(storageBucket.isNotEmpty, 'Storage Bucket cannot be empty!');
    assert(customApiKey.isNotEmpty, 'Custom API Key cannot be empty!');
    assert(customApiUrl.isNotEmpty, 'Custom API URL cannot be empty!');
  }
}