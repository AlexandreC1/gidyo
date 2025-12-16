import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_client.dart';
import '../../data/datasources/chat_remote_datasource.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';

// Datasource Provider
final chatDatasourceProvider = Provider<ChatRemoteDatasource>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return ChatRemoteDatasource(supabase);
});

// Conversations Provider
final conversationsProvider =
    FutureProvider<List<ConversationEntity>>((ref) async {
  final datasource = ref.watch(chatDatasourceProvider);
  return await datasource.getConversations();
});

// Get or Create Conversation Provider
final getOrCreateConversationProvider = FutureProvider.family<
    ConversationEntity,
    ({String guideId, String visitorId})>((ref, params) async {
  final datasource = ref.watch(chatDatasourceProvider);
  return await datasource.getOrCreateConversation(
    guideId: params.guideId,
    visitorId: params.visitorId,
  );
});

// Messages Stream Provider
final messagesProvider =
    StreamProvider.family<List<MessageEntity>, String>((ref, conversationId) {
  final datasource = ref.watch(chatDatasourceProvider);
  return datasource.getMessages(conversationId);
});

// Chat Controller Provider
final chatControllerProvider =
    StateNotifierProvider<ChatController, ChatState>((ref) {
  return ChatController(ref);
});

class ChatController extends StateNotifier<ChatState> {
  final Ref _ref;

  ChatController(this._ref) : super(const ChatState());

  Future<void> sendTextMessage({
    required String conversationId,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;

    state = state.copyWith(isSending: true, error: null);

    try {
      final datasource = _ref.read(chatDatasourceProvider);
      await datasource.sendTextMessage(
        conversationId: conversationId,
        text: text.trim(),
      );

      // Refresh conversations to update last message
      _ref.invalidate(conversationsProvider);

      state = state.copyWith(isSending: false);
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        error: e.toString(),
      );
    }
  }

  Future<void> sendImageMessage({
    required String conversationId,
    required String imagePath,
  }) async {
    state = state.copyWith(isSending: true, error: null);

    try {
      final datasource = _ref.read(chatDatasourceProvider);
      await datasource.sendImageMessage(
        conversationId: conversationId,
        imagePath: imagePath,
      );

      _ref.invalidate(conversationsProvider);
      state = state.copyWith(isSending: false);
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        error: e.toString(),
      );
    }
  }

  Future<void> sendVoiceMessage({
    required String conversationId,
    required String voicePath,
    required double durationSeconds,
  }) async {
    state = state.copyWith(isSending: true, error: null);

    try {
      final datasource = _ref.read(chatDatasourceProvider);
      await datasource.sendVoiceMessage(
        conversationId: conversationId,
        voicePath: voicePath,
        durationSeconds: durationSeconds,
      );

      _ref.invalidate(conversationsProvider);
      state = state.copyWith(isSending: false);
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        error: e.toString(),
      );
    }
  }

  Future<void> sendLocationMessage({
    required String conversationId,
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    state = state.copyWith(isSending: true, error: null);

    try {
      final datasource = _ref.read(chatDatasourceProvider);
      await datasource.sendLocationMessage(
        conversationId: conversationId,
        latitude: latitude,
        longitude: longitude,
        address: address,
      );

      _ref.invalidate(conversationsProvider);
      state = state.copyWith(isSending: false);
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        error: e.toString(),
      );
    }
  }

  Future<void> markMessagesAsRead({
    required String conversationId,
    required List<String> messageIds,
  }) async {
    if (messageIds.isEmpty) return;

    try {
      final datasource = _ref.read(chatDatasourceProvider);
      await datasource.markMessagesAsRead(
        conversationId: conversationId,
        messageIds: messageIds,
      );

      _ref.invalidate(conversationsProvider);
      _ref.invalidate(unreadCountProvider);
    } catch (e) {
      // Silently fail for read receipts
    }
  }
}

class ChatState {
  final bool isSending;
  final String? error;

  const ChatState({
    this.isSending = false,
    this.error,
  });

  ChatState copyWith({
    bool? isSending,
    String? error,
  }) {
    return ChatState(
      isSending: isSending ?? this.isSending,
      error: error,
    );
  }
}

// Unread Count Provider
final unreadCountProvider = FutureProvider<int>((ref) async {
  final datasource = ref.watch(chatDatasourceProvider);
  return await datasource.getUnreadCount();
});
