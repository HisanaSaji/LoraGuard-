class AlertModel {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final String severity;
  final bool isRead;

  AlertModel({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.severity,
    this.isRead = false,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      severity: json['severity'] as String,
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'severity': severity,
      'isRead': isRead,
    };
  }

  AlertModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? timestamp,
    String? severity,
    bool? isRead,
  }) {
    return AlertModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      severity: severity ?? this.severity,
      isRead: isRead ?? this.isRead,
    );
  }
} 