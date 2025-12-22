import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../domain/entities/guide_onboarding_entity.dart';
import '../providers/guide_onboarding_providers.dart';
import 'basic_info_screen.dart';
import 'identification_screen.dart';
import 'services_setup_screen.dart';

class GuideOnboardingScreen extends ConsumerWidget {
  const GuideOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingData = ref.watch(guideOnboardingDataProvider);

    // Show appropriate screen based on current step and status
    if (onboardingData.overallStatus == VerificationStatus.pending) {
      return _UnderReviewScreen();
    }

    if (onboardingData.overallStatus == VerificationStatus.approved) {
      // Redirect to dashboard
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/guide/dashboard');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Show current step screen
    switch (onboardingData.currentStep) {
      case OnboardingStep.basicInfo:
        return const BasicInfoScreen();
      case OnboardingStep.identification:
        return const IdentificationScreen();
      case OnboardingStep.servicesSetup:
        return const ServicesSetupScreen();
      case OnboardingStep.vehicleInfo:
        return _SimpleStepScreen(
          title: 'Vehicle Information',
          stepNumber: 4,
          description:
              'Add details about your vehicle for transportation services',
          onContinue: () {
            ref
                .read(guideOnboardingDataProvider.notifier)
                .goToStep(OnboardingStep.availability);
          },
        );
      case OnboardingStep.availability:
        return _SimpleStepScreen(
          title: 'Set Your Availability',
          stepNumber: 5,
          description: 'Let visitors know when you\'re available to guide',
          onContinue: () {
            ref
                .read(guideOnboardingDataProvider.notifier)
                .goToStep(OnboardingStep.paymentSetup);
          },
        );
      case OnboardingStep.paymentSetup:
        return _SimpleStepScreen(
          title: 'Payment Setup',
          stepNumber: 6,
          description: 'Set up how you\'ll receive payments',
          onContinue: () {
            ref
                .read(guideOnboardingDataProvider.notifier)
                .goToStep(OnboardingStep.review);
          },
        );
      case OnboardingStep.review:
        return _ReviewScreen();
    }
  }
}

class _SimpleStepScreen extends ConsumerWidget {
  final String title;
  final int stepNumber;
  final String description;
  final VoidCallback onContinue;

  const _SimpleStepScreen({
    required this.title,
    required this.stepNumber,
    required this.description,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        subtitle: Text('Step $stepNumber of 7'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.construction, size: 64, color: AppColors.textSecondary),
              const SizedBox(height: 24),
              Text(
                description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '(Screen under construction)',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onContinue,
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(guideOnboardingDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review & Submit'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          LinearProgressIndicator(
            value: 1.0,
            backgroundColor: AppColors.lightGray,
            valueColor: const AlwaysStoppedAnimation(AppColors.accentTeal),
          ),
          const SizedBox(height: 32),
          _ReviewSection(
            title: 'Basic Information',
            icon: Icons.person,
            isComplete: data.isBasicInfoComplete,
            children: [
              if (data.fullName != null) _InfoRow('Name', data.fullName!),
              if (data.phone != null)
                _InfoRow('Phone', data.phone!,
                    verified: data.phoneVerified),
              if (data.email != null) _InfoRow('Email', data.email!),
            ],
          ),
          _ReviewSection(
            title: 'Identification',
            icon: Icons.badge,
            isComplete: data.isIdentificationComplete,
            children: [
              if (data.idType != null)
                _InfoRow('ID Type', data.idType.toString()),
              _InfoRow('Status', data.idVerificationStatus.toString()),
            ],
          ),
          _ReviewSection(
            title: 'Services',
            icon: Icons.work,
            isComplete: data.isServicesSetupComplete,
            children: [
              _InfoRow('Services Offered', '${data.services.length} services'),
            ],
          ),
          const SizedBox(height: 32),
          if (!data.canSubmit)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: AppColors.error),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Please complete all required sections before submitting',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accentTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.accentTeal.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.accentTeal),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Ready to submit!',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your application will be reviewed within 24-48 hours. You\'ll receive a notification when approved.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: data.canSubmit
                ? () async {
                    try {
                      await ref
                          .read(guideOnboardingDataProvider.notifier)
                          .submitForReview();
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error submitting: $e'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    }
                  }
                : null,
            child: const Text('Submit for Verification'),
          ),
        ],
      ),
    );
  }
}

class _ReviewSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isComplete;
  final List<Widget> children;

  const _ReviewSection({
    required this.title,
    required this.icon,
    required this.isComplete,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.accentTeal),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Icon(
                  isComplete ? Icons.check_circle : Icons.error_outline,
                  color: isComplete ? AppColors.success : AppColors.error,
                ),
              ],
            ),
            if (children.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...children,
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool verified;

  const _InfoRow(this.label, this.value, {this.verified = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                if (verified)
                  const Icon(Icons.verified, size: 16, color: AppColors.success),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UnderReviewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Status'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.accentTeal.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.hourglass_empty,
                  size: 60,
                  color: AppColors.accentTeal,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Under Review',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your application is being reviewed by our team',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _TimelineStep(
                      title: 'Application Submitted',
                      isComplete: true,
                    ),
                    _TimelineStep(
                      title: 'Document Verification',
                      isComplete: false,
                      isCurrent: true,
                    ),
                    _TimelineStep(
                      title: 'Final Review',
                      isComplete: false,
                    ),
                    _TimelineStep(
                      title: 'Approval',
                      isComplete: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Expected wait time: 24-48 hours',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'You\'ll receive a push notification when approved',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final String title;
  final bool isComplete;
  final bool isCurrent;

  const _TimelineStep({
    required this.title,
    this.isComplete = false,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            isComplete
                ? Icons.check_circle
                : isCurrent
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
            color: isComplete || isCurrent
                ? AppColors.accentTeal
                : AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isComplete || isCurrent ? null : AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
