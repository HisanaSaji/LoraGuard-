import 'package:freezed_annotation/freezed_annotation.dart';

part 'alert_model.freezed.dart';
part 'alert_model.g.dart';

enum AlertSeverity {
  @JsonValue(0)
  low,
  @JsonValue(1)
  medium,
  @JsonValue(2)
  high,
  @JsonValue(3)
  critical,
}

enum AlertType {
  @JsonValue(0)
  flood,
  @JsonValue(1)
  earthquake,
  @JsonValue(2)
  hurricane,
  @JsonValue(3)
  wildfire,
  @JsonValue(4)
  tornado,
  @JsonValue(5)
  other,
}

@freezed
class AlertModel with _$AlertModel {
  const factory AlertModel({
    required String id,
    required AlertType type,
    required String location,
    required String description,
    required DateTime timestamp,
    required AlertSeverity severity,
    @JsonKey(includeFromJson: true, includeToJson: false)
    DateTime? createdAt,
    @JsonKey(includeFromJson: true, includeToJson: false)
    DateTime? updatedAt,
    @Default(false)
    bool isDeleted,
  }) = _AlertModel;

  factory AlertModel.fromJson(Map<String, dynamic> json) =>
      _$AlertModelFromJson(json);
} 