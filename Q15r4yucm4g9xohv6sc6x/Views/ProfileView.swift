import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query private var dreams: [Dream]
    @State private var showResetAlert: Bool = false

    private var profile: UserProfile? { profiles.first }

    private var completedCount: Int { dreams.filter(\.isCompleted).count }
    private var activeCount: Int { dreams.filter { !$0.isCompleted }.count }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    avatarSection
                    statsSection
                    if let profile, !profile.skills.isEmpty { skillsSection(profile: profile) }
                    if let profile, !profile.interests.isEmpty { interestsSection(profile: profile) }
                    actionsSection
                }
                .padding(16)
            }
            .navigationTitle("Profile")
        }
    }

    private var avatarSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(colors: [.indigo, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 88, height: 88)

                Text(initials)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }

            Text(profile?.name ?? "User")
                .font(.title2.bold())

            if let profile {
                Text("Age \(profile.age) \u{2022} Member since \(profile.createdAt.formatted(.dateTime.month(.wide).year()))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    private var initials: String {
        guard let name = profile?.name, !name.isEmpty else { return "?" }
        let parts = name.components(separatedBy: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    private var statsSection: some View {
        HStack(spacing: 12) {
            StatCard(value: "\(dreams.count)", label: "Total", icon: "star.fill", color: .indigo)
            StatCard(value: "\(activeCount)", label: "Active", icon: "flame.fill", color: .orange)
            StatCard(value: "\(completedCount)", label: "Done", icon: "checkmark.seal.fill", color: .green)
        }
    }

    private func skillsSection(profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Skills", systemImage: "star.circle.fill")
                .font(.headline)

            FlowLayout(spacing: 8) {
                ForEach(profile.skills, id: \.self) { skill in
                    Text(skill)
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Color.indigo.opacity(0.1), in: .capsule)
                        .foregroundStyle(.indigo)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 16))
    }

    private func interestsSection(profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Interests", systemImage: "heart.circle.fill")
                .font(.headline)

            FlowLayout(spacing: 8) {
                ForEach(profile.interests, id: \.self) { interest in
                    Text(interest)
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Color.purple.opacity(0.1), in: .capsule)
                        .foregroundStyle(.purple)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 16))
    }

    private var actionsSection: some View {
        VStack(spacing: 0) {
            Button {
                showResetAlert = true
            } label: {
                HStack {
                    Label("Reset Profile", systemImage: "arrow.counterclockwise")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .foregroundStyle(.red)
                .padding(16)
            }
        }
        .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 16))
        .confirmationDialog("Reset your profile?", isPresented: $showResetAlert, titleVisibility: .visible) {
            Button("Reset Everything", role: .destructive) {
                resetProfile()
            }
        } message: {
            Text("This will delete your profile and all dreams. You'll go through onboarding again.")
        }
    }

    private func resetProfile() {
        for dream in dreams { modelContext.delete(dream) }
        if let profile { modelContext.delete(profile) }
    }
}

struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.title2.bold())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 16))
    }
}

struct FlowLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x - spacing)
        }

        return (positions, CGSize(width: maxX, height: y + rowHeight))
    }
}
