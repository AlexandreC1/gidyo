// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_payload.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

NotificationPayload _$NotificationPayloadFromJson(Map<String, dynamic> json) {
  return _NotificationPayload.fromJson(json);
}

/// @nodoc
mixin _$NotificationPayload {
  String get title => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  NotificationType get type => throw _privateConstructorUsedError;
  String? get bookingId => throw _privateConstructorUsedError;
  String? get messageId => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;
  String? get screen => throw _privateConstructorUsedError;
  Map<String, dynamic>? get additionalData =>
      throw _privateConstructorUsedError;

  /// Serializes this NotificationPayload to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationPayloadCopyWith<NotificationPayload> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationPayloadCopyWith<$Res> {
  factory $NotificationPayloadCopyWith(
    NotificationPayload value,
    $Res Function(NotificationPayload) then,
  ) = _$NotificationPayloadCopyWithImpl<$Res, NotificationPayload>;
  @useResult
  $Res call({
    String title,
    String body,
    NotificationType type,
    String? bookingId,
    String? messageId,
    String? userId,
    String? screen,
    Map<String, dynamic>? additionalData,
  });
}

/// @nodoc
class _$NotificationPayloadCopyWithImpl<$Res, $Val extends NotificationPayload>
    implements $NotificationPayloadCopyWith<$Res> {
  _$NotificationPayloadCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationPayload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? body = null,
    Object? type = null,
    Object? bookingId = freezed,
    Object? messageId = freezed,
    Object? userId = freezed,
    Object? screen = freezed,
    Object? additionalData = freezed,
  }) {
    return _then(
      _value.copyWith(
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            body: null == body
                ? _value.body
                : body // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as NotificationType,
            bookingId: freezed == bookingId
                ? _value.bookingId
                : bookingId // ignore: cast_nullable_to_non_nullable
                      as String?,
            messageId: freezed == messageId
                ? _value.messageId
                : messageId // ignore: cast_nullable_to_non_nullable
                      as String?,
            userId: freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String?,
            screen: freezed == screen
                ? _value.screen
                : screen // ignore: cast_nullable_to_non_nullable
                      as String?,
            additionalData: freezed == additionalData
                ? _value.additionalData
                : additionalData // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NotificationPayloadImplCopyWith<$Res>
    implements $NotificationPayloadCopyWith<$Res> {
  factory _$$NotificationPayloadImplCopyWith(
    _$NotificationPayloadImpl value,
    $Res Function(_$NotificationPayloadImpl) then,
  ) = __$$NotificationPayloadImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String title,
    String body,
    NotificationType type,
    String? bookingId,
    String? messageId,
    String? userId,
    String? screen,
    Map<String, dynamic>? additionalData,
  });
}

/// @nodoc
class __$$NotificationPayloadImplCopyWithImpl<$Res>
    extends _$NotificationPayloadCopyWithImpl<$Res, _$NotificationPayloadImpl>
    implements _$$NotificationPayloadImplCopyWith<$Res> {
  __$$NotificationPayloadImplCopyWithImpl(
    _$NotificationPayloadImpl _value,
    $Res Function(_$NotificationPayloadImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NotificationPayload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? body = null,
    Object? type = null,
    Object? bookingId = freezed,
    Object? messageId = freezed,
    Object? userId = freezed,
    Object? screen = freezed,
    Object? additionalData = freezed,
  }) {
    return _then(
      _$NotificationPayloadImpl(
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        body: null == body
            ? _value.body
            : body // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as NotificationType,
        bookingId: freezed == bookingId
            ? _value.bookingId
            : bookingId // ignore: cast_nullable_to_non_nullable
                  as String?,
        messageId: freezed == messageId
            ? _value.messageId
            : messageId // ignore: cast_nullable_to_non_nullable
                  as String?,
        userId: freezed == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String?,
        screen: freezed == screen
            ? _value.screen
            : screen // ignore: cast_nullable_to_non_nullable
                  as String?,
        additionalData: freezed == additionalData
            ? _value._additionalData
            : additionalData // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationPayloadImpl extends _NotificationPayload {
  const _$NotificationPayloadImpl({
    required this.title,
    required this.body,
    required this.type,
    this.bookingId,
    this.messageId,
    this.userId,
    this.screen,
    final Map<String, dynamic>? additionalData,
  }) : _additionalData = additionalData,
       super._();

  factory _$NotificationPayloadImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationPayloadImplFromJson(json);

  @override
  final String title;
  @override
  final String body;
  @override
  final NotificationType type;
  @override
  final String? bookingId;
  @override
  final String? messageId;
  @override
  final String? userId;
  @override
  final String? screen;
  final Map<String, dynamic>? _additionalData;
  @override
  Map<String, dynamic>? get additionalData {
    final value = _additionalData;
    if (value == null) return null;
    if (_additionalData is EqualUnmodifiableMapView) return _additionalData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'NotificationPayload(title: $title, body: $body, type: $type, bookingId: $bookingId, messageId: $messageId, userId: $userId, screen: $screen, additionalData: $additionalData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationPayloadImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.bookingId, bookingId) ||
                other.bookingId == bookingId) &&
            (identical(other.messageId, messageId) ||
                other.messageId == messageId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.screen, screen) || other.screen == screen) &&
            const DeepCollectionEquality().equals(
              other._additionalData,
              _additionalData,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    title,
    body,
    type,
    bookingId,
    messageId,
    userId,
    screen,
    const DeepCollectionEquality().hash(_additionalData),
  );

  /// Create a copy of NotificationPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationPayloadImplCopyWith<_$NotificationPayloadImpl> get copyWith =>
      __$$NotificationPayloadImplCopyWithImpl<_$NotificationPayloadImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationPayloadImplToJson(this);
  }
}

abstract class _NotificationPayload extends NotificationPayload {
  const factory _NotificationPayload({
    required final String title,
    required final String body,
    required final NotificationType type,
    final String? bookingId,
    final String? messageId,
    final String? userId,
    final String? screen,
    final Map<String, dynamic>? additionalData,
  }) = _$NotificationPayloadImpl;
  const _NotificationPayload._() : super._();

  factory _NotificationPayload.fromJson(Map<String, dynamic> json) =
      _$NotificationPayloadImpl.fromJson;

  @override
  String get title;
  @override
  String get body;
  @override
  NotificationType get type;
  @override
  String? get bookingId;
  @override
  String? get messageId;
  @override
  String? get userId;
  @override
  String? get screen;
  @override
  Map<String, dynamic>? get additionalData;

  /// Create a copy of NotificationPayload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationPayloadImplCopyWith<_$NotificationPayloadImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NotificationDisplay _$NotificationDisplayFromJson(Map<String, dynamic> json) {
  return _NotificationDisplay.fromJson(json);
}

/// @nodoc
mixin _$NotificationDisplay {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get channelId => throw _privateConstructorUsedError;
  String? get channelName => throw _privateConstructorUsedError;
  bool get showBadge => throw _privateConstructorUsedError;
  bool get playSound => throw _privateConstructorUsedError;
  bool get enableVibration => throw _privateConstructorUsedError;

  /// Serializes this NotificationDisplay to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationDisplay
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationDisplayCopyWith<NotificationDisplay> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationDisplayCopyWith<$Res> {
  factory $NotificationDisplayCopyWith(
    NotificationDisplay value,
    $Res Function(NotificationDisplay) then,
  ) = _$NotificationDisplayCopyWithImpl<$Res, NotificationDisplay>;
  @useResult
  $Res call({
    int id,
    String title,
    String body,
    String? imageUrl,
    String? channelId,
    String? channelName,
    bool showBadge,
    bool playSound,
    bool enableVibration,
  });
}

/// @nodoc
class _$NotificationDisplayCopyWithImpl<$Res, $Val extends NotificationDisplay>
    implements $NotificationDisplayCopyWith<$Res> {
  _$NotificationDisplayCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationDisplay
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? body = null,
    Object? imageUrl = freezed,
    Object? channelId = freezed,
    Object? channelName = freezed,
    Object? showBadge = null,
    Object? playSound = null,
    Object? enableVibration = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            body: null == body
                ? _value.body
                : body // ignore: cast_nullable_to_non_nullable
                      as String,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            channelId: freezed == channelId
                ? _value.channelId
                : channelId // ignore: cast_nullable_to_non_nullable
                      as String?,
            channelName: freezed == channelName
                ? _value.channelName
                : channelName // ignore: cast_nullable_to_non_nullable
                      as String?,
            showBadge: null == showBadge
                ? _value.showBadge
                : showBadge // ignore: cast_nullable_to_non_nullable
                      as bool,
            playSound: null == playSound
                ? _value.playSound
                : playSound // ignore: cast_nullable_to_non_nullable
                      as bool,
            enableVibration: null == enableVibration
                ? _value.enableVibration
                : enableVibration // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NotificationDisplayImplCopyWith<$Res>
    implements $NotificationDisplayCopyWith<$Res> {
  factory _$$NotificationDisplayImplCopyWith(
    _$NotificationDisplayImpl value,
    $Res Function(_$NotificationDisplayImpl) then,
  ) = __$$NotificationDisplayImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String title,
    String body,
    String? imageUrl,
    String? channelId,
    String? channelName,
    bool showBadge,
    bool playSound,
    bool enableVibration,
  });
}

/// @nodoc
class __$$NotificationDisplayImplCopyWithImpl<$Res>
    extends _$NotificationDisplayCopyWithImpl<$Res, _$NotificationDisplayImpl>
    implements _$$NotificationDisplayImplCopyWith<$Res> {
  __$$NotificationDisplayImplCopyWithImpl(
    _$NotificationDisplayImpl _value,
    $Res Function(_$NotificationDisplayImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NotificationDisplay
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? body = null,
    Object? imageUrl = freezed,
    Object? channelId = freezed,
    Object? channelName = freezed,
    Object? showBadge = null,
    Object? playSound = null,
    Object? enableVibration = null,
  }) {
    return _then(
      _$NotificationDisplayImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        body: null == body
            ? _value.body
            : body // ignore: cast_nullable_to_non_nullable
                  as String,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        channelId: freezed == channelId
            ? _value.channelId
            : channelId // ignore: cast_nullable_to_non_nullable
                  as String?,
        channelName: freezed == channelName
            ? _value.channelName
            : channelName // ignore: cast_nullable_to_non_nullable
                  as String?,
        showBadge: null == showBadge
            ? _value.showBadge
            : showBadge // ignore: cast_nullable_to_non_nullable
                  as bool,
        playSound: null == playSound
            ? _value.playSound
            : playSound // ignore: cast_nullable_to_non_nullable
                  as bool,
        enableVibration: null == enableVibration
            ? _value.enableVibration
            : enableVibration // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationDisplayImpl implements _NotificationDisplay {
  const _$NotificationDisplayImpl({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    this.channelId,
    this.channelName,
    this.showBadge = true,
    this.playSound = true,
    this.enableVibration = true,
  });

  factory _$NotificationDisplayImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationDisplayImplFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  final String body;
  @override
  final String? imageUrl;
  @override
  final String? channelId;
  @override
  final String? channelName;
  @override
  @JsonKey()
  final bool showBadge;
  @override
  @JsonKey()
  final bool playSound;
  @override
  @JsonKey()
  final bool enableVibration;

  @override
  String toString() {
    return 'NotificationDisplay(id: $id, title: $title, body: $body, imageUrl: $imageUrl, channelId: $channelId, channelName: $channelName, showBadge: $showBadge, playSound: $playSound, enableVibration: $enableVibration)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationDisplayImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.channelId, channelId) ||
                other.channelId == channelId) &&
            (identical(other.channelName, channelName) ||
                other.channelName == channelName) &&
            (identical(other.showBadge, showBadge) ||
                other.showBadge == showBadge) &&
            (identical(other.playSound, playSound) ||
                other.playSound == playSound) &&
            (identical(other.enableVibration, enableVibration) ||
                other.enableVibration == enableVibration));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    body,
    imageUrl,
    channelId,
    channelName,
    showBadge,
    playSound,
    enableVibration,
  );

  /// Create a copy of NotificationDisplay
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationDisplayImplCopyWith<_$NotificationDisplayImpl> get copyWith =>
      __$$NotificationDisplayImplCopyWithImpl<_$NotificationDisplayImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationDisplayImplToJson(this);
  }
}

abstract class _NotificationDisplay implements NotificationDisplay {
  const factory _NotificationDisplay({
    required final int id,
    required final String title,
    required final String body,
    final String? imageUrl,
    final String? channelId,
    final String? channelName,
    final bool showBadge,
    final bool playSound,
    final bool enableVibration,
  }) = _$NotificationDisplayImpl;

  factory _NotificationDisplay.fromJson(Map<String, dynamic> json) =
      _$NotificationDisplayImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  String get body;
  @override
  String? get imageUrl;
  @override
  String? get channelId;
  @override
  String? get channelName;
  @override
  bool get showBadge;
  @override
  bool get playSound;
  @override
  bool get enableVibration;

  /// Create a copy of NotificationDisplay
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationDisplayImplCopyWith<_$NotificationDisplayImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
