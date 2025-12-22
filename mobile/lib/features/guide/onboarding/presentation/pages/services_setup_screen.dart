import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/guide_onboarding_entity.dart';
import '../providers/guide_onboarding_providers.dart';

class ServicesSetupScreen extends ConsumerStatefulWidget {
  const ServicesSetupScreen({super.key});

  @override
  ConsumerState<ServicesSetupScreen> createState() =>
      _ServicesSetupScreenState();
}

class _ServicesSetupScreenState extends ConsumerState<ServicesSetupScreen> {
  final Map<String, ServiceOffering> _selectedServices = {};
  final Map<String, TextEditingController> _priceControllers = {};
  final Map<String, TextEditingController> _descriptionControllers = {};
  bool _isLoading = false;

  @override
  void dispose() {
    for (var controller in _priceControllers.values) {
      controller.dispose();
    }
    for (var controller in _descriptionControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _toggleService(ServiceType serviceType) {
    setState(() {
      if (_selectedServices.containsKey(serviceType.id)) {
        _selectedServices.remove(serviceType.id);
        _priceControllers[serviceType.id]?.dispose();
        _descriptionControllers[serviceType.id]?.dispose();
        _priceControllers.remove(serviceType.id);
        _descriptionControllers.remove(serviceType.id);
      } else {
        _selectedServices[serviceType.id] = ServiceOffering(
          serviceTypeId: serviceType.id,
          serviceTypeName: serviceType.nameEn,
          price: 0,
          description: '',
          included: [],
          requiresVehicle: serviceType.requiresVehicle,
        );
        _priceControllers[serviceType.id] = TextEditingController();
        _descriptionControllers[serviceType.id] = TextEditingController();
      }
    });
  }

  Future<void> _continue() async {
    if (_selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one service')),
      );
      return;
    }

    // Validate all services have price and description
    for (var entry in _selectedServices.entries) {
      final price = _priceControllers[entry.key]?.text ?? '';
      final description = _descriptionControllers[entry.key]?.text ?? '';

      if (price.isEmpty || double.tryParse(price) == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Please set a valid price for ${entry.value.serviceTypeName}')),
        );
        return;
      }

      if (description.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Please add a description for ${entry.value.serviceTypeName}')),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Build service offerings
      final services = _selectedServices.entries.map((entry) {
        return ServiceOffering(
          serviceTypeId: entry.key,
          serviceTypeName: entry.value.serviceTypeName,
          price: double.parse(_priceControllers[entry.key]!.text),
          description: _descriptionControllers[entry.key]!.text,
          included: [], // Simplified - could add included items
          requiresVehicle: entry.value.requiresVehicle,
        );
      }).toList();

      final notifier = ref.read(guideOnboardingDataProvider.notifier);
      await notifier.saveServices(services);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final serviceTypesAsync = ref.watch(serviceTypesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Services Setup'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: LinearProgressIndicator(
              value: 3 / 7,
              backgroundColor: AppColors.lightGray,
              valueColor: const AlwaysStoppedAnimation(AppColors.accentTeal),
            ),
          ),
          Expanded(
            child: serviceTypesAsync.when(
              data: (serviceTypes) {
                return ListView(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  children: [
                    Text(
                      'Select Services You Offer',
                      style:
                          Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: AppDimensions.paddingM),
                    ...serviceTypes.map((serviceType) {
                      final isSelected =
                          _selectedServices.containsKey(serviceType.id);
                      return _ServiceCard(
                        serviceType: serviceType,
                        isSelected: isSelected,
                        priceController: _priceControllers[serviceType.id],
                        descriptionController:
                            _descriptionControllers[serviceType.id],
                        onToggle: () => _toggleService(serviceType),
                      );
                    }).toList(),
                    const SizedBox(height: AppDimensions.paddingXL),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _continue,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation(AppColors.white),
                              ),
                            )
                          : const Text('Continue'),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error loading services: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceType serviceType;
  final bool isSelected;
  final TextEditingController? priceController;
  final TextEditingController? descriptionController;
  final VoidCallback onToggle;

  const _ServiceCard({
    required this.serviceType,
    required this.isSelected,
    this.priceController,
    this.descriptionController,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      color: isSelected ? AppColors.accentTeal.withOpacity(0.05) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        side: BorderSide(
          color: isSelected ? AppColors.accentTeal : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: onToggle,
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: isSelected
                        ? AppColors.accentTeal
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppDimensions.paddingM),
                  Expanded(
                    child: Text(
                      serviceType.nameEn,
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ),
                  if (serviceType.requiresVehicle)
                    Chip(
                      label: const Text('Requires Vehicle'),
                      backgroundColor: AppColors.accentTeal.withOpacity(0.1),
                      labelStyle: const TextStyle(
                        fontSize: 11,
                        color: AppColors.accentTeal,
                      ),
                    ),
                ],
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: AppDimensions.paddingM),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Price (USD) *',
                  hintText: '50',
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppDimensions.paddingM),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  hintText: 'What does this service include?',
                ),
                maxLines: 2,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
