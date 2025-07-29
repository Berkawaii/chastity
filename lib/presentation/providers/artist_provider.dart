import 'package:flutter/foundation.dart';
import '../../data/repositories/europeana_repository.dart';
import '../../data/models/artist.dart';

class ArtistProvider extends ChangeNotifier {
  final ArtistRepository _repository;

  // State variables
  List<Artist> _artists = [];
  List<Artist> _featuredArtists = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMoreData = true;

  // Constructor
  ArtistProvider({ArtistRepository? repository}) : _repository = repository ?? ArtistRepository();

  // Getters
  List<Artist> get artists => _artists;
  List<Artist> get featuredArtists => _featuredArtists;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMoreData => _hasMoreData;

  // Load featured artists
  Future<void> loadFeaturedArtists() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.getFeaturedArtists();
      _featuredArtists = response.items ?? [];
    } catch (e) {
      _error = 'Failed to load featured artists: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search for artists
  Future<void> searchArtists({required String query, bool resetResults = true}) async {
    if (resetResults) {
      _artists = [];
      _currentPage = 1;
      _hasMoreData = true;
    }

    if (_isLoading || !_hasMoreData) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.searchArtists(query: query, page: _currentPage);

      final newArtists = response.items ?? [];

      if (resetResults) {
        _artists = newArtists;
      } else {
        _artists = [..._artists, ...newArtists];
      }

      _currentPage++;
      _hasMoreData = newArtists.isNotEmpty && (_artists.length < (response.total ?? 0));
    } catch (e) {
      _error = 'Failed to search artists: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load more artists (pagination)
  Future<void> loadMoreArtists(String query) async {
    if (!_hasMoreData || _isLoading) return;
    await searchArtists(query: query, resetResults: false);
  }

  // Reset state
  void reset() {
    _artists = [];
    _error = null;
    _currentPage = 1;
    _hasMoreData = true;
    notifyListeners();
  }
}
