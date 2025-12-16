import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required super.senderName,
    super.senderAvatar,
    required super.type,
    super.textContent,
    super.imageUrl,
    super.voiceUrl,
    super.voiceDurationSeconds,
    super.location,
    super.status,
    required super.createdAt,
    super.readAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    MessageType type = MessageType.text;
    switch (json['type'] as String) {
      case 'text':
        type = MessageType.text;
        break;
      case 'image':
        type = MessageType.image;
        break;
      case 'voice':
        type = MessageType.voice;
        break;
      case 'location':
        type = MessageType.location;
        break;
    }

    MessageStatus status = MessageStatus.sent;
    switch (json['status'] as String? ?? 'sent') {
      case 'sending':
        status = MessageStatus.sending;
        break;
      case 'sent':
        status = MessageStatus.sent;
        break;
      case 'delivered':
        status = MessageStatus.delivered;
        break;
      case 'read':
        status = MessageStatus.read;
        break;
      case 'failed':
        status = MessageStatus.failed;
        break;
    }

    LocationData? location;
    if (json['location_latitude'] != null && json['location_longitude'] != null) {
      location = LocationData(
        latitude: (json['location_latitude'] as num).toDouble(),
        longitude: (json['location_longitude'] as num).toDouble(),
        address: json['location_address'] as String?,
      );
    }

    return MessageModel(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      senderId: json['sender_id'] as String,
      senderName: json['sender_name'] as String? ?? 'Unknown',
      senderAvatar: json['sender_avatar'] as String?,
      type: type,
      textContent: json['text_content'] as String?,
      imageUrl: json['image_url'] as String?,
      voiceUrl: json['voice_url'] as String?,
      voiceDurationSeconds: json['voice_duration_seconds'] != null
          ? (json['voice_duration_seconds'] as num).toDouble()
          : null,
      location: location,
      status: status,
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    String typeString = 'text';
    switch (type) {
      case MessageType.text:
        typeString = 'text';
        break;
      case MessageType.image:
        typeString = 'image';
        break;
      case MessageType.voice:
        typeString = 'voice';
        break;
      case MessageType.location:
        typeString = 'location';
        break;
    }

    String statusString = 'sent';
    switch (status) {
      case MessageStatus.sending:
        statusString = 'sending';
        break;
      case MessageStatus.sent:
        statusString = 'sent';
        break;
      case MessageStatus.delivered:
        statusString = 'delivered';
        break;
      case MessageStatus.read:
        statusString = 'read';
        break;
      case MessageStatus.failed:
        statusString = 'failed';
        break;
    }

    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_avatar': senderAvatar,
      'type': typeString,
      'text_content': textContent,
      'image_url': imageUrl,
      'voice_url': voiceUrl,
      'voice_duration_seconds': voiceDurationSeconds,
      'location_latitude': location?.latitude,
      'location_longitude': location?.longitude,
      'location_address': location?.address,
      'status': statusString,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
    };
  }
}
