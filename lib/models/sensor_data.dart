class SensorData {
  final int id;
  final double temperature;
  final double turbidity;
  final double ph;
  final double ammonia;
  final double dissolvedOxygen;
  final int qualityCode; // 0=excellent, 1=good, 2=poor
  final int taken;
  final DateTime timestamp;

  SensorData({
    required this.id,
    required this.temperature,
    required this.turbidity,
    required this.ph,
    required this.ammonia,
    required this.dissolvedOxygen,
    required this.qualityCode,
    required this.taken,
    required this.timestamp,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      id: json['id'] as int,
      temperature: (json['temperature'] as num).toDouble(),
      turbidity: (json['turbidity'] as num).toDouble(),
      ph: (json['ph'] as num).toDouble(),
      ammonia: (json['ammonia'] as num).toDouble(),
      dissolvedOxygen: (json['dissolved_oxygen'] as num).toDouble(),
      qualityCode: json['quality_code'] as int,
      taken: json['taken'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'temperature': temperature,
      'turbidity': turbidity,
      'ph': ph,
      'ammonia': ammonia,
      'dissolved_oxygen': dissolvedOxygen,
      'quality_code': qualityCode,
      'taken': taken,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  SensorData copyWith({
    int? id,
    double? temperature,
    double? turbidity,
    double? ph,
    double? ammonia,
    double? dissolvedOxygen,
    int? qualityCode,
    int? taken,
    DateTime? timestamp,
  }) {
    return SensorData(
      id: id ?? this.id,
      temperature: temperature ?? this.temperature,
      turbidity: turbidity ?? this.turbidity,
      ph: ph ?? this.ph,
      ammonia: ammonia ?? this.ammonia,
      dissolvedOxygen: dissolvedOxygen ?? this.dissolvedOxygen,
      qualityCode: qualityCode ?? this.qualityCode,
      taken: taken ?? this.taken,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  String get qualityStatus {
    switch (qualityCode) {
      case 0:
        return 'Excellent';
      case 1:
        return 'Good';
      case 2:
        return 'Poor';
      default:
        return 'Unknown';
    }
  }
}
