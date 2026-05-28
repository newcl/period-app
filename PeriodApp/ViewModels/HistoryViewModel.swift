import Foundation
import Observation

@Observable
final class HistoryViewModel {
    private let recordStore: RecordStore
    private let settingsStore: SettingsStore

    /// The record currently open in the edit sheet.
    var editingRecord: MenstrualRecord?

    init(recordStore: RecordStore, settingsStore: SettingsStore) {
        self.recordStore  = recordStore
        self.settingsStore = settingsStore
    }

    var sortedRecords: [MenstrualRecord] {
        recordStore.sortedRecords
    }

    func saveRecord(_ record: MenstrualRecord) {
        recordStore.updateRecord(record)
        reschedule()
    }

    func deleteRecord(id: UUID) {
        recordStore.deleteRecord(id: id)
        reschedule()
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
