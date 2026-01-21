# widgets/ - Reusable UI Components

Contains reusable widget components used across the application.

## 📁 Files

| File | Purpose |
|------|---------|
| `bottom_nav_bar.dart` | Custom bottom navigation bar widget |

## 🔄 Component Usage

```
┌─────────────────────────────────────────┐
│              HomeScreen                  │
│  ┌───────────────────────────────────┐  │
│  │         Screen Content             │  │
│  └───────────────────────────────────┘  │
│  ┌───────────────────────────────────┐  │
│  │         BottomNavBar               │  │
│  │  (Currently using built-in        │  │
│  │   BottomNavigationBar)            │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

## 📦 BottomNavBar Widget

A custom bottom navigation bar with badge support.

### Properties

```dart
BottomNavBar({
  required int currentIndex,     // Active tab index
  required Function(int) onTap,  // Tab tap callback
  int unreadCount = 0,           // Badge count for alerts tab
})
```

### Features

- 4 navigation items (Dashboard, Alerts, History, Settings)
- Unread badge indicator on Alerts tab
- Active/inactive state styling
- Safe area support

**Note**: The home_screen.dart currently uses Flutter's built-in `BottomNavigationBar`. This custom widget is available as an alternative for more customization.
