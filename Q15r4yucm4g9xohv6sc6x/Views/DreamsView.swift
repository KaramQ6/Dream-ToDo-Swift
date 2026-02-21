import SwiftUI
import SwiftData

struct DreamsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Dream.createdAt, order: .reverse) private var dreams: [Dream]
    @State private var searchText: String = ""
    @State private var selectedCategory: DreamCategory? = nil
    @State private var showingAddDream: Bool = false

    private var filteredDreams: [Dream] {
        dreams.filter { dream in
            let matchesSearch = searchText.isEmpty || dream.title.localizedStandardContains(searchText)
            let matchesCategory = selectedCategory == nil || dream.categoryRaw == selectedCategory?.rawValue
            return matchesSearch && matchesCategory
        }
    }

    private var activeDreams: [Dream] { filteredDreams.filter { !$0.isCompleted } }
    private var completedDreams: [Dream] { filteredDreams.filter(\.isCompleted) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    categoryFilter
                        .padding(.bottom, 16)

                    if dreams.isEmpty {
                        emptyState
                    } else if filteredDreams.isEmpty {
                        ContentUnavailableView.search(text: searchText)
                            .padding(.top, 60)
                    } else {
                        dreamSections
                    }
                }
            }
            .navigationTitle("My Dreams")
            .searchable(text: $searchText, prompt: "Search dreams...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingAddDream = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.indigo)
                    }
                }
            }
            .sheet(isPresented: $showingAddDream) {
                AddDreamView()
            }
            .navigationDestination(for: Dream.self) { dream in
                DreamDetailView(dream: dream)
            }
        }
    }

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(title: "All", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }

                ForEach(DreamCategory.allCases, id: \.self) { category in
                    FilterChip(
                        title: category.rawValue,
                        icon: category.icon,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = selectedCategory == category ? nil : category
                    }
                }
            }
        }
        .contentMargins(.horizontal, 16)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "star.leadinghalf.filled")
                .font(.system(size: 56))
                .foregroundStyle(.indigo.opacity(0.5))

            Text("No Dreams Yet")
                .font(.title2.bold())

            Text("Start by adding a dream or check out\npersonalized suggestions in Discover.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                showingAddDream = true
            } label: {
                Label("Add Your First Dream", systemImage: "plus")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(.indigo)
            .padding(.top, 8)
        }
        .padding(.top, 80)
    }

    private var dreamSections: some View {
        VStack(spacing: 24) {
            if !activeDreams.isEmpty {
                dreamSection(title: "In Progress", dreams: activeDreams, icon: "flame.fill")
            }
            if !completedDreams.isEmpty {
                dreamSection(title: "Completed", dreams: completedDreams, icon: "checkmark.seal.fill")
            }
        }
        .padding(.horizontal, 16)
    }

    private func dreamSection(title: String, dreams: [Dream], icon: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Text("(\(dreams.count))")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
            }

            ForEach(dreams) { dream in
                NavigationLink(value: dream) {
                    DreamCard(dream: dream)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct DreamCard: View {
    let dream: Dream

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(dream.category.rawValue, systemImage: dream.category.icon)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(dream.category.color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(dream.category.color.opacity(0.12), in: .capsule)

                Spacer()

                if dream.priority == 3 {
                    Image(systemName: "flame.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }

                if dream.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }

            Text(dream.title)
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(2)

            if !dream.dreamDescription.isEmpty {
                Text(dream.dreamDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            if !dream.steps.isEmpty && !dream.isCompleted {
                VStack(spacing: 6) {
                    ProgressView(value: dream.progress)
                        .tint(dream.category.color)

                    HStack {
                        Text("\(dream.steps.filter(\.isCompleted).count)/\(dream.steps.count) steps")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(Int(dream.progress * 100))%")
                            .font(.caption.bold())
                            .foregroundStyle(dream.category.color)
                    }
                }
            }

            if let targetDate = dream.targetDate {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption2)
                    Text(targetDate, format: .dateTime.month().day().year())
                        .font(.caption)
                }
                .foregroundStyle(.tertiary)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 16))
    }
}

struct FilterChip: View {
    let title: String
    var icon: String? = nil
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon {
                    Image(systemName: icon)
                        .font(.caption2)
                }
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.indigo : Color(.tertiarySystemBackground), in: .capsule)
            .foregroundStyle(isSelected ? .white : .primary)
        }
    }
}
