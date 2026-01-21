# lib/ - Source Code Directory

Main source code directory for the HydroBot Flutter application.

## 📁 Structure

```
lib/
├── main.dart          # Application entry point
├── config/            # API and app configuration
├── models/            # Data models (SensorData, Alert)
├── providers/         # State management (Provider)
├── screens/           # UI screens
├── services/          # Backend service integrations
└── theme/             # App theming and styling
```

## 🔄 Module Dependencies

```
                    ┌─────────────┐
                    │  main.dart  │
                    └──────┬──────┘
                           │
                           ▼
                    ┌─────────────┐
                    │   theme/    │
                    └──────┬──────┘
                           │
                           ▼
                    ┌─────────────┐
                    │  screens/   │
                    └──────┬──────┘
                           │
                           ▼
                    ┌─────────────┐
                    │ providers/  │
                    └──────┬──────┘
                           │
              ┌────────────┼────────────┐
              │            │            │
              ▼            ▼            ▼
        ┌──────────┐ ┌──────────┐ ┌──────────┐
        │ services/│ │ models/  │ │ config/  │
        └──────────┘ └──────────┘ └──────────┘
```

## 📝 Entry Point

`main.dart` initializes:
1. Flutter bindings
2. Provider for state management
3. Material theme
4. Home screen with bottom navigation
