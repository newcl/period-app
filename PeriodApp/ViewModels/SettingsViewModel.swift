import Foundation
import Observation

@Observable
final class SettingsViewModel {
    private let settingsStore: SettingsStore
    private let recordStore: RecordStore

    init(settingsStore: SettingsStore, recordStore: RecordStore) {
        self.settingsStore = settingsStore
        self.recordStore   = recordStore
    }

    var cycleLengthDays: Int {
        get { settingsStore.cycleLengthDays }
        set {
            settingsStore.cycleLengthDays = newValue
            reschedule()
        }
    }

    func requestNotificationPermission() {
        Task {
            _ = await NotificationService.shared.requestAuthorization()
        }
    }

    private func reschedule() {
        Task {
            await NotificationService.shared.rescheduleAll(
                records: recordStore.records,
                cycleLengthDays: settingsStore.cycleLengthDays
            )
        }
    }
}
