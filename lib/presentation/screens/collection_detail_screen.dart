import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/artwork.dart';
import '../../data/models/collection.dart';
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
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final collectionProvider = Provider.of<CollectionProvider>(context, listen: false);
      await collectionProvider.selectCollection(collectionId);

      final collection = collectionProvider.selectedCollection;
      if (collection != null) {
        setState(() {
          _collection = collection;
        });

        if (collection.artworkIds.isNotEmpty) {
          await _loadArtworks(collection.artworkIds);
        } else {
          setState(() {
            _artworks = [];
          });
        }
      } else {
        setState(() {
          _error = 'Collection not found';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading collection: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadArtworks(List<String> artworkIds) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final artworks = <Artwork>[];

      // This is a simplified version. In a real app, we would need to fetch the artwork details
      // for each ID using the API. For now, we'll use placeholder data.
      for (final artworkId in artworkIds) {
        // Here we would fetch the artwork from the API or local storage
        // For now, let's create a placeholder
        artworks.add(
          Artwork(
            id: artworkId,
            titles: ['Artwork #$artworkId'],
            creators: ['Unknown Artist'],
            years: ['Date unknown'],
          ),
        );
      }

      setState(() {
        _artworks = artworks;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading artworks: $e';
      });
    } finally {
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
