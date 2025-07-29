import 'dart:io' show Platform;

import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // API constants
  static const String apiBaseUrl = 'https://api.europeana.eu';

  // API key from .env file or environment variable
  static String get apiKey {
    // Try to get from dotenv first
    final envKey = dotenv.env['API_KEY'];
    if (envKey != null && envKey.isNotEmpty) {
      return envKey;
    }

    // Try from platform environment variables
    final platformKey = Platform.environment['API_KEY'];
    if (platformKey != null && platformKey.isNotEmpty) {
      return platformKey;
    }

    // Fallback for development only - NEVER commit actual keys
    return 'fallback_dev_key_replace_in_production';
  }

  // API endpoints
  static const String searchEndpoint = '/record/v2/search.json'; // Updated as per documentation
  static const String recordEndpoint = '/record/v2'; // Used for specific record retrieval
  static const String entityEndpoint = '/entity/v2/search.json';

  // App constants
  static const String appName = 'Chastity';
  static const String appVersion = '1.0.0';

  // Storage keys
  static const String favoriteStorageKey = 'favorites';
  static const String collectionsStorageKey = 'collections';
}
