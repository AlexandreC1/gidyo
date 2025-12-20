import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_animations.dart';

/// Custom page transition builders for GoRouter
///
/// Provides various animated transitions for different navigation scenarios

/// Slide from right transition (for detail screens)
class SlideRightTransition extends CustomTransitionPage<void> {
  SlideRightTransition({
    required super.child,
    super.key,
  }) : super(
          transitionDuration: AppAnimations.normal,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end);
            final offsetAnimation = animation.drive(
              tween.chain(CurveTween(curve: AppAnimations.easeInOut)),
            );

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
}

/// Slide from bottom transition (for modals)
class SlideUpTransition extends CustomTransitionPage<void> {
  SlideUpTransition({
    required super.child,
    super.key,
  }) : super(
          transitionDuration: AppAnimations.normal,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end);
            final offsetAnimation = animation.drive(
              tween.chain(CurveTween(curve: AppAnimations.easeInOut)),
            );

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
}

/// Fade transition (for overlays)
class FadeTransitionPage extends CustomTransitionPage<void> {
  FadeTransitionPage({
    required super.child,
    super.key,
  }) : super(
          transitionDuration: AppAnimations.fast,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation.drive(
                CurveTween(curve: AppAnimations.easeInOut),
              ),
              child: child,
            );
          },
        );
}

/// Scale transition (for dialogs)
class ScaleTransitionPage extends CustomTransitionPage<void> {
  ScaleTransitionPage({
    required super.child,
    super.key,
  }) : super(
          transitionDuration: AppAnimations.normal,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return ScaleTransition(
              scale: animation.drive(
                Tween(begin: 0.8, end: 1.0).chain(
                  CurveTween(curve: AppAnimations.easeInOut),
                ),
              ),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        );
}

/// Fade + Scale transition (combined)
class FadeScaleTransition extends CustomTransitionPage<void> {
  FadeScaleTransition({
    required super.child,
    super.key,
  }) : super(
          transitionDuration: AppAnimations.normal,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: animation.drive(
                  Tween(begin: 0.95, end: 1.0).chain(
                    CurveTween(curve: AppAnimations.easeInOut),
                  ),
                ),
                child: child,
              ),
            );
          },
        );
}

/// Shared axis transition (Material Design 3)
///
/// Provides a smooth lateral navigation effect where the outgoing
/// page fades and scales down while the incoming page fades and scales up
class SharedAxisTransition extends CustomTransitionPage<void> {
  SharedAxisTransition({
    required super.child,
    super.key,
  }) : super(
          transitionDuration: AppAnimations.medium,
          reverseTransitionDuration: AppAnimations.medium,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Forward animation (page coming in)
            final fadeInAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
              ),
            );

            final scaleInAnimation = Tween<double>(
              begin: 0.8,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
              ),
            );

            // Reverse animation (page going out)
            final fadeOutAnimation = Tween<double>(
              begin: 1.0,
              end: 0.0,
            ).animate(
              CurvedAnimation(
                parent: secondaryAnimation,
                curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
              ),
            );

            final scaleOutAnimation = Tween<double>(
              begin: 1.0,
              end: 1.1,
            ).animate(
              CurvedAnimation(
                parent: secondaryAnimation,
                curve: const Interval(0.0, 1.0, curve: Curves.easeInCubic),
              ),
            );

            return Stack(
              children: [
                // Outgoing page
                FadeTransition(
                  opacity: fadeOutAnimation,
                  child: ScaleTransition(
                    scale: scaleOutAnimation,
                    child: secondaryAnimation.status != AnimationStatus.dismissed
                        ? Container() // Hide when transition complete
                        : Container(),
                  ),
                ),
                // Incoming page
                FadeTransition(
                  opacity: fadeInAnimation,
                  child: ScaleTransition(
                    scale: scaleInAnimation,
                    child: child,
                  ),
                ),
              ],
            );
          },
        );
}

/// Helper function to create a slide right transition page
CustomTransitionPage<void> buildSlideRightTransition({
  required Widget child,
  LocalKey? key,
}) {
  return SlideRightTransition(
    key: key,
    child: child,
  );
}

/// Helper function to create a slide up transition page
CustomTransitionPage<void> buildSlideUpTransition({
  required Widget child,
  LocalKey? key,
}) {
  return SlideUpTransition(
    key: key,
    child: child,
  );
}

/// Helper function to create a fade transition page
CustomTransitionPage<void> buildFadeTransition({
  required Widget child,
  LocalKey? key,
}) {
  return FadeTransitionPage(
    key: key,
    child: child,
  );
}

/// Helper function to create a scale transition page
CustomTransitionPage<void> buildScaleTransition({
  required Widget child,
  LocalKey? key,
}) {
  return ScaleTransitionPage(
    key: key,
    child: child,
  );
}

/// Helper function to create a shared axis transition page
CustomTransitionPage<void> buildSharedAxisTransition({
  required Widget child,
  LocalKey? key,
}) {
  return SharedAxisTransition(
    key: key,
    child: child,
  );
}
