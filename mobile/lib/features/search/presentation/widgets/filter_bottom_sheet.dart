import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/search_params_entity.dart';
import '../providers/search_providers.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late List<String> _selectedServiceTypes;
  late DateTimeRange? _dateRange;
  late RangeValues _priceRange;
  late double? _minRating;
  late List<String> _selectedLanguages;
  late String? _vehicleType;

  @override
  void initState() {
    super.initState();
    final params = ref.read(searchParamsProvider);
    _selectedServiceTypes = List.from(params.serviceTypeIds);
    _dateRange = params.startDate != null && params.endDate != null
        ? DateTimeRange(start: params.startDate!, end: params.endDate!)
        : null;
    _priceRange = RangeValues(
      params.minPrice ?? 0,
      params.maxPrice ?? 500,
    );
    _minRating = params.minRating;
    _selectedLanguages = List.from(params.languages);
    _vehicleType = params.vehicleType;
  }

  @override
  Widget build(BuildContext context) {
    final serviceTypesAsync = ref.watch(serviceTypesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDimensions.radiusXL),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(
                    vertical: AppDimensions.paddingM,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gray,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title and Clear
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filters',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    TextButton(
                      onPressed: _resetFilters,
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Filter Options
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  children: [
                    // Service Type
                    Text(
                      'Service Type',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppDimensions.paddingM),
                    serviceTypesAsync.when(
                      data: (serviceTypes) => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: serviceTypes.map((serviceType) {
                          final isSelected =
                              _selectedServiceTypes.contains(serviceType.id);
                          return FilterChip(
                            label: Text(serviceType.nameEn),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedServiceTypes.add(serviceType.id);
                                } else {
                                  _selectedServiceTypes.remove(serviceType.id);
                                }
                              });
                            },
                            selectedColor: AppColors.accentTeal.withOpacity(0.2),
                            checkmarkColor: AppColors.accentTeal,
                          );
                        }).toList(),
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (_, __) => const Text('Failed to load service types'),
                    ),

                    const SizedBox(height: AppDimensions.paddingL),

                    // Date Range
                    Text(
                      'Date Range',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppDimensions.paddingM),
                    OutlinedButton.icon(
                      onPressed: _selectDateRange,
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        _dateRange != null
                            ? '${_formatDate(_dateRange!.start)} - ${_formatDate(_dateRange!.end)}'
                            : 'Select dates',
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingL),

                    // Price Range
                    Text(
                      'Price Range',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppDimensions.paddingM),
                    RangeSlider(
                      values: _priceRange,
                      min: 0,
                      max: 500,
                      divisions: 50,
                      labels: RangeLabels(
                        '\$${_priceRange.start.round()}',
                        '\$${_priceRange.end.round()}',
                      ),
                      onChanged: (values) {
                        setState(() {
                          _priceRange = values;
                        });
                      },
                    ),
                    Text(
                      '\$${_priceRange.start.round()} - \$${_priceRange.end.round()}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppDimensions.paddingL),

                    // Minimum Rating
                    Text(
                      'Minimum Rating',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppDimensions.paddingM),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Any'),
                          selected: _minRating == null,
                          onSelected: (selected) {
                            setState(() {
                              _minRating = null;
                            });
                          },
                        ),
                        ...List.generate(5, (index) {
                          final rating = (index + 1).toDouble();
                          return ChoiceChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('$rating'),
                                const SizedBox(width: 4),
                                const Icon(Icons.star, size: 16),
                              ],
                            ),
                            selected: _minRating == rating,
                            onSelected: (selected) {
                              setState(() {
                                _minRating = rating;
                              });
                            },
                            selectedColor: AppColors.accentGolden.withOpacity(0.2),
                          );
                        }),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.paddingL),

                    // Languages
                    Text(
                      'Languages',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppDimensions.paddingM),
                    ..._buildLanguageCheckboxes(),

                    const SizedBox(height: AppDimensions.paddingL),

                    // Vehicle Type (conditional)
                    if (_selectedServiceTypes.any((id) =>
                        id.contains('driver') || id.contains('transport'))) ...[
                      Text(
                        'Vehicle Type',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: AppDimensions.paddingM),
                      Wrap(
                        spacing: 8,
                        children: ['Sedan', 'SUV', 'Van', 'Bus'].map((vehicle) {
                          return ChoiceChip(
                            label: Text(vehicle),
                            selected: _vehicleType == vehicle,
                            onSelected: (selected) {
                              setState(() {
                                _vehicleType = selected ? vehicle : null;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppDimensions.paddingL),
                    ],
                  ],
                ),
              ),

              // Apply Button
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    child: const Text('Apply Filters'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildLanguageCheckboxes() {
    final languages = ['English', 'French', 'Creole', 'Spanish'];
    return languages.map((language) {
      final isSelected = _selectedLanguages.contains(language);
      return CheckboxListTile(
        title: Text(language),
        value: isSelected,
        onChanged: (selected) {
          setState(() {
            if (selected == true) {
              _selectedLanguages.add(language);
            } else {
              _selectedLanguages.remove(language);
            }
          });
        },
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
      );
    }).toList();
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _dateRange,
    );

    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedServiceTypes = [];
      _dateRange = null;
      _priceRange = const RangeValues(0, 500);
      _minRating = null;
      _selectedLanguages = [];
      _vehicleType = null;
    });
  }

  void _applyFilters() {
    final notifier = ref.read(searchParamsProvider.notifier);

    notifier.updateServiceTypes(_selectedServiceTypes);
    notifier.updateDateRange(_dateRange?.start, _dateRange?.end);
    notifier.updatePriceRange(_priceRange.start, _priceRange.end);
    notifier.updateMinRating(_minRating);
    notifier.updateLanguages(_selectedLanguages);
    notifier.updateVehicleType(_vehicleType);

    Navigator.pop(context);
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
