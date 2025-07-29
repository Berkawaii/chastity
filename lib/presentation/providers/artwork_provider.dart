import 'package:flutter/foundation.dart';
import '../../data/repositories/europeana_repository.dart';
import '../../data/models/artwork.dart';

class ArtworkProvider extends ChangeNotifier {
  final ArtworkRepository _repository;

  // State variables
  List<Artwork> _artworks = [];
  List<Artwork> _featuredArtworks = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMoreData = true;

  // Constructor
  ArtworkProvider({ArtworkRepository? repository})
    : _repository = repository ?? ArtworkRepository();

  // Getters
  List<Artwork> get artworks => _artworks;
  List<Artwork> get featuredArtworks => _featuredArtworks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMoreData => _hasMoreData;

  // Initialize with featured artworks
  Future<void> loadFeaturedArtworks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.getFeaturedArtworks();
      _featuredArtworks = response.items ?? [];
    } catch (e) {
      _error = 'Failed to load featured artworks: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search for artworks
  Future<void> searchArtworks({
    required String query,
    bool resetResults = true,
    String? reusability,
    String? mediaType,
    String? country,
    String? year,
  }) async {
    if (resetResults) {
      _artworks = [];
      _currentPage = 1;
      _hasMoreData = true;
    }

    if (_isLoading || !_hasMoreData) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.searchArtworks(
        query: query,
        page: _currentPage,
        reusability: reusability,
        mediaType: mediaType,
        country: country,
        year: year,
      );

      final newArtworks = response.items ?? [];

      if (resetResults) {
        _artworks = newArtworks;
      } else {
        _artworks = [..._artworks, ...newArtworks];
      }

      _currentPage++;
      _hasMoreData = newArtworks.isNotEmpty && (_artworks.length < (response.totalResults ?? 0));
    } catch (e) {
      _error = 'Failed to search artworks: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get artwork details
  Future<Map<String, dynamic>?> getArtworkDetail(String recordId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final detail = await _repository.getArtworkDetail(recordId);
      _isLoading = false;
      notifyListeners();
      return detail;
    } catch (e) {
      _error = 'Failed to get artwork details: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Get artworks by artist
  Future<void> getArtworksByArtist(String artistName) async {
    _artworks = [];
    _currentPage = 1;
    _hasMoreData = true;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.getArtworksByArtist(artistName);
      _artworks = response.items ?? [];
      _hasMoreData = false; // Usually we get all results in one call for an artist
    } catch (e) {
      _error = 'Failed to get artworks by artist: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset state
  void reset() {
    _artworks = [];
    _error = null;
    _currentPage = 1;
    _hasMoreData = true;
    notifyListeners();
  }
}
