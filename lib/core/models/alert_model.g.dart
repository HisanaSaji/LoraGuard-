// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AlertModelImpl _$$AlertModelImplFromJson(Map<String, dynamic> json) =>
    _$AlertModelImpl(
      id: json['id'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      location:
          json['location'] == null
              ? null
              : AlertLocation.fromJson(
                json['location'] as Map<String, dynamic>,
              ),
      isDeleted: json['isDeleted'] as bool? ?? false,
    );

Map<String, dynamic> _$$AlertModelImplToJson(_$AlertModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'timestamp': instance.timestamp.toIso8601String(),
      'location': instance.location,
      'isDeleted': instance.isDeleted,
    };
