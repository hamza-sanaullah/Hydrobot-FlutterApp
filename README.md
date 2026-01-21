# HydroBot Mobile Application

A Flutter mobile application for aquaculture monitoring system. This app helps fish farmers monitor water quality in real-time and receive AI-powered alerts and recommendations.

## 🌊 Overview

HydroBot is part of an aquacultural engineering project that includes:
- **Hardware**: Sensors, Raspberry Pi, Camera
- **ML Pipeline**: Water Quality Monitoring (WQM), Fish Health Detection (FHD)
- **Frontend**: This Flutter mobile application

## 📱 Features

- **Dashboard**: Real-time water quality status with visual indicators
- **Alerts**: AI-generated recommendations from ML pipeline
- **History**: Historical sensor data grouped by date
- **Settings**: App configuration and system status

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        HydroBot Mobile App                          │
├─────────────────────────────────────────────────────────────────────┤
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐                │
│  │Dashboard│  │ Alerts  │  │ History │  │Settings │   SCREENS      │
│  └────┬────┘  └────┬────┘  └────┬────┘  └────┬────┘                │
│       │            │            │            │                      │
│       └────────────┴─────┬──────┴────────────┘                      │
│                          │                                          │
│                 ┌────────┴────────┐                                 │
│                 │ HydrobotProvider│  STATE MANAGEMENT               │
│                 └────────┬────────┘                                 │
│                          │                                          │
│       ┌──────────────────┼──────────────────┐                       │
│       │                  │                  │                       │
│  ┌────┴─────┐    ┌───────┴───────┐   ┌─────┴─────┐                 │
│  │InfluxDB  │    │  WQM Service  │   │FHD Service│  SERVICES       │
│  │ Service  │    │               │   │ (Future)  │                 │
│  └────┬─────┘    └───────┬───────┘   └───────────┘                 │
│       │                  │                                          │
└───────┼──────────────────┼──────────────────────────────────────────┘
        │                  │
        ▼                  ▼
┌───────────────┐  ┌───────────────┐
│   InfluxDB    │  │  ML Backend   │
│  (Database)   │  │   (FastAPI)   │
└───────────────┘  └───────────────┘
```

## 🔄 Data Flow Sequence

```
┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
│ Sensors  │     │ InfluxDB │     │  Mobile  │     │    WQM   │     │  Mobile  │
│(Hardware)│     │(Database)│     │   App    │     │ Backend  │     │   App    │
└────┬─────┘     └────┬─────┘     └────┬─────┘     └────┬─────┘     └────┬─────┘
     │                │                │                │                │
     │ Upload Data    │                │                │                │
     │ (taken=0)      │                │                │                │
     │───────────────>│                │                │                │
     │                │                │                │                │
     │                │  Poll every 3s │                │                │
     │                │  (taken=0)     │                │                │
     │                │<───────────────│                │                │
     │                │                │                │                │
     │                │  Return raw    │                │                │
     │                │  sensor data   │                │                │
     │                │───────────────>│                │                │
     │                │                │                │                │
     │                │                │  POST /WQM     │                │
     │                │                │  {temp,ph,     │                │
     │                │                │   turbidity,   │                │
     │                │                │   timestamp}   │                │
     │                │                │───────────────>│                │
     │                │                │                │                │
     │                │                │                │  ML Prediction │
     │                │                │                │  & Processing  │
     │                │                │                │                │
     │                │  Update taken=1│                │                │
     │                │<───────────────┼────────────────│                │
     │                │                │                │                │
     │                │                │  Return Alert  │                │
     │                │                │  {alert: "..."} │                │
     │                │                │<───────────────│                │
     │                │                │                │                │
     │                │                │                │  Display Alert │
     │                │                │                │───────────────>│
     │                │                │                │                │
```

## 📁 Project Structure

```
hydrobot_app/
├── lib/
│   ├── main.dart              # App entry point
│   ├── config/                # Configuration files
│   ├── models/                # Data models
│   ├── providers/             # State management
│   ├── screens/               # UI screens
│   ├── services/              # Backend services
│   └── theme/                 # App theming
├── assets/
│   └── images/                # App images
└── pubspec.yaml               # Dependencies
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / VS Code
- InfluxDB running on `localhost:8086`
- WQM Backend running on `127.0.0.1:8000`

### Installation

```bash
# Clone the repository
cd hydrobot_app

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Configuration

Update `lib/config/api_config.dart` with your server details:

```dart
class ApiConfig {
  static const String influxUrl = 'http://localhost:8086';
  static const String influxToken = 'your-token';
  static const String influxOrg = 'Hydrobot';
  static const String backendBaseUrl = 'http://127.0.0.1:8000';
}
```

## 📊 Data Sources

| Bucket | Purpose | Fields |
|--------|---------|--------|
| `raw_sensors` | Unprocessed sensor data | temperature, ph, turbidity, taken, timestamp |
| `processed_results` | Processed data for display | temperature, ph, turbidity, ammonia, do, quality_code |

## 🔌 API Endpoints

| Service | Endpoint | Method | Purpose |
|---------|----------|--------|---------|
| WQM | `/WQM` | POST | Water quality prediction |
| FHD | `/FHD` | POST | Fish health detection (future) |

## 📄 License

This project is part of a Final Year Project (FYP) for aquacultural engineering.

## 👥 Authors

HydroBot Team
