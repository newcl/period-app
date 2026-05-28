import Foundation
import Observation

/// Data point for the bar chart.
struct CycleDataPoint: Identifiable {
    let id: UUID
    let index: Int           // x-axis label (cycle number from oldest)
    let periodDuration: Int  // days the period lasted
    let cycleLength: Int?    // days from this start to next start (nil for the latest)
    let status: RecordStatus
    let startDate: Date
}

@Observable
final class StatisticsViewModel {
    private let recordStore: RecordStore

    init(recordStore: RecordStore) {
        self.recordStore = recordStore
    }

    /// Data points ordered oldest → newest.
    var dataPoints: [CycleDataPoint] {
        // sortedRecords is newest-first; reverse to oldest-first for chronological chart display.
        let sorted = Array(recordStore.sortedRecords.reversed())
        var result: [CycleDataPoint] = []

        for (i, record) in sorted.enumerated() {
            let duration = record.durationDays ?? 0
            // Cycle length = days between this start and the next start date.
            let cycleLen: Int? = (i + 1 < sorted.count)
                ? Calendar.current.dateComponents(
                    [.day], from: record.startDate, to: sorted[i + 1].startDate).day
                : nil
            result.append(CycleDataPoint(
                id: record.id,
                index: i + 1,
                periodDuration: duration,
                cycleLength: cycleLen,
                status: record.status,
                startDate: record.startDate
            ))
        }
        return result
    }

    var hasData: Bool { !dataPoints.isEmpty }

    var averagePeriodDuration: Double {
        guard !dataPoints.isEmpty else { return 0 }
        let total = dataPoints.reduce(0) { $0 + $1.periodDuration }
        return Double(total) / Double(dataPoints.count)
    }

    var averageCycleLength: Double {
        let pts = dataPoints.compactMap(\.cycleLength)
        guard !pts.isEmpty else { return 0 }
        return Double(pts.reduce(0, +)) / Double(pts.count)
    }
}
