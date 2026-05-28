import SwiftUI

struct HistoryView: View {
    @Environment(HistoryViewModel.self) private var viewModel

    var body: some View {
        @Bindable var vm = viewModel

        NavigationStack {
            Group {
                if viewModel.sortedRecords.isEmpty {
                    ContentUnavailableView(
                        "No Records",
                        systemImage: "calendar.badge.clock",
                        description: Text("Start tracking your period from the Home tab.")
                    )
                } else {
                    List {
                        ForEach(viewModel.sortedRecords) { record in
                            Button {
                                viewModel.editingRecord = record
                            } label: {
                                RecordRowView(record: record)
                            }
                            .buttonStyle(.plain)
                        }
                        .onDelete { indexSet in
                            for i in indexSet {
                                let id = viewModel.sortedRecords[i].id
                                viewModel.deleteRecord(id: id)
                            }
                        }
                    }
                }
            }
            .navigationTitle("History")
            .sheet(item: $vm.editingRecord) { record in
                EditRecordView(
                    record: EditableRecord(from: record),
                    onSave: { updated in viewModel.saveRecord(updated) },
                    onDismiss: { viewModel.editingRecord = nil }
                )
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let rs = RecordStore()
    let ss = SettingsStore()
    let vm = HistoryViewModel(recordStore: rs, settingsStore: ss)
    HistoryView()
        .environment(vm)
}
