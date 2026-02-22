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
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                if step > 0 && step < 5 {
                    HStack(spacing: 6) {
                        ForEach(1..<5) { i in
                            Capsule()
                                .fill(i <= step ? Color.primary : Color(.tertiarySystemFill))
                                .frame(height: 3)
                        }
                    }
                    .padding(.horizontal, 32)
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

    private var welcomeStep: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.primary.opacity(0.06))
                    .frame(width: 120, height: 120)

                Image(systemName: "book.closed.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(.primary)
                    .symbolEffect(.pulse, options: .repeating)
            }
            .padding(.bottom, 8)

            VStack(spacing: 12) {
                Text("DreamBook")
                    .font(.system(size: 42, weight: .bold))

                Text("Your intelligent dream notebook.\nCapture, analyze, and understand\nyour aspirations.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
        }
        .padding(.horizontal, 32)
    }

    private var nameStep: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.text.rectangle")
                .font(.system(size: 48))
                .foregroundStyle(.primary)

            VStack(spacing: 8) {
                Text("What's your name?")
                    .font(.title.bold())

                Text("Let's personalize your experience")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            TextField("Your name", text: $name)
                .font(.title3)
                .padding(16)
                .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 14))
                .padding(.horizontal, 32)
                .textContentType(.givenName)
                .submitLabel(.continue)
                .onSubmit { if canContinue { advanceStep() } }
        }
    }

    private var ageStep: some View {
        VStack(spacing: 24) {
            Image(systemName: "calendar")
                .font(.system(size: 48))
                .foregroundStyle(.primary)

            VStack(spacing: 8) {
                Text("How old are you?")
                    .font(.title.bold())

                Text("This helps tailor recommendations")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

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
            Image(systemName: "star.fill")
                .font(.system(size: 48))
                .foregroundStyle(.primary)

            VStack(spacing: 8) {
                Text("Your strengths")
                    .font(.title.bold())

                Text("Select skills you have or want to develop")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                    ForEach(availableSkills, id: \.self) { skill in
                        OnboardingChip(
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
            Image(systemName: "heart.fill")
                .font(.system(size: 48))
                .foregroundStyle(.primary)

            VStack(spacing: 8) {
                Text("What excites you?")
                    .font(.title.bold())

                Text("Pick your passions and interests")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                    ForEach(availableInterests, id: \.self) { interest in
                        OnboardingChip(
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
                .font(.system(size: 72))
                .foregroundStyle(.green)
                .symbolEffect(.bounce, value: step == 5)

            VStack(spacing: 8) {
                Text("Ready, \(name)")
                    .font(.title.bold())

                Text("Your notebook is personalized.\nLet's start capturing your dreams.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            HStack(spacing: 20) {
                OnboardingStatPill(value: "\(selectedSkills.count)", label: "Skills")
                OnboardingStatPill(value: "\(selectedInterests.count)", label: "Interests")
                OnboardingStatPill(value: "\(age)", label: "Age")
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
                .foregroundStyle(canContinue ? Color(.systemBackground) : .secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(canContinue ? Color.primary : Color(.tertiarySystemFill), in: .capsule)
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
                Text("Open Notebook")
                    .font(.headline)
                Image(systemName: "arrow.right")
                    .font(.headline)
            }
            .foregroundStyle(Color(.systemBackground))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.primary, in: .capsule)
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

struct OnboardingChip: View {
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
                .background(isSelected ? Color.primary : Color(.tertiarySystemBackground), in: .capsule)
                .foregroundStyle(isSelected ? Color(.systemBackground) : .primary)
        }
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

struct OnboardingStatPill: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 12))
    }
}
