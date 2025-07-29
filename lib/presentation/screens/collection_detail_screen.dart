import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/artwork.dart';
import '../../data/models/collection.dart';
import '../providers/artwork_provider.dart';
import '../providers/local_provider.dart';
import '../widgets/artwork_grid.dart';
import '../widgets/loading_indicator.dart';

class CollectionDetailScreen extends StatefulWidget {
  const CollectionDetailScreen({super.key});

  @override
  State<CollectionDetailScreen> createState() => _CollectionDetailScreenState();
}

class _CollectionDetailScreenState extends State<CollectionDetailScreen> {
  Collection? _collection;
  List<Artwork> _artworks = [];
  bool _isLoading = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get collection ID from arguments
    final dynamic args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is String) {
      _loadCollection(args);
    }
  }

  Future<void> _loadCollection(String collectionId) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final collectionProvider = Provider.of<CollectionProvider>(context, listen: false);
      await collectionProvider.selectCollection(collectionId);

      if (!mounted) return;

      final collection = collectionProvider.selectedCollection;
      if (collection != null) {
        setState(() {
          _collection = collection;
        });

        if (collection.artworkIds.isNotEmpty) {
          await _loadArtworks(collection.artworkIds);
        } else {
          if (!mounted) return;
          setState(() {
            _artworks = [];
          });
        }
      } else {
        if (!mounted) return;
        setState(() {
          _error = 'Collection not found';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error loading collection: $e';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadArtworks(List<String> artworkIds) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final artworks = <Artwork>[];
      final artworkProvider = Provider.of<ArtworkProvider>(context, listen: false);

      // Debug output to track collection artwork IDs
      log('Loading ${artworkIds.length} artworks for collection: $artworkIds');

      // Fetch each artwork by ID from the API
      for (final artworkId in artworkIds) {
        try {
          log('Fetching artwork details for ID: $artworkId');

          // Get the artwork details from the API
          final artworkDetail = await artworkProvider.getArtworkDetail(artworkId);

          log('Artwork detail response: ${artworkDetail != null ? 'received' : 'null'}');

          if (artworkDetail != null) {
            // Extract the item data from the response
            final item = artworkDetail['object'];

            // Debug the structure of the response
            log('Artwork object: ${item != null ? 'found' : 'null'}');
            if (item != null) {
              log('Artwork object keys: ${item.keys.toList()}');
              log('Title: ${item['title']}');
              log('Creator: ${item['creator']}');

              // Parse the item into an Artwork object
              final artwork = Artwork.fromJson(item);
              log(
                'Created Artwork object with title: ${artwork.titles?.firstOrNull ?? 'No Title'} and creator: ${artwork.creators?.firstOrNull ?? 'Unknown Artist'}',
              );
              artworks.add(artwork);
            }
          }
        } catch (e) {
          log('Error loading artwork $artworkId: $e');
        }
      }

      // If we failed to load any artworks through the API, try to load them from the database
      // since we might have saved them there when adding to the collection
      if (artworks.isEmpty) {
        log('No artworks loaded from API, trying to load from local favorites');
        final favoriteProvider = Provider.of<FavoriteProvider>(context, listen: false);
        await favoriteProvider.loadFavorites();

        final favorites = favoriteProvider.favorites;
        log('Found ${favorites.length} favorites in local storage');

        for (final artworkId in artworkIds) {
          // Try to find this artwork in favorites
          final favorite = favorites.firstWhere(
            (fav) => fav['id'] == artworkId,
            orElse: () => {'id': artworkId, 'data': null},
          );

          if (favorite['data'] != null) {
            log('Found artwork $artworkId in favorites');
            // We found the artwork in favorites, parse it
            try {
              final data = favorite['data'];
              final artwork = Artwork(
                id: artworkId,
                titles: data['title'] is List
                    ? data['title']
                    : data['title'] != null
                    ? [data['title']]
                    : ['Artwork #$artworkId'],
                creators: data['creator'] is List
                    ? data['creator']
                    : data['creator'] != null
                    ? [data['creator']]
                    : ['Unknown Artist'],
                years: data['year'] is List
                    ? data['year']
                    : data['year'] != null
                    ? [data['year']]
                    : ['Date unknown'],
                previewUrl: data['edmPreview'],
              );
              artworks.add(artwork);
            } catch (e) {
              log('Error parsing favorite data: $e');
              // Create placeholder
              artworks.add(
                Artwork(
                  id: artworkId,
                  titles: ['Artwork #$artworkId'],
                  creators: ['Unknown Artist'],
                  years: ['Date unknown'],
                  previewUrl: null,
                ),
              );
            }
          } else {
            // Create placeholder
            log('Creating placeholder for artwork $artworkId');
            artworks.add(
              Artwork(
                id: artworkId,
                titles: ['Artwork #$artworkId'],
                creators: ['Unknown Artist'],
                years: ['Date unknown'],
                previewUrl: null,
              ),
            );
          }
        }
      }

      if (!mounted) return;

      setState(() {
        _artworks = artworks;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Error loading artworks: $e';
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showEditCollectionDialog() {
    if (_collection == null) return;

    final titleController = TextEditingController(text: _collection!.title);
    final descriptionController = TextEditingController(text: _collection!.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Collection'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Collection Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              final description = descriptionController.text.trim();

              if (title.isNotEmpty) {
                final updatedCollection = _collection!.copyWith(
                  title: title,
                  description: description,
                );

                Provider.of<CollectionProvider>(
                  context,
                  listen: false,
                ).updateCollection(updatedCollection).then((_) {
                  setState(() {
                    _collection = updatedCollection;
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _collection == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Collection')),
        body: const Center(child: LoadingIndicator()),
      );
    }

    if (_error != null && _collection == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Collection')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(_error!, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    if (_collection == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Collection')),
        body: const Center(child: Text('Collection not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_collection!.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showEditCollectionDialog,
            tooltip: 'Edit',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Collection info
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Description', style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 8),
                Text(_collection!.description, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text('${_artworks.length} artworks', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),

          const Divider(height: 1),

          // Artworks
          Expanded(
            child: _isLoading
                ? const Center(child: LoadingIndicator())
                : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(_error!, textAlign: TextAlign.center),
                    ),
                  )
                : _artworks.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'There are no artworks in this collection yet.\n\nYou can add artworks from the search page.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ArtworkGrid(artworks: _artworks),
          ),
        ],
      ),
    );
  }
}
