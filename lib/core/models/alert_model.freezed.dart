// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'alert_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AlertModel _$AlertModelFromJson(Map<String, dynamic> json) {
  return _AlertModel.fromJson(json);
}

/// @nodoc
mixin _$AlertModel {
  String get id => throw _privateConstructorUsedError;
  AlertType get type => throw _privateConstructorUsedError;
  String get location => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  AlertSeverity get severity => throw _privateConstructorUsedError;
  @JsonKey(includeFromJson: true, includeToJson: false)
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(includeFromJson: true, includeToJson: false)
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  bool get isDeleted => throw _privateConstructorUsedError;

  /// Serializes this AlertModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AlertModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AlertModelCopyWith<AlertModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AlertModelCopyWith<$Res> {
  factory $AlertModelCopyWith(
    AlertModel value,
    $Res Function(AlertModel) then,
  ) = _$AlertModelCopyWithImpl<$Res, AlertModel>;
  @useResult
  $Res call({
    String id,
    AlertType type,
    String location,
    String description,
    DateTime timestamp,
    AlertSeverity severity,
    @JsonKey(includeFromJson: true, includeToJson: false) DateTime? createdAt,
    @JsonKey(includeFromJson: true, includeToJson: false) DateTime? updatedAt,
    bool isDeleted,
  });
}

/// @nodoc
class _$AlertModelCopyWithImpl<$Res, $Val extends AlertModel>
    implements $AlertModelCopyWith<$Res> {
  _$AlertModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AlertModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? location = null,
    Object? description = null,
    Object? timestamp = null,
    Object? severity = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? isDeleted = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            type:
                null == type
                    ? _value.type
                    : type // ignore: cast_nullable_to_non_nullable
                        as AlertType,
            location:
                null == location
                    ? _value.location
                    : location // ignore: cast_nullable_to_non_nullable
                        as String,
            description:
                null == description
                    ? _value.description
                    : description // ignore: cast_nullable_to_non_nullable
                        as String,
            timestamp:
                null == timestamp
                    ? _value.timestamp
                    : timestamp // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            severity:
                null == severity
                    ? _value.severity
                    : severity // ignore: cast_nullable_to_non_nullable
                        as AlertSeverity,
            createdAt:
                freezed == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            updatedAt:
                freezed == updatedAt
                    ? _value.updatedAt
                    : updatedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            isDeleted:
                null == isDeleted
                    ? _value.isDeleted
                    : isDeleted // ignore: cast_nullable_to_non_nullable
                        as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AlertModelImplCopyWith<$Res>
    implements $AlertModelCopyWith<$Res> {
  factory _$$AlertModelImplCopyWith(
    _$AlertModelImpl value,
    $Res Function(_$AlertModelImpl) then,
  ) = __$$AlertModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    AlertType type,
    String location,
    String description,
    DateTime timestamp,
    AlertSeverity severity,
    @JsonKey(includeFromJson: true, includeToJson: false) DateTime? createdAt,
    @JsonKey(includeFromJson: true, includeToJson: false) DateTime? updatedAt,
    bool isDeleted,
  });
}

/// @nodoc
class __$$AlertModelImplCopyWithImpl<$Res>
    extends _$AlertModelCopyWithImpl<$Res, _$AlertModelImpl>
    implements _$$AlertModelImplCopyWith<$Res> {
  __$$AlertModelImplCopyWithImpl(
    _$AlertModelImpl _value,
    $Res Function(_$AlertModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AlertModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? location = null,
    Object? description = null,
    Object? timestamp = null,
    Object? severity = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? isDeleted = null,
  }) {
    return _then(
      _$AlertModelImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        type:
            null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                    as AlertType,
        location:
            null == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                    as String,
        description:
            null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                    as String,
        timestamp:
            null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        severity:
            null == severity
                ? _value.severity
                : severity // ignore: cast_nullable_to_non_nullable
                    as AlertSeverity,
        createdAt:
            freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        updatedAt:
            freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        isDeleted:
            null == isDeleted
                ? _value.isDeleted
                : isDeleted // ignore: cast_nullable_to_non_nullable
                    as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AlertModelImpl implements _AlertModel {
  const _$AlertModelImpl({
    required this.id,
    required this.type,
    required this.location,
    required this.description,
    required this.timestamp,
    required this.severity,
    @JsonKey(includeFromJson: true, includeToJson: false) this.createdAt,
    @JsonKey(includeFromJson: true, includeToJson: false) this.updatedAt,
    this.isDeleted = false,
  });

  factory _$AlertModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AlertModelImplFromJson(json);

  @override
  final String id;
  @override
  final AlertType type;
  @override
  final String location;
  @override
  final String description;
  @override
  final DateTime timestamp;
  @override
  final AlertSeverity severity;
  @override
  @JsonKey(includeFromJson: true, includeToJson: false)
  final DateTime? createdAt;
  @override
  @JsonKey(includeFromJson: true, includeToJson: false)
  final DateTime? updatedAt;
  @override
  @JsonKey()
  final bool isDeleted;

  @override
  String toString() {
    return 'AlertModel(id: $id, type: $type, location: $location, description: $description, timestamp: $timestamp, severity: $severity, createdAt: $createdAt, updatedAt: $updatedAt, isDeleted: $isDeleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AlertModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    type,
    location,
    description,
    timestamp,
    severity,
    createdAt,
    updatedAt,
    isDeleted,
  );

  /// Create a copy of AlertModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AlertModelImplCopyWith<_$AlertModelImpl> get copyWith =>
      __$$AlertModelImplCopyWithImpl<_$AlertModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AlertModelImplToJson(this);
  }
}

abstract class _AlertModel implements AlertModel {
  const factory _AlertModel({
    required final String id,
    required final AlertType type,
    required final String location,
    required final String description,
    required final DateTime timestamp,
    required final AlertSeverity severity,
    @JsonKey(includeFromJson: true, includeToJson: false)
    final DateTime? createdAt,
    @JsonKey(includeFromJson: true, includeToJson: false)
    final DateTime? updatedAt,
    final bool isDeleted,
  }) = _$AlertModelImpl;

  factory _AlertModel.fromJson(Map<String, dynamic> json) =
      _$AlertModelImpl.fromJson;

  @override
  String get id;
  @override
  AlertType get type;
  @override
  String get location;
  @override
  String get description;
  @override
  DateTime get timestamp;
  @override
  AlertSeverity get severity;
  @override
  @JsonKey(includeFromJson: true, includeToJson: false)
  DateTime? get createdAt;
  @override
  @JsonKey(includeFromJson: true, includeToJson: false)
  DateTime? get updatedAt;
  @override
  bool get isDeleted;

  /// Create a copy of AlertModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AlertModelImplCopyWith<_$AlertModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
