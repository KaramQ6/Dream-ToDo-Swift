import SwiftUI
import SwiftData

struct AddDreamView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var category: DreamCategory = .personalGrowth
    @State private var mood: DreamMood = .neutral
    @State private var priority: Int = 2
    @State private var steps: [String] = [""]
    @State private var hasTargetDate: Bool = false
    @State private var targetDate: Date = Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()
    @State private var tagInput: String = ""
    @State private var tags: [String] = []
    @State private var lucidityLevel: Int = 1

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Dream title", text: $title)
                        .font(.headline)
                    TextField("Describe your dream...", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Category & Mood") {
                    Picker("Category", selection: $category) {
                        ForEach(DreamCategory.allCases, id: \.self) { cat in
                            Label(cat.rawValue, systemImage: cat.icon)
                                .tag(cat)
                        }
                    }
                    .pickerStyle(.navigationLink)

                    Picker("Mood", selection: $mood) {
                        ForEach(DreamMood.allCases, id: \.self) { m in
                            Label(m.rawValue, systemImage: m.icon)
                                .tag(m)
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

                Section("Clarity Level") {
                    HStack {
                        Text("How clear is this dream?")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        HStack(spacing: 4) {
                            ForEach(1...5, id: \.self) { level in
                                Button {
                                    lucidityLevel = level
                                } label: {
                                    Image(systemName: level <= lucidityLevel ? "circle.fill" : "circle")
                                        .font(.caption)
                                        .foregroundStyle(level <= lucidityLevel ? .primary : .tertiary)
                                }
                            }
                        }
                    }
                }

                Section("Steps") {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, _ in
                        HStack {
                            Image(systemName: "circle")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
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
                    }
                }

                Section("Tags") {
                    HStack {
                        TextField("Add tag", text: $tagInput)
                            .submitLabel(.done)
                            .onSubmit { addTag() }
                        Button { addTag() } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.primary)
                        }
                        .disabled(tagInput.trimmingCharacters(in: .whitespaces).isEmpty)
                    }

                    if !tags.isEmpty {
                        FlowLayout(spacing: 6) {
                            ForEach(tags, id: \.self) { tag in
                                HStack(spacing: 4) {
                                    Text(tag)
                                        .font(.caption)
                                    Button {
                                        tags.removeAll { $0 == tag }
                                    } label: {
                                        Image(systemName: "xmark")
                                            .font(.caption2)
                                    }
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color(.tertiarySystemFill), in: .capsule)
                            }
                        }
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

    private func addTag() {
        let trimmed = tagInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !tags.contains(trimmed) else { return }
        tags.append(trimmed)
        tagInput = ""
    }

    private func saveDream() {
        let dreamSteps = steps
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .map { DreamStep(title: $0) }

        let dreamTags = tags.map { DreamTag(name: $0) }

        let dream = Dream(
            title: title.trimmingCharacters(in: .whitespaces),
            dreamDescription: description.trimmingCharacters(in: .whitespaces),
            category: category,
            mood: mood,
            priority: priority,
            steps: dreamSteps,
            tags: dreamTags,
            targetDate: hasTargetDate ? targetDate : nil,
            lucidityLevel: lucidityLevel
        )
        modelContext.insert(dream)
        dismiss()
    }
}
