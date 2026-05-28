import SwiftUI
import UserNotifications

@main
struct PeriodAppApp: App {
    @State private var container = AppContainer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(container.recordStore)
                .environment(container.settingsStore)
                .environment(container.homeViewModel)
                .environment(container.historyViewModel)
                .environment(container.statisticsViewModel)
                .environment(container.settingsViewModel)
                .task {
                    // Request notification permission on first launch (non-blocking).
                    _ = await NotificationService.shared.requestAuthorization()
                    // Schedule notifications for any existing records.
                    await NotificationService.shared.rescheduleAll(
                        records: container.recordStore.records,
                        cycleLengthDays: container.settingsStore.cycleLengthDays
                    )
                }
                .onReceive(
                    NotificationCenter.default.publisher(
                        for: UIApplication.willEnterForegroundNotification
                    )
                ) { _ in
                    // Run reconciliation and reschedule whenever app becomes active.
                    container.recordStore.runReconciliation()
                    Task {
                        await NotificationService.shared.rescheduleAll(
                            records: container.recordStore.records,
                            cycleLengthDays: container.settingsStore.cycleLengthDays
                        )
                    }
                }
        }
    }
}
