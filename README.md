# Period App

A minimalist menstrual cycle tracking app built with SwiftUI for iOS 17+.

---

## Features

### 🔴 One-Tap Recording
Tap the large circular button on the Home screen to instantly record your period start. The button updates in real time to reflect whether you have an active period or are waiting for the next cycle.

### 🔔 Smart Notifications
- **Period start reminder** — scheduled 3 days before your predicted next period ("Has your period started?").
- **Period end reminder** — scheduled 5 days after each recorded start date ("Has your period stopped?").
- Notifications are rescheduled automatically whenever you add, edit, or delete a record, or change your cycle-length setting.

### 📋 Auto-Estimated End Dates
If you ignore the end reminder, the app automatically converts open records to **estimated** status at day 8 (end date = start + 7 days). This reconciliation runs on every app launch and every time the app returns to the foreground, because iOS cannot guarantee background execution at a precise moment.

### 🗂 History & Backfill
The History tab lists all records, clearly labelling estimated ones. Tap any row to open an editor where you can correct dates. Saving a real end date for an estimated record automatically upgrades its status to **real**.

### 📊 Statistics & Chart
A bar chart shows period duration and cycle length for each recorded cycle. Real data is rendered in solid pink; estimated bars use a semi-transparent fill with a dashed border so you can instantly spot records that need correction. Tap an estimated bar (or the "Needs Attention" list below the chart) to open the editor inline.

### ⚙️ Settings
Adjust your cycle length (20–45 days, default 28) and enable local notifications from the Settings tab.

---

## Architecture

| Layer | Pattern |
|-------|---------|
| State management | `@Observable` macro (Swift 5.9+) — no `ObservableObject` or `@Published` |
| Architecture | MVVM — views are declarative; all business logic lives in ViewModels/Stores |
| Dependency injection | `AppContainer` wires stores and view models; injected via SwiftUI `.environment()` |
| Persistence | JSON files in the app's Documents directory via generic `PersistenceService<T>` |
| Notifications | `UNUserNotificationCenter` — local only, no server required |
| Charts | Native `Charts` framework (iOS 16+) |

### Key files

```
PeriodApp/
├── Models/
│   ├── MenstrualRecord.swift     # Data model + RecordStatus enum (real/estimated)
│   └── UserSettings.swift        # Cycle length setting
├── Services/
│   ├── AppContainer.swift        # Dependency-injection container
│   ├── NotificationService.swift # Centralised notification scheduling
│   └── PersistenceService.swift  # Generic JSON persistence
├── Stores/
│   ├── RecordStore.swift         # CRUD + day-8 reconciliation logic
│   └── SettingsStore.swift       # Persisted user settings
├── ViewModels/
│   ├── HomeViewModel.swift
│   ├── HistoryViewModel.swift
│   ├── StatisticsViewModel.swift
│   └── SettingsViewModel.swift
└── Views/
    ├── HomeView.swift
    ├── HistoryView.swift
    ├── StatisticsView.swift
    ├── SettingsView.swift
    └── Components/
        ├── MainCircleButton.swift
        ├── RecordRowView.swift
        ├── EditRecordView.swift   # Backfill / edit sheet
        └── CycleBarChart.swift   # Bar chart with real vs estimated styling
```

---

## Requirements

- **Xcode 15+**
- **iOS 17+** deployment target
- **Swift 5.10+**

No external dependencies — the app uses only Apple frameworks (SwiftUI, Charts, UserNotifications).

---

## Getting Started

1. Clone the repository.
2. Open `PeriodApp.xcodeproj` in Xcode.
3. Select your target device or simulator (iOS 17+).
4. Build and run (`⌘R`).

On first launch the app will request notification permission. You can also grant it later via **Settings → Notifications → Enable Notifications**.

---

## Data & Privacy

All data is stored locally on device using JSON files in the app's sandboxed Documents directory. No data is ever sent to any server or third party.

