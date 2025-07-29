import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../data/models/artwork.dart';

class ArtworkGrid extends StatefulWidget {
  final List<Artwork> artworks;
  final Function? onLoadMore;
  final bool isLoading;

  const ArtworkGrid({Key? key, required this.artworks, this.onLoadMore, this.isLoading = false})
    : super(key: key);

  @override
  State<ArtworkGrid> createState() => _ArtworkGridState();
}

class _ArtworkGridState extends State<ArtworkGrid> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (widget.onLoadMore != null &&
        !widget.isLoading &&
        _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 500) {
      widget.onLoadMore!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8.0),
      itemCount: widget.artworks.length + (widget.isLoading ? 1 : 0),
      gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemBuilder: (context, index) {
        // Show loading indicator at the bottom
        if (index == widget.artworks.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0),
            child: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
                strokeWidth: 3,
              ),
            ),
          );
        }

        // Build artwork card
        final artwork = widget.artworks[index];
        return ArtworkCard(artwork: artwork);
      },
    );
  }
}

class ArtworkCard extends StatelessWidget {
  final Artwork artwork;

  const ArtworkCard({Key? key, required this.artwork}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.all(8.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.15), width: 1),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to artwork detail screen
          Navigator.pushNamed(context, '/artwork-detail', arguments: artwork.toJson());
        },
        splashColor: theme.colorScheme.primary.withOpacity(0.1),
        highlightColor: theme.colorScheme.primary.withOpacity(0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with elegant overlay
            if (artwork.previewUrl != null)
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: Image.network(
                      artwork.previewUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: theme.colorScheme.surface,
                          child: Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: theme.colorScheme.onSurface.withOpacity(0.3),
                              size: 32,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Subtle gradient overlay for better text visibility
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 60,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.15)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            // Artwork info with elegant styling
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    artwork.mainTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    artwork.mainCreator.isEmpty ? 'Unknown Artist' : artwork.mainCreator,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
