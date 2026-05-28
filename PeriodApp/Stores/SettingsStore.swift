import Foundation
import Observation

@Observable
final class SettingsStore {
    var cycleLengthDays: Int = 28 {
        didSet { save() }
    }

    private let persistence = PersistenceService<UserSettings>(filename: "settings.json")

    init() {
        let loaded = persistence.load() ?? UserSettings()
        cycleLengthDays = loaded.cycleLengthDays
    }

    private func save() {
        persistence.save(UserSettings(cycleLengthDays: cycleLengthDays))
    }
}
