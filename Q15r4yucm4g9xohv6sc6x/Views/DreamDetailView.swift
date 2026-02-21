import SwiftUI
import SwiftData

struct DreamDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var dream: Dream
    @State private var showDeleteConfirmation: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerCard
                if !dream.steps.isEmpty { stepsSection }
                detailsSection
                actionSection
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

    private var headerCard: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(dream.category.color.gradient)
                    .frame(width: 72, height: 72)

                Image(systemName: dream.category.icon)
                    .font(.system(size: 32))
                    .foregroundStyle(.white)
            }

            Label(dream.category.rawValue, systemImage: dream.category.icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(dream.category.color)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(dream.category.color.opacity(0.12), in: .capsule)

            if !dream.dreamDescription.isEmpty {
                Text(dream.dreamDescription)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            if !dream.steps.isEmpty {
                VStack(spacing: 8) {
                    ProgressView(value: dream.progress)
                        .tint(dream.category.color)
                        .scaleEffect(y: 1.5)

                    Text("\(Int(dream.progress * 100))% Complete")
                        .font(.caption.bold())
                        .foregroundStyle(dream.category.color)
                }
                .padding(.top, 4)
            }

            if dream.isCompleted {
                Label("Dream Achieved!", systemImage: "party.popper.fill")
                    .font(.headline)
                    .foregroundStyle(.green)
                    .padding(.top, 4)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 20))
    }

    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Steps")
                .font(.headline)

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
                            .foregroundStyle(step.isCompleted ? .green : .secondary)
                            .contentTransition(.symbolEffect(.replace))

                        Text(step.title)
                            .font(.body)
                            .foregroundStyle(step.isCompleted ? .secondary : .primary)
                            .strikethrough(step.isCompleted)

                        Spacer()
                    }
                    .padding(14)
                    .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 12))
                }
                .sensoryFeedback(.impact(flexibility: .soft), trigger: step.isCompleted)
            }
        }
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.headline)

            VStack(spacing: 0) {
                detailRow(icon: "flag.fill", label: "Priority", value: priorityLabel)
                Divider().padding(.horizontal, 16)
                detailRow(icon: "calendar", label: "Created", value: dream.createdAt.formatted(date: .abbreviated, time: .omitted))

                if let target = dream.targetDate {
                    Divider().padding(.horizontal, 16)
                    detailRow(icon: "target", label: "Target", value: target.formatted(date: .abbreviated, time: .omitted))
                }

                if dream.aiGenerated {
                    Divider().padding(.horizontal, 16)
                    detailRow(icon: "sparkles", label: "Source", value: "AI Suggested")
                }
            }
            .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 16))
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

    private var actionSection: some View {
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
            .background(dream.isCompleted ? Color.orange : Color.green, in: .rect(cornerRadius: 16))
        }
    }
}
