class AppConfig {
  final String firebaseApiKey;
  final String firebaseAppId;
  final String firebaseProjectId;
  final String firebaseMessagingSenderId;
  final String firebaseStorageBucket;
  final String customApiKey;
  final String customApiUrl;
  final String environment;
  final String logLevel;
  final bool isProduction;
  final bool isDevelopment;

  AppConfig({
    required this.firebaseApiKey,
    required this.firebaseAppId,
    required this.firebaseProjectId,
    required this.firebaseMessagingSenderId,
    required this.firebaseStorageBucket,
    required this.customApiKey,
    required this.customApiUrl,
    required this.environment,
    required this.logLevel,
    required this.isProduction,
    required this.isDevelopment,
  });

  void validateConfig() {
    // Add validation logic here
  }
}