class AppConfig {
  // Supabase Configuration
  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://your-project.supabase.co');
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key',
  );

  // Stripe Configuration
  static const String stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: 'pk_test_your_publishable_key',
  );

  // API Base URL
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://your-project.supabase.co',
  );

  // App Configuration
  static const String appName = 'GIDYO';
  static const String appVersion = '1.0.0';

  // Platform Fees
  static const double platformFeePercentage = 0.10; // 10%

  // Feature Flags
  static const bool enableStripePayments = true;
  static const bool enableMonCashPayments = false;
  static const bool enableGoogleMaps = true;

  // Validation
  static bool get isConfigured {
    return supabaseUrl != 'https://your-project.supabase.co' &&
        supabaseAnonKey != 'your-anon-key' &&
        stripePublishableKey != 'pk_test_your_publishable_key';
  }
}
