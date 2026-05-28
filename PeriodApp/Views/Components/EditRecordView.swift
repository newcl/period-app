import SwiftUI

/// Sheet that lets the user view and edit a single menstrual record.
struct EditRecordView: View {
    @Bindable var record: EditableRecord
    let onSave: (MenstrualRecord) -> Void
    let onDismiss: () -> Void

    @State private var showEndDatePicker = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Period Dates") {
                    DatePicker("Start Date",
                               selection: $record.startDate,
                               displayedComponents: [.date])

                    Toggle("End Date Recorded", isOn: $showEndDatePicker)
                        .onChange(of: showEndDatePicker) { _, newValue in
                            if !newValue { record.endDate = nil }
                            else if record.endDate == nil {
                                record.endDate = Date()
                            }
                        }

                    if showEndDatePicker, let binding = Binding($record.endDate) {
                        DatePicker("End Date",
                                   selection: binding,
                                   in: record.startDate...,
                                   displayedComponents: [.date])
                    }
                }

                if record.originalStatus == .estimated {
                    Section {
                        HStack {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundStyle(.orange)
                            Text("This record was auto-estimated. Enter a real end date to confirm it.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Edit Record")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onDismiss)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(record.toMenstrualRecord())
                        onDismiss()
                    }
                }
            }
            .onAppear {
                showEndDatePicker = record.endDate != nil
            }
        }
    }
}

// MARK: - EditableRecord (bridging @Observable to @Bindable)

/// @Observable wrapper around a MenstrualRecord for form binding.
@Observable
final class EditableRecord {
    var startDate: Date
    var endDate: Date?
    let originalStatus: RecordStatus
    private let originalID: UUID
    private let createdAt: Date

    init(from record: MenstrualRecord) {
        self.originalID     = record.id
        self.startDate      = record.startDate
        self.endDate        = record.endDate
        self.originalStatus = record.status
        self.createdAt      = record.createdAt
    }

    func toMenstrualRecord() -> MenstrualRecord {
        MenstrualRecord(
            id: originalID,
            startDate: startDate,
            endDate: endDate,
            // Status promoted to real if a genuine end date is now set
            status: (endDate != nil && originalStatus == .estimated) ? .real : originalStatus,
            createdAt: createdAt,
            updatedAt: Date()
        )
    }
}

// MARK: - Preview

#Preview {
    EditRecordView(
        record: EditableRecord(from: MenstrualRecord(
            startDate: Calendar.current.date(byAdding: .day, value: -60, to: Date())!,
            endDate: Calendar.current.date(byAdding: .day, value: -53, to: Date()),
            status: .estimated
        )),
        onSave: { _ in },
        onDismiss: {}
    )
}
