import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart'; // Add this import for WidgetsBinding
import '../../data/repositories/local_repository.dart';
import '../../data/models/collection.dart';

class FavoriteProvider extends ChangeNotifier {
  final FavoriteRepository _repository;

  List<Map<String, dynamic>> _favorites = [];
  bool _isLoading = false;
  String? _error;

  FavoriteProvider({FavoriteRepository? repository})
    : _repository = repository ?? FavoriteRepository();

  List<Map<String, dynamic>> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all favorites
  Future<void> loadFavorites() async {
    _isLoading = true;
    _error = null;
    // Use post-frame callback to avoid build phase conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      _favorites = await _repository.getFavorites();
    } catch (e) {
      _error = 'Failed to load favorites: $e';
    } finally {
      _isLoading = false;
      // Use post-frame callback to avoid build phase conflicts
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // Add an artwork to favorites
  Future<bool> addToFavorites(String artworkId, Map<String, dynamic> artworkData) async {
    try {
      final success = await _repository.addFavorite(artworkId, artworkData);
      if (success) {
        await loadFavorites(); // Refresh the favorites list
      }
      return success;
    } catch (e) {
      _error = 'Failed to add to favorites: $e';
      // Use post-frame callback to avoid build phase conflicts
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return false;
    }
  }

  // Remove an artwork from favorites
  Future<bool> removeFromFavorites(String artworkId) async {
    try {
      final success = await _repository.removeFavorite(artworkId);
      if (success) {
        await loadFavorites(); // Refresh the favorites list
      }
      return success;
    } catch (e) {
      _error = 'Failed to remove from favorites: $e';
      // Use post-frame callback to avoid build phase conflicts
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return false;
    }
  }

  // Check if an artwork is in favorites
  Future<bool> isFavorite(String artworkId) async {
    try {
      return await _repository.isFavorite(artworkId);
    } catch (e) {
      _error = 'Failed to check favorite status: $e';
      // Use post-frame callback to avoid build phase conflicts
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return false;
    }
  }
}

class CollectionProvider extends ChangeNotifier {
  final CollectionRepository _repository;

  List<Collection> _collections = [];
  Collection? _selectedCollection;
  bool _isLoading = false;
  String? _error;

  CollectionProvider({CollectionRepository? repository})
    : _repository = repository ?? CollectionRepository();

  List<Collection> get collections => _collections;
  Collection? get selectedCollection => _selectedCollection;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all collections
  Future<void> loadCollections() async {
    _isLoading = true;
    _error = null;
    // Use post-frame callback to avoid build phase conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      _collections = await _repository.getCollections();
    } catch (e) {
      _error = 'Failed to load collections: $e';
    } finally {
      _isLoading = false;
      // Use post-frame callback to avoid build phase conflicts
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // Create a new collection
  Future<bool> createCollection(String title, String description, {String? coverImageUrl}) async {
    final newCollection = Collection(
      title: title,
      description: description,
      coverImageUrl: coverImageUrl,
    );

    try {
      final success = await _repository.saveCollection(newCollection);
      if (success) {
        await loadCollections(); // Refresh the collections list
      }
      return success;
    } catch (e) {
      _error = 'Failed to create collection: $e';
      // Use post-frame callback to avoid build phase conflicts
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return false;
    }
  }

  // Update an existing collection
  Future<bool> updateCollection(Collection collection) async {
    try {
      final success = await _repository.saveCollection(collection);
      if (success) {
        await loadCollections(); // Refresh the collections list
        if (_selectedCollection?.id == collection.id) {
          _selectedCollection =
              collection; // Update the selected collection if it's the one being modified
        }
      }
      return success;
    } catch (e) {
      _error = 'Failed to update collection: $e';
      // Use post-frame callback to avoid build phase conflicts
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return false;
    }
  }

  // Delete a collection
  Future<bool> deleteCollection(String collectionId) async {
    try {
      final success = await _repository.deleteCollection(collectionId);
      if (success) {
        await loadCollections(); // Refresh the collections list
        if (_selectedCollection?.id == collectionId) {
          _selectedCollection = null; // Clear the selected collection if it's the one being deleted
        }
      }
      return success;
    } catch (e) {
      _error = 'Failed to delete collection: $e';
      // Use post-frame callback to avoid build phase conflicts
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return false;
    }
  }

  // Select a collection
  Future<void> selectCollection(String collectionId) async {
    // Set loading state without notifying listeners during build
    _isLoading = true;
    _error = null;
    // Only notify if not in build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      _selectedCollection = await _repository.getCollection(collectionId);
    } catch (e) {
      _error = 'Failed to select collection: $e';
    } finally {
      _isLoading = false;
      // Use post-frame callback to avoid build phase conflicts
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // Add artwork to a collection
  Future<bool> addArtworkToCollection(String collectionId, String artworkId) async {
    try {
      var collection = await _repository.getCollection(collectionId);
      if (collection == null) return false;

      collection = collection.addArtwork(artworkId);
      final success = await _repository.saveCollection(collection);

      if (success && _selectedCollection?.id == collectionId) {
        _selectedCollection =
            collection; // Update the selected collection if it's the one being modified
      }

      await loadCollections(); // Refresh the collections list
      return success;
    } catch (e) {
      _error = 'Failed to add artwork to collection: $e';
      // Use post-frame callback to avoid build phase conflicts
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return false;
    }
  }

  // Remove artwork from a collection
  Future<bool> removeArtworkFromCollection(String collectionId, String artworkId) async {
    try {
      var collection = await _repository.getCollection(collectionId);
      if (collection == null) return false;

      collection = collection.removeArtwork(artworkId);
      final success = await _repository.saveCollection(collection);

      if (success && _selectedCollection?.id == collectionId) {
        _selectedCollection =
            collection; // Update the selected collection if it's the one being modified
      }

      await loadCollections(); // Refresh the collections list
      return success;
    } catch (e) {
      _error = 'Failed to remove artwork from collection: $e';
      // Use post-frame callback to avoid build phase conflicts
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return false;
    }
  }
}
