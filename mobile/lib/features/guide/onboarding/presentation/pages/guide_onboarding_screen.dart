import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';

class GuideOnboardingScreen extends ConsumerStatefulWidget {
  const GuideOnboardingScreen({super.key});

  @override
  ConsumerState<GuideOnboardingScreen> createState() =>
      _GuideOnboardingScreenState();
}

class _GuideOnboardingScreenState extends ConsumerState<GuideOnboardingScreen> {
  int _currentStep = 0;

  final List<_OnboardingStep> _steps = [
    _OnboardingStep(
      title: 'Complete Your Profile',
      description: 'Add your bio, services, and pricing',
      icon: Icons.person_add,
    ),
    _OnboardingStep(
      title: 'Upload Documents',
      description: 'Government ID and vehicle registration',
      icon: Icons.upload_file,
    ),
    _OnboardingStep(
      title: 'Record Introduction',
      description: 'Create a short video introducing yourself',
      icon: Icons.videocam,
    ),
    _OnboardingStep(
      title: 'Verification',
      description: 'We\'ll review your application within 3-5 days',
      icon: Icons.verified_user,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Become a Guide'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress Indicator
          LinearProgressIndicator(
            value: (_currentStep + 1) / _steps.length,
            backgroundColor: AppColors.lightGray,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentTeal),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                children: [
                  // Step Indicator
                  Text(
                    'Step ${_currentStep + 1} of ${_steps.length}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: AppDimensions.paddingXL),

                  // Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: AppColors.accentGradient,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusXXL),
                    ),
                    child: Icon(
                      _steps[_currentStep].icon,
                      size: 60,
                      color: AppColors.white,
                    ),
                  ),

                  const SizedBox(height: AppDimensions.paddingXL),

                  // Title
                  Text(
                    _steps[_currentStep].title,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppDimensions.paddingM),

                  // Description
                  Text(
                    _steps[_currentStep].description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(),

                  // Action based on step
                  _buildStepContent(),

                  const SizedBox(height: AppDimensions.paddingXL),
                ],
              ),
            ),
          ),

          // Navigation Buttons
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _currentStep--;
                        });
                      },
                      child: const Text('Back'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: AppDimensions.paddingM),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentStep < _steps.length - 1) {
                        setState(() {
                          _currentStep++;
                        });
                      } else {
                        // Submit for verification
                        _submitForVerification();
                      }
                    },
                    child: Text(
                      _currentStep < _steps.length - 1
                          ? 'Continue'
                          : 'Submit for Verification',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return Column(
          children: [
            _InfoCard(
              icon: Icons.info_outline,
              text: 'Tell visitors about yourself, your experience, and what makes you a great guide.',
            ),
          ],
        );
      case 1:
        return Column(
          children: [
            _InfoCard(
              icon: Icons.security,
              text: 'All documents are encrypted and securely stored. We verify your identity to keep everyone safe.',
            ),
          ],
        );
      case 2:
        return Column(
          children: [
            _InfoCard(
              icon: Icons.tips_and_updates,
              text: 'A 30-60 second video helps visitors get to know you better before booking.',
            ),
          ],
        );
      case 3:
        return Column(
          children: [
            _InfoCard(
              icon: Icons.access_time,
              text: 'Our team will review your application within 3-5 business days. You\'ll be notified via email.',
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _submitForVerification() {
    // TODO: Submit guide application
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Application submitted! We\'ll review it within 3-5 days.'),
        backgroundColor: AppColors.success,
      ),
    );

    // Navigate to pending verification screen or dashboard
  }
}

class _OnboardingStep {
  final String title;
  final String description;
  final IconData icon;

  _OnboardingStep({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoCard({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.accentTeal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: AppColors.accentTeal.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.accentTeal,
            size: 24,
          ),
          const SizedBox(width: AppDimensions.paddingM),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
