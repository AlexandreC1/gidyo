import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/search_params_entity.dart';
import '../providers/search_providers.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/guide_card.dart';
import 'map_view_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider);
    final searchParams = ref.watch(searchParamsProvider);
    final viewMode = ref.watch(viewModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Guides'),
        actions: [
          // View Toggle
          IconButton(
            icon: Icon(
              viewMode == ViewMode.list ? Icons.map : Icons.list,
            ),
            onPressed: () {
              ref.read(viewModeProvider.notifier).state =
                  viewMode == ViewMode.list ? ViewMode.map : ViewMode.list;
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            color: AppColors.white,
            child: Column(
              children: [
                // Location Search
                TextField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    hintText: 'Where do you need a guide?',
                    prefixIcon: const Icon(Icons.location_on),
                    suffixIcon: _locationController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _locationController.clear();
                              ref
                                  .read(searchParamsProvider.notifier)
                                  .updateLocation(null);
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    ref
                        .read(searchParamsProvider.notifier)
                        .updateLocation(value.isEmpty ? null : value);
                  },
                ),

                const SizedBox(height: AppDimensions.paddingM),

                // Filter and Sort Row
                Row(
                  children: [
                    // Filter Button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _showFilterSheet,
                        icon: Icon(
                          Icons.tune,
                          color: searchParams.hasFilters
                              ? AppColors.accentTeal
                              : null,
                        ),
                        label: Text(
                          searchParams.hasFilters
                              ? 'Filters Applied'
                              : 'Filters',
                          style: TextStyle(
                            color: searchParams.hasFilters
                                ? AppColors.accentTeal
                                : null,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: AppDimensions.paddingM),

                    // Sort Dropdown
                    Expanded(
                      child: DropdownButtonFormField<SortOption>(
                        value: searchParams.sortBy,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.sort),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingM,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: SortOption.rating,
                            child: Text('Rating'),
                          ),
                          DropdownMenuItem(
                            value: SortOption.priceLowToHigh,
                            child: Text('Price: Low-High'),
                          ),
                          DropdownMenuItem(
                            value: SortOption.priceHighToLow,
                            child: Text('Price: High-Low'),
                          ),
                          DropdownMenuItem(
                            value: SortOption.distance,
                            child: Text('Distance'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            ref
                                .read(searchParamsProvider.notifier)
                                .updateSortBy(value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Active Filter Chips
          if (searchParams.hasFilters)
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
              ),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _buildFilterChips(searchParams),
              ),
            ),

          const Divider(height: 1),

          // Content Based on View Mode
          Expanded(
            child: viewMode == ViewMode.list
                ? _buildListView(searchResults)
                : const MapViewScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(AsyncValue searchResults) {
    return searchResults.when(
      data: (guides) {
        if (guides.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 80,
                  color: AppColors.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: AppDimensions.paddingL),
                Text(
                  'No guides found',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: AppDimensions.paddingM),
                Text(
                  'Try adjusting your filters',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          itemCount: guides.length,
          itemBuilder: (context, index) {
            return GuideCard(
              guide: guides[index],
              onTap: () {
                // Navigate to guide profile
              },
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.error,
            ),
            const SizedBox(height: AppDimensions.paddingL),
            Text(
              'Error loading guides',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.paddingL),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(searchResultsProvider);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFilterChips(SearchParamsEntity params) {
    final chips = <Widget>[];

    // Price Range Chip
    if (params.minPrice != null || params.maxPrice != null) {
      chips.add(
        Chip(
          label: Text('\$${params.minPrice?.round() ?? 0} - \$${params.maxPrice?.round() ?? 500}'),
          deleteIcon: const Icon(Icons.close, size: 18),
          onDeleted: () {
            ref.read(searchParamsProvider.notifier).updatePriceRange(null, null);
          },
        ),
      );
    }

    // Rating Chip
    if (params.minRating != null) {
      chips.add(
        Chip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${params.minRating}+ '),
              const Icon(Icons.star, size: 14),
            ],
          ),
          deleteIcon: const Icon(Icons.close, size: 18),
          onDeleted: () {
            ref.read(searchParamsProvider.notifier).updateMinRating(null);
          },
        ),
      );
    }

    // Date Range Chip
    if (params.startDate != null && params.endDate != null) {
      chips.add(
        Chip(
          label: Text(
            '${_formatDate(params.startDate!)} - ${_formatDate(params.endDate!)}',
          ),
          deleteIcon: const Icon(Icons.close, size: 18),
          onDeleted: () {
            ref.read(searchParamsProvider.notifier).updateDateRange(null, null);
          },
        ),
      );
    }

    // Languages Chips
    for (final language in params.languages) {
      chips.add(
        Chip(
          label: Text(language),
          deleteIcon: const Icon(Icons.close, size: 18),
          onDeleted: () {
            final updated = List<String>.from(params.languages)..remove(language);
            ref.read(searchParamsProvider.notifier).updateLanguages(updated);
          },
        ),
      );
    }

    return chips
        .map((chip) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: chip,
            ))
        .toList();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}
