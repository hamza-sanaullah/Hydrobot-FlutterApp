# services/ - Backend Services

Contains service classes for external API communication.

## 📁 Files

| File | Purpose | Status |
|------|---------|--------|
| `influxdb_service.dart` | InfluxDB database queries | ✅ Active |
| `wqm_service.dart` | Water Quality Monitoring ML | ✅ Active |
| `fhd_service.dart` | Fish Health Detection ML | 🔜 Reserved |

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
└───────┬───────┘  └───────┬───────┘  └───────────────┘
        │                  │                  │
        │ HTTP/Flux        │ HTTP/REST        │ (Future)
        ▼                  ▼                  ▼
┌───────────────┐  ┌───────────────┐  ┌───────────────┐
│   InfluxDB    │  │  FastAPI      │  │  FastAPI      │
│  :8086        │  │  /WQM         │  │  /FHD         │
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

## 3️⃣ FHD Service (Fish Health Detection) 🔜

Reserved for future implementation.

### Planned Features

- Camera feed analysis
- Fish behavior detection
- Disease identification
- Health recommendations

### API Endpoint (Planned)

```
POST http://127.0.0.1:8000/FHD
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
       │                    │ POST /WQM
       │                    ▼
       │              ┌─────────────┐
       │              │ WQM Backend │
       │              │  (FastAPI)  │
       │              └──────┬──────┘
       │                     │
       │  Update taken=1     │
       │◄────────────────────┤
       │                     │
       │  Write processed    │
       │◄────────────────────┤
       ▼                     │
┌─────────────┐              │
│  InfluxDB   │              │
│ processed_  │              │ Return Alert
│  results    │              │
└──────┬──────┘              │
       │                     │
       │ Query for           │
       │ dashboard/history   │
       │                     ▼
       └────────────────►┌─────────────┐
                         │   Mobile    │
                         │    App      │
                         └─────────────┘
```
