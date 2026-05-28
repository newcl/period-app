import Foundation

// MARK: - RecordStatus

/// Indicates whether the period end date was confirmed by the user (real)
/// or automatically estimated by the system (estimated).
enum RecordStatus: String, Codable, CaseIterable {
    case real
    case estimated
}

// MARK: - MenstrualRecord

/// A single menstrual cycle record persisted to disk.
struct MenstrualRecord: Identifiable, Codable, Equatable {
    var id: UUID
    var startDate: Date
    /// nil while the period is still in progress
    var endDate: Date?
    var status: RecordStatus
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        startDate: Date,
        endDate: Date? = nil,
        status: RecordStatus = .real,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// Duration in whole days; nil when the period has no recorded end date.
    var durationDays: Int? {
        guard let endDate else { return nil }
        return Calendar.current.dateComponents([.day], from: startDate, to: endDate).day
    }

    var isActive: Bool { endDate == nil }
}
