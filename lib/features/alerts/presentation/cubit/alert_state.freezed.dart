// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'alert_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AlertState {
  List<AlertModel> get alerts => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get hasError => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of AlertState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AlertStateCopyWith<AlertState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AlertStateCopyWith<$Res> {
  factory $AlertStateCopyWith(
    AlertState value,
    $Res Function(AlertState) then,
  ) = _$AlertStateCopyWithImpl<$Res, AlertState>;
  @useResult
  $Res call({
    List<AlertModel> alerts,
    bool isLoading,
    bool hasError,
    String? errorMessage,
  });
}

/// @nodoc
class _$AlertStateCopyWithImpl<$Res, $Val extends AlertState>
    implements $AlertStateCopyWith<$Res> {
  _$AlertStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AlertState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? alerts = null,
    Object? isLoading = null,
    Object? hasError = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            alerts:
                null == alerts
                    ? _value.alerts
                    : alerts // ignore: cast_nullable_to_non_nullable
                        as List<AlertModel>,
            isLoading:
                null == isLoading
                    ? _value.isLoading
                    : isLoading // ignore: cast_nullable_to_non_nullable
                        as bool,
            hasError:
                null == hasError
                    ? _value.hasError
                    : hasError // ignore: cast_nullable_to_non_nullable
                        as bool,
            errorMessage:
                freezed == errorMessage
                    ? _value.errorMessage
                    : errorMessage // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AlertStateImplCopyWith<$Res>
    implements $AlertStateCopyWith<$Res> {
  factory _$$AlertStateImplCopyWith(
    _$AlertStateImpl value,
    $Res Function(_$AlertStateImpl) then,
  ) = __$$AlertStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<AlertModel> alerts,
    bool isLoading,
    bool hasError,
    String? errorMessage,
  });
}

/// @nodoc
class __$$AlertStateImplCopyWithImpl<$Res>
    extends _$AlertStateCopyWithImpl<$Res, _$AlertStateImpl>
    implements _$$AlertStateImplCopyWith<$Res> {
  __$$AlertStateImplCopyWithImpl(
    _$AlertStateImpl _value,
    $Res Function(_$AlertStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AlertState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? alerts = null,
    Object? isLoading = null,
    Object? hasError = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$AlertStateImpl(
        alerts:
            null == alerts
                ? _value._alerts
                : alerts // ignore: cast_nullable_to_non_nullable
                    as List<AlertModel>,
        isLoading:
            null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                    as bool,
        hasError:
            null == hasError
                ? _value.hasError
                : hasError // ignore: cast_nullable_to_non_nullable
                    as bool,
        errorMessage:
            freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc

class _$AlertStateImpl implements _AlertState {
  const _$AlertStateImpl({
    final List<AlertModel> alerts = const [],
    this.isLoading = true,
    this.hasError = false,
    this.errorMessage,
  }) : _alerts = alerts;

  final List<AlertModel> _alerts;
  @override
  @JsonKey()
  List<AlertModel> get alerts {
    if (_alerts is EqualUnmodifiableListView) return _alerts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_alerts);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool hasError;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'AlertState(alerts: $alerts, isLoading: $isLoading, hasError: $hasError, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AlertStateImpl &&
            const DeepCollectionEquality().equals(other._alerts, _alerts) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.hasError, hasError) ||
                other.hasError == hasError) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_alerts),
    isLoading,
    hasError,
    errorMessage,
  );

  /// Create a copy of AlertState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AlertStateImplCopyWith<_$AlertStateImpl> get copyWith =>
      __$$AlertStateImplCopyWithImpl<_$AlertStateImpl>(this, _$identity);
}

abstract class _AlertState implements AlertState {
  const factory _AlertState({
    final List<AlertModel> alerts,
    final bool isLoading,
    final bool hasError,
    final String? errorMessage,
  }) = _$AlertStateImpl;

  @override
  List<AlertModel> get alerts;
  @override
  bool get isLoading;
  @override
  bool get hasError;
  @override
  String? get errorMessage;

  /// Create a copy of AlertState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AlertStateImplCopyWith<_$AlertStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
