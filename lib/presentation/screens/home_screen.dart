import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/artwork_provider.dart';
import '../providers/local_provider.dart';
import '../widgets/featured_carousel.dart';
import '../widgets/loading_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load featured artworks when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ArtworkProvider>(context, listen: false).loadFeaturedArtworks();
      Provider.of<CollectionProvider>(context, listen: false).loadCollections();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Using Consumer widgets instead of Provider.of to avoid rebuild issues
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Image.asset('assets/images/chastity_logo.png', height: 40),
            ),
            const Text('Chastity Virtual Museum'),
          ],
        ),
        centerTitle: false,
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<ArtworkProvider>(context, listen: false).loadFeaturedArtworks();
          await Provider.of<CollectionProvider>(context, listen: false).loadCollections();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Featured artworks carousel
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
                child: Text(
                  'Featured Artworks',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              Consumer<ArtworkProvider>(
                builder: (context, artworkProvider, _) {
                  if (artworkProvider.isLoading && artworkProvider.featuredArtworks.isEmpty) {
                    return const Center(child: LoadingIndicator());
                  } else if (artworkProvider.error != null &&
                      artworkProvider.featuredArtworks.isEmpty) {
                    return Center(
                      child: Text(
                        'Error loading featured artworks: ${artworkProvider.error}',
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else {
                    return FeaturedCarousel(artworks: artworkProvider.featuredArtworks);
                  }
                },
              ),

              // Collections section
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Collections',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                        letterSpacing: 0.2,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/collections');
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.secondary,
                      ),
                      child: const Text('View All', style: TextStyle(fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
              Consumer<CollectionProvider>(
                builder: (context, collectionProvider, _) {
                  if (collectionProvider.isLoading && collectionProvider.collections.isEmpty) {
                    return const Center(child: LoadingIndicator());
                  } else if (collectionProvider.error != null &&
                      collectionProvider.collections.isEmpty) {
                    return Center(
                      child: Text(
                        'Error loading collections: ${collectionProvider.error}',
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else if (collectionProvider.collections.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'You haven\'t created any collections yet.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  } else {
                    return SizedBox(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: collectionProvider.collections.length,
                        itemBuilder: (context, index) {
                          final collection = collectionProvider.collections[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/collection',
                                  arguments: collection.id,
                                );
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: 180,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Theme.of(context).colorScheme.surface,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                                    width: 1,
                                  ),
                                  image: collection.coverImageUrl != null
                                      ? DecorationImage(
                                          image: NetworkImage(collection.coverImageUrl!),
                                          fit: BoxFit.cover,
                                          colorFilter: ColorFilter.mode(
                                            Colors.black.withOpacity(0.3),
                                            BlendMode.darken,
                                          ),
                                        )
                                      : null,
                                ),
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      collection.title,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: collection.coverImageUrl != null
                                            ? Colors.white
                                            : Theme.of(context).colorScheme.onSurface,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.2,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.image_outlined,
                                          size: 14,
                                          color: collection.coverImageUrl != null
                                              ? Colors.white70
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.onSurface.withOpacity(0.6),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${collection.artworkIds.length} Artworks',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: collection.coverImageUrl != null
                                                ? Colors.white70
                                                : Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface.withOpacity(0.6),
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                },
              ),

              // Quick search categories
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
                child: Text(
                  'Categories',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
                children: [
                  _buildCategoryCard(
                    context,
                    'Paintings',
                    'painting',
                    Theme.of(context).colorScheme.secondary,
                  ),
                  _buildCategoryCard(
                    context,
                    'Sculptures',
                    'sculpture',
                    Theme.of(context).colorScheme.tertiary,
                  ),
                  _buildCategoryCard(
                    context,
                    'Photography',
                    'photography',
                    Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                  ),
                  _buildCategoryCard(
                    context,
                    'Manuscripts',
                    'manuscript',
                    Theme.of(context).colorScheme.tertiary.withOpacity(0.8),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, String searchQuery, Color color) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/search', arguments: searchQuery);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 2)),
          ],
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        padding: const EdgeInsets.all(16.0),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getCategoryIcon(searchQuery), color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'painting':
        return Icons.brush_outlined;
      case 'sculpture':
        return Icons.architecture_outlined;
      case 'photography':
        return Icons.camera_alt_outlined;
      case 'manuscript':
        return Icons.auto_stories_outlined;
      default:
        return Icons.image_outlined;
    }
  }
}
