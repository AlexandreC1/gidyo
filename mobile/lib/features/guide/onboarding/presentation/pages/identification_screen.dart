import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/guide_onboarding_entity.dart';
import '../providers/guide_onboarding_providers.dart';

class IdentificationScreen extends ConsumerStatefulWidget {
  const IdentificationScreen({super.key});

  @override
  ConsumerState<IdentificationScreen> createState() =>
      _IdentificationScreenState();
}

class _IdentificationScreenState extends ConsumerState<IdentificationScreen> {
  IDType? _selectedIdType;
  String? _idFrontPhotoUrl;
  String? _idBackPhotoUrl;
  String? _selfiePhotoUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final data = ref.read(guideOnboardingDataProvider);
    _selectedIdType = data.idType;
    _idFrontPhotoUrl = data.idFrontPhotoUrl;
    _idBackPhotoUrl = data.idBackPhotoUrl;
    _selfiePhotoUrl = data.selfiePhotoUrl;
  }

  Future<void> _uploadPhoto(String type) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notifier = ref.read(guideOnboardingDataProvider.notifier);
      final url = await notifier.uploadPhoto('id_$type', 'mock_path');

      setState(() {
        switch (type) {
          case 'front':
            _idFrontPhotoUrl = url;
            break;
          case 'back':
            _idBackPhotoUrl = url;
            break;
          case 'selfie':
            _selfiePhotoUrl = url;
            break;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _continue() async {
    if (_selectedIdType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select ID type')),
      );
      return;
    }

    if (_idFrontPhotoUrl == null ||
        _idBackPhotoUrl == null ||
        _selfiePhotoUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload all required photos')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final notifier = ref.read(guideOnboardingDataProvider.notifier);
      await notifier.saveIdentification(
        idType: _selectedIdType!,
        idFrontPhotoUrl: _idFrontPhotoUrl!,
        idBackPhotoUrl: _idBackPhotoUrl!,
        selfiePhotoUrl: _selfiePhotoUrl!,
      );

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Identification'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        children: [
          LinearProgressIndicator(
            value: 2 / 7,
            backgroundColor: AppColors.lightGray,
            valueColor: const AlwaysStoppedAnimation(AppColors.accentTeal),
          ),

          const SizedBox(height: AppDimensions.paddingXL),

          Text(
            'ID Type',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppDimensions.paddingM),

          // ID Type Selection
          _IDTypeCard(
            title: 'NIF (National ID)',
            icon: Icons.badge,
            isSelected: _selectedIdType == IDType.nif,
            onTap: () => setState(() => _selectedIdType = IDType.nif),
          ),
          _IDTypeCard(
            title: 'Passport',
            icon: Icons.card_travel,
            isSelected: _selectedIdType == IDType.passport,
            onTap: () => setState(() => _selectedIdType = IDType.passport),
          ),
          _IDTypeCard(
            title: "Driver's License",
            icon: Icons.drive_eta,
            isSelected: _selectedIdType == IDType.driversLicense,
            onTap: () =>
                setState(() => _selectedIdType = IDType.driversLicense),
          ),

          const SizedBox(height: AppDimensions.paddingXL),

          Text(
            'Upload Documents',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppDimensions.paddingM),

          // ID Front Photo
          _PhotoUploadCard(
            title: 'ID Front Side',
            description: 'Clear photo of the front of your ID',
            photoUrl: _idFrontPhotoUrl,
            onUpload: () => _uploadPhoto('front'),
            isLoading: _isLoading,
          ),

          const SizedBox(height: AppDimensions.paddingM),

          // ID Back Photo
          _PhotoUploadCard(
            title: 'ID Back Side',
            description: 'Clear photo of the back of your ID',
            photoUrl: _idBackPhotoUrl,
            onUpload: () => _uploadPhoto('back'),
            isLoading: _isLoading,
          ),

          const SizedBox(height: AppDimensions.paddingM),

          // Selfie Photo
          _PhotoUploadCard(
            title: 'Selfie for Verification',
            description: 'Take a clear selfie holding your ID',
            photoUrl: _selfiePhotoUrl,
            onUpload: () => _uploadPhoto('selfie'),
            isLoading: _isLoading,
            icon: Icons.face,
          ),

          const SizedBox(height: AppDimensions.paddingL),

          // Status Notice
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            decoration: BoxDecoration(
              color: AppColors.accentTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              border:
                  Border.all(color: AppColors.accentTeal.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.accentTeal),
                const SizedBox(width: AppDimensions.paddingM),
                Expanded(
                  child: Text(
                    'Your documents will be reviewed within 24-48 hours',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.paddingXL),

          ElevatedButton(
            onPressed: _isLoading ? null : _continue,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(AppColors.white),
                    ),
                  )
                : const Text('Continue'),
          ),
        ],
      ),
    );
  }
}

class _IDTypeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _IDTypeCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      color: isSelected ? AppColors.accentTeal.withOpacity(0.1) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        side: BorderSide(
          color: isSelected ? AppColors.accentTeal : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color:
                    isSelected ? AppColors.accentTeal : AppColors.textSecondary,
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Icon(icon, color: AppColors.accentTeal),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoUploadCard extends StatelessWidget {
  final String title;
  final String description;
  final String? photoUrl;
  final VoidCallback onUpload;
  final bool isLoading;
  final IconData icon;

  const _PhotoUploadCard({
    required this.title,
    required this.description,
    this.photoUrl,
    required this.onUpload,
    this.isLoading = false,
    this.icon = Icons.credit_card,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.accentTeal),
              const SizedBox(width: AppDimensions.paddingS),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingM),
          if (photoUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              child: Image.network(
                photoUrl!,
                width: double.infinity,
                height: 150,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              child: Icon(
                icon,
                size: 64,
                color: AppColors.textSecondary.withOpacity(0.3),
              ),
            ),
          const SizedBox(height: AppDimensions.paddingM),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isLoading ? null : onUpload,
              icon: Icon(photoUrl == null ? Icons.upload : Icons.change_circle),
              label: Text(photoUrl == null ? 'Upload Photo' : 'Change Photo'),
            ),
          ),
        ],
      ),
    );
  }
}
