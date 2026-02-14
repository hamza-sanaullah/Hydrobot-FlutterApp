# services/ - Backend Services

Contains service classes for external API communication.

## 📁 Files

| File | Purpose | Status |
|------|---------|--------|
| `influxdb_service.dart` | InfluxDB database queries | ✅ Active |
| `wqm_service.dart` | Water Quality Monitoring ML | ✅ Active |
| `fhd_service.dart` | Fish Health Detection ML | ✅ Active |

## 🔄 Service Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     HydrobotProvider                             │
└──────────────────────────┬──────────────────────────────────────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
        ▼                  ▼                  ▼
┌───────────────┐  ┌───────────────┐  ┌───────────────┐
│   InfluxDB    │  │     WQM       │  │     FHD       │
│   Service     │  │   Service     │  │   Service     │
└───────┬───────┘  └───────┬───────┘  └───────┬───────┘
        │                  │                  │
        │ HTTP/Flux        │ HTTP/REST        │ HTTP/REST
        ▼                  ▼                  ▼
┌───────────────┐  ┌───────────────┐  ┌───────────────┐
│   InfluxDB    │  │  FastAPI      │  │  FastAPI      │
│  :8086        │  │  :8000/WQM    │  │  :8001/FHD    │
└───────────────┘  └───────────────┘  └───────────────┘
```

---

## 1️⃣ InfluxDB Service

Handles all database operations with InfluxDB.

### Endpoints Used

| Operation | Bucket | Purpose |
|-----------|--------|---------|
| Query | `raw_sensors` | Get unprocessed data (taken=0) |
| Query | `processed_results` | Get latest data for dashboard |
| Query | `processed_results` | Get history data |

### Methods

```dart
// Get unprocessed raw data for polling
Future<List<RawSensorPoint>> getUnprocessedRawData()

// Get latest processed data for dashboard
Future<SensorData?> getLatestProcessedData()

// Get history data
Future<List<SensorData>> getProcessedDataHistory({
  Duration range = const Duration(hours: 24),
  int limit = 50,
})

// Test connection
Future<bool> testConnection()
```

### Flux Query Example

```flux
from(bucket: "processed_results")
  |> range(start: -24h)
  |> filter(fn: (r) => r["_measurement"] == "sensor_readings")
  |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
  |> sort(columns: ["_time"], desc: true)
  |> limit(n: 1)
```

---

## 2️⃣ WQM Service (Water Quality Monitoring)

Handles communication with WQM ML backend.

### API Endpoint

```
POST http://127.0.0.1:8000/WQM
```

### Request Payload

```json
{
  "temp": 26.5,
  "ph": 7.2,
  "turbidity": 15.0,
  "timestamp": 1737484800000000000
}
```

### Response

```json
{
  "alert": "The monitoring system shows the pH is the biggest problem..."
}
```

### Method

```dart
Future<Alert?> getWaterQualityPrediction({
  required double temp,
  required double ph,
  required double turbidity,
  required int timestampNano,
})
```

---

## 3️⃣ FHD Service (Fish Health Detection)

Handles communication with FHD ML backend for fish disease detection via camera analysis.

### API Endpoint

```
POST http://localhost:8001/FHD
```

### Request Payload

```json
{}
```
Empty JSON payload - FHD backend handles camera capture internally.

### Response

```json
{
  "alert_msg1": "",
  "alert_msg2": "🟢 HEALTHY | No disease symptoms detected. Fish appear normal and active.",
  "alert_msg3": "🟡 CONCERNING | White Spot Disease (Ich) suspected...",
  "alert_msg14": "🔴 CRITICAL | Epizootic Ulcerative Syndrome (EUS) detected...",
  ...
}
```

**Note**: Response contains variable number of `alert_msg` fields (alert_msg1 to alert_msgN).
Each non-empty message becomes a separate alert notification.

### Alert Severity Levels

| Emoji | Level | Description |
|-------|-------|-------------|
| 🟢 | HEALTHY | No disease symptoms detected |
| 🟡 | CONCERNING | Potential disease, monitoring required |
| 🔴 | CRITICAL | Urgent action required |

### Method

```dart
// Returns list of alerts (one for each non-empty alert_msg)
Future<List<Alert>> getFishHealthPredictions()
```

---

## 🔄 Service Communication Flow

```
┌─────────────┐
│   Sensors   │
│ (Raspberry) │
└──────┬──────┘
       │ Upload (taken=0)
       ▼
┌─────────────┐      ┌─────────────┐
│  InfluxDB   │      │   Mobile    │
│ raw_sensors │◄─────│    App      │
└──────┬──────┘ Poll └──────┬──────┘
       │                    │
       │         ┌──────────┴──────────┐
       │         │                     │
       │         ▼                     ▼
       │   ┌───────────┐         ┌───────────┐
       │   │    WQM    │         │    FHD    │
       │   │  :8000    │         │  :8001    │
       │   └─────┬─────┘         └─────┬─────┘
       │         │                     │
       │         │ Water Quality       │ Fish Health
       │         │ Alert (1)           │ Alerts (N)
       │         │                     │
       │  Update │                     │
       │  taken=1│                     │
       │◄────────┘                     │
       │                               │
       ▼                               ▼
┌─────────────┐              ┌─────────────────┐
│  InfluxDB   │              │  Mobile App     │
│ processed_  │              │  Alerts List    │
│  results    │              │  (WQM + FHD)    │
└─────────────┘              └─────────────────┘
```
