import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/conversation_entity.dart';
import '../entities/message_entity.dart';

abstract class ChatRepository {
  /// Get all conversations for the current user
  Future<Either<Failure, List<ConversationEntity>>> getConversations();

  /// Get or create a conversation between user and guide
  Future<Either<Failure, ConversationEntity>> getOrCreateConversation({
    required String guideId,
    required String visitorId,
  });

  /// Get messages for a conversation
  Stream<List<MessageEntity>> getMessages(String conversationId);

  /// Send a text message
  Future<Either<Failure, MessageEntity>> sendTextMessage({
    required String conversationId,
    required String text,
  });

  /// Send an image message
  Future<Either<Failure, MessageEntity>> sendImageMessage({
    required String conversationId,
    required String imagePath,
  });

  /// Send a voice message
  Future<Either<Failure, MessageEntity>> sendVoiceMessage({
    required String conversationId,
    required String voicePath,
    required double durationSeconds,
  });

  /// Send a location message
  Future<Either<Failure, MessageEntity>> sendLocationMessage({
    required String conversationId,
    required double latitude,
    required double longitude,
    String? address,
  });

  /// Mark messages as read
  Future<Either<Failure, void>> markMessagesAsRead({
    required String conversationId,
    required List<String> messageIds,
  });

  /// Subscribe to new messages in a conversation
  Stream<MessageEntity> subscribeToNewMessages(String conversationId);

  /// Get unread message count for all conversations
  Future<Either<Failure, int>> getUnreadCount();
}
