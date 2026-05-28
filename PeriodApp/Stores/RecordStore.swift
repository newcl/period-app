import Foundation
import Observation

/// Central store for all menstrual records.
/// All mutations are assumed to happen on the main thread (SwiftUI actions).
@Observable
final class RecordStore {
    private(set) var records: [MenstrualRecord] = []

    private let persistence = PersistenceService<[MenstrualRecord]>(filename: "records.json")

    init() {
        records = persistence.load() ?? []
        runReconciliation()
    }

    // MARK: - Public API

    /// Start a new period. Pass a custom date for historical backfill.
    func startPeriod(date: Date = Date()) {
        // Prevent duplicate active records
        guard activeRecord == nil else { return }
        records.append(MenstrualRecord(startDate: date))
        save()
    }

    /// End the currently active period.
    func endActivePeriod(endDate: Date = Date()) {
        guard let idx = records.firstIndex(where: \.isActive) else { return }
        records[idx].endDate = endDate
        records[idx].status = .real
        records[idx].updatedAt = Date()
        save()
    }

    /// Update an existing record (e.g. backfilling a real end date).
    func updateRecord(_ record: MenstrualRecord) {
        guard let idx = records.firstIndex(where: { $0.id == record.id }) else { return }
        var updated = record
        updated.updatedAt = Date()
        // Promote estimated → real when a genuine end date is supplied.
        if updated.endDate != nil && updated.status == .estimated {
            updated.status = .real
        }
        records[idx] = updated
        save()
    }

    func deleteRecord(id: UUID) {
        records.removeAll { $0.id == id }
        save()
    }

    // MARK: - Reconciliation

    /// Converts overdue open records into estimated records.
    /// Must be called on app launch and when the app returns to the foreground,
    /// because iOS cannot guarantee background execution at a precise time.
    func runReconciliation() {
        let now = Date()
        let calendar = Calendar.current
        var changed = false

        for i in records.indices where records[i].isActive {
            let days = calendar.dateComponents([.day], from: records[i].startDate, to: now).day ?? 0
            // At or after day 8, auto-close with estimated end = startDate + 7 days.
            if days >= 8 {
                records[i].endDate = calendar.date(byAdding: .day, value: 7,
                                                    to: records[i].startDate)
                records[i].status    = .estimated
                records[i].updatedAt = now
                changed = true
            }
        }

        if changed { save() }
    }

    // MARK: - Computed helpers

    var activeRecord: MenstrualRecord? {
        records.first { $0.isActive }
    }

    /// All records sorted newest-first.
    var sortedRecords: [MenstrualRecord] {
        records.sorted { $0.startDate > $1.startDate }
    }

    var mostRecentRecord: MenstrualRecord? {
        sortedRecords.first
    }

    // MARK: - Private

    private func save() {
        persistence.save(records)
    }
}
