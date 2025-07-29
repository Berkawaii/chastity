class AppConstants {
  // API constants
  static const String apiBaseUrl = 'https://api.europeana.eu';
  static const String apiKey = 'hakeaditc'; // Updated to valid API key

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
