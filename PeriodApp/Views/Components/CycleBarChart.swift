import SwiftUI
import Charts

/// Bar chart visualising period duration and cycle length.
/// Estimated records appear lighter/translucent with a dashed-border legend indicator.
/// Tapping a bar fires onTapEstimated when the selected point is estimated.
struct CycleBarChart: View {
    let dataPoints: [CycleDataPoint]
    /// Called when the user taps/selects a bar for an estimated data point.
    var onTapEstimated: ((CycleDataPoint) -> Void)?

    // Tracks the x-axis label currently selected in the duration chart.
    @State private var selectedDurationLabel: String?
    // Tracks the x-axis label currently selected in the cycle-length chart.
    @State private var selectedCycleLenLabel: String?

    private var durationValues: [(CycleDataPoint, Double)] {
        dataPoints.map { ($0, Double($0.periodDuration)) }
    }

    private var cycleLengthValues: [(CycleDataPoint, Double)] {
        dataPoints.compactMap { p in
            p.cycleLength.map { (p, Double($0)) }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // ── Period duration chart ──
            chartSection(
                title: "Period Duration (days)",
                values: durationValues,
                selectedLabel: $selectedDurationLabel
            )
            .onChange(of: selectedDurationLabel) { _, label in
                fireCallbackIfEstimated(label: label, in: durationValues)
            }

            // ── Cycle length chart ──
            if !cycleLengthValues.isEmpty {
                chartSection(
                    title: "Cycle Length (days)",
                    values: cycleLengthValues,
                    selectedLabel: $selectedCycleLenLabel
                )
                .onChange(of: selectedCycleLenLabel) { _, label in
                    fireCallbackIfEstimated(label: label, in: cycleLengthValues)
                }
            }

            if dataPoints.contains(where: { $0.status == .estimated }) {
                estimatedLegend
            }
        }
    }

    // MARK: - Chart section

    @ViewBuilder
    private func chartSection(
        title: String,
        values: [(CycleDataPoint, Double)],
        selectedLabel: Binding<String?>
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            Chart(values, id: \.0.id) { item in
                let point = item.0
                let value = item.1
                let isEstimated = point.status == .estimated
                let label = "\(point.index)"

                BarMark(
                    x: .value("Cycle", label),
                    y: .value("Days", value)
                )
                // Estimated bars: muted + semi-transparent to stand out from real bars.
                .foregroundStyle(isEstimated ? Color.pink.opacity(0.28) : Color.pink)
                .cornerRadius(4)
                // Overlay dashed stroke on estimated bars for further visual distinction.
                .annotation(position: .overlay, alignment: .bottom) {
                    if isEstimated {
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(
                                Color.pink.opacity(0.6),
                                style: StrokeStyle(lineWidth: 1.5, dash: [4, 3])
                            )
                    }
                }
            }
            .frame(height: 160)
            // iOS 17 chart selection: enables tap/drag selection on the x-axis.
            .chartXSelection(value: selectedLabel)
            .chartXAxis {
                AxisMarks(preset: .automatic)
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
    }

    // MARK: - Legend

    private var estimatedLegend: some View {
        HStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.pink.opacity(0.25))
                    .frame(width: 20, height: 14)
                RoundedRectangle(cornerRadius: 3)
                    .stroke(
                        Color.pink.opacity(0.6),
                        style: StrokeStyle(lineWidth: 1.5, dash: [4, 3])
                    )
                    .frame(width: 20, height: 14)
            }
            Text("Estimated — tap bar to review")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Helpers

    private func fireCallbackIfEstimated(label: String?, in values: [(CycleDataPoint, Double)]) {
        guard let label,
              let match = values.first(where: { "\($0.0.index)" == label }),
              match.0.status == .estimated else { return }
        onTapEstimated?(match.0)
    }
}

// MARK: - Preview

#Preview {
    let calendar = Calendar.current
    let now = Date()
    let points: [CycleDataPoint] = [
        CycleDataPoint(id: UUID(), index: 1,
                       periodDuration: 5, cycleLength: 28,
                       status: .real,
                       startDate: calendar.date(byAdding: .day, value: -84, to: now)!),
        CycleDataPoint(id: UUID(), index: 2,
                       periodDuration: 7, cycleLength: 29,
                       status: .estimated,
                       startDate: calendar.date(byAdding: .day, value: -56, to: now)!),
        CycleDataPoint(id: UUID(), index: 3,
                       periodDuration: 4, cycleLength: 27,
                       status: .real,
                       startDate: calendar.date(byAdding: .day, value: -28, to: now)!),
        CycleDataPoint(id: UUID(), index: 4,
                       periodDuration: 5, cycleLength: nil,
                       status: .real,
                       startDate: now),
    ]

    ScrollView {
        CycleBarChart(dataPoints: points)
            .padding()
    }
}
