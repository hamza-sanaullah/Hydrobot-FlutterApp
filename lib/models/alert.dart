enum AlertType {
  waterQuality,
  fishHealth, // Reserved for future
}

class Alert {
  final int id;
  final AlertType type;
  final String message; // Full alert message from backend
  final DateTime timestamp;
  final bool read;

  Alert({
    required this.id,
    required this.type,
    required this.message,
    required this.timestamp,
    this.read = false,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id'] as int,
      type: json['type'] == 'water_quality'
          ? AlertType.waterQuality
          : AlertType.fishHealth,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      read: json['read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type == AlertType.waterQuality ? 'water_quality' : 'fish_health',
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'read': read,
    };
  }

  Alert copyWith({
    int? id,
    AlertType? type,
    String? message,
    DateTime? timestamp,
    bool? read,
  }) {
    return Alert(
      id: id ?? this.id,
      type: type ?? this.type,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      read: read ?? this.read,
    );
  }

  String get typeDisplayName {
    return type == AlertType.waterQuality ? 'Water Quality Alert' : 'Fish Health Alert';
  }

  /// Get short preview of message (first line or first 100 chars)
  String get messagePreview {
    final firstLine = message.split('\n').first;
    if (firstLine.length > 100) {
      return '${firstLine.substring(0, 100)}...';
    }
    return firstLine;
  }
}
