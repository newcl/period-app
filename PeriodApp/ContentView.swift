import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "list.bullet.clipboard")
                }
            StatisticsView()
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar.fill")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(.pink)
    }
}

#Preview {
    let container = AppContainer()
    ContentView()
        .environment(container.recordStore)
        .environment(container.settingsStore)
        .environment(container.homeViewModel)
        .environment(container.historyViewModel)
        .environment(container.statisticsViewModel)
        .environment(container.settingsViewModel)
}
