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

    private var patterns: [PatternInsight] {
        DreamEngine.shared.analyzeDreamPatterns(dreams: dreams)
    }

    private var categorizedSuggestions: [DreamCategory: [DreamTemplate]] {
        Dictionary(grouping: suggestions, by: \.category)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    if !dreams.isEmpty {
                        patternsSection
                    }

                    if !topSuggestions.isEmpty {
                        topPicksSection
                    }

                    categorySections
                }
                .padding(.bottom, 32)
            }
            .navigationTitle("Insights")
        }
    }

    private var patternsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                Image(systemName: "brain.head.profile.fill")
                    .font(.subheadline)
                Text("Dream Patterns")
                    .font(.title3.bold())
            }
            .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(patterns.enumerated()), id: \.offset) { _, pattern in
                        PatternCard(pattern: pattern)
                    }
                }
            }
            .contentMargins(.horizontal, 16)
        }
    }

    private var topPicksSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.subheadline)
                Text("For You")
                    .font(.title3.bold())
            }
            .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(topSuggestions, id: \.title) { template in
                        InsightSuggestionCard(template: template, isAdded: addedTitles.contains(template.title)) {
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

            VStack(spacing: 8) {
                ForEach(templates, id: \.title) { template in
                    InsightCompactRow(template: template, isAdded: addedTitles.contains(template.title)) {
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
            mood: template.mood,
            priority: 2,
            steps: template.suggestedSteps.map { DreamStep(title: $0) },
            aiGenerated: true,
            aiInsight: template.insight
        )
        modelContext.insert(dream)
        addedTitles.insert(template.title)
    }
}

struct PatternCard: View {
    let pattern: PatternInsight

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: pattern.icon)
                .font(.title3)
                .foregroundStyle(pattern.color)
                .padding(8)
                .background(pattern.color.opacity(0.12), in: .rect(cornerRadius: 10))

            Text(pattern.title)
                .font(.subheadline.weight(.semibold))

            Text(pattern.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(4)
        }
        .padding(14)
        .frame(width: 200, alignment: .leading)
        .frame(minHeight: 160)
        .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 16))
    }
}

struct InsightSuggestionCard: View {
    let template: DreamTemplate
    let isAdded: Bool
    let onAdd: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: template.category.icon)
                    .font(.caption)
                    .foregroundStyle(template.category.color)
                    .padding(6)
                    .background(template.category.color.opacity(0.12), in: Circle())

                Spacer()

                if isAdded {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                        .transition(.scale.combined(with: .opacity))
                }
            }

            Text(template.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(2)

            Text(template.insight)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(3)

            Spacer(minLength: 0)

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
                        .foregroundStyle(isAdded ? .green : .primary)
                        .frame(width: 28, height: 28)
                        .background(isAdded ? Color.green.opacity(0.15) : Color(.tertiarySystemFill), in: Circle())
                }
                .disabled(isAdded)
            }
        }
        .padding(14)
        .frame(width: 200, height: 210)
        .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 16))
    }
}

struct InsightCompactRow: View {
    let template: DreamTemplate
    let isAdded: Bool
    let onAdd: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(template.category.color.gradient)
                    .frame(width: 42, height: 42)
                Image(systemName: template.category.icon)
                    .font(.subheadline)
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
                    .foregroundStyle(isAdded ? .green : .primary)
            }
            .disabled(isAdded)
        }
        .padding(12)
        .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 14))
    }
}
