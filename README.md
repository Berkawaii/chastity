# Chastity - Europeana API Flutter Application

This Flutter application has been developed to provide art enthusiasts with a virtual museum experience using Europeana APIs. Users can search for digital artworks from European cultural heritage, view their details, add them to favorites, and create personal collections.

## Features

- **Artwork Search**: Users can search Europeana records using keywords
- **Detail View**: View metadata and images of selected artworks
- **Artist Information**: Access information about artists
- **Add to Favorites**: Save favorite artworks to a personal list
- **Collection Creation**: Create themed collections of artworks
- **Filtering**: Filter search results by year, country, and media type
- **Virtual Museum Navigation**: Browse artworks in grid or slider view
- **Sharing**: Share artwork information via social media

## Technical Information

### Technologies Used

- **Flutter SDK**: Multiplatform app development for iOS, Android, and Web
- **HTTP Packages**: http, Dio
- **JSON Serialization**: json_serializable
- **State Management**: Provider
- **Database**: SQLite
- **Europeana APIs**: Search, Record, Entity

### Project Structure

```
lib/
  ├── core/
  │   ├── constants.dart
  │   └── theme.dart
  ├── data/
  │   ├── models/
  │   │   ├── artwork.dart
  │   │   ├── artist.dart
  │   │   └── collection.dart
  │   ├── repositories/
  │   │   ├── europeana_repository.dart
  │   │   └── local_repository.dart
  │   └── services/
  │       ├── europeana_api_service.dart
  │       └── database_service.dart
  ├── presentation/
  │   ├── providers/
  │   │   ├── artwork_provider.dart
  │   │   ├── artist_provider.dart
  │   │   └── local_provider.dart
  │   ├── screens/
  │   │   ├── home_screen.dart
  │   │   ├── search_screen.dart
  │   │   ├── artwork_detail_screen.dart
  │   │   ├── favorites_screen.dart
  │   │   ├── collections_screen.dart
  │   │   ├── collection_detail_screen.dart
  │   │   └── main_navigation_screen.dart
  │   └── widgets/
  │       ├── artwork_grid.dart
  │       ├── featured_carousel.dart
  │       └── loading_indicator.dart
  └── main.dart
```

## API Documentation

- **Search API**: https://pro.europeana.eu/page/search
- **Record API**: https://pro.europeana.eu/page/record
- **Entity API**: https://pro.europeana.eu/page/entity-api

## Installation

1. Clone the project

   ```bash
   git clone https://github.com/yourusername/virtual-museum.git
   ```

2. Install dependencies

   ```bash
   flutter pub get
   ```

3. Generate code for models

   ```bash
   flutter pub run build_runner build
   ```

4. Set up your API key
   Replace the `apiKey` value in the `lib/core/constants.dart` file with your own Europeana API key.

5. Run the application
   ```bash
   flutter run
   ```

## Development Roadmap

1. API Prototype: Basic API integration completed
2. UI Prototype: Page interfaces designed
3. Favorite and Collection Management: Local database integrated
4. Virtual Museum Layout: Home page and detail page designs to be improved
5. User Experience Enhancement: Animations and transitions to be added

## Running with VS Code

The project includes a `.vscode/launch.json` file with several configurations:

- **Flutter (Debug)**: Standard debugging mode
- **Flutter (Profile)**: Performance profiling mode
- **Flutter (Release)**: Release build mode
- **Flutter Web**: Runs the app in Chrome browser on port 8000
- **All Tests**: Runs all test files in the test directory
