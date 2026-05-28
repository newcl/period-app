import SwiftUI

/// A single row in the history list displaying one menstrual record.
struct RecordRowView: View {
    let record: MenstrualRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(record.startDate, style: .date)
                        .font(.headline)
                    if let endDate = record.endDate {
                        Text("Ended \(endDate, style: .date)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("In progress…")
                            .font(.subheadline)
                            .foregroundStyle(.pink)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    if let days = record.durationDays {
                        Text("\(days)d")
                            .font(.title2.monospacedDigit().bold())
                            .foregroundStyle(record.status == .real ? .pink : .secondary)
                    } else {
                        Text("–")
                            .font(.title2.bold())
                            .foregroundStyle(.secondary)
                    }
                    Text(record.status == .real ? "Confirmed" : "Estimated")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            record.status == .real
                                ? Color.pink.opacity(0.15)
                                : Color.secondary.opacity(0.15),
                            in: Capsule()
                        )
                        .foregroundStyle(record.status == .real ? .pink : .secondary)
                }
            }

            if record.status == .estimated {
                Label("Tap to backfill real end date", systemImage: "pencil.circle")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
        .padding(.vertical, 4)
        .opacity(record.status == .estimated ? 0.8 : 1.0)
    }
}

// MARK: - Preview

#Preview {
    List {
        RecordRowView(record: MenstrualRecord(
            startDate: Calendar.current.date(byAdding: .day, value: -30, to: Date())!,
            endDate: Calendar.current.date(byAdding: .day, value: -25, to: Date()),
            status: .real
        ))
        RecordRowView(record: MenstrualRecord(
            startDate: Calendar.current.date(byAdding: .day, value: -60, to: Date())!,
            endDate: Calendar.current.date(byAdding: .day, value: -53, to: Date()),
            status: .estimated
        ))
        RecordRowView(record: MenstrualRecord(
            startDate: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
            endDate: nil,
            status: .real
        ))
    }
}
