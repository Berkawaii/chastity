import '../services/database_service.dart';
import '../models/collection.dart';

class CollectionRepository {
  final DatabaseService _databaseService;

  CollectionRepository({DatabaseService? databaseService})
    : _databaseService = databaseService ?? DatabaseService();

  // Get all collections
  Future<List<Collection>> getCollections() async {
    return await _databaseService.getCollections();
  }

  // Get a specific collection by ID
  Future<Collection?> getCollection(String id) async {
    return await _databaseService.getCollection(id);
  }

  // Create or update a collection
  Future<bool> saveCollection(Collection collection) async {
    return await _databaseService.saveCollection(collection);
  }

  // Delete a collection
  Future<bool> deleteCollection(String id) async {
    return await _databaseService.deleteCollection(id);
  }
}

class FavoriteRepository {
  final DatabaseService _databaseService;

  FavoriteRepository({DatabaseService? databaseService})
    : _databaseService = databaseService ?? DatabaseService();

  // Add an artwork to favorites
  Future<bool> addFavorite(String artworkId, Map<String, dynamic> artworkData) async {
    return await _databaseService.addFavorite(artworkId, artworkData);
  }

  // Remove an artwork from favorites
  Future<bool> removeFavorite(String artworkId) async {
    return await _databaseService.removeFavorite(artworkId);
  }

  // Check if an artwork is in favorites
  Future<bool> isFavorite(String artworkId) async {
    return await _databaseService.isFavorite(artworkId);
  }

  // Get all favorite artworks
  Future<List<Map<String, dynamic>>> getFavorites() async {
    return await _databaseService.getFavorites();
  }
}
