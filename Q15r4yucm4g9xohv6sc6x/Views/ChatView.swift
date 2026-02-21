import SwiftUI
import SwiftData

struct ChatMessage: Identifiable {
    let id: UUID = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date = Date()
}

@Observable
class ChatViewModel {
    var messages: [ChatMessage] = []
    var isTyping: Bool = false

    init() {
        messages.append(ChatMessage(
            content: "Hi there! I'm your Dream Assistant. I can help you discover new dreams, track your progress, and stay motivated. What's on your mind?",
            isUser: false
        ))
    }

    func sendMessage(_ text: String, profile: UserProfile?, dreams: [Dream]) {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        messages.append(ChatMessage(content: trimmed, isUser: true))
        isTyping = true

        Task {
            try? await Task.sleep(for: .milliseconds(600 + Int.random(in: 0...1000)))
            let response = generateResponse(to: trimmed, profile: profile, dreams: dreams)
            isTyping = false
            messages.append(ChatMessage(content: response, isUser: false))
        }
    }

    private func generateResponse(to message: String, profile: UserProfile?, dreams: [Dream]) -> String {
        let lower = message.lowercased()
        let name = profile?.name ?? "friend"

        if lower.hasPrefix("hi") || lower.hasPrefix("hello") || lower.hasPrefix("hey") || lower.contains("good morning") || lower.contains("good evening") {
            return [
                "Hey \(name)! Great to see you. What dreams are we working on today?",
                "Hello \(name)! Ready to make some progress on your goals?",
                "Hi \(name)! I'm here to help. What would you like to focus on?"
            ].randomElement()!
        }

        if lower.contains("progress") || lower.contains("how am i") || lower.contains("status") || lower.contains("update") {
            let total = dreams.count
            let completed = dreams.filter(\.isCompleted).count
            let inProgress = total - completed
            if total == 0 {
                return "You haven't added any dreams yet! Head to the Discover tab \u{2014} I've curated personalized suggestions based on your skills and interests."
            }
            let avgProgress = dreams.filter { !$0.isCompleted }.map(\.progress).reduce(0, +) / Double(max(inProgress, 1))
            return "Here's your snapshot, \(name):\n\n\(total) total dreams\n\(completed) completed\n\(inProgress) in progress\n\(Int(avgProgress * 100))% average progress\n\nKeep pushing forward! Every step counts."
        }

        if lower.contains("motivat") || lower.contains("inspire") || lower.contains("encourage") || (lower.contains("feel") && (lower.contains("down") || lower.contains("stuck"))) {
            return [
                "Remember, \(name): every expert was once a beginner. Your dreams are valid and absolutely achievable!",
                "The fact that you're here working on your dreams puts you ahead of most people. Keep going!",
                "Think about where you'll be a year from now if you keep taking small steps every day. You've got this, \(name)!",
                "Dreams don't work unless you do \u{2014} but the good news? You're already doing the work!",
                "Every step forward, no matter how small, is real progress. Be proud of yourself, \(name)!"
            ].randomElement()!
        }

        if lower.contains("suggest") || lower.contains("recommend") || lower.contains("idea") || lower.contains("new dream") {
            if let profile {
                let suggestions = DreamEngine.shared.suggestDreams(for: profile, excluding: dreams)
                let top3 = suggestions.prefix(3)
                if !top3.isEmpty {
                    let list = top3.map { "  \u{2022} \($0.title)" }.joined(separator: "\n")
                    return "Based on your profile, here are some dreams that might excite you:\n\n\(list)\n\nCheck the Discover tab for the full list!"
                }
            }
            return "Check out the Discover tab \u{2014} I've curated personalized dream suggestions just for you based on your skills and interests!"
        }

        if lower.contains("help") || lower.contains("what can you") {
            return "I can help you with:\n\n\u{2022} Track your dream progress\n\u{2022} Discover new dreams and goals\n\u{2022} Break down big dreams into steps\n\u{2022} Stay motivated and focused\n\u{2022} Review your achievements\n\nJust ask me anything!"
        }

        if lower.contains("thank") {
            return [
                "You're welcome, \(name)! I'm always here when you need a boost.",
                "Anytime! That's what I'm here for. Keep dreaming big!",
                "My pleasure! Let me know if there's anything else I can help with."
            ].randomElement()!
        }

        if lower.contains("complete") || lower.contains("finish") || lower.contains("done") || lower.contains("achieve") {
            let completed = dreams.filter(\.isCompleted)
            if completed.isEmpty {
                return "You're working hard toward your first completed dream! Keep at it \u{2014} the feeling of achievement will be incredible."
            }
            return "Amazing work! You've already completed \(completed.count) dream\(completed.count == 1 ? "" : "s"). Each one is proof that you can achieve anything you set your mind to!"
        }

        return [
            "That's an interesting thought, \(name)! What dream does this connect to?",
            "I love your energy! Have you checked your dream progress lately? You might be closer than you think.",
            "Great point! Remember, achieving your dreams is a journey. Every day counts.",
            "What's the one thing you could do today to move closer to your biggest dream, \(name)?",
            "Thanks for sharing! Is there a specific dream you'd like to focus on right now?"
        ].randomElement()!
    }
}

struct ChatView: View {
    @Query private var profiles: [UserProfile]
    @Query private var dreams: [Dream]
    @State private var viewModel = ChatViewModel()
    @State private var inputText: String = ""
    @FocusState private var isInputFocused: Bool

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                messageList
                quickActions
                inputBar
            }
            .navigationTitle("Dream Assistant")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        MessageBubble(message: message)
                            .id(message.id)
                    }

                    if viewModel.isTyping {
                        TypingIndicator()
                            .id("typing")
                    }
                }
                .padding(16)
            }
            .onChange(of: viewModel.messages.count) { _, _ in
                withAnimation(.spring(duration: 0.3)) {
                    if viewModel.isTyping {
                        proxy.scrollTo("typing", anchor: .bottom)
                    } else if let last = viewModel.messages.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
            .onChange(of: viewModel.isTyping) { _, _ in
                withAnimation(.spring(duration: 0.3)) {
                    if viewModel.isTyping {
                        proxy.scrollTo("typing", anchor: .bottom)
                    }
                }
            }
        }
    }

    private var quickActions: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                QuickActionButton(title: "My Progress", icon: "chart.bar.fill") {
                    sendQuickAction("How am I doing with my dreams?")
                }
                QuickActionButton(title: "Suggest Dreams", icon: "sparkles") {
                    sendQuickAction("Can you suggest some new dreams for me?")
                }
                QuickActionButton(title: "Motivate Me", icon: "flame.fill") {
                    sendQuickAction("I need some motivation!")
                }
                QuickActionButton(title: "What Can You Do?", icon: "questionmark.circle") {
                    sendQuickAction("What can you help me with?")
                }
            }
        }
        .contentMargins(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }

    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("Ask me anything...", text: $inputText, axis: .vertical)
                .lineLimit(1...4)
                .padding(12)
                .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 20))
                .focused($isInputFocused)
                .submitLabel(.send)
                .onSubmit { sendMessage() }

            Button {
                sendMessage()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(inputText.trimmingCharacters(in: .whitespaces).isEmpty ? Color.secondary : Color.indigo)
            }
            .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.bar)
    }

    private func sendMessage() {
        let text = inputText
        inputText = ""
        viewModel.sendMessage(text, profile: profile, dreams: dreams)
    }

    private func sendQuickAction(_ text: String) {
        viewModel.sendMessage(text, profile: profile, dreams: dreams)
    }
}

struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isUser { Spacer(minLength: 48) }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.body)
                    .foregroundStyle(message.isUser ? .white : .primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        message.isUser
                        ? AnyShapeStyle(LinearGradient(colors: [.indigo, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                        : AnyShapeStyle(Color(.secondarySystemBackground)),
                        in: .rect(
                            topLeadingRadius: message.isUser ? 18 : 4,
                            bottomLeadingRadius: 18,
                            bottomTrailingRadius: message.isUser ? 4 : 18,
                            topTrailingRadius: 18
                        )
                    )

                Text(message.timestamp, format: .dateTime.hour().minute())
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            if !message.isUser { Spacer(minLength: 48) }
        }
    }
}

struct TypingIndicator: View {
    @State private var phase: Int = 0

    var body: some View {
        HStack {
            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Color.secondary.opacity(0.5))
                        .frame(width: 8, height: 8)
                        .scaleEffect(phase == index ? 1.3 : 0.8)
                        .animation(.easeInOut(duration: 0.4).repeatForever().delay(Double(index) * 0.15), value: phase)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(.secondarySystemBackground), in: .rect(topLeadingRadius: 4, bottomLeadingRadius: 18, bottomTrailingRadius: 18, topTrailingRadius: 18))

            Spacer()
        }
        .onAppear { phase = 2 }
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.tertiarySystemBackground), in: .capsule)
        }
    }
}
