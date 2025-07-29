import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../data/models/artwork.dart';

class FeaturedCarousel extends StatefulWidget {
  final List<Artwork> artworks;

  const FeaturedCarousel({super.key, required this.artworks});

  @override
  State<FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<FeaturedCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Auto-scroll functionality
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _startAutoScroll();
      }
    });
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && widget.artworks.isNotEmpty) {
        final nextPage = (_currentPage + 1) % widget.artworks.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
        _startAutoScroll();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.artworks.isEmpty) {
      return const SizedBox(height: 200, child: Center(child: Text('No featured artworks found')));
    }

    return Column(
      children: [
        SizedBox(
          height: 280,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.artworks.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final artwork = widget.artworks[index];
              return _buildFeaturedItem(context, artwork);
            },
          ),
        ),
        const SizedBox(height: 16),
        SmoothPageIndicator(
          controller: _pageController,
          count: widget.artworks.length,
          effect: ExpandingDotsEffect(
            activeDotColor: Theme.of(context).colorScheme.primary,
            dotColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            dotHeight: 6,
            dotWidth: 6,
            expansionFactor: 4,
            spacing: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedItem(BuildContext context, Artwork artwork) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Artwork image
            if (artwork.previewUrl != null)
              Image.network(
                artwork.previewUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: theme.colorScheme.surface,
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                        size: 48,
                      ),
                    ),
                  );
                },
              )
            else
              Container(
                color: theme.colorScheme.surface,
                child: Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    size: 48,
                  ),
                ),
              ),

            // Elegant gradient overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            ),

            // Artwork info with elegant styling
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    artwork.mainTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.brush_outlined, color: Colors.white.withOpacity(0.8), size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${artwork.mainCreator} · ${artwork.mainYear}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Make the whole card clickable with subtle feedback
            Material(
              color: Colors.transparent,
              child: InkWell(
                splashColor: theme.colorScheme.primary.withOpacity(0.1),
                highlightColor: theme.colorScheme.primary.withOpacity(0.05),
                onTap: () {
                  Navigator.pushNamed(context, '/artwork-detail', arguments: artwork.toJson());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
