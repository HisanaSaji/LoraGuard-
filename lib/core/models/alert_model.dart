class AlertModel {
  final String id;
  final String location;
  final String description;
  final DateTime timestamp;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;

  AlertModel({
    required this.id,
    required this.location,
    required this.description,
    required this.timestamp,
    this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
  });

  // Create a copy with some fields changed
  AlertModel copyWith({
    String? id,
    String? location,
    String? description,
    DateTime? timestamp,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return AlertModel(
      id: id ?? this.id,
      location: location ?? this.location,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  // Simple fromJson implementation
  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'] as String,
      location: json['location'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  // Simple toJson implementation
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'location': location,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }
} 