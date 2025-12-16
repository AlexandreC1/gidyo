import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';

class GuideProfileScreen extends ConsumerWidget {
  const GuideProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock guide data
    final guideName = 'Pierre Alexandre';
    final guideEmail = 'pierre.alex@example.com';
    final guidePhone = '+509 1234 5678';
    final memberSince = 'January 2024';
    final rating = 4.8;
    final totalReviews = 127;
    final completedBookings = 156;
    final isVerified = true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.white,
                        child: Text(
                          guideName[0],
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accentTeal,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: AppColors.accentTeal,
                          ),
                        ),
                      ),
                      if (isVerified)
                        Positioned(
                          left: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.verified,
                              size: 20,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        guideName,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (isVerified) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.verified,
                          color: AppColors.success,
                          size: 24,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppDimensions.paddingS),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: AppColors.accentGolden, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '$rating ($totalReviews reviews)',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.white.withOpacity(0.9),
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.paddingS),
                  Text(
                    'Guide since $memberSince',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.white.withOpacity(0.9),
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.paddingL),

            // Stats Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.event_available,
                      value: completedBookings.toString(),
                      label: 'Completed',
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingM),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.star,
                      value: rating.toString(),
                      label: 'Rating',
                      color: AppColors.accentGolden,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingM),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.attach_money,
                      value: '\$2.4k',
                      label: 'Earned',
                      color: AppColors.accentTeal,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.paddingL),

            // Quick Actions
            _SectionTitle(title: 'Quick Actions'),
            _ActionTile(
              icon: Icons.edit_note,
              title: 'Edit Profile',
              subtitle: 'Update bio, services, and pricing',
              color: AppColors.accentTeal,
              onTap: () {},
            ),
            _ActionTile(
              icon: Icons.photo_library,
              title: 'Manage Photos',
              subtitle: 'Add or update profile photos',
              color: AppColors.info,
              onTap: () {},
            ),
            _ActionTile(
              icon: Icons.description,
              title: 'Documents',
              subtitle: 'View verification documents',
              color: AppColors.accentGolden,
              onTap: () {},
            ),

            const SizedBox(height: AppDimensions.paddingL),

            // Services
            _SectionTitle(title: 'My Services'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
              child: Column(
                children: [
                  _ServiceCard(
                    name: 'Airport Pickup',
                    price: 50,
                    isActive: true,
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  _ServiceCard(
                    name: 'City Tour',
                    price: 75,
                    isActive: true,
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  _ServiceCard(
                    name: 'Daily Driver',
                    price: 100,
                    isActive: false,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.paddingL),

            // Contact Information
            _SectionTitle(title: 'Contact Information'),
            _InfoTile(
              icon: Icons.email_outlined,
              label: 'Email',
              value: guideEmail,
            ),
            _InfoTile(
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: guidePhone,
            ),
            _InfoTile(
              icon: Icons.location_on_outlined,
              label: 'Location',
              value: 'Port-au-Prince, Haiti',
            ),

            const SizedBox(height: AppDimensions.paddingL),

            // Settings
            _SectionTitle(title: 'Settings'),
            _SettingTile(
              icon: Icons.language,
              title: 'Language',
              trailing: 'English',
              onTap: () {},
            ),
            _SettingTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              trailing: null,
              onTap: () {},
            ),
            _SettingTile(
              icon: Icons.payment,
              title: 'Payment Methods',
              trailing: null,
              onTap: () {},
            ),
            _SettingTile(
              icon: Icons.security,
              title: 'Privacy & Security',
              trailing: null,
              onTap: () {},
            ),

            const SizedBox(height: AppDimensions.paddingL),

            // Support
            _SectionTitle(title: 'Support'),
            _SettingTile(
              icon: Icons.help_outline,
              title: 'Help Center',
              trailing: null,
              onTap: () {},
            ),
            _SettingTile(
              icon: Icons.info_outline,
              title: 'Guide Guidelines',
              trailing: null,
              onTap: () {},
            ),
            _SettingTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              trailing: null,
              onTap: () {},
            ),

            const SizedBox(height: AppDimensions.paddingL),

            // Logout Button
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Logout
                  },
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: const Text(
                    'Logout',
                    style: TextStyle(color: AppColors.error),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.paddingM,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.paddingXL),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.gray.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppDimensions.paddingS),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String name;
  final int price;
  final bool isActive;

  const _ServiceCard({
    required this.name,
    required this.price,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: isActive ? AppColors.accentTeal : AppColors.gray,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$$price/day',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.accentTeal,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          Switch(
            value: isActive,
            onChanged: (value) {
              // Toggle service
            },
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.accentTeal),
      title: Text(label),
      subtitle: Text(value),
      trailing: const Icon(Icons.edit_outlined, size: 20),
      onTap: () {
        // Edit information
      },
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;
  final VoidCallback onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.accentTeal),
      title: Text(title),
      trailing: trailing != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  trailing!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, size: 20),
              ],
            )
          : const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
