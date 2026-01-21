# providers/ - State Management

Contains Provider-based state management for the application.

## 📁 Files

| File | Purpose |
|------|---------|
| `hydrobot_provider.dart` | Main app state and business logic |

## 🔄 HydrobotProvider

Central state manager that handles:

- **Data State**: Sensor data, alerts, latest readings
- **Connection State**: InfluxDB, WQM, FHD service status
- **Settings**: Polling interval, notifications toggle
- **Polling Loop**: Continuous check for unprocessed data

### State Properties

```dart
// Data
List<SensorData> sensorDataHistory;
List<Alert> alerts;
SensorData? latestSensorData;

// Connection Status
bool influxConnected;
bool wqmConnected;
bool fhdConnected;

// Settings
int pollingIntervalSeconds;
bool notificationsEnabled;

// Computed
int unreadCount;
List<Alert> recentAlerts;
```

## 🔄 Polling Loop Sequence

```
┌─────────────────────────────────────────────────────────────────┐
│                     POLLING LOOP (Every 3s)                     │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │ Query InfluxDB  │
                    │ raw_sensors     │
                    │ (taken = 0)     │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │ Found unprocessed│
                    │     data?       │
                    └────────┬────────┘
                             │
              ┌──────────────┴──────────────┐
              │ YES                         │ NO
              ▼                             ▼
    ┌─────────────────┐           ┌─────────────────┐
    │ Send to WQM     │           │     Sleep       │
    │ POST /WQM       │           │     3 sec       │
    │ {temp,ph,       │           └────────┬────────┘
    │  turbidity,     │                    │
    │  timestamp}     │                    │
    └────────┬────────┘                    │
             │                             │
             ▼                             │
    ┌─────────────────┐                    │
    │ Receive Alert   │                    │
    │ Response        │                    │
    └────────┬────────┘                    │
             │                             │
             ▼                             │
    ┌─────────────────┐                    │
    │ Add Alert to    │                    │
    │ alerts list     │                    │
    └────────┬────────┘                    │
             │                             │
             ▼                             │
    ┌─────────────────┐                    │
    │ Refresh         │                    │
    │ Dashboard Data  │                    │
    └────────┬────────┘                    │
             │                             │
             └──────────────┬──────────────┘
                            │
                            ▼
                   ┌─────────────────┐
                   │ Notify Listeners│
                   │ (Update UI)     │
                   └────────┬────────┘
                            │
                            └──────────► Loop
```

## 🎯 Key Methods

| Method | Purpose |
|--------|---------|
| `_initialize()` | Test connections, load initial data, start polling |
| `_processUnprocessedRawData()` | Main polling loop logic |
| `refreshDashboardData()` | Fetch latest from processed_results |
| `refreshHistoryData()` | Fetch history from processed_results |
| `markAlertAsRead()` | Update alert read status |
| `setPollingInterval()` | Change polling frequency |
| `setNotificationsEnabled()` | Toggle alert notifications |
