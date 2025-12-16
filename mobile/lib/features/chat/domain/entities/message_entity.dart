import 'package:equatable/equatable.dart';

enum MessageType {
  text,
  image,
  voice,
  location,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

class MessageEntity extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final MessageType type;
  final String? textContent;
  final String? imageUrl;
  final String? voiceUrl;
  final double? voiceDurationSeconds;
  final LocationData? location;
  final MessageStatus status;
  final DateTime createdAt;
  final DateTime? readAt;

  const MessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.type,
    this.textContent,
    this.imageUrl,
    this.voiceUrl,
    this.voiceDurationSeconds,
    this.location,
    this.status = MessageStatus.sent,
    required this.createdAt,
    this.readAt,
  });

  bool get isRead => status == MessageStatus.read;
  bool get isSent => status == MessageStatus.sent || status == MessageStatus.delivered || status == MessageStatus.read;

  MessageEntity copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    MessageType? type,
    String? textContent,
    String? imageUrl,
    String? voiceUrl,
    double? voiceDurationSeconds,
    LocationData? location,
    MessageStatus? status,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      type: type ?? this.type,
      textContent: textContent ?? this.textContent,
      imageUrl: imageUrl ?? this.imageUrl,
      voiceUrl: voiceUrl ?? this.voiceUrl,
      voiceDurationSeconds: voiceDurationSeconds ?? this.voiceDurationSeconds,
      location: location ?? this.location,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        conversationId,
        senderId,
        senderName,
        senderAvatar,
        type,
        textContent,
        imageUrl,
        voiceUrl,
        voiceDurationSeconds,
        location,
        status,
        createdAt,
        readAt,
      ];
}

class LocationData extends Equatable {
  final double latitude;
  final double longitude;
  final String? address;

  const LocationData({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  @override
  List<Object?> get props => [latitude, longitude, address];
}
