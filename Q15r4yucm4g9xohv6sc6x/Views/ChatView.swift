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
            content: "Welcome to your Dream Assistant. I analyze your dreams, track patterns, and help you stay focused on what matters most. What would you like to explore?",
            isUser: false
        ))
    }

    func sendMessage(_ text: String, profile: UserProfile?, dreams: [Dream]) {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        messages.append(ChatMessage(content: trimmed, isUser: true))
        isTyping = true

        Task {
            try? await Task.sleep(for: .milliseconds(500 + Int.random(in: 0...800)))
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
                "Hey \(name). What dreams are on your mind today?",
                "Hello \(name). Ready to make progress on your goals?",
                "Hi \(name). Let's dive into your notebook."
            ].randomElement()!
        }

        if lower.contains("progress") || lower.contains("how am i") || lower.contains("status") || lower.contains("update") || lower.contains("overview") {
            let total = dreams.count
            let completed = dreams.filter(\.isCompleted).count
            let inProgress = total - completed
            if total == 0 {
                return "Your notebook is empty. Head to Insights — I've curated personalized dream suggestions based on your profile."
            }
            let activeProgress = dreams.filter { !$0.isCompleted }
            let avgProgress = activeProgress.isEmpty ? 0 : activeProgress.map(\.progress).reduce(0, +) / Double(activeProgress.count)

            var response = "Here's your overview, \(name):\n\n"
            response += "📓 \(total) dreams in your notebook\n"
            response += "✅ \(completed) completed\n"
            response += "🔥 \(inProgress) in progress\n"
            response += "📊 \(Int(avgProgress * 100))% average progress\n\n"

            if let closest = activeProgress.sorted(by: { $0.progress > $1.progress }).first {
                response += "Closest to completion: \"\(closest.title)\" at \(Int(closest.progress * 100))%."
            }
            return response
        }

        if lower.contains("pattern") || lower.contains("analyze") || lower.contains("insight") || lower.contains("theme") {
            let patterns = DreamEngine.shared.analyzeDreamPatterns(dreams: dreams)
            if patterns.isEmpty {
                return "Add more dreams to your notebook and I'll uncover patterns in your aspirations."
            }
            var response = "Here's what I see in your dream patterns:\n\n"
            for pattern in patterns.prefix(3) {
                response += "• \(pattern.title): \(pattern.description)\n\n"
            }
            return response
        }

        if lower.contains("motivat") || lower.contains("inspire") || lower.contains("encourage") || (lower.contains("feel") && (lower.contains("down") || lower.contains("stuck"))) {
            return [
                "Remember, \(name) — every expert was once a beginner. Your dreams are valid and achievable. The fact that you wrote them down puts you ahead.",
                "Think about where you'll be a year from now if you keep taking small steps every day. Consistency beats intensity.",
                "Your notebook tells a story of ambition and growth. Each step you take, no matter how small, rewrites the ending.",
                "The gap between where you are and where you want to be is filled with small, daily actions. You've already started.",
            ].randomElement()!
        }

        if lower.contains("suggest") || lower.contains("recommend") || lower.contains("idea") || lower.contains("new dream") {
            if let profile {
                let suggestions = DreamEngine.shared.suggestDreams(for: profile, excluding: dreams)
                let top3 = suggestions.prefix(3)
                if !top3.isEmpty {
                    var response = "Based on your profile, these align with your strengths:\n\n"
                    for suggestion in top3 {
                        response += "• \(suggestion.title) — \(suggestion.insight)\n\n"
                    }
                    response += "Check Insights for the full list."
                    return response
                }
            }
            return "Check the Insights tab — I've curated personalized dream suggestions based on your skills and interests."
        }

        if lower.contains("help") || lower.contains("what can you") {
            return "I can help you with:\n\n• Track and analyze your dream progress\n• Discover patterns in your aspirations\n• Get personalized dream suggestions\n• Break down big dreams into steps\n• Journal reflections on your journey\n• Stay motivated and focused\n\nJust ask me anything about your dreams."
        }

        if lower.contains("thank") {
            return [
                "Anytime, \(name). Your notebook is always here when you need it.",
                "My pleasure. Keep building that dream collection.",
                "You're welcome. Let me know if there's anything else to explore."
            ].randomElement()!
        }

        if lower.contains("complete") || lower.contains("finish") || lower.contains("done") || lower.contains("achieve") {
            let completed = dreams.filter(\.isCompleted)
            if completed.isEmpty {
                return "You're working toward your first completed dream. The first one always feels the most meaningful — keep pushing."
            }
            return "You've completed \(completed.count) dream\(completed.count == 1 ? "" : "s"). Each one is evidence that you can achieve what you set your mind to. What's next?"
        }

        if lower.contains("focus") || lower.contains("priority") || lower.contains("important") {
            let highPriority = dreams.filter { $0.priority == 3 && !$0.isCompleted }
            if highPriority.isEmpty {
                let active = dreams.filter { !$0.isCompleted }.sorted { $0.progress > $1.progress }
                if let top = active.first {
                    return "Your closest dream to completion is \"\(top.title)\" at \(Int(top.progress * 100))%. Focus your energy here for a quick win."
                }
                return "You don't have any active dreams yet. Start by adding one that truly excites you."
            }
            var response = "Your high-priority dreams:\n\n"
            for dream in highPriority.prefix(3) {
                response += "🔥 \(dream.title) — \(Int(dream.progress * 100))% complete\n"
            }
            response += "\nFocus on one step in each today."
            return response
        }

        return [
            "Interesting thought, \(name). How does this connect to your current dreams?",
            "I hear you. Have you checked your notebook lately? You might be closer to a breakthrough than you think.",
            "Good point. What's the one thing you could do today to move closer to your biggest dream?",
            "Thanks for sharing. Want me to analyze your dream patterns or suggest something new?",
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
            .navigationTitle("Assistant")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.messages) { message in
                        ChatBubble(message: message)
                            .id(message.id)
                    }

                    if viewModel.isTyping {
                        ChatTypingIndicator()
                            .id("typing")
                    }
                }
                .padding(16)
            }
            .scrollDismissesKeyboard(.interactively)
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
                ChatQuickAction(title: "Overview", icon: "chart.bar.fill") {
                    sendQuickAction("Give me an overview of my dreams")
                }
                ChatQuickAction(title: "Patterns", icon: "brain.head.profile.fill") {
                    sendQuickAction("Analyze my dream patterns")
                }
                ChatQuickAction(title: "Suggest", icon: "sparkles") {
                    sendQuickAction("Suggest new dreams for me")
                }
                ChatQuickAction(title: "Focus", icon: "scope") {
                    sendQuickAction("What should I focus on?")
                }
                ChatQuickAction(title: "Motivate", icon: "flame.fill") {
                    sendQuickAction("I need some motivation")
                }
            }
        }
        .contentMargins(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }

    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("Ask about your dreams...", text: $inputText, axis: .vertical)
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
                    .font(.system(size: 32))
                    .foregroundStyle(inputText.trimmingCharacters(in: .whitespaces).isEmpty ? Color(.tertiaryLabel) : .primary)
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

struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            if message.isUser {
                Spacer(minLength: 48)
            } else {
                ZStack {
                    Circle()
                        .fill(Color(.tertiarySystemFill))
                        .frame(width: 28, height: 28)
                    Image(systemName: "sparkles")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.body)
                    .foregroundStyle(message.isUser ? .white : .primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        message.isUser
                        ? AnyShapeStyle(Color.primary)
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
                    .foregroundStyle(.quaternary)
            }

            if !message.isUser {
                Spacer(minLength: 48)
            }
        }
    }
}

struct ChatTypingIndicator: View {
    @State private var phase: Int = 0

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color(.tertiarySystemFill))
                    .frame(width: 28, height: 28)
                Image(systemName: "sparkles")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Color.secondary.opacity(0.4))
                        .frame(width: 7, height: 7)
                        .scaleEffect(phase == index ? 1.3 : 0.7)
                        .animation(.easeInOut(duration: 0.4).repeatForever().delay(Double(index) * 0.15), value: phase)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(Color(.secondarySystemBackground), in: .rect(topLeadingRadius: 4, bottomLeadingRadius: 18, bottomTrailingRadius: 18, topTrailingRadius: 18))

            Spacer()
        }
        .onAppear { phase = 2 }
    }
}

struct ChatQuickAction: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.caption2)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.secondarySystemBackground), in: .capsule)
        }
    }
}
