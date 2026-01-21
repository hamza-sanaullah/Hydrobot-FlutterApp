class ApiConfig {
  // InfluxDB Configuration
  static const String influxUrl = 'http://localhost:8086';
  static const String influxToken = 'dApD6ecZgLLxJfQBw35dLh9ADpmbzJUD_AKgAiE61f67Ws4uZvPBEPKOwlZD9WtkDspIWqqAaapbmmdAJovrqQ==';
  static const String influxOrg = 'Hydrobot';
  static const String bucketRaw = 'raw_sensors';
  static const String bucketProcessed = 'processed_results';

  // Backend ML Pipeline Configuration
  static const String backendBaseUrl = 'http://127.0.0.1:8000';
  
  // Water Quality Monitoring (WQM) Service
  static const String wqmEndpoint = '/WQM';
  
  // Fish Health Detection (FHD) Service - Reserved for future
  static const String fhdEndpoint = '/FHD';
}
