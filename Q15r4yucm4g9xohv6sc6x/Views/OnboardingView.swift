import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var step: Int = 0
    @State private var name: String = ""
    @State private var age: Int = 25
    @State private var selectedSkills: Set<String> = []
    @State private var selectedInterests: Set<String> = []

    private let availableSkills = [
        "Programming", "Design", "Writing", "Marketing", "Music", "Art",
        "Photography", "Cooking", "Teaching", "Leadership", "Communication",
        "Problem Solving", "Analytics", "Fitness", "Languages", "Public Speaking",
        "Engineering", "Medicine", "Law", "Finance"
    ]

    private let availableInterests = [
        "Technology", "Science", "Sports", "Travel", "Food", "Music",
        "Art", "Fashion", "Gaming", "Reading", "Nature", "Photography",
        "Business", "Health", "Education", "Movies", "Volunteering",
        "Crafts", "Sustainability", "Psychology"
    ]

    private var canContinue: Bool {
        switch step {
        case 0: true
        case 1: !name.trimmingCharacters(in: .whitespaces).isEmpty
        case 2: true
        case 3: !selectedSkills.isEmpty
        case 4: !selectedInterests.isEmpty
        default: true
        }
    }

    var body: some View {
        ZStack {
            backgroundView

            VStack(spacing: 0) {
                if step > 0 && step < 5 {
                    progressBar
                        .padding(.top, 16)
                        .transition(.opacity)
                }

                Spacer()

                Group {
                    switch step {
                    case 0: welcomeStep
                    case 1: nameStep
                    case 2: ageStep
                    case 3: skillsStep
                    case 4: interestsStep
                    case 5: completionStep
                    default: EmptyView()
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

                Spacer()

                if step < 5 {
                    bottomButton
                } else {
                    startButton
                }
            }
            .padding(.bottom, 24)
        }
        .animation(.spring(duration: 0.5, bounce: 0.2), value: step)
    }

    private var backgroundView: some View {
        MeshGradient(width: 3, height: 3, points: [
            [0, 0], [0.5, 0], [1, 0],
            [0, 0.5], [0.5, 0.5], [1, 0.5],
            [0, 1], [0.5, 1], [1, 1]
        ], colors: [
            .indigo.opacity(0.3), .purple.opacity(0.2), .blue.opacity(0.15),
            .indigo.opacity(0.15), .purple.opacity(0.1), .indigo.opacity(0.2),
            .blue.opacity(0.1), .indigo.opacity(0.15), .purple.opacity(0.25)
        ])
        .ignoresSafeArea()
        .overlay {
            Color(.systemBackground).opacity(0.7)
                .ignoresSafeArea()
        }
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(.tertiarySystemFill))
                Capsule()
                    .fill(
                        LinearGradient(colors: [.indigo, .purple], startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(width: geo.size.width * CGFloat(step) / 4.0)
                    .animation(.spring(duration: 0.4), value: step)
            }
        }
        .frame(height: 4)
        .padding(.horizontal, 32)
    }

    private var welcomeStep: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 72))
                .foregroundStyle(
                    LinearGradient(colors: [.indigo, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .symbolEffect(.pulse, options: .repeating)
                .padding(.bottom, 8)

            Text("Dream")
                .font(.system(size: 52, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(colors: [.indigo, .purple], startPoint: .leading, endPoint: .trailing)
                )

            Text("Your personal dream companion.\nDiscover, plan, and achieve\nyour biggest aspirations.")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(.horizontal, 32)
    }

    private var nameStep: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.crop.circle")
                .font(.system(size: 56))
                .foregroundStyle(.indigo)

            Text("What should I call you?")
                .font(.title.bold())
                .multilineTextAlignment(.center)

            Text("Let's get to know each other")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            TextField("Your name", text: $name)
                .font(.title3)
                .padding(16)
                .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 16))
                .padding(.horizontal, 32)
                .textContentType(.givenName)
                .submitLabel(.continue)
                .onSubmit { if canContinue { advanceStep() } }
        }
    }

    private var ageStep: some View {
        VStack(spacing: 24) {
            Image(systemName: "calendar.circle")
                .font(.system(size: 56))
                .foregroundStyle(.indigo)

            Text("How old are you?")
                .font(.title.bold())

            Text("This helps us personalize your experience")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Picker("Age", selection: $age) {
                ForEach(10...80, id: \.self) { value in
                    Text("\(value)").tag(value)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 150)
            .padding(.horizontal, 64)
        }
    }

    private var skillsStep: some View {
        VStack(spacing: 20) {
            Image(systemName: "star.circle")
                .font(.system(size: 56))
                .foregroundStyle(.indigo)

            Text("What are your superpowers?")
                .font(.title.bold())
                .multilineTextAlignment(.center)

            Text("Select skills you have or want to develop")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                    ForEach(availableSkills, id: \.self) { skill in
                        ChipButton(
                            title: skill,
                            isSelected: selectedSkills.contains(skill)
                        ) {
                            if selectedSkills.contains(skill) {
                                selectedSkills.remove(skill)
                            } else {
                                selectedSkills.insert(skill)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
            .frame(maxHeight: 280)
        }
    }

    private var interestsStep: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.circle")
                .font(.system(size: 56))
                .foregroundStyle(.indigo)

            Text("What excites you?")
                .font(.title.bold())

            Text("Pick your passions and interests")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                    ForEach(availableInterests, id: \.self) { interest in
                        ChipButton(
                            title: interest,
                            isSelected: selectedInterests.contains(interest)
                        ) {
                            if selectedInterests.contains(interest) {
                                selectedInterests.remove(interest)
                            } else {
                                selectedInterests.insert(interest)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
            .frame(maxHeight: 280)
        }
    }

    private var completionStep: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green)
                .symbolEffect(.bounce, value: step == 5)

            Text("You're all set, \(name)!")
                .font(.title.bold())
                .multilineTextAlignment(.center)

            Text("We've crafted personalized dream\nsuggestions just for you.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            HStack(spacing: 24) {
                StatPill(value: "\(selectedSkills.count)", label: "Skills")
                StatPill(value: "\(selectedInterests.count)", label: "Interests")
                StatPill(value: "\(age)", label: "Age")
            }
            .padding(.top, 8)
        }
    }

    private var bottomButton: some View {
        Button {
            advanceStep()
        } label: {
            Text(step == 0 ? "Get Started" : "Continue")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    canContinue
                    ? LinearGradient(colors: [.indigo, .purple], startPoint: .leading, endPoint: .trailing)
                    : LinearGradient(colors: [.gray, .gray], startPoint: .leading, endPoint: .trailing),
                    in: .capsule
                )
        }
        .disabled(!canContinue)
        .padding(.horizontal, 32)
        .sensoryFeedback(.impact(flexibility: .soft), trigger: step)
    }

    private var startButton: some View {
        Button {
            completeOnboarding()
        } label: {
            HStack {
                Text("Start Dreaming")
                    .font(.headline)
                Image(systemName: "arrow.right")
                    .font(.headline)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(colors: [.indigo, .purple], startPoint: .leading, endPoint: .trailing),
                in: .capsule
            )
        }
        .padding(.horizontal, 32)
        .sensoryFeedback(.success, trigger: step)
    }

    private func advanceStep() {
        withAnimation(.spring(duration: 0.5, bounce: 0.2)) {
            step += 1
        }
    }

    private func completeOnboarding() {
        let profile = UserProfile(
            name: name.trimmingCharacters(in: .whitespaces),
            age: age,
            skills: Array(selectedSkills),
            interests: Array(selectedInterests),
            onboardingCompleted: true
        )
        modelContext.insert(profile)
    }
}

struct ChipButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.indigo : Color(.tertiarySystemBackground), in: .capsule)
                .foregroundStyle(isSelected ? .white : .primary)
        }
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

struct StatPill: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(.indigo)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 12))
    }
}
