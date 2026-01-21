# config/ - Configuration

Contains all configuration constants for the application.

## 📁 Files

| File | Purpose |
|------|---------|
| `api_config.dart` | API endpoints and credentials |

## 🔧 api_config.dart

```dart
class ApiConfig {
  // InfluxDB Configuration
  static const String influxUrl = 'http://localhost:8086';
  static const String influxToken = '...';
  static const String influxOrg = 'Hydrobot';
  static const String bucketRaw = 'raw_sensors';
  static const String bucketProcessed = 'processed_results';

  // Backend ML Pipeline
  static const String backendBaseUrl = 'http://127.0.0.1:8000';
  static const String wqmEndpoint = '/WQM';
  static const String fhdEndpoint = '/FHD';
}
```

## 🔐 Security Note

⚠️ In production, move sensitive credentials to:
- Environment variables
- Secure storage
- Backend proxy

## 🔄 Configuration Flow

```
┌─────────────────┐
│   api_config    │
└────────┬────────┘
         │
         ├──────────────────┬──────────────────┐
         │                  │                  │
         ▼                  ▼                  ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│InfluxDB Service │ │   WQM Service   │ │   FHD Service   │
└─────────────────┘ └─────────────────┘ └─────────────────┘
```
