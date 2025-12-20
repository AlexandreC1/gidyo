import 'package:flutter/animation.dart';

/// Animation constants for the GIDYO app
///
/// Provides centralized animation durations, curves, delays, and hero tags
/// to ensure consistent animations throughout the application.
class AppAnimations {
  AppAnimations._();

  // ========== Duration Constants ==========

  /// Fast animation duration (200ms) - For quick feedback
  static const Duration fast = Duration(milliseconds: 200);

  /// Normal animation duration (300ms) - Default for most animations
  static const Duration normal = Duration(milliseconds: 300);

  /// Medium animation duration (400ms) - For moderate transitions
  static const Duration medium = Duration(milliseconds: 400);

  /// Slow animation duration (600ms) - For smooth, deliberate animations
  static const Duration slow = Duration(milliseconds: 600);

  /// Very slow animation duration (800ms) - For emphasis
  static const Duration verySlow = Duration(milliseconds: 800);

  // ========== Curve Constants ==========

  /// Ease in curve - Starts slow, ends fast
  static const Curve easeIn = Curves.easeIn;

  /// Ease out curve - Starts fast, ends slow
  static const Curve easeOut = Curves.easeOut;

  /// Ease in-out cubic curve - Smooth acceleration and deceleration
  static const Curve easeInOut = Curves.easeInOutCubic;

  /// Spring/elastic curve - Bouncy effect
  static const Curve spring = Curves.elasticOut;

  /// Bounce curve - Bouncing ball effect
  static const Curve bounce = Curves.bounceOut;

  // ========== Stagger Delays ==========

  /// Small stagger delay (50ms) - For tightly grouped items
  static const Duration staggerDelay = Duration(milliseconds: 50);

  /// List item delay (100ms) - For list item animations
  static const Duration listItemDelay = Duration(milliseconds: 100);

  /// Card delay (150ms) - For card stagger animations
  static const Duration cardDelay = Duration(milliseconds: 150);

  // ========== Hero Animation Tags ==========

  /// Hero tag for guide avatar images
  ///
  /// Usage: `AppAnimations.guideAvatar(guide.id)`
  static String guideAvatar(String guideId) => 'guide_avatar_$guideId';

  /// Hero tag for guide cards
  ///
  /// Usage: `AppAnimations.guideCard(guide.id)`
  static String guideCard(String guideId) => 'guide_card_$guideId';

  /// Hero tag for service cards
  ///
  /// Usage: `AppAnimations.serviceCard(service.id)`
  static String serviceCard(String serviceId) => 'service_$serviceId';

  /// Hero tag for destination images
  ///
  /// Usage: `AppAnimations.destination(destination.id)`
  static String destination(String destinationId) => 'destination_$destinationId';

  /// Hero tag for the search bar
  static const String searchBar = 'search_bar';

  /// Hero tag for booking confirmation
  static String bookingConfirmation(String bookingId) => 'booking_confirmation_$bookingId';

  // ========== Lottie Asset Paths ==========

  /// Path to loading animation
  static const String loadingAnimation = 'assets/animations/lottie/loading.json';

  /// Path to empty state animation
  static const String emptyStateAnimation = 'assets/animations/lottie/empty_state.json';

  /// Path to success animation
  static const String successAnimation = 'assets/animations/lottie/success.json';

  /// Path to error animation
  static const String errorAnimation = 'assets/animations/lottie/error.json';

  /// Path to search animation (for empty search results)
  static const String searchAnimation = 'assets/animations/lottie/search_animation.json';

  /// Path to no messages animation
  static const String noMessagesAnimation = 'assets/animations/lottie/no_messages.json';

  /// Path to calendar check animation
  static const String calendarCheckAnimation = 'assets/animations/lottie/calendar_check.json';

  // ========== Animation Sizes ==========

  /// Small Lottie animation size
  static const double lottieSizeSmall = 100.0;

  /// Medium Lottie animation size
  static const double lottieSizeMedium = 150.0;

  /// Large Lottie animation size
  static const double lottieSizeLarge = 200.0;

  /// Extra large Lottie animation size
  static const double lottieSizeXLarge = 250.0;

  // ========== Scale Factors ==========

  /// Button press scale (slightly smaller)
  static const double buttonPressScale = 0.95;

  /// Card hover scale (slightly larger)
  static const double cardHoverScale = 1.02;

  /// Icon pulse scale
  static const double iconPulseScale = 1.2;
}
