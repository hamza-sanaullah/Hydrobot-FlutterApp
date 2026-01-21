# theme/ - App Theming

Contains theming and styling configuration for the application.

## 📁 Files

| File | Purpose |
|------|---------|
| `app_theme.dart` | Colors, theme data, styling constants |

## 🎨 Color Palette

### Base Colors

| Color | Hex | Usage |
|-------|-----|-------|
| Background | `#F9FAFB` | Page backgrounds |
| White | `#FFFFFF` | Cards, surfaces |
| Gray 100 | `#F3F4F6` | Light backgrounds |
| Gray 300 | `#D1D5DB` | Borders |
| Gray 400 | `#9CA3AF` | Inactive icons |
| Gray 500 | `#6B7280` | Secondary text |
| Gray 600 | `#4B5563` | Labels |
| Gray 700 | `#374151` | Body text |
| Gray 900 | `#111827` | Primary text |

### Status Colors

| Status | Color | Hex |
|--------|-------|-----|
| 🟢 Excellent/Success | Green | `#22C55E` |
| 🟡 Good/Warning | Yellow | `#EAB308` |
| 🔴 Poor/Error | Red | `#EF4444` |

### Chart Colors

| Factor | Color | Hex |
|--------|-------|-----|
| pH | Blue | `#3B82F6` |
| Temperature | Red | `#EF4444` |
| Turbidity | Amber | `#F59E0B` |
| Dissolved O₂ | Green | `#22C55E` |
| Ammonia | Purple | `#A855F7` |

### Alert Type Colors

| Type | Color | Hex |
|------|-------|-----|
| Water Quality | Blue | `#3B82F6` |
| Fish Health | Orange | `#F97316` |

## 🎯 Design System

```
┌─────────────────────────────────────────┐
│              App Theme                   │
├─────────────────────────────────────────┤
│                                         │
│  Typography                             │
│  ├── Title: 18px, Medium                │
│  ├── Body: 14-16px, Regular             │
│  ├── Caption: 12px, Regular             │
│  └── Button: 16px, Medium               │
│                                         │
│  Spacing                                │
│  ├── XS: 4px                            │
│  ├── SM: 8px                            │
│  ├── MD: 12px                           │
│  ├── LG: 16px                           │
│  └── XL: 24px                           │
│                                         │
│  Border Radius                          │
│  ├── Small: 8px                         │
│  ├── Medium: 12px                       │
│  ├── Large: 16px                        │
│  └── Full: 24px (badges)                │
│                                         │
│  Borders                                │
│  ├── Card: 2px gray300                  │
│  ├── Input: 1px gray300                 │
│  └── Active: 2px blue500                │
│                                         │
└─────────────────────────────────────────┘
```

## 📱 Component Styling

### Cards

```dart
Container(
  decoration: BoxDecoration(
    color: AppTheme.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppTheme.gray300, width: 2),
  ),
)
```

### Status Badge

```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
  decoration: BoxDecoration(
    color: statusColor, // green/yellow/red
    borderRadius: BorderRadius.circular(24),
  ),
)
```

### Bottom Navigation

```dart
BottomNavigationBar(
  backgroundColor: AppTheme.white,
  selectedItemColor: AppTheme.gray900,
  unselectedItemColor: AppTheme.gray400,
)
```
