import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/local_provider.dart';
import '../widgets/loading_indicator.dart';

class ArtworkDetailScreen extends StatefulWidget {
  const ArtworkDetailScreen({super.key});

  @override
  State<ArtworkDetailScreen> createState() => _ArtworkDetailScreenState();
}

class _ArtworkDetailScreenState extends State<ArtworkDetailScreen> {
  Map<String, dynamic>? _artwork;
  bool _isFavorite = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get artwork data from arguments
    final dynamic args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      setState(() {
        _artwork = args;
      });

      // Check if artwork is in favorites
      _checkFavoriteStatus();
    }
  }

  Future<void> _checkFavoriteStatus() async {
    if (_artwork != null && _artwork!['id'] != null) {
      final isFavorite = await Provider.of<FavoriteProvider>(
        context,
        listen: false,
      ).isFavorite(_artwork!['id']);

      if (mounted) {
        setState(() {
          _isFavorite = isFavorite;
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (_artwork == null) return;

    final favoriteProvider = Provider.of<FavoriteProvider>(context, listen: false);

    bool success;
    if (_isFavorite) {
      success = await favoriteProvider.removeFromFavorites(_artwork!['id']);
    } else {
      success = await favoriteProvider.addToFavorites(_artwork!['id'], _artwork!);
    }

    if (success && mounted) {
      setState(() {
        _isFavorite = !_isFavorite;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFavorite ? 'Added to favorites' : 'Removed from favorites'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _addToCollection() {
    if (_artwork == null) return;

    // First save the artwork to favorites to ensure we have a local copy
    final artworkId = _artwork!['id'];

    log('Adding artwork $artworkId to collection');
    log('Artwork data: $_artwork');

    // Save artwork to favorites first to make sure we have a local copy
    Provider.of<FavoriteProvider>(context, listen: false).addToFavorites(artworkId, _artwork!);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return _CollectionSelectionBottomSheet(artworkId: artworkId);
      },
    );
  }

  void _shareArtwork() {
    if (_artwork == null) return;

    String title = _artwork!['title']?[0] ?? 'Artwork';
    // Clean up title if it contains format information
    if (title.contains('["') && title.contains('"]')) {
      final match = RegExp(r'.*\["(.*)"\].*').firstMatch(title);
      if (match != null && match.groupCount >= 1) {
        title = match.group(1) ?? title;
      }
    }

    // Try to extract the artist name from multiple possible fields
    String creator = 'Unknown Artist';
    if (_artwork!['creator'] != null &&
        _artwork!['creator'] is List &&
        _artwork!['creator'].isNotEmpty) {
      creator = _artwork!['creator'][0];
    } else if (_artwork!['dc:creator'] != null &&
        _artwork!['dc:creator'] is List &&
        _artwork!['dc:creator'].isNotEmpty) {
      creator = _artwork!['dc:creator'][0];
    }

    final String? link = _artwork!['link'];

    final String shareText =
        'I discovered $title by $creator in the Chastity Virtual Museum!\n\n'
        '${link ?? 'Check out more in the Chastity Virtual Museum app!'}';

    Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    if (_artwork == null) {
      return const Scaffold(body: Center(child: Text('Artwork information not found')));
    }

    String title = _artwork!['title']?[0] ?? 'Untitled';
    // Clean up title if it contains format information like "painting (oil): ["Self Portrait"]"
    if (title.contains('["') && title.contains('"]')) {
      final match = RegExp(r'.*\["(.*)"\].*').firstMatch(title);
      if (match != null && match.groupCount >= 1) {
        title = match.group(1) ?? title;
      }
    }

    // Try to extract the artist name from multiple possible creator fields
    String creator = 'Unknown Artist';
    // Check different possible creator field names and formats
    if (_artwork!['creator'] != null) {
      if (_artwork!['creator'] is List && _artwork!['creator'].isNotEmpty) {
        creator = _artwork!['creator'][0];
      } else if (_artwork!['creator'] is String) {
        creator = _artwork!['creator'];
      }
    } else if (_artwork!['dc:creator'] != null) {
      if (_artwork!['dc:creator'] is List && _artwork!['dc:creator'].isNotEmpty) {
        creator = _artwork!['dc:creator'][0];
      } else if (_artwork!['dc:creator'] is String) {
        creator = _artwork!['dc:creator'];
      }
    } else if (_artwork!['proxy_dc_creator'] != null) {
      if (_artwork!['proxy_dc_creator'] is List && _artwork!['proxy_dc_creator'].isNotEmpty) {
        creator = _artwork!['proxy_dc_creator'][0];
      } else if (_artwork!['proxy_dc_creator'] is String) {
        creator = _artwork!['proxy_dc_creator'];
      }
    }

    // If still unknown artist, try to find artist name in the description
    if (creator == 'Unknown Artist' && _artwork!['dcDescription'] != null) {
      List<String> knownArtists = [
        'Van Gogh',
        'Vincent van Gogh',
        'Rembrandt',
        'da Vinci',
        'Leonardo da Vinci',
        'Picasso',
        'Monet',
        'Claude Monet',
        'Vermeer',
        'Dali',
        'Salvador Dali',
      ];

      String description = '';
      if (_artwork!['dcDescription'] is List && _artwork!['dcDescription'].isNotEmpty) {
        description = _artwork!['dcDescription'][0].toString();
      } else if (_artwork!['dcDescription'] is String) {
        description = _artwork!['dcDescription'];
      }

      for (String artist in knownArtists) {
        if (description.contains(artist)) {
          creator = artist;
          log('Found artist $artist in description');
          break;
        }
      }
    }

    // If creator is still unknown, try to extract from description
    if (creator == 'Unknown Artist' && _artwork!['dcDescription'] != null) {
      String description = '';
      if (_artwork!['dcDescription'] is List && _artwork!['dcDescription'].isNotEmpty) {
        description = _artwork!['dcDescription'][0];
      } else if (_artwork!['dcDescription'] is String) {
        description = _artwork!['dcDescription'];
      }

      // Check for common artist names in the description
      // List of well-known artists to check for
      final List<String> knownArtists = [
        'Vincent van Gogh',
        'Van Gogh',
        'Vincent',
        'Pablo Picasso',
        'Picasso',
        'Claude Monet',
        'Monet',
        'Leonardo da Vinci',
        'Leonardo',
        'da Vinci',
        'Rembrandt',
        'Rembrandt van Rijn',
        'Michelangelo',
        'Michelangelo Buonarroti',
        'Salvador Dalí',
        'Dalí',
        'Frida Kahlo',
        'Kahlo',
        'Johannes Vermeer',
        'Vermeer',
        'Caravaggio',
        'Andy Warhol',
        'Warhol',
      ];

      for (String artist in knownArtists) {
        if (description.contains(artist)) {
          creator = artist;
          break;
        }
      }

      // Additional check specifically for Vincent van Gogh who is sometimes referred to just by first name
      if (creator == 'Unknown Artist' &&
          (description.toLowerCase().contains('van gogh') ||
              description.toLowerCase().contains('vincent') &&
                  (description.toLowerCase().contains('self portrait') ||
                      description.toLowerCase().contains('self-portrait')))) {
        creator = 'Vincent van Gogh';
      }
    }

    // Clean up creator name if needed
    if (creator.contains('["') && creator.contains('"]')) {
      final match = RegExp(r'.*\["(.*)"\].*').firstMatch(creator);
      if (match != null && match.groupCount >= 1) {
        creator = match.group(1) ?? creator;
      }
    }

    // Handle year/date information - check multiple possible date fields
    String year = 'Date unknown';
    if (_artwork!['year'] != null) {
      if (_artwork!['year'] is List && _artwork!['year'].isNotEmpty) {
        year = _artwork!['year'][0];
      } else if (_artwork!['year'] is String) {
        year = _artwork!['year'];
      }
    } else if (_artwork!['dc:date'] != null) {
      if (_artwork!['dc:date'] is List && _artwork!['dc:date'].isNotEmpty) {
        year = _artwork!['dc:date'][0];
      } else if (_artwork!['dc:date'] is String) {
        year = _artwork!['dc:date'];
      }
    } else if (_artwork!['timestamp_created'] != null) {
      year = _artwork!['timestamp_created'].toString().substring(
        0,
        4,
      ); // Extract year from timestamp
    } else if (_artwork!['proxy_dc_date'] != null) {
      if (_artwork!['proxy_dc_date'] is List && _artwork!['proxy_dc_date'].isNotEmpty) {
        year = _artwork!['proxy_dc_date'][0];
      } else if (_artwork!['proxy_dc_date'] is String) {
        year = _artwork!['proxy_dc_date'];
      }
    }

    // Clean up year if needed
    if (year.contains('["') && year.contains('"]')) {
      final match = RegExp(r'.*\["(.*)"\].*').firstMatch(year);
      if (match != null && match.groupCount >= 1) {
        year = match.group(1) ?? year;
      }
    }

    final description =
        _artwork!['dcDescription']?[0] ?? 'No description available for this artwork.';
    final imageUrl = _artwork!['edmPreview'] ?? '';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with image
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.4,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
                      ),
                    ),
            ),
            actions: [
              IconButton(
                icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
                onPressed: _toggleFavorite,
              ),
              IconButton(icon: const Icon(Icons.add_to_photos), onPressed: _addToCollection),
              IconButton(icon: const Icon(Icons.share), onPressed: _shareArtwork),
            ],
          ),

          // Artwork details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.displayMedium),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      // Navigate to artist details or artworks by this artist
                      if (creator != 'Unknown Artist') {
                        // If the creator name contains extra information (like dates), extract just the name
                        String searchName = creator;
                        if (searchName.contains(',')) {
                          searchName = searchName.split(',')[0].trim();
                        }
                        Navigator.pushNamed(context, '/search', arguments: 'who:"$searchName"');
                      }
                    },
                    child: Text(
                      creator,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.indigo,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(year, style: Theme.of(context).textTheme.bodySmall),

                  const Divider(height: 32),

                  Text('Description', style: Theme.of(context).textTheme.displaySmall),
                  const SizedBox(height: 8),
                  Text(description, style: Theme.of(context).textTheme.bodyMedium),

                  const Divider(height: 32),

                  // Additional metadata
                  if (_artwork!['dataProvider'] != null)
                    _buildMetadataItem(context, 'Provider', _artwork!['dataProvider'][0]),

                  if (_artwork!['country'] != null)
                    _buildMetadataItem(context, 'Country', _artwork!['country'][0]),

                  if (_artwork!['type'] != null)
                    _buildMetadataItem(context, 'Type', _artwork!['type']),

                  // View in Europeana link
                  if (_artwork!['link'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: Center(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.open_in_browser),
                          label: const Text('View on Europeana'),
                          onPressed: () {
                            // Open link in browser
                            // Use url_launcher package to open the link
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _CollectionSelectionBottomSheet extends StatefulWidget {
  final String artworkId;

  const _CollectionSelectionBottomSheet({required this.artworkId});

  @override
  State<_CollectionSelectionBottomSheet> createState() => _CollectionSelectionBottomSheetState();
}

class _CollectionSelectionBottomSheetState extends State<_CollectionSelectionBottomSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CollectionProvider>(context, listen: false).loadCollections();
    });
  }

  @override
  Widget build(BuildContext context) {
    final collectionsProvider = Provider.of<CollectionProvider>(context);
    final collections = collectionsProvider.collections;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 16,
        left: 16,
        right: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Add to Collection', style: Theme.of(context).textTheme.displaySmall),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),

          const SizedBox(height: 16),

          if (collectionsProvider.isLoading)
            const Center(child: LoadingIndicator())
          else if (collectionsProvider.error != null)
            Center(
              child: Text(
                'Error loading collections: ${collectionsProvider.error}',
                textAlign: TextAlign.center,
              ),
            )
          else if (collections.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'You haven\'t created any collections yet. Click the "New Collection" button to create your first collection.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              itemCount: collections.length,
              itemBuilder: (context, index) {
                final collection = collections[index];
                final isInCollection = collection.artworkIds.contains(widget.artworkId);

                return ListTile(
                  title: Text(collection.title),
                  subtitle: Text(
                    '${collection.artworkIds.length} ${collection.artworkIds.length == 1 ? 'artwork' : 'artworks'}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: isInCollection
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                  onTap: () async {
                    final collectionProvider = Provider.of<CollectionProvider>(
                      context,
                      listen: false,
                    );

                    if (isInCollection) {
                      await collectionProvider.removeArtworkFromCollection(
                        collection.id,
                        widget.artworkId,
                      );

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Artwork removed from "${collection.title}" collection'),
                          ),
                        );
                      }
                    } else {
                      await collectionProvider.addArtworkToCollection(
                        collection.id,
                        widget.artworkId,
                      );

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Artwork added to "${collection.title}" collection'),
                          ),
                        );
                      }
                    }

                    setState(() {});
                  },
                );
              },
            ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Create New Collection'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/create-collection');
              },
            ),
          ),
        ],
      ),
    );
  }
}
