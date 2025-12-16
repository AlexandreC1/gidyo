import '../../domain/entities/conversation_entity.dart';

class ConversationModel extends ConversationEntity {
  const ConversationModel({
    required super.id,
    required super.guideId,
    required super.guideName,
    super.guideAvatar,
    required super.visitorId,
    required super.visitorName,
    super.visitorAvatar,
    super.lastMessageText,
    super.lastMessageTime,
    super.unreadCount,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as String,
      guideId: json['guide_id'] as String,
      guideName: json['guide_name'] as String? ?? 'Unknown',
      guideAvatar: json['guide_avatar'] as String?,
      visitorId: json['visitor_id'] as String,
      visitorName: json['visitor_name'] as String? ?? 'Unknown',
      visitorAvatar: json['visitor_avatar'] as String?,
      lastMessageText: json['last_message_text'] as String?,
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time'] as String)
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'guide_id': guideId,
      'guide_name': guideName,
      'guide_avatar': guideAvatar,
      'visitor_id': visitorId,
      'visitor_name': visitorName,
      'visitor_avatar': visitorAvatar,
      'last_message_text': lastMessageText,
      'last_message_time': lastMessageTime?.toIso8601String(),
      'unread_count': unreadCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
