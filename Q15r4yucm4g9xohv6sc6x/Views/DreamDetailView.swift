import SwiftUI
import SwiftData

struct DreamDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [UserProfile]
    @Bindable var dream: Dream
    @State private var showDeleteConfirmation: Bool = false
    @State private var showJournalEditor: Bool = false
    @State private var journalText: String = ""

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection
                insightCard
                if !dream.steps.isEmpty { stepsSection }
                if !dream.tags.isEmpty { tagsSection }
                if dream.journalNotes != nil || showJournalEditor { journalSection }
                detailsSection
                actionButtons
            }
            .padding(16)
        }
        .navigationTitle(dream.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(dream.isCompleted ? "Mark Incomplete" : "Mark Complete", systemImage: dream.isCompleted ? "arrow.uturn.backward" : "checkmark.circle") {
                        withAnimation(.spring) {
                            dream.isCompleted.toggle()
                        }
                    }
                    Button("Add Journal Note", systemImage: "note.text") {
                        journalText = dream.journalNotes ?? ""
                        showJournalEditor = true
                    }
                    Divider()
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        showDeleteConfirmation = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .confirmationDialog("Delete this dream?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                modelContext.delete(dream)
                dismiss()
            }
        }
        .sensoryFeedback(.impact(flexibility: .soft), trigger: dream.isCompleted)
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(dream.category.color.gradient)
                        .frame(width: 56, height: 56)
                    Image(systemName: dream.category.icon)
                        .font(.title3)
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Label(dream.category.rawValue, systemImage: dream.category.icon)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(dream.category.color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(dream.category.color.opacity(0.12), in: .capsule)

                        Label(dream.mood.rawValue, systemImage: dream.mood.icon)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(dream.mood.color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(dream.mood.color.opacity(0.12), in: .capsule)
                    }

                    if dream.isCompleted {
                        Label("Achieved", systemImage: "checkmark.seal.fill")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.green)
                    }
                }

                Spacer()
            }

            if !dream.dreamDescription.isEmpty {
                Text(dream.dreamDescription)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineSpacing(4)
            }

            if !dream.steps.isEmpty && !dream.isCompleted {
                VStack(spacing: 6) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color(.tertiarySystemFill))
                            Capsule()
                                .fill(dream.category.color)
                                .frame(width: geo.size.width * dream.progress)
                                .animation(.spring(duration: 0.4), value: dream.progress)
                        }
                    }
                    .frame(height: 6)

                    HStack {
                        Text("\(dream.steps.filter(\.isCompleted).count) of \(dream.steps.count) steps")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(Int(dream.progress * 100))%")
                            .font(.caption.bold().monospacedDigit())
                            .foregroundStyle(dream.category.color)
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 16))
    }

    private var insightCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.caption)
                Text("AI Insight")
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(.secondary)

            Text(dream.aiInsight ?? DreamEngine.shared.generateInsight(for: dream, profile: profile))
                .font(.subheadline)
                .foregroundStyle(.primary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 16))
    }

    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Steps")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)

            ForEach(Array(dream.steps.enumerated()), id: \.offset) { index, step in
                Button {
                    withAnimation(.spring(duration: 0.3)) {
                        var updatedSteps = dream.steps
                        updatedSteps[index].isCompleted.toggle()
                        dream.steps = updatedSteps

                        if dream.steps.allSatisfy(\.isCompleted) {
                            dream.isCompleted = true
                        }
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: step.isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.title3)
                            .foregroundStyle(step.isCompleted ? Color.green : Color(.tertiaryLabel))
                            .contentTransition(.symbolEffect(.replace))

                        Text(step.title)
                            .font(.body)
                            .foregroundStyle(step.isCompleted ? .secondary : .primary)
                            .strikethrough(step.isCompleted)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(14)
                    .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 12))
                }
                .sensoryFeedback(.impact(flexibility: .soft), trigger: step.isCompleted)
            }
        }
    }

    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tags")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)

            FlowLayout(spacing: 6) {
                ForEach(dream.tags, id: \.name) { tag in
                    Text(tag.name)
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(.tertiarySystemFill), in: .capsule)
                }
            }
        }
    }

    private var journalSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Journal")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                Spacer()
                if !showJournalEditor {
                    Button {
                        journalText = dream.journalNotes ?? ""
                        showJournalEditor = true
                    } label: {
                        Image(systemName: "pencil")
                            .font(.caption)
                    }
                }
            }

            if showJournalEditor {
                VStack(spacing: 10) {
                    TextField("Write your thoughts...", text: $journalText, axis: .vertical)
                        .lineLimit(4...8)
                        .padding(12)
                        .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 12))

                    HStack {
                        Button("Cancel") {
                            showJournalEditor = false
                        }
                        .font(.subheadline)

                        Spacer()

                        Button("Save") {
                            dream.journalNotes = journalText.isEmpty ? nil : journalText
                            showJournalEditor = false
                        }
                        .font(.subheadline.weight(.semibold))
                    }
                }
            } else if let notes = dream.journalNotes {
                Text(notes)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .lineSpacing(4)
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 12))
            }
        }
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Details")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)

            VStack(spacing: 0) {
                detailRow(icon: "flag.fill", label: "Priority", value: priorityLabel)
                Divider().padding(.horizontal, 14)
                detailRow(icon: "circle.fill", label: "Clarity", value: "\(dream.lucidityLevel)/5")
                Divider().padding(.horizontal, 14)
                detailRow(icon: "calendar", label: "Created", value: dream.createdAt.formatted(date: .abbreviated, time: .omitted))

                if let target = dream.targetDate {
                    Divider().padding(.horizontal, 14)
                    detailRow(icon: "target", label: "Target", value: target.formatted(date: .abbreviated, time: .omitted))
                }

                if dream.aiGenerated {
                    Divider().padding(.horizontal, 14)
                    detailRow(icon: "sparkles", label: "Source", value: "AI Suggested")
                }
            }
            .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 14))
        }
    }

    private func detailRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Label(label, systemImage: icon)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.medium))
        }
        .padding(14)
    }

    private var priorityLabel: String {
        switch dream.priority {
        case 1: "Low"
        case 3: "High"
        default: "Medium"
        }
    }

    private var actionButtons: some View {
        Button {
            withAnimation(.spring) {
                dream.isCompleted.toggle()
            }
        } label: {
            Label(
                dream.isCompleted ? "Reopen Dream" : "Mark as Complete",
                systemImage: dream.isCompleted ? "arrow.uturn.backward.circle.fill" : "checkmark.circle.fill"
            )
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(dream.isCompleted ? Color.orange : Color.green, in: .rect(cornerRadius: 14))
        }
    }
}
