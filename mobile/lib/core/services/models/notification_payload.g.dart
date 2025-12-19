// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationPayloadImpl _$$NotificationPayloadImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationPayloadImpl(
  title: json['title'] as String,
  body: json['body'] as String,
  type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
  bookingId: json['bookingId'] as String?,
  messageId: json['messageId'] as String?,
  userId: json['userId'] as String?,
  screen: json['screen'] as String?,
  additionalData: json['additionalData'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$NotificationPayloadImplToJson(
  _$NotificationPayloadImpl instance,
) => <String, dynamic>{
  'title': instance.title,
  'body': instance.body,
  'type': _$NotificationTypeEnumMap[instance.type]!,
  'bookingId': instance.bookingId,
  'messageId': instance.messageId,
  'userId': instance.userId,
  'screen': instance.screen,
  'additionalData': instance.additionalData,
};

const _$NotificationTypeEnumMap = {
  NotificationType.bookingRequest: 'bookingRequest',
  NotificationType.bookingConfirmed: 'bookingConfirmed',
  NotificationType.bookingCancelled: 'bookingCancelled',
  NotificationType.newMessage: 'newMessage',
  NotificationType.paymentReceived: 'paymentReceived',
  NotificationType.reviewReceived: 'reviewReceived',
  NotificationType.guideApproved: 'guideApproved',
  NotificationType.unknown: 'unknown',
};

_$NotificationDisplayImpl _$$NotificationDisplayImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationDisplayImpl(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  body: json['body'] as String,
  imageUrl: json['imageUrl'] as String?,
  channelId: json['channelId'] as String?,
  channelName: json['channelName'] as String?,
  showBadge: json['showBadge'] as bool? ?? true,
  playSound: json['playSound'] as bool? ?? true,
  enableVibration: json['enableVibration'] as bool? ?? true,
);

Map<String, dynamic> _$$NotificationDisplayImplToJson(
  _$NotificationDisplayImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'body': instance.body,
  'imageUrl': instance.imageUrl,
  'channelId': instance.channelId,
  'channelName': instance.channelName,
  'showBadge': instance.showBadge,
  'playSound': instance.playSound,
  'enableVibration': instance.enableVibration,
};
