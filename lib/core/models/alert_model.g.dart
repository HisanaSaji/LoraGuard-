// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AlertModelImpl _$$AlertModelImplFromJson(Map<String, dynamic> json) =>
    _$AlertModelImpl(
      id: json['id'] as String,
      type: $enumDecode(_$AlertTypeEnumMap, json['type']),
      location: json['location'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      severity: $enumDecode(_$AlertSeverityEnumMap, json['severity']),
      createdAt:
          json['createdAt'] == null
              ? null
              : DateTime.parse(json['createdAt'] as String),
      updatedAt:
          json['updatedAt'] == null
              ? null
              : DateTime.parse(json['updatedAt'] as String),
      isDeleted: json['isDeleted'] as bool? ?? false,
    );

Map<String, dynamic> _$$AlertModelImplToJson(_$AlertModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$AlertTypeEnumMap[instance.type]!,
      'location': instance.location,
      'description': instance.description,
      'timestamp': instance.timestamp.toIso8601String(),
      'severity': _$AlertSeverityEnumMap[instance.severity]!,
      'isDeleted': instance.isDeleted,
    };

const _$AlertTypeEnumMap = {
  AlertType.flood: 0,
  AlertType.earthquake: 1,
  AlertType.hurricane: 2,
  AlertType.wildfire: 3,
  AlertType.tornado: 4,
  AlertType.other: 5,
};

const _$AlertSeverityEnumMap = {
  AlertSeverity.low: 0,
  AlertSeverity.medium: 1,
  AlertSeverity.high: 2,
  AlertSeverity.critical: 3,
};
