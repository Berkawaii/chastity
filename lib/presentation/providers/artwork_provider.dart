import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../../data/models/artwork.dart';
import '../../data/repositories/europeana_repository.dart';

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
      log('ArtworkProvider: Getting details for artwork ID: $recordId');
      final detail = await _repository.getArtworkDetail(recordId);
      log('ArtworkProvider: Received detail response: ${detail != null ? 'success' : 'null'}');
      log('ArtworkProvider: Response has object: ${detail.containsKey('object')}');
      _isLoading = false;
      notifyListeners();
      return detail;
    } catch (e) {
      log('ArtworkProvider: Error getting artwork details: $e');
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
      // First try with the who: prefix
      final response = await _repository.getArtworksByArtist(artistName);
      _artworks = response.items ?? [];

      // If no results found, try alternative search approaches
      if (_artworks.isEmpty) {
        // Log the attempt for debugging
        log('No results found with who:$artistName, trying alternative search');

        // Try without the who: prefix - direct name search
        final alternativeResponse = await _repository.searchArtworks(
          query: artistName,
          pageSize: 30,
        );

        _artworks = alternativeResponse.items ?? [];

        // If still empty, try with broader terms
        if (_artworks.isEmpty) {
          log('Still no results, trying with broader search terms');

          // Try to extract the last name or first name for broader search
          String searchTerm = artistName;
          if (artistName.contains(' ')) {
            // For artists with spaces in name like "Vincent van Gogh"
            // Try using just the last name or most distinctive part
            final nameParts = artistName.split(' ');
            if (nameParts.length > 1) {
              if (nameParts.contains('van') ||
                  nameParts.contains('de') ||
                  nameParts.contains('da')) {
                // For names like "van Gogh" or "da Vinci", keep the prefix
                searchTerm = nameParts.sublist(nameParts.length - 2).join(' ');
              } else {
                // Otherwise just use last name
                searchTerm = nameParts.last;
              }
            }
          }

          final broadResponse = await _repository.searchArtworks(
            query: 'creator:$searchTerm OR dc_creator:$searchTerm',
            pageSize: 30,
          );

          _artworks = broadResponse.items ?? [];
        }
      }

      _hasMoreData = false; // Usually we get all results in one call for an artist

      if (_artworks.isEmpty) {
        _error = 'No artworks found for artist: $artistName';
      }
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
