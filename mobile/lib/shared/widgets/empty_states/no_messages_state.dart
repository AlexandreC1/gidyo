import 'package:flutter/material.dart';
import '../../../core/constants/app_animations.dart';
import 'lottie_empty_state.dart';

/// Empty state for when there are no messages
class NoMessagesState extends StatelessWidget {
  /// Callback for the "Start Conversation" action
  final VoidCallback? onStartConversation;

  const NoMessagesState({
    super.key,
    this.onStartConversation,
  });

  @override
  Widget build(BuildContext context) {
    return LottieEmptyState(
      animationPath: AppAnimations.noMessagesAnimation,
      title: 'No Messages',
      description:
          'You don\'t have any conversations yet. Book a guide to start chatting!',
      actionText: onStartConversation != null ? 'Find a Guide' : null,
      onAction: onStartConversation,
      loop: true,
    );
  }
}
