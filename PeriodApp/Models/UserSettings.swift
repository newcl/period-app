import Foundation

struct UserSettings: Codable, Equatable {
    /// User-configured menstrual cycle length in days (default 28).
    var cycleLengthDays: Int = 28
}
