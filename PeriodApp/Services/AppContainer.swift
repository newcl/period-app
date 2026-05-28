import Foundation

/// Creates and wires together all stores and view models for the application lifetime.
/// Injected into the SwiftUI environment via PeriodAppApp.
final class AppContainer {
    let recordStore: RecordStore
    let settingsStore: SettingsStore
    let homeViewModel: HomeViewModel
    let historyViewModel: HistoryViewModel
    let statisticsViewModel: StatisticsViewModel
    let settingsViewModel: SettingsViewModel

    init() {
        let rs = RecordStore()
        let ss = SettingsStore()
        self.recordStore        = rs
        self.settingsStore      = ss
        self.homeViewModel      = HomeViewModel(recordStore: rs, settingsStore: ss)
        self.historyViewModel   = HistoryViewModel(recordStore: rs, settingsStore: ss)
        self.statisticsViewModel = StatisticsViewModel(recordStore: rs)
        self.settingsViewModel  = SettingsViewModel(settingsStore: ss, recordStore: rs)
    }
}
