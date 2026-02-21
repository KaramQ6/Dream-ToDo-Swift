import SwiftUI
import SwiftData

struct AddDreamView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var category: DreamCategory = .personalGrowth
    @State private var priority: Int = 2
    @State private var steps: [String] = [""]
    @State private var hasTargetDate: Bool = false
    @State private var targetDate: Date = Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Dream title", text: $title)
                        .font(.headline)
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Category") {
                    Picker("Category", selection: $category) {
                        ForEach(DreamCategory.allCases, id: \.self) { cat in
                            Label(cat.rawValue, systemImage: cat.icon)
                                .tag(cat)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }

                Section("Priority") {
                    Picker("Priority", selection: $priority) {
                        Text("Low").tag(1)
                        Text("Medium").tag(2)
                        Text("High").tag(3)
                    }
                    .pickerStyle(.segmented)
                }

                Section("Steps") {
                    ForEach(steps.indices, id: \.self) { index in
                        HStack {
                            Image(systemName: "circle")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            TextField("Step \(index + 1)", text: $steps[index])
                        }
                    }
                    .onDelete { offsets in
                        steps.remove(atOffsets: offsets)
                        if steps.isEmpty { steps.append("") }
                    }

                    Button {
                        steps.append("")
                    } label: {
                        Label("Add Step", systemImage: "plus.circle.fill")
                            .foregroundStyle(.indigo)
                    }
                }

                Section("Target Date") {
                    Toggle("Set a target date", isOn: $hasTargetDate)
                    if hasTargetDate {
                        DatePicker("Date", selection: $targetDate, in: Date()..., displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("New Dream")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveDream() }
                        .fontWeight(.semibold)
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func saveDream() {
        let dreamSteps = steps
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .map { DreamStep(title: $0) }

        let dream = Dream(
            title: title.trimmingCharacters(in: .whitespaces),
            dreamDescription: description.trimmingCharacters(in: .whitespaces),
            category: category,
            priority: priority,
            steps: dreamSteps,
            targetDate: hasTargetDate ? targetDate : nil
        )
        modelContext.insert(dream)
        dismiss()
    }
}
