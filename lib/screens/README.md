# screens/ - UI Screens

Contains all the UI screens for the application.

## 📁 Files

| File | Purpose |
|------|---------|
| `home_screen.dart` | Main container with bottom navigation |
| `dashboard_screen.dart` | Water quality overview |
| `alerts_screen.dart` | List of all alerts |
| `alert_detail_screen.dart` | Single alert full details |
| `history_screen.dart` | Historical sensor data |
| `settings_screen.dart` | App settings and status |

## 🗺️ Navigation Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                         HomeScreen                               │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                      IndexedStack                          │  │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐      │  │
│  │  │Dashboard│  │ Alerts  │  │ History │  │Settings │      │  │
│  │  │ Screen  │  │ Screen  │  │ Screen  │  │ Screen  │      │  │
│  │  └─────────┘  └────┬────┘  └─────────┘  └─────────┘      │  │
│  │                    │                                       │  │
│  │                    │ onTap                                 │  │
│  │                    ▼                                       │  │
│  │              ┌───────────┐                                 │  │
│  │              │AlertDetail│                                 │  │
│  │              │  Screen   │                                 │  │
│  │              └───────────┘                                 │  │
│  └───────────────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │              BottomNavigationBar                           │  │
│  │  ┌────┐  ┌────┐  ┌────┐  ┌────┐                          │  │
│  │  │ 🏠 │  │ 🔔 │  │ 📜 │  │ ⚙️ │                          │  │
│  │  │    │  │ 3  │  │    │  │    │                          │  │
│  │  └────┘  └────┘  └────┘  └────┘                          │  │
│  │Dashboard Alerts  History Settings                         │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## 📱 Screen Details

### 1. Dashboard Screen

```
┌─────────────────────────┐
│        HydroBot         │
├─────────────────────────┤
│  Water Quality Status   │
│     ┌───────────┐       │
│     │ Excellent │       │
│     └───────────┘       │
│   Last updated: 14:30   │
├─────────────────────────┤
│  Factor Contribution    │
│      ┌─────────┐        │
│     /    🟦    \        │
│    │  🟥  🟨   │        │
│     \  🟩 🟪 /          │
│      └───────┘          │
│  ● pH  ● Temp  ● Turb   │
│  ● DO  ● Ammonia        │
├─────────────────────────┤
│  Recent Alerts          │
│  ● Alert message...     │
│  ● Alert message...     │
└─────────────────────────┘
```

### 2. Alerts Screen

```
┌─────────────────────────┐
│      Alerts  [3]        │
├─────────────────────────┤
│ ┌─────────────────────┐ │
│ │ 💧 Water Quality    │ │
│ │ The pH is below...  │ │
│ │ Tap to view details │ │
│ └─────────────────────┘ │
│ ┌─────────────────────┐ │
│ │ 💧 Water Quality    │ │
│ │ Temperature is...   │ │
│ └─────────────────────┘ │
└─────────────────────────┘
```

### 3. Alert Detail Screen

```
┌─────────────────────────┐
│  ←  Alert Details       │
├─────────────────────────┤
│   ┌─────────────────┐   │
│   │ 💧 Water Quality│   │
│   │     Alert       │   │
│   └─────────────────┘   │
│                         │
│  ┌───────────────────┐  │
│  │ Alert Details     │  │
│  │                   │  │
│  │ The monitoring    │  │
│  │ system shows...   │  │
│  │                   │  │
│  │ • Recommendation 1│  │
│  │ • Recommendation 2│  │
│  │ • Recommendation 3│  │
│  └───────────────────┘  │
│                         │
│   Jan 21, 2026 14:30    │
└─────────────────────────┘
```

### 4. History Screen

```
┌─────────────────────────┐
│        History          │
├─────────────────────────┤
│ 📅 Jan 21, 2026         │
│ ┌─────────────────────┐ │
│ │ 14:30    Excellent  │ │
│ │ Temp: 26.5°C pH:7.1 │ │
│ │ Turb: 12  NH3: 0.2  │ │
│ │ DO: 6.5             │ │
│ └─────────────────────┘ │
│ ┌─────────────────────┐ │
│ │ 14:15       Good    │ │
│ │ Temp: 27.0°C pH:7.3 │ │
│ └─────────────────────┘ │
├─────────────────────────┤
│ 📅 Jan 20, 2026         │
│ ...                     │
└─────────────────────────┘
```

### 5. Settings Screen

```
┌─────────────────────────┐
│       Settings          │
├─────────────────────────┤
│ ┌─────────────────────┐ │
│ │ Enable Notifications│ │
│ │              [====] │ │
│ └─────────────────────┘ │
│ ┌─────────────────────┐ │
│ │ Polling Interval    │ │
│ │ [3 seconds    ▼]    │ │
│ └─────────────────────┘ │
│ ┌─────────────────────┐ │
│ │ System Status       │ │
│ │ WQM Service    🟢   │ │
│ │ InfluxDB       🟢   │ │
│ │ FHD Service    🔴   │ │
│ └─────────────────────┘ │
│ ┌─────────────────────┐ │
│ │ About               │ │
│ │ App Name: HydroBot  │ │
│ │ Version: 1.0.0      │ │
│ └─────────────────────┘ │
└─────────────────────────┘
```
