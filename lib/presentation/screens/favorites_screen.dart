import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/artwork.dart';
import '../providers/local_provider.dart';
import '../widgets/artwork_grid.dart';
import '../widgets/loading_indicator.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FavoriteProvider>(context, listen: false).loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final favorites = favoriteProvider.favorites;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Favorites',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await favoriteProvider.loadFavorites();
        },
        child: favoriteProvider.isLoading
            ? const Center(child: LoadingIndicator())
            : favoriteProvider.error != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Error loading favorites: ${favoriteProvider.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : favorites.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'You haven\'t added any favorites yet.\n\nAdd artworks to your favorites to view them here.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : _buildFavoritesGrid(favorites),
      ),
    );
  }

  Widget _buildFavoritesGrid(List<Map<String, dynamic>> favorites) {
    // Convert favorite items to Artwork objects
    final artworks = favorites.map((favorite) {
      final data = favorite['data'] as Map<String, dynamic>;
      return Artwork.fromJson(data);
    }).toList();

    return ArtworkGrid(artworks: artworks);
  }
}
