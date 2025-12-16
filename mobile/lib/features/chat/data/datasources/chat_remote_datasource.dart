import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../../domain/entities/message_entity.dart';

class ChatRemoteDatasource {
  final SupabaseClient _supabase;
  final Map<String, StreamController<MessageEntity>> _messageStreams = {};

  ChatRemoteDatasource(this._supabase);

  Future<List<ConversationModel>> getConversations() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const UnauthorizedException('User not logged in');
      }

      // Get conversations with joins to get participant info
      final response = await _supabase
          .from('conversations')
          .select('''
            *,
            guide:guide_profiles!conversations_guide_id_fkey(
              user_id,
              users!inner(first_name, last_name, profile_image_url)
            ),
            visitor:visitor_profiles!conversations_visitor_id_fkey(
              user_id,
              users!inner(first_name, last_name, profile_image_url)
            )
          ''')
          .or('guide_id.eq.$userId,visitor_id.eq.$userId')
          .order('updated_at', ascending: false);

      return (response as List).map((json) {
        // Extract guide info
        final guideData = json['guide'] as Map<String, dynamic>?;
        final guideUser = guideData?['users'] as Map<String, dynamic>?;
        final guideName = guideUser != null
            ? '${guideUser['first_name']} ${guideUser['last_name']}'
            : 'Unknown';
        final guideAvatar = guideUser?['profile_image_url'] as String?;

        // Extract visitor info
        final visitorData = json['visitor'] as Map<String, dynamic>?;
        final visitorUser = visitorData?['users'] as Map<String, dynamic>?;
        final visitorName = visitorUser != null
            ? '${visitorUser['first_name']} ${visitorUser['last_name']}'
            : 'Unknown';
        final visitorAvatar = visitorUser?['profile_image_url'] as String?;

        return ConversationModel.fromJson({
          ...json,
          'guide_name': guideName,
          'guide_avatar': guideAvatar,
          'visitor_name': visitorName,
          'visitor_avatar': visitorAvatar,
        });
      }).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<ConversationModel> getOrCreateConversation({
    required String guideId,
    required String visitorId,
  }) async {
    try {
      // Check if conversation exists
      final existing = await _supabase
          .from('conversations')
          .select()
          .eq('guide_id', guideId)
          .eq('visitor_id', visitorId)
          .maybeSingle();

      if (existing != null) {
        // Get with participant info
        final withInfo = await _supabase
            .from('conversations')
            .select('''
              *,
              guide:guide_profiles!conversations_guide_id_fkey(
                user_id,
                users!inner(first_name, last_name, profile_image_url)
              ),
              visitor:visitor_profiles!conversations_visitor_id_fkey(
                user_id,
                users!inner(first_name, last_name, profile_image_url)
              )
            ''')
            .eq('id', existing['id'])
            .single();

        final guideData = withInfo['guide'] as Map<String, dynamic>;
        final guideUser = guideData['users'] as Map<String, dynamic>;
        final visitorData = withInfo['visitor'] as Map<String, dynamic>;
        final visitorUser = visitorData['users'] as Map<String, dynamic>;

        return ConversationModel.fromJson({
          ...withInfo,
          'guide_name': '${guideUser['first_name']} ${guideUser['last_name']}',
          'guide_avatar': guideUser['profile_image_url'],
          'visitor_name':
              '${visitorUser['first_name']} ${visitorUser['last_name']}',
          'visitor_avatar': visitorUser['profile_image_url'],
        });
      }

      // Create new conversation
      final response = await _supabase.from('conversations').insert({
        'guide_id': guideId,
        'visitor_id': visitorId,
      }).select('''
        *,
        guide:guide_profiles!conversations_guide_id_fkey(
          user_id,
          users!inner(first_name, last_name, profile_image_url)
        ),
        visitor:visitor_profiles!conversations_visitor_id_fkey(
          user_id,
          users!inner(first_name, last_name, profile_image_url)
        )
      ''').single();

      final guideData = response['guide'] as Map<String, dynamic>;
      final guideUser = guideData['users'] as Map<String, dynamic>;
      final visitorData = response['visitor'] as Map<String, dynamic>;
      final visitorUser = visitorData['users'] as Map<String, dynamic>;

      return ConversationModel.fromJson({
        ...response,
        'guide_name': '${guideUser['first_name']} ${guideUser['last_name']}',
        'guide_avatar': guideUser['profile_image_url'],
        'visitor_name':
            '${visitorUser['first_name']} ${visitorUser['last_name']}',
        'visitor_avatar': visitorUser['profile_image_url'],
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Stream<List<MessageModel>> getMessages(String conversationId) {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const UnauthorizedException('User not logged in');
      }

      // Get initial messages
      return _supabase
          .from('messages')
          .stream(primaryKey: ['id'])
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true)
          .map((data) {
            return data.map((json) => MessageModel.fromJson(json)).toList();
          });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<MessageModel> sendTextMessage({
    required String conversationId,
    required String text,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const UnauthorizedException('User not logged in');
      }

      // Get sender info
      final user = await _supabase.from('users').select().eq('id', userId).single();

      final response = await _supabase.from('messages').insert({
        'conversation_id': conversationId,
        'sender_id': userId,
        'type': 'text',
        'text_content': text,
        'status': 'sent',
      }).select().single();

      // Update conversation last message
      await _updateConversationLastMessage(conversationId, text);

      return MessageModel.fromJson({
        ...response,
        'sender_name': '${user['first_name']} ${user['last_name']}',
        'sender_avatar': user['profile_image_url'],
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<MessageModel> sendImageMessage({
    required String conversationId,
    required String imagePath,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const UnauthorizedException('User not logged in');
      }

      // TODO: Upload image to Supabase Storage
      final imageUrl = 'https://placeholder.com/image.jpg';

      final user = await _supabase.from('users').select().eq('id', userId).single();

      final response = await _supabase.from('messages').insert({
        'conversation_id': conversationId,
        'sender_id': userId,
        'type': 'image',
        'image_url': imageUrl,
        'status': 'sent',
      }).select().single();

      await _updateConversationLastMessage(conversationId, 'Sent an image');

      return MessageModel.fromJson({
        ...response,
        'sender_name': '${user['first_name']} ${user['last_name']}',
        'sender_avatar': user['profile_image_url'],
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<MessageModel> sendVoiceMessage({
    required String conversationId,
    required String voicePath,
    required double durationSeconds,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const UnauthorizedException('User not logged in');
      }

      // TODO: Upload voice to Supabase Storage
      final voiceUrl = 'https://placeholder.com/voice.mp3';

      final user = await _supabase.from('users').select().eq('id', userId).single();

      final response = await _supabase.from('messages').insert({
        'conversation_id': conversationId,
        'sender_id': userId,
        'type': 'voice',
        'voice_url': voiceUrl,
        'voice_duration_seconds': durationSeconds,
        'status': 'sent',
      }).select().single();

      await _updateConversationLastMessage(conversationId, 'Sent a voice message');

      return MessageModel.fromJson({
        ...response,
        'sender_name': '${user['first_name']} ${user['last_name']}',
        'sender_avatar': user['profile_image_url'],
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<MessageModel> sendLocationMessage({
    required String conversationId,
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const UnauthorizedException('User not logged in');
      }

      final user = await _supabase.from('users').select().eq('id', userId).single();

      final response = await _supabase.from('messages').insert({
        'conversation_id': conversationId,
        'sender_id': userId,
        'type': 'location',
        'location_latitude': latitude,
        'location_longitude': longitude,
        'location_address': address,
        'status': 'sent',
      }).select().single();

      await _updateConversationLastMessage(conversationId, 'Sent a location');

      return MessageModel.fromJson({
        ...response,
        'sender_name': '${user['first_name']} ${user['last_name']}',
        'sender_avatar': user['profile_image_url'],
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> markMessagesAsRead({
    required String conversationId,
    required List<String> messageIds,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const UnauthorizedException('User not logged in');
      }

      // Mark messages as read
      await _supabase
          .from('messages')
          .update({
            'status': 'read',
            'read_at': DateTime.now().toIso8601String(),
          })
          .in_('id', messageIds)
          .neq('sender_id', userId);

      // Update unread count
      await _updateUnreadCount(conversationId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> _updateConversationLastMessage(
    String conversationId,
    String text,
  ) async {
    await _supabase.from('conversations').update({
      'last_message_text': text,
      'last_message_time': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', conversationId);
  }

  Future<void> _updateUnreadCount(String conversationId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final unreadMessages = await _supabase
        .from('messages')
        .select('id')
        .eq('conversation_id', conversationId)
        .neq('sender_id', userId)
        .neq('status', 'read');

    await _supabase.from('conversations').update({
      'unread_count': (unreadMessages as List).length,
    }).eq('id', conversationId);
  }

  Future<int> getUnreadCount() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const UnauthorizedException('User not logged in');
      }

      final conversations = await _supabase
          .from('conversations')
          .select('unread_count')
          .or('guide_id.eq.$userId,visitor_id.eq.$userId');

      int total = 0;
      for (var conv in conversations) {
        total += (conv['unread_count'] as int? ?? 0);
      }

      return total;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  void dispose() {
    for (var controller in _messageStreams.values) {
      controller.close();
    }
    _messageStreams.clear();
  }
}
