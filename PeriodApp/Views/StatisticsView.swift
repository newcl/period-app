import SwiftUI
import Charts

struct StatisticsView: View {
    @Environment(StatisticsViewModel.self) private var viewModel
    @Environment(HistoryViewModel.self) private var historyViewModel

    /// Local state for the edit sheet; independent of HistoryView's sheet state.
    @State private var editingRecord: MenstrualRecord?

    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.hasData {
                    VStack(alignment: .leading, spacing: 24) {
                        summaryCards
                        Divider()
                        CycleBarChart(
                            dataPoints: viewModel.dataPoints,
                            onTapEstimated: { point in
                                editingRecord = findRecord(id: point.id)
                            }
                        )
                        .padding(.horizontal)

                        estimatedRecordsSection
                    }
                    .padding(.vertical)
                } else {
                    ContentUnavailableView(
                        "No Data Yet",
                        systemImage: "chart.bar.xaxis",
                        description: Text("Complete at least one cycle to see your statistics.")
                    )
                    .frame(maxWidth: .infinity, minHeight: 300)
                }
            }
            .navigationTitle("Statistics")
            .sheet(item: $editingRecord) { record in
                EditRecordView(
                    record: EditableRecord(from: record),
                    onSave: { updated in historyViewModel.saveRecord(updated) },
                    onDismiss: { editingRecord = nil }
                )
            }
        }
    }

    // MARK: - Summary cards

    private var summaryCards: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            StatCard(
                title: "Avg Period",
                value: viewModel.averagePeriodDuration > 0
                    ? String(format: "%.1f days", viewModel.averagePeriodDuration)
                    : "–",
                icon: "drop.fill",
                color: .pink
            )
            StatCard(
                title: "Avg Cycle",
                value: viewModel.averageCycleLength > 0
                    ? String(format: "%.1f days", viewModel.averageCycleLength)
                    : "–",
                icon: "arrow.clockwise",
                color: .purple
            )
        }
        .padding(.horizontal)
    }

    // MARK: - Estimated records needing attention

    @ViewBuilder
    private var estimatedRecordsSection: some View {
        let estimated = viewModel.dataPoints.filter { $0.status == .estimated }
        if !estimated.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Needs Attention")
                    .font(.headline)
                    .padding(.horizontal)
                ForEach(estimated) { point in
                    if let record = findRecord(id: point.id) {
                        Button {
                            editingRecord = record
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(point.startDate, style: .date)
                                        .font(.subheadline.weight(.medium))
                                    Text("Estimated end date — tap to fix")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "pencil.circle.fill")
                                    .foregroundStyle(.orange)
                            }
                            .foregroundStyle(.primary)
                            .padding()
                            .background(Color.orange.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func findRecord(id: UUID) -> MenstrualRecord? {
        historyViewModel.sortedRecords.first { $0.id == id }
    }
}

// MARK: - StatCard

private struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            Text(value)
                .font(.title2.monospacedDigit().bold())
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Preview

#Preview {
    let rs = RecordStore()
    let ss = SettingsStore()
    let vm  = StatisticsViewModel(recordStore: rs)
    let hvm = HistoryViewModel(recordStore: rs, settingsStore: ss)
    StatisticsView()
        .environment(vm)
        .environment(hvm)
}
