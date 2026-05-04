class ApiConfig {
  // InfluxDB Configuration
  static const String influxUrl = 'http://localhost:8086';
  static const String influxToken =
      'YWIhRpnw7LrSH6VOlH0iYA0fEvg91DobZJnEO6qbHK5Lp2BpmUVVfeGpmp9KtxAJKn90hGKUqWYXb2qo_F2yJw==';
  static const String influxOrg = 'Hydrobot';
  static const String bucketRaw = 'raw_sensors';
  static const String bucketProcessed = 'processed_results';

  // Water Quality Monitoring (WQM) Service - Port 8000
  static const String wqmBaseUrl = 'http://127.0.0.1:8000';
  static const String wqmEndpoint = '/WQM';

  // Fish Health Detection (FHD) Service - Port 8001
  static const String fhdBaseUrl = 'http://localhost:8001';
  static const String fhdEndpoint = '/FHD';
}
