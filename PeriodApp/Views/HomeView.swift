import SwiftUI

struct HomeView: View {
    @Environment(HomeViewModel.self) private var viewModel
    @State private var showEndConfirmation = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Soft background
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 32) {
                    Spacer()

                    // ── Main button ──
                    mainButton

                    // ── Status info ──
                    statusInfoView

                    Spacer()

                    // ── End period button (only shown when active) ──
                    if case .periodInProgress(let record) = viewModel.homeState {
                        endPeriodButton(record: record)
                    }
                }
                .padding()
            }
            .navigationTitle("Period Tracker")
            .navigationBarTitleDisplayMode(.large)
            .confirmationDialog(
                "End Period",
                isPresented: $showEndConfirmation,
                titleVisibility: .visible
            ) {
                Button("Yes, record today as end date", role: .none) {
                    withAnimation {
                        viewModel.endActivePeriod()
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Confirm that your period has ended today.")
            }
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private var mainButton: some View {
        switch viewModel.homeState {
        case .noPeriod:
            MainCircleButton(state: .noPeriod) {
                withAnimation { viewModel.startPeriod() }
            }
        case .periodInProgress:
            MainCircleButton(state: .periodInProgress, action: {})
                .allowsHitTesting(false)
        case .waitingForNextCycle:
            MainCircleButton(state: .waitingForNextCycle, action: {})
                .allowsHitTesting(false)
        }
    }

    @ViewBuilder
    private var statusInfoView: some View {
        switch viewModel.homeState {
        case .noPeriod:
            Text("Tap to record the start of your period.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

        case .periodInProgress(let record):
            VStack(spacing: 4) {
                Text("Started \(record.startDate, style: .date)")
                    .font(.headline)
                let days = Calendar.current.dateComponents(
                    [.day], from: record.startDate, to: Date()).day ?? 0
                Text("Day \(days + 1)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

        case .waitingForNextCycle(_, let nextDate):
            VStack(spacing: 4) {
                if let next = nextDate {
                    Text("Next period expected")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(next, style: .date)
                        .font(.headline)
                    if let daysLeft = viewModel.daysUntilNext {
                        Text(daysLeft == 0 ? "Today" : "in \(daysLeft) days")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text("Record more cycles to see predictions.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func endPeriodButton(record: MenstrualRecord) -> some View {
        Button {
            showEndConfirmation = true
        } label: {
            Label("End Period", systemImage: "stop.circle.fill")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .foregroundStyle(.pink)
                .font(.headline)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .sensoryFeedback(.warning, trigger: showEndConfirmation)
    }
}

// MARK: - Preview

#Preview {
    let rs = RecordStore()
    let ss = SettingsStore()
    let vm = HomeViewModel(recordStore: rs, settingsStore: ss)
    HomeView()
        .environment(vm)
}
