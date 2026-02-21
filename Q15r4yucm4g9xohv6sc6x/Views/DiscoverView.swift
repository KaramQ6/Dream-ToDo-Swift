import SwiftUI
import SwiftData

struct DiscoverView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query private var dreams: [Dream]
    @State private var addedTitles: Set<String> = []

    private var profile: UserProfile? { profiles.first }

    private var suggestions: [DreamTemplate] {
        guard let profile else { return [] }
        return DreamEngine.shared.suggestDreams(for: profile, excluding: dreams)
    }

    private var topSuggestions: [DreamTemplate] {
        Array(suggestions.prefix(6))
    }

    private var categorizedSuggestions: [DreamCategory: [DreamTemplate]] {
        Dictionary(grouping: suggestions, by: \.category)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    if !topSuggestions.isEmpty {
                        topPicksSection
                    }
                    categorySections
                }
                .padding(.bottom, 32)
            }
            .navigationTitle("Discover")
        }
    }

    private var topPicksSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .foregroundStyle(.indigo)
                Text("Picked for You")
                    .font(.title3.bold())
            }
            .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(topSuggestions, id: \.title) { template in
                        SuggestionCard(template: template, isAdded: addedTitles.contains(template.title)) {
                            addDream(from: template)
                        }
                    }
                }
            }
            .contentMargins(.horizontal, 16)
        }
    }

    private var categorySections: some View {
        VStack(spacing: 24) {
            ForEach(DreamCategory.allCases, id: \.self) { category in
                if let templates = categorizedSuggestions[category], !templates.isEmpty {
                    categorySection(category: category, templates: Array(templates.prefix(4)))
                }
            }
        }
    }

    private func categorySection(category: DreamCategory, templates: [DreamTemplate]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .foregroundStyle(category.color)
                Text(category.rawValue)
                    .font(.title3.bold())
            }
            .padding(.horizontal, 16)

            VStack(spacing: 10) {
                ForEach(templates, id: \.title) { template in
                    CompactSuggestionRow(template: template, isAdded: addedTitles.contains(template.title)) {
                        addDream(from: template)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func addDream(from template: DreamTemplate) {
        let dream = Dream(
            title: template.title,
            dreamDescription: template.description,
            category: template.category,
            priority: 2,
            steps: template.suggestedSteps.map { DreamStep(title: $0) },
            aiGenerated: true
        )
        modelContext.insert(dream)
        addedTitles.insert(template.title)
    }
}

struct SuggestionCard: View {
    let template: DreamTemplate
    let isAdded: Bool
    let onAdd: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(template.category.color.gradient)
                        .frame(width: 40, height: 40)
                    Image(systemName: template.category.icon)
                        .font(.body)
                        .foregroundStyle(.white)
                }
                Spacer()
                if isAdded {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .transition(.scale.combined(with: .opacity))
                }
            }

            Text(template.title)
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(2)

            Text(template.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(3)

            Spacer()

            HStack {
                Text("\(template.suggestedSteps.count) steps")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Spacer()
                Button {
                    withAnimation(.spring(duration: 0.3)) { onAdd() }
                } label: {
                    Image(systemName: isAdded ? "checkmark" : "plus")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 28)
                        .background(isAdded ? Color.green : Color.indigo, in: Circle())
                }
                .disabled(isAdded)
            }
        }
        .padding(16)
        .frame(width: 200, height: 220)
        .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 20))
    }
}

struct CompactSuggestionRow: View {
    let template: DreamTemplate
    let isAdded: Bool
    let onAdd: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(template.category.color.gradient)
                    .frame(width: 44, height: 44)
                Image(systemName: template.category.icon)
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(template.title)
                    .font(.subheadline.weight(.semibold))
                Text("\(template.suggestedSteps.count) steps")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                withAnimation(.spring(duration: 0.3)) { onAdd() }
            } label: {
                Image(systemName: isAdded ? "checkmark.circle.fill" : "plus.circle.fill")
                    .font(.title3)
                    .foregroundStyle(isAdded ? .green : .indigo)
            }
            .disabled(isAdded)
        }
        .padding(12)
        .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 14))
    }
}
