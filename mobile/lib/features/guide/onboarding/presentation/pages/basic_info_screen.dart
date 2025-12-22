import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../providers/guide_onboarding_providers.dart';

class BasicInfoScreen extends ConsumerStatefulWidget {
  const BasicInfoScreen({super.key});

  @override
  ConsumerState<BasicInfoScreen> createState() => _BasicInfoScreenState();
}

class _BasicInfoScreenState extends ConsumerState<BasicInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();
  final _otpController = TextEditingController();

  String? _profilePhotoUrl;
  bool _phoneVerified = false;
  bool _otpSent = false;
  bool _isLoading = false;
  String? _sentOtp;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final data = ref.read(guideOnboardingDataProvider);
    if (data.fullName != null) _fullNameController.text = data.fullName!;
    if (data.phone != null) _phoneController.text = data.phone!;
    if (data.email != null) _emailController.text = data.email!;
    if (data.bio != null) _bioController.text = data.bio!;
    _profilePhotoUrl = data.profilePhotoUrl;
    _phoneVerified = data.phoneVerified;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _pickProfilePhoto() async {
    // Mock image picker - in production use image_picker package
    setState(() {
      _isLoading = true;
    });

    try {
      final notifier = ref.read(guideOnboardingDataProvider.notifier);
      final url = await notifier.uploadPhoto('profile', 'mock_path');

      setState(() {
        _profilePhotoUrl = url;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading photo: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _sendOTP() async {
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter phone number')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final notifier = ref.read(guideOnboardingDataProvider.notifier);
      final otp = await notifier.sendOTP(_phoneController.text.trim());

      setState(() {
        _otpSent = true;
        _sentOtp = otp;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OTP sent: $otp (demo)')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending OTP: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter OTP')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final notifier = ref.read(guideOnboardingDataProvider.notifier);
      final verified = await notifier.verifyOTP(
        _phoneController.text.trim(),
        _otpController.text.trim(),
      );

      setState(() {
        _phoneVerified = verified;
        _isLoading = false;
      });

      if (mounted) {
        if (verified) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Phone verified successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid OTP'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error verifying OTP: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_phoneVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please verify your phone number')),
      );
      return;
    }

    if (_profilePhotoUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a profile photo')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final notifier = ref.read(guideOnboardingDataProvider.notifier);
      await notifier.saveBasicInfo(
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        phoneVerified: _phoneVerified,
        email: _emailController.text.trim(),
        profilePhotoUrl: _profilePhotoUrl,
        bio: _bioController.text.trim(),
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
        title: const Text('Basic Information'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          children: [
            // Progress Indicator
            LinearProgressIndicator(
              value: 1 / 7,
              backgroundColor: AppColors.lightGray,
              valueColor: const AlwaysStoppedAnimation(AppColors.accentTeal),
            ),

            const SizedBox(height: AppDimensions.paddingXL),

            // Profile Photo
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _profilePhotoUrl != null
                        ? NetworkImage(_profilePhotoUrl!)
                        : null,
                    child: _profilePhotoUrl == null
                        ? const Icon(Icons.person, size: 60)
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: CircleAvatar(
                      backgroundColor: AppColors.accentTeal,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt,
                            color: AppColors.white),
                        onPressed: _isLoading ? null : _pickProfilePhoto,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.paddingXL),

            // Full Name
            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'Full Name *',
                hintText: 'John Doe',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),

            const SizedBox(height: AppDimensions.paddingL),

            // Phone with OTP
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number *',
                hintText: '509 1234 5678',
                prefixIcon: const Icon(Icons.phone_outlined),
                suffixIcon: _phoneVerified
                    ? const Icon(Icons.verified, color: AppColors.success)
                    : TextButton(
                        onPressed: _isLoading ? null : _sendOTP,
                        child: const Text('Send OTP'),
                      ),
              ),
              keyboardType: TextInputType.phone,
              enabled: !_phoneVerified,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),

            if (_otpSent && !_phoneVerified) ...[
              const SizedBox(height: AppDimensions.paddingL),
              TextFormField(
                controller: _otpController,
                decoration: InputDecoration(
                  labelText: 'Enter OTP',
                  hintText: '123456',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: TextButton(
                    onPressed: _isLoading ? null : _verifyOTP,
                    child: const Text('Verify'),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ],

            const SizedBox(height: AppDimensions.paddingL),

            // Email
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email *',
                hintText: 'john@example.com',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),

            const SizedBox(height: AppDimensions.paddingL),

            // Bio
            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Short Bio *',
                hintText:
                    'Tell visitors about yourself and your guiding experience...',
                prefixIcon: Icon(Icons.description_outlined),
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a short bio';
                }
                if (value.trim().length < 50) {
                  return 'Bio must be at least 50 characters';
                }
                return null;
              },
            ),

            const SizedBox(height: AppDimensions.paddingXL),

            // Continue Button
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
      ),
    );
  }
}
