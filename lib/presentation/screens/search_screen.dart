import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/artwork_provider.dart';
import '../widgets/artwork_grid.dart';
import '../widgets/loading_indicator.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _initialQuery;

  // Filter state
  String? _selectedReusability;
  String? _selectedMediaType;
  String? _selectedCountry;
  String? _selectedYear;

  final List<String> _reusabilityOptions = ['open', 'restricted', 'permission'];
  final List<String> _mediaTypeOptions = ['image', 'text', '3d', 'sound', 'video'];
  final List<String> _countryOptions = [
    'Austria',
    'Belgium',
    'Bulgaria',
    'Croatia',
    'Cyprus',
    'Czechia',
    'Denmark',
    'Estonia',
    'Finland',
    'France',
    'Germany',
    'Greece',
    'Hungary',
    'Ireland',
    'Italy',
    'Latvia',
    'Lithuania',
    'Luxembourg',
    'Malta',
    'Netherlands',
    'Poland',
    'Portugal',
    'Romania',
    'Slovakia',
    'Slovenia',
    'Spain',
    'Sweden',
    'United Kingdom',
  ];

  final List<String> _yearOptions = [
    'Before 1000',
    '1000-1499',
    '1500-1699',
    '1700-1799',
    '1800-1849',
    '1850-1899',
    '1900-1945',
    'After 1945',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get the initial query from arguments if available
    final dynamic args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is String && _initialQuery == null) {
      _initialQuery = args;
      _searchController.text = args;

      // Use post-frame callback to avoid calling setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _performSearch();
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    if (_searchController.text.trim().isNotEmpty) {
      Provider.of<ArtworkProvider>(context, listen: false).searchArtworks(
        query: _searchController.text,
        reusability: _selectedReusability,
        mediaType: _selectedMediaType,
        country: _selectedCountry,
        year: _selectedYear,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search',
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
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for artworks or artists...',
                      prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 1.5,
                        ),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.filter_list, color: Theme.of(context).colorScheme.primary),
                    onPressed: _showFilterBottomSheet,
                    tooltip: 'Filter',
                  ),
                ),
              ],
            ),
          ),

          // Filter chips
          if (_selectedReusability != null ||
              _selectedMediaType != null ||
              _selectedCountry != null ||
              _selectedYear != null)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  if (_selectedReusability != null)
                    _buildFilterChip('Lisans: $_selectedReusability', () {
                      setState(() {
                        _selectedReusability = null;
                      });
                      _performSearch();
                    }),
                  if (_selectedMediaType != null)
                    _buildFilterChip('Medya: $_selectedMediaType', () {
                      setState(() {
                        _selectedMediaType = null;
                      });
                      _performSearch();
                    }),
                  if (_selectedCountry != null)
                    _buildFilterChip('Country: $_selectedCountry', () {
                      setState(() {
                        _selectedCountry = null;
                      });
                      _performSearch();
                    }),
                  if (_selectedYear != null)
                    _buildFilterChip('Period: $_selectedYear', () {
                      setState(() {
                        _selectedYear = null;
                      });
                      _performSearch();
                    }),
                  _buildFilterChip('Clear All', () {
                    setState(() {
                      _selectedReusability = null;
                      _selectedMediaType = null;
                      _selectedCountry = null;
                      _selectedYear = null;
                    });
                    _performSearch();
                  }, clearAll: true),
                ],
              ),
            ),

          // Results
          Expanded(
            child: Consumer<ArtworkProvider>(
              builder: (context, artworkProvider, _) {
                if (artworkProvider.isLoading && artworkProvider.artworks.isEmpty) {
                  return const Center(child: LoadingIndicator());
                } else if (artworkProvider.error != null && artworkProvider.artworks.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Error loading search results: ${artworkProvider.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                } else if (artworkProvider.artworks.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Use the search box above to find artworks.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                } else {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Results',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onBackground,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ArtworkGrid(
                          artworks: artworkProvider.artworks,
                          onLoadMore: artworkProvider.hasMoreData
                              ? () => artworkProvider.searchArtworks(
                                  query: _searchController.text,
                                  resetResults: false,
                                  reusability: _selectedReusability,
                                  mediaType: _selectedMediaType,
                                  country: _selectedCountry,
                                  year: _selectedYear,
                                )
                              : null,
                          isLoading: artworkProvider.isLoading,
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onTap, {bool clearAll = false}) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
      child: ActionChip(
        backgroundColor: clearAll
            ? theme.colorScheme.errorContainer.withOpacity(0.7)
            : theme.colorScheme.primaryContainer.withOpacity(0.7),
        side: BorderSide(
          color: clearAll
              ? theme.colorScheme.error.withOpacity(0.3)
              : theme.colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        labelStyle: TextStyle(
          color: clearAll ? theme.colorScheme.error : theme.colorScheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        label: Text(
          clearAll
              ? 'Clear All'
              : label
                    .replaceFirst('Lisans:', 'License:')
                    .replaceFirst('Medya:', 'Media:')
                    .replaceFirst('Ülke:', 'Country:')
                    .replaceFirst('Dönem:', 'Period:')
                    .replaceFirst('Tümünü Temizle', 'Clear All'),
        ),
        onPressed: onTap,
        avatar: clearAll
            ? Icon(Icons.clear_all, color: theme.colorScheme.error, size: 16)
            : Icon(Icons.close, color: theme.colorScheme.primary, size: 16),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Options',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onBackground,
                          letterSpacing: 0.2,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Text(
                    'License',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _reusabilityOptions.map((option) {
                      final isSelected = _selectedReusability == option;
                      return ChoiceChip(
                        label: Text(option),
                        selected: isSelected,
                        selectedColor: Theme.of(context).colorScheme.primaryContainer,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _selectedReusability = selected ? option : null;
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),
                  Text(
                    'Media Type',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _mediaTypeOptions.map((option) {
                      final isSelected = _selectedMediaType == option;
                      return ChoiceChip(
                        label: Text(option),
                        selected: isSelected,
                        selectedColor: Theme.of(context).colorScheme.primaryContainer,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _selectedMediaType = selected ? option : null;
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),
                  Text(
                    'Period',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _yearOptions.map((option) {
                      final isSelected = _selectedYear == option;
                      return ChoiceChip(
                        label: Text(option),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedYear = selected ? option : null;
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _performSearch();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Apply Filters',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
