import '../models/artist.dart';
import '../models/artwork.dart';
import '../services/europeana_api_service.dart';

class ArtworkRepository {
  final EuropeanaApiService _apiService;

  ArtworkRepository({EuropeanaApiService? apiService})
    : _apiService = apiService ?? EuropeanaApiService();

  // Search for artworks
  Future<ArtworkSearchResponse> searchArtworks({
    required String query,
    int page = 1,
    int pageSize = 24,
    String? reusability,
    String? mediaType,
    String? country,
    String? year,
  }) async {
    return await _apiService.searchArtworks(
      query: query,
      page: page,
      pageSize: pageSize,
      reusability: reusability,
      mediaType: mediaType,
      country: country,
      year: year,
    );
  }

  // Get detailed information about a specific artwork
  Future<Map<String, dynamic>> getArtworkDetail(String recordId) async {
    return await _apiService.getArtworkDetail(recordId);
  }

  // Get featured artworks (curated examples)
  Future<ArtworkSearchResponse> getFeaturedArtworks() async {
    // Using a more reliable search term
    return await _apiService.searchArtworks(
      query: 'painting OR portrait',
      pageSize: 10,
      reusability: null, // Remove the reusability filter for now
    );
  }

  // Get artworks by a specific artist
  Future<ArtworkSearchResponse> getArtworksByArtist(String artistName) async {
    // Clean the artist name for better search results
    String cleanArtistName = artistName.trim();

    // Form a more comprehensive query to catch various artist name formats
    String artistQuery = 'who:"$cleanArtistName"';

    return await _apiService.searchArtworks(
      query: artistQuery,
      pageSize: 30,
      // Remove filters that might restrict results
      reusability: null,
    );
  }
}

class ArtistRepository {
  final EuropeanaApiService _apiService;

  ArtistRepository({EuropeanaApiService? apiService})
    : _apiService = apiService ?? EuropeanaApiService();

  // Search for artists
  Future<ArtistSearchResponse> searchArtists({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) async {
    return await _apiService.searchArtists(query: query, page: page, pageSize: pageSize);
  }

  // Get featured/famous artists
  Future<ArtistSearchResponse> getFeaturedArtists() async {
    // List of some famous artists to search for
    const famousArtists = [
      'Leonardo da Vinci',
      'Vincent van Gogh',
      'Pablo Picasso',
      'Michelangelo',
      'Claude Monet',
      'Rembrandt',
      'Johannes Vermeer',
    ];

    // Choose a random subset of artists for variety
    final selectedArtist = famousArtists[DateTime.now().microsecond % famousArtists.length];

    return await _apiService.searchArtists(query: selectedArtist, pageSize: 5);
  }
}
