import Foundation

nonisolated struct DreamTemplate: Sendable {
    let title: String
    let description: String
    let category: DreamCategory
    let mood: DreamMood
    let suggestedSteps: [String]
    let relevantSkills: Set<String>
    let relevantInterests: Set<String>
    let ageRange: ClosedRange<Int>
    let insight: String
}

class DreamEngine {
    static let shared = DreamEngine()

    private let templates: [DreamTemplate] = [
        DreamTemplate(
            title: "Launch a Side Business",
            description: "Turn your passion into a profitable venture. Start small, think big, and build something meaningful.",
            category: .career, mood: .exciting,
            suggestedSteps: ["Identify your niche and target market", "Create a business plan", "Build a minimum viable product", "Set up online presence", "Launch and get first customers", "Iterate based on feedback"],
            relevantSkills: Set(["marketing", "leadership", "communication", "design", "programming"]),
            relevantInterests: Set(["business", "technology"]),
            ageRange: 16...55,
            insight: "Entrepreneurship aligns with your creative and leadership skills. Starting small reduces risk while building real-world experience."
        ),
        DreamTemplate(
            title: "Earn a Professional Certification",
            description: "Level up your career with a recognized certification in your field.",
            category: .career, mood: .neutral,
            suggestedSteps: ["Research certifications in your field", "Choose exam and register", "Create a study schedule", "Complete practice tests", "Pass the certification exam"],
            relevantSkills: Set(["analytics", "problem solving", "engineering"]),
            relevantInterests: Set(["education", "business", "technology"]),
            ageRange: 18...50,
            insight: "Certifications signal expertise and commitment. They open doors to roles that value proven, structured knowledge."
        ),
        DreamTemplate(
            title: "Master Public Speaking",
            description: "Overcome stage fright and become a confident, compelling speaker.",
            category: .career, mood: .exciting,
            suggestedSteps: ["Join a speaking group or club", "Prepare a 5-minute talk", "Practice in front of friends", "Give a talk at a local event", "Seek feedback and refine your style"],
            relevantSkills: Set(["communication", "leadership", "public speaking"]),
            relevantInterests: Set(["business", "education"]),
            ageRange: 14...60,
            insight: "Public speaking is one of the most transferable skills. Mastering it amplifies every other professional ability you have."
        ),
        DreamTemplate(
            title: "Land Your Dream Job",
            description: "Position yourself for the career you've always wanted through strategic preparation.",
            category: .career, mood: .joyful,
            suggestedSteps: ["Define your ideal role and company", "Update resume and portfolio", "Network with industry professionals", "Prepare for interviews", "Apply to target companies", "Negotiate your offer"],
            relevantSkills: Set(["communication", "leadership", "problem solving"]),
            relevantInterests: Set(["business"]),
            ageRange: 18...45,
            insight: "Strategic career moves require clarity about what you want. Define the destination first, then reverse-engineer the path."
        ),
        DreamTemplate(
            title: "Run a Half Marathon",
            description: "Challenge yourself physically and mentally by training for and completing a half marathon.",
            category: .health, mood: .exciting,
            suggestedSteps: ["Get a health checkup", "Start with a couch-to-5K plan", "Build up weekly mileage", "Complete a 10K race", "Follow a half marathon training plan", "Race day — finish strong!"],
            relevantSkills: Set(["fitness"]),
            relevantInterests: Set(["sports", "health"]),
            ageRange: 14...55,
            insight: "Endurance training builds mental resilience as much as physical strength. The discipline transfers to every area of life."
        ),
        DreamTemplate(
            title: "Develop a Daily Meditation Practice",
            description: "Find inner calm and clarity through a consistent meditation routine.",
            category: .health, mood: .peaceful,
            suggestedSteps: ["Start with 5 minutes daily", "Try different meditation styles", "Build up to 15 minutes", "Create a dedicated meditation space", "Maintain a 30-day streak"],
            relevantSkills: Set([]),
            relevantInterests: Set(["health", "psychology"]),
            ageRange: 12...70,
            insight: "Meditation rewires your brain for focus and emotional regulation. Even 5 minutes daily creates measurable cognitive benefits."
        ),
        DreamTemplate(
            title: "Master Healthy Cooking",
            description: "Learn to prepare nutritious, delicious meals that fuel your body and delight your taste buds.",
            category: .health, mood: .joyful,
            suggestedSteps: ["Learn 5 basic cooking techniques", "Plan weekly meal prep", "Master 10 healthy recipes", "Experiment with global cuisines", "Cook a healthy dinner party"],
            relevantSkills: Set(["cooking"]),
            relevantInterests: Set(["food", "health"]),
            ageRange: 14...65,
            insight: "Cooking is a creative act with immediate rewards. Mastering it gives you control over your health and brings people together."
        ),
        DreamTemplate(
            title: "Learn a New Language",
            description: "Open doors to new cultures and connections by becoming conversational in another language.",
            category: .education, mood: .mysterious,
            suggestedSteps: ["Choose your target language", "Start with basics and pronunciation", "Practice daily for 20 minutes", "Find a language exchange partner", "Watch shows in that language", "Have a 10-minute conversation"],
            relevantSkills: Set(["languages", "communication"]),
            relevantInterests: Set(["travel", "education"]),
            ageRange: 10...70,
            insight: "Language learning reshapes how you think. Bilingual minds show enhanced problem-solving and cognitive flexibility."
        ),
        DreamTemplate(
            title: "Read 30 Books This Year",
            description: "Expand your mind and perspective through a dedicated reading challenge.",
            category: .education, mood: .peaceful,
            suggestedSteps: ["Create a reading list", "Set aside 30 minutes daily for reading", "Join a book club", "Mix fiction and non-fiction", "Track and review each book", "Share your favorites with friends"],
            relevantSkills: Set(["writing"]),
            relevantInterests: Set(["reading", "education"]),
            ageRange: 12...70,
            insight: "Reading is compound interest for your mind. Each book adds context and depth to everything that follows."
        ),
        DreamTemplate(
            title: "Master a Musical Instrument",
            description: "Express yourself through music by learning to play an instrument you love.",
            category: .creative, mood: .joyful,
            suggestedSteps: ["Choose your instrument", "Find a teacher or course", "Practice 20 minutes daily", "Learn 5 songs you love", "Perform for friends or family", "Join a jam session or band"],
            relevantSkills: Set(["music"]),
            relevantInterests: Set(["music"]),
            ageRange: 10...70,
            insight: "Musical training strengthens neural connections across your entire brain. It's one of the few activities that engages every cognitive system simultaneously."
        ),
        DreamTemplate(
            title: "Create a Digital Art Portfolio",
            description: "Build a stunning collection of digital artwork that showcases your unique style.",
            category: .creative, mood: .surreal,
            suggestedSteps: ["Learn digital art fundamentals", "Choose your tools and software", "Create 10 portfolio pieces", "Develop a consistent style", "Build an online portfolio", "Share on art communities"],
            relevantSkills: Set(["art", "design", "photography"]),
            relevantInterests: Set(["art", "technology"]),
            ageRange: 12...55,
            insight: "Digital art removes traditional barriers to creative expression. Your portfolio becomes a living document of your creative evolution."
        ),
        DreamTemplate(
            title: "Start a Photography Project",
            description: "Tell visual stories through a focused photography project that pushes your creative boundaries.",
            category: .creative, mood: .peaceful,
            suggestedSteps: ["Define your project theme", "Learn composition techniques", "Shoot weekly", "Edit and curate best shots", "Create a photo series", "Display or publish your work"],
            relevantSkills: Set(["photography", "art", "design"]),
            relevantInterests: Set(["photography", "art", "nature", "travel"]),
            ageRange: 12...65,
            insight: "Photography trains you to see beauty in the ordinary. A focused project gives your creative eye direction and purpose."
        ),
        DreamTemplate(
            title: "Plan a Dream Vacation",
            description: "Design and experience the trip of a lifetime to a place you've always wanted to visit.",
            category: .travel, mood: .exciting,
            suggestedSteps: ["Choose your dream destination", "Research best times to visit", "Create a savings plan", "Book flights and accommodation", "Plan your itinerary", "Go and make memories!"],
            relevantSkills: Set([]),
            relevantInterests: Set(["travel"]),
            ageRange: 18...70,
            insight: "Travel expands your worldview more than any book or course. The planning itself is part of the adventure."
        ),
        DreamTemplate(
            title: "Build an Emergency Fund",
            description: "Create financial security with 3-6 months of expenses saved for unexpected situations.",
            category: .financial, mood: .neutral,
            suggestedSteps: ["Calculate monthly expenses", "Set a target savings amount", "Open a high-yield savings account", "Automate monthly transfers", "Cut unnecessary expenses", "Reach your savings goal"],
            relevantSkills: Set(["analytics", "finance"]),
            relevantInterests: Set(["business"]),
            ageRange: 18...60,
            insight: "Financial security isn't about wealth — it's about freedom. An emergency fund removes the anxiety that blocks creative thinking."
        ),
        DreamTemplate(
            title: "Journal Every Day",
            description: "Develop self-awareness and clarity through a daily journaling practice.",
            category: .personalGrowth, mood: .peaceful,
            suggestedSteps: ["Choose a journal format", "Write at the same time daily", "Start with gratitude entries", "Reflect on weekly progress", "Complete a 60-day streak"],
            relevantSkills: Set(["writing"]),
            relevantInterests: Set(["psychology", "health"]),
            ageRange: 12...70,
            insight: "Journaling externalizes your thoughts, making patterns visible that are invisible in your mind. It's therapy you give yourself."
        ),
        DreamTemplate(
            title: "Build a Powerful Morning Routine",
            description: "Start every day with intention and energy through a carefully crafted morning ritual.",
            category: .personalGrowth, mood: .exciting,
            suggestedSteps: ["Wake up 30 minutes earlier", "Add exercise or stretching", "Include mindfulness or meditation", "Plan your top 3 priorities", "Maintain for 30 consecutive days"],
            relevantSkills: Set(["fitness"]),
            relevantInterests: Set(["health", "psychology"]),
            ageRange: 14...70,
            insight: "Your morning routine sets the trajectory for your entire day. Winning the morning means winning the day."
        ),
        DreamTemplate(
            title: "Build Your First App",
            description: "Bring your ideas to life by learning to build a mobile or web application from scratch.",
            category: .technology, mood: .exciting,
            suggestedSteps: ["Choose a platform (iOS, Android, Web)", "Learn the fundamentals", "Design your app concept", "Build a working prototype", "Test with real users", "Launch on a store or platform"],
            relevantSkills: Set(["programming", "design", "engineering"]),
            relevantInterests: Set(["technology", "science"]),
            ageRange: 14...50,
            insight: "Building an app teaches you to think in systems. It's the intersection of creativity, logic, and empathy for users."
        ),
        DreamTemplate(
            title: "Learn AI & Machine Learning",
            description: "Understand the technology shaping the future by diving into AI fundamentals.",
            category: .technology, mood: .mysterious,
            suggestedSteps: ["Learn Python basics", "Study ML fundamentals", "Complete an AI course", "Build a simple ML model", "Apply AI to a real problem"],
            relevantSkills: Set(["programming", "analytics", "engineering"]),
            relevantInterests: Set(["technology", "science"]),
            ageRange: 16...50,
            insight: "AI literacy is becoming as essential as digital literacy. Understanding it positions you at the frontier of every industry."
        ),
        DreamTemplate(
            title: "Volunteer Regularly",
            description: "Make a meaningful impact in your community through consistent volunteer work.",
            category: .social, mood: .joyful,
            suggestedSteps: ["Identify causes you care about", "Research local organizations", "Commit to a regular schedule", "Complete 50 volunteer hours", "Inspire others to join"],
            relevantSkills: Set(["leadership", "communication", "teaching"]),
            relevantInterests: Set(["volunteering"]),
            ageRange: 14...70,
            insight: "Service to others is paradoxically one of the best things you can do for yourself. It builds purpose, connection, and perspective."
        ),
        DreamTemplate(
            title: "Try 12 New Experiences",
            description: "Step outside your comfort zone with one new experience every month for a year.",
            category: .adventure, mood: .exciting,
            suggestedSteps: ["Brainstorm 20 experiences you've never tried", "Pick one per month", "Document each experience", "Rate and reflect on each one", "Share your favorites with others"],
            relevantSkills: Set([]),
            relevantInterests: Set(["travel", "sports", "nature"]),
            ageRange: 14...60,
            insight: "Novelty is the antidote to stagnation. Each new experience rewires your brain and expands your sense of what's possible."
        ),
        DreamTemplate(
            title: "Start a Podcast",
            description: "Share your voice and ideas with the world through your own podcast show.",
            category: .creative, mood: .exciting,
            suggestedSteps: ["Define your podcast concept and audience", "Get recording equipment", "Record your first 3 episodes", "Launch on podcast platforms", "Build a consistent release schedule", "Reach 100 listeners"],
            relevantSkills: Set(["communication", "marketing", "music"]),
            relevantInterests: Set(["technology", "business", "movies"]),
            ageRange: 16...55,
            insight: "Podcasting develops your voice — literally and figuratively. Teaching others forces you to deeply understand your subject."
        ),
        DreamTemplate(
            title: "Write a Short Story Collection",
            description: "Channel your creativity into compelling narratives that captivate readers.",
            category: .creative, mood: .mysterious,
            suggestedSteps: ["Brainstorm story ideas", "Write one short story per month", "Join a writing workshop", "Get feedback from beta readers", "Edit and polish your collection", "Publish or submit to magazines"],
            relevantSkills: Set(["writing", "communication"]),
            relevantInterests: Set(["reading", "art"]),
            ageRange: 14...70,
            insight: "Writing fiction is an exercise in radical empathy. Creating characters teaches you to see the world through completely different eyes."
        ),
        DreamTemplate(
            title: "Build a Workout Routine",
            description: "Create a sustainable fitness habit that transforms your energy and confidence.",
            category: .health, mood: .exciting,
            suggestedSteps: ["Set specific fitness goals", "Choose your workout style", "Start with 3 days per week", "Track your progress", "Increase intensity gradually", "Hit a personal record"],
            relevantSkills: Set(["fitness"]),
            relevantInterests: Set(["sports", "health"]),
            ageRange: 14...60,
            insight: "Physical fitness is the foundation that supports every other dream. A strong body creates a strong mind."
        ),
        DreamTemplate(
            title: "Build a Personal Brand",
            description: "Establish yourself as a thought leader in your industry.",
            category: .career, mood: .exciting,
            suggestedSteps: ["Define your unique value proposition", "Create content strategy", "Build social media presence", "Write articles or blog posts", "Speak at events or podcasts"],
            relevantSkills: Set(["marketing", "writing", "communication", "design"]),
            relevantInterests: Set(["business", "technology"]),
            ageRange: 16...50,
            insight: "Your personal brand is your reputation at scale. In the attention economy, visibility compounds like interest."
        ),
    ]

    func suggestDreams(for profile: UserProfile, excluding existingDreams: [Dream] = []) -> [DreamTemplate] {
        let userSkills = Set(profile.skills.map { $0.lowercased() })
        let userInterests = Set(profile.interests.map { $0.lowercased() })
        let existingTitles = Set(existingDreams.map(\.title))

        return templates
            .filter { !existingTitles.contains($0.title) }
            .filter { $0.ageRange.contains(profile.age) }
            .sorted { t1, t2 in
                scoreTemplate(t1, skills: userSkills, interests: userInterests) >
                scoreTemplate(t2, skills: userSkills, interests: userInterests)
            }
    }

    func generateInsight(for dream: Dream, profile: UserProfile?) -> String {
        if let template = templates.first(where: { $0.title == dream.title }) {
            return template.insight
        }

        let name = profile?.name ?? "you"
        let progress = Int(dream.progress * 100)

        if dream.isCompleted {
            return "Congratulations on achieving this dream! Completing '\(dream.title)' demonstrates real commitment. Consider how this accomplishment can fuel your next aspiration."
        }

        if progress > 70 {
            return "You're \(progress)% through '\(dream.title)' — the finish line is in sight, \(name). The final stretch often feels hardest, but momentum is on your side."
        }

        if progress > 30 {
            return "Solid progress at \(progress)%, \(name). You've built real momentum with '\(dream.title)'. Focus on one step at a time to maintain consistency."
        }

        return "Every dream starts with a single step, \(name). '\(dream.title)' is waiting for you to begin. Break it into small, actionable pieces and start today."
    }

    func analyzeDreamPatterns(dreams: [Dream]) -> [PatternInsight] {
        var insights: [PatternInsight] = []

        let categoryGroups = Dictionary(grouping: dreams, by: \.categoryRaw)
        if let topCategory = categoryGroups.max(by: { $0.value.count < $1.value.count }) {
            let cat = DreamCategory(rawValue: topCategory.key) ?? .personalGrowth
            insights.append(PatternInsight(
                title: "Your Focus Area",
                description: "You're drawn to \(cat.rawValue) dreams — \(topCategory.value.count) out of \(dreams.count). This reveals a core drive in your aspirations.",
                icon: cat.icon,
                color: cat.color
            ))
        }

        let completed = dreams.filter(\.isCompleted)
        if !completed.isEmpty {
            let rate = Int(Double(completed.count) / Double(dreams.count) * 100)
            insights.append(PatternInsight(
                title: "Completion Rate",
                description: "You've achieved \(rate)% of your dreams. \(rate > 50 ? "Outstanding consistency!" : "Every completed dream builds momentum for the next.")",
                icon: "chart.line.uptrend.xyaxis",
                color: .green
            ))
        }

        let moodGroups = Dictionary(grouping: dreams, by: \.moodRaw)
        if let topMood = moodGroups.max(by: { $0.value.count < $1.value.count }) {
            let m = DreamMood(rawValue: topMood.key) ?? .neutral
            insights.append(PatternInsight(
                title: "Emotional Pattern",
                description: "Your dreams tend to feel \(m.rawValue.lowercased()). This emotional signature reveals what truly motivates you.",
                icon: m.icon,
                color: m.color
            ))
        }

        let active = dreams.filter { !$0.isCompleted }
        if active.count > 5 {
            insights.append(PatternInsight(
                title: "Focus Check",
                description: "You have \(active.count) active dreams. Consider focusing on 3-5 at a time for deeper progress on each.",
                icon: "scope",
                color: .orange
            ))
        }

        let highPriority = dreams.filter { $0.priority == 3 && !$0.isCompleted }
        if !highPriority.isEmpty {
            insights.append(PatternInsight(
                title: "Priority Dreams",
                description: "\(highPriority.count) high-priority dream\(highPriority.count == 1 ? "" : "s") need\(highPriority.count == 1 ? "s" : "") your attention. Start each day with one small step toward these.",
                icon: "flame.fill",
                color: .red
            ))
        }

        if insights.isEmpty {
            insights.append(PatternInsight(
                title: "Getting Started",
                description: "Add more dreams to unlock personalized pattern analysis. Your dream collection tells a story — let's write it together.",
                icon: "sparkles",
                color: .purple
            ))
        }

        return insights
    }

    private func scoreTemplate(_ template: DreamTemplate, skills: Set<String>, interests: Set<String>) -> Int {
        let skillMatch = template.relevantSkills.intersection(skills).count
        let interestMatch = template.relevantInterests.intersection(interests).count
        return skillMatch * 3 + interestMatch * 2
    }
}

struct PatternInsight {
    let title: String
    let description: String
    let icon: String
    let color: Color
}

import SwiftUI
