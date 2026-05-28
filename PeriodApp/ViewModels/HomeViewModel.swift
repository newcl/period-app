import Foundation
import Observation

// MARK: - HomeState

enum HomeState {
    case noPeriod
    case periodInProgress(record: MenstrualRecord)
    /// Waiting for the next cycle; predicted start date may be nil if no records exist yet.
    case waitingForNextCycle(lastRecord: MenstrualRecord, nextPredicted: Date?)
}

// MARK: - HomeViewModel

// Note: All mutations happen from SwiftUI views, which run on the main thread.
@Observable
final class HomeViewModel {
    private let recordStore: RecordStore
    private let settingsStore: SettingsStore

    init(recordStore: RecordStore, settingsStore: SettingsStore) {
        self.recordStore  = recordStore
        self.settingsStore = settingsStore
    }

    // MARK: - Derived state

    var homeState: HomeState {
        if let active = recordStore.activeRecord {
            return .periodInProgress(record: active)
        }
        if let last = recordStore.mostRecentRecord {
            return .waitingForNextCycle(lastRecord: last, nextPredicted: nextPredictedDate)
        }
        return .noPeriod
    }

    var nextPredictedDate: Date? {
        guard let last = recordStore.mostRecentRecord else { return nil }
        return Calendar.current.date(
            byAdding: .day,
            value: settingsStore.cycleLengthDays,
            to: last.startDate
        )
    }

    var daysUntilNext: Int? {
        guard let next = nextPredictedDate else { return nil }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: next).day ?? 0
        return max(0, days)
    }

    // MARK: - Actions

    func startPeriod() {
        recordStore.startPeriod()
        reschedule()
    }

    func endActivePeriod() {
        recordStore.endActivePeriod()
        reschedule()
    }

    // MARK: - Private

    private func reschedule() {
        Task {
            await NotificationService.shared.rescheduleAll(
                records: recordStore.records,
                cycleLengthDays: settingsStore.cycleLengthDays
            )
        }
    }
}
