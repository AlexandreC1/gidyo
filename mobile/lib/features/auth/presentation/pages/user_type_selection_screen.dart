import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/user_entity.dart';
import '../providers/auth_controller.dart';
import '../providers/auth_providers.dart';

class UserTypeSelectionScreen extends ConsumerStatefulWidget {
  const UserTypeSelectionScreen({super.key});

  @override
  ConsumerState<UserTypeSelectionScreen> createState() =>
      _UserTypeSelectionScreenState();
}

class _UserTypeSelectionScreenState
    extends ConsumerState<UserTypeSelectionScreen> {
  UserType? _selectedType;

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authLoadingProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppDimensions.paddingXL),

              // Title
              Text(
                'Welcome to GIDYO!',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.paddingM),

              Text(
                'Tell us how you\'ll be using GIDYO',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppDimensions.paddingXXL),

              // User Type Cards
              Expanded(
                child: Column(
                  children: [
                    // Visitor Card
                    Expanded(
                      child: _UserTypeCard(
                        icon: Icons.explore,
                        title: 'I\'m a Visitor',
                        description:
                            'Discover Haiti with trusted local guides. Book experiences, tours, and transportation.',
                        isSelected: _selectedType == UserType.visitor,
                        onTap: () {
                          setState(() {
                            _selectedType = UserType.visitor;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingL),

                    // Guide Card
                    Expanded(
                      child: _UserTypeCard(
                        icon: Icons.person_pin_circle,
                        title: 'I\'m a Guide',
                        description:
                            'Share your love for Haiti. Earn money by offering tours, transportation, and local expertise.',
                        isSelected: _selectedType == UserType.guide,
                        onTap: () {
                          setState(() {
                            _selectedType = UserType.guide;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.paddingXL),

              // Continue Button
              ElevatedButton(
                onPressed: _selectedType == null || isLoading
                    ? null
                    : () => _handleContinue(),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.white),
                        ),
                      )
                    : const Text('Continue'),
              ),

              const SizedBox(height: AppDimensions.paddingM),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleContinue() async {
    if (_selectedType == null) return;

    final controller = ref.read(authControllerProvider);
    final success = await controller.updateUserProfile(userType: _selectedType);

    if (!mounted) return;

    if (success) {
      // Navigation will be handled automatically by GoRouter
      // based on the updated user type in the redirect logic
    } else {
      // Show error message
      final error = ref.read(authErrorProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to update profile. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

class _UserTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _UserTypeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          border: Border.all(
            color: isSelected ? AppColors.accentTeal : AppColors.border,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.accentTeal.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 20 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.white.withOpacity(0.2)
                      : AppColors.accentTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: isSelected ? AppColors.white : AppColors.accentTeal,
                ),
              ),

              const SizedBox(height: AppDimensions.paddingL),

              // Title
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: isSelected ? AppColors.white : AppColors.primaryNavy,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppDimensions.paddingM),

              // Description
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? AppColors.white.withOpacity(0.9)
                          : AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),

              // Selection Indicator
              if (isSelected) ...[
                const SizedBox(height: AppDimensions.paddingL),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingM,
                    vertical: AppDimensions.paddingS,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.white,
                        size: 16,
                      ),
                      const SizedBox(width: AppDimensions.paddingS),
                      Text(
                        'Selected',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
