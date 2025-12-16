import 'package:equatable/equatable.dart';

class ConversationEntity extends Equatable {
  final String id;
  final String guideId;
  final String guideName;
  final String? guideAvatar;
  final String visitorId;
  final String visitorName;
  final String? visitorAvatar;
  final String? lastMessageText;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ConversationEntity({
    required this.id,
    required this.guideId,
    required this.guideName,
    this.guideAvatar,
    required this.visitorId,
    required this.visitorName,
    this.visitorAvatar,
    this.lastMessageText,
    this.lastMessageTime,
    this.unreadCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  // Get other participant's name based on current user type
  String getOtherParticipantName(String currentUserId) {
    return currentUserId == visitorId ? guideName : visitorName;
  }

  // Get other participant's avatar based on current user type
  String? getOtherParticipantAvatar(String currentUserId) {
    return currentUserId == visitorId ? guideAvatar : visitorAvatar;
  }

  // Get other participant's ID based on current user type
  String getOtherParticipantId(String currentUserId) {
    return currentUserId == visitorId ? guideId : visitorId;
  }

  @override
  List<Object?> get props => [
        id,
        guideId,
        guideName,
        guideAvatar,
        visitorId,
        visitorName,
        visitorAvatar,
        lastMessageText,
        lastMessageTime,
        unreadCount,
        createdAt,
        updatedAt,
      ];
}
