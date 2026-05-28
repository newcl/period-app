import SwiftUI

struct SettingsView: View {
    @Environment(SettingsViewModel.self) private var viewModel

    var body: some View {
        @Bindable var vm = viewModel

        NavigationStack {
            Form {
                Section {
                    Stepper(
                        "\(viewModel.cycleLengthDays) days",
                        value: $vm.cycleLengthDays,
                        in: 20...45,
                        step: 1
                    )
                } header: {
                    Text("Cycle Length")
                } footer: {
                    Text("Used to predict your next period. Notifications are rescheduled automatically when this changes.")
                }

                Section("Notifications") {
                    Button {
                        viewModel.requestNotificationPermission()
                    } label: {
                        Label("Enable Notifications", systemImage: "bell.badge")
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Period start reminder")
                            .font(.subheadline)
                        Text("3 days before expected start date")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 2)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Period end reminder")
                            .font(.subheadline)
                        Text("5 days after start date")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 2)
                }

                Section("About") {
                    LabeledContent("Version", value: "1.0")
                    LabeledContent("Data stored", value: "On device only")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

// MARK: - Preview

#Preview {
    let ss = SettingsStore()
    let rs = RecordStore()
    let vm = SettingsViewModel(settingsStore: ss, recordStore: rs)
    SettingsView()
        .environment(vm)
}
