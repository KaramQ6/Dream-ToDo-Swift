import SwiftUI
import SwiftData

struct DreamsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Dream.createdAt, order: .reverse) private var dreams: [Dream]
    @State private var searchText: String = ""
    @State private var selectedCategory: DreamCategory? = nil
    @State private var showingAddDream: Bool = false
    @State private var viewMode: ViewMode = .grid

    nonisolated enum ViewMode: String {
        case list, grid
    }

    private var filteredDreams: [Dream] {
        dreams.filter { dream in
            let matchesSearch = searchText.isEmpty || dream.title.localizedStandardContains(searchText) || dream.dreamDescription.localizedStandardContains(searchText)
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
                    if !dreams.isEmpty {
                        summaryHeader
                            .padding(.bottom, 16)
                    }

                    categoryFilter
                        .padding(.bottom, 20)

                    if dreams.isEmpty {
                        emptyState
                    } else if filteredDreams.isEmpty {
                        ContentUnavailableView.search(text: searchText)
                            .padding(.top, 60)
                    } else {
                        dreamContent
                    }
                }
            }
            .navigationTitle("Notebook")
            .searchable(text: $searchText, prompt: "Search dreams...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        Button {
                            withAnimation(.spring(duration: 0.3)) {
                                viewMode = viewMode == .grid ? .list : .grid
                            }
                        } label: {
                            Image(systemName: viewMode == .grid ? "list.bullet" : "square.grid.2x2")
                                .contentTransition(.symbolEffect(.replace))
                        }

                        Button { showingAddDream = true } label: {
                            Image(systemName: "plus")
                                .fontWeight(.semibold)
                        }
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

    private var summaryHeader: some View {
        HStack(spacing: 0) {
            SummaryPill(
                value: "\(dreams.count)",
                label: "Total",
                icon: "book.fill"
            )
            SummaryPill(
                value: "\(activeDreams.count)",
                label: "Active",
                icon: "flame.fill"
            )
            SummaryPill(
                value: "\(completedDreams.count)",
                label: "Done",
                icon: "checkmark.circle.fill"
            )
            SummaryPill(
                value: "\(Int(averageProgress * 100))%",
                label: "Progress",
                icon: "chart.bar.fill"
            )
        }
        .padding(.horizontal, 16)
    }

    private var averageProgress: Double {
        let active = dreams.filter { !$0.isCompleted }
        guard !active.isEmpty else { return dreams.isEmpty ? 0 : 1 }
        return active.map(\.progress).reduce(0, +) / Double(active.count)
    }

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                NotebookFilterChip(title: "All", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }

                ForEach(DreamCategory.allCases, id: \.self) { category in
                    NotebookFilterChip(
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
        VStack(spacing: 20) {
            Image(systemName: "book.closed")
                .font(.system(size: 56))
                .foregroundStyle(.quaternary)

            VStack(spacing: 8) {
                Text("Your notebook is empty")
                    .font(.title3.bold())

                Text("Start by adding a dream or explore\npersonalized suggestions in Insights.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                showingAddDream = true
            } label: {
                Label("Add First Dream", systemImage: "plus")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(.primary)
            .padding(.top, 4)
        }
        .padding(.top, 80)
    }

    private var dreamContent: some View {
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
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                Spacer()
                Text("\(dreams.count)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color(.tertiarySystemFill), in: .capsule)
            }

            if viewMode == .grid {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(dreams) { dream in
                        NavigationLink(value: dream) {
                            NotebookGridCard(dream: dream)
                        }
                        .buttonStyle(.plain)
                    }
                }
            } else {
                ForEach(dreams) { dream in
                    NavigationLink(value: dream) {
                        NotebookListCard(dream: dream)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct SummaryPill: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3.bold().monospacedDigit())
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct NotebookGridCard: View {
    let dream: Dream

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: dream.category.icon)
                    .font(.caption)
                    .foregroundStyle(dream.category.color)
                    .padding(6)
                    .background(dream.category.color.opacity(0.12), in: Circle())

                Spacer()

                if dream.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }

            Text(dream.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            if !dream.dreamDescription.isEmpty {
                Text(dream.dreamDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }

            Spacer(minLength: 0)

            if !dream.steps.isEmpty && !dream.isCompleted {
                VStack(spacing: 4) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color(.tertiarySystemFill))
                            Capsule()
                                .fill(dream.category.color)
                                .frame(width: geo.size.width * dream.progress)
                        }
                    }
                    .frame(height: 3)

                    HStack {
                        Text("\(Int(dream.progress * 100))%")
                            .font(.caption2.bold().monospacedDigit())
                            .foregroundStyle(dream.category.color)
                        Spacer()
                    }
                }
            }

            HStack(spacing: 4) {
                Image(systemName: dream.mood.icon)
                    .font(.caption2)
                    .foregroundStyle(dream.mood.color)
                Text(dream.createdAt, format: .dateTime.month(.abbreviated).day())
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 160)
        .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 16))
    }
}

struct NotebookListCard: View {
    let dream: Dream

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(dream.category.color.gradient)
                    .frame(width: 48, height: 48)
                Image(systemName: dream.category.icon)
                    .font(.body)
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(dream.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Image(systemName: dream.mood.icon)
                        .font(.caption2)
                        .foregroundStyle(dream.mood.color)

                    Text(dream.category.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if !dream.steps.isEmpty && !dream.isCompleted {
                        Text("·")
                            .foregroundStyle(.tertiary)
                        Text("\(Int(dream.progress * 100))%")
                            .font(.caption.bold().monospacedDigit())
                            .foregroundStyle(dream.category.color)
                    }
                }
            }

            Spacer()

            if dream.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            } else if dream.priority == 3 {
                Image(systemName: "flame.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }

            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundStyle(.quaternary)
        }
        .padding(14)
        .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 14))
    }
}

struct NotebookFilterChip: View {
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
            .background(isSelected ? Color.primary : Color(.tertiarySystemBackground), in: .capsule)
            .foregroundStyle(isSelected ? Color(.systemBackground) : .primary)
        }
    }
}
