import Foundation

nonisolated struct DreamTemplate: Sendable {
    let title: String
    let description: String
    let category: DreamCategory
    let suggestedSteps: [String]
    let relevantSkills: Set<String>
    let relevantInterests: Set<String>
    let ageRange: ClosedRange<Int>
}

class DreamEngine {
    static let shared = DreamEngine()

    private let templates: [DreamTemplate] = [
        DreamTemplate(
            title: "Launch a Side Business",
            description: "Turn your passion into a profitable venture. Start small, think big, and build something meaningful.",
            category: .career,
            suggestedSteps: ["Identify your niche and target market", "Create a business plan", "Build a minimum viable product", "Set up online presence", "Launch and get first customers", "Iterate based on feedback"],
            relevantSkills: Set(["marketing", "leadership", "communication", "design", "programming"]),
            relevantInterests: Set(["business", "technology"]),
            ageRange: 16...55
        ),
        DreamTemplate(
            title: "Earn a Professional Certification",
            description: "Level up your career with a recognized certification in your field.",
            category: .career,
            suggestedSteps: ["Research certifications in your field", "Choose exam and register", "Create a study schedule", "Complete practice tests", "Pass the certification exam"],
            relevantSkills: Set(["analytics", "problem solving", "engineering"]),
            relevantInterests: Set(["education", "business", "technology"]),
            ageRange: 18...50
        ),
        DreamTemplate(
            title: "Master Public Speaking",
            description: "Overcome stage fright and become a confident, compelling speaker.",
            category: .career,
            suggestedSteps: ["Join a speaking group or club", "Prepare a 5-minute talk", "Practice in front of friends", "Give a talk at a local event", "Seek feedback and refine your style"],
            relevantSkills: Set(["communication", "leadership", "public speaking"]),
            relevantInterests: Set(["business", "education"]),
            ageRange: 14...60
        ),
        DreamTemplate(
            title: "Land Your Dream Job",
            description: "Position yourself for the career you've always wanted through strategic preparation.",
            category: .career,
            suggestedSteps: ["Define your ideal role and company", "Update resume and portfolio", "Network with industry professionals", "Prepare for interviews", "Apply to target companies", "Negotiate your offer"],
            relevantSkills: Set(["communication", "leadership", "problem solving"]),
            relevantInterests: Set(["business"]),
            ageRange: 18...45
        ),
        DreamTemplate(
            title: "Build a Personal Brand",
            description: "Establish yourself as a thought leader and create a recognizable presence in your industry.",
            category: .career,
            suggestedSteps: ["Define your unique value proposition", "Create content strategy", "Build social media presence", "Write articles or blog posts", "Speak at events or podcasts"],
            relevantSkills: Set(["marketing", "writing", "communication", "design"]),
            relevantInterests: Set(["business", "technology"]),
            ageRange: 16...50
        ),
        DreamTemplate(
            title: "Run a Half Marathon",
            description: "Challenge yourself physically and mentally by training for and completing a half marathon.",
            category: .health,
            suggestedSteps: ["Get a health checkup", "Start with a couch-to-5K plan", "Build up weekly mileage", "Complete a 10K race", "Follow a half marathon training plan", "Race day - finish strong!"],
            relevantSkills: Set(["fitness"]),
            relevantInterests: Set(["sports", "health"]),
            ageRange: 14...55
        ),
        DreamTemplate(
            title: "Develop a Daily Meditation Practice",
            description: "Find inner calm and clarity through a consistent meditation routine.",
            category: .health,
            suggestedSteps: ["Start with 5 minutes daily", "Try different meditation styles", "Build up to 15 minutes", "Create a dedicated meditation space", "Maintain a 30-day streak"],
            relevantSkills: Set([]),
            relevantInterests: Set(["health", "psychology"]),
            ageRange: 12...70
        ),
        DreamTemplate(
            title: "Master Healthy Cooking",
            description: "Learn to prepare nutritious, delicious meals that fuel your body and delight your taste buds.",
            category: .health,
            suggestedSteps: ["Learn 5 basic cooking techniques", "Plan weekly meal prep", "Master 10 healthy recipes", "Experiment with global cuisines", "Cook a healthy dinner party"],
            relevantSkills: Set(["cooking"]),
            relevantInterests: Set(["food", "health"]),
            ageRange: 14...65
        ),
        DreamTemplate(
            title: "Build a Workout Routine",
            description: "Create a sustainable fitness habit that transforms your energy and confidence.",
            category: .health,
            suggestedSteps: ["Set specific fitness goals", "Choose your workout style", "Start with 3 days per week", "Track your progress", "Increase intensity gradually", "Hit a personal record"],
            relevantSkills: Set(["fitness"]),
            relevantInterests: Set(["sports", "health"]),
            ageRange: 14...60
        ),
        DreamTemplate(
            title: "Learn a New Language",
            description: "Open doors to new cultures and connections by becoming conversational in another language.",
            category: .education,
            suggestedSteps: ["Choose your target language", "Start with basics and pronunciation", "Practice daily for 20 minutes", "Find a language exchange partner", "Watch shows in that language", "Have a 10-minute conversation"],
            relevantSkills: Set(["languages", "communication"]),
            relevantInterests: Set(["travel", "education"]),
            ageRange: 10...70
        ),
        DreamTemplate(
            title: "Read 30 Books This Year",
            description: "Expand your mind and perspective through a dedicated reading challenge.",
            category: .education,
            suggestedSteps: ["Create a reading list", "Set aside 30 minutes daily for reading", "Join a book club", "Mix fiction and non-fiction", "Track and review each book", "Share your favorites with friends"],
            relevantSkills: Set(["writing"]),
            relevantInterests: Set(["reading", "education"]),
            ageRange: 12...70
        ),
        DreamTemplate(
            title: "Complete an Online Course",
            description: "Gain new knowledge and skills through structured online learning.",
            category: .education,
            suggestedSteps: ["Choose a platform and course", "Set a weekly study schedule", "Complete all modules", "Do hands-on projects", "Earn your certificate"],
            relevantSkills: Set(["problem solving", "analytics"]),
            relevantInterests: Set(["education", "technology", "science"]),
            ageRange: 14...60
        ),
        DreamTemplate(
            title: "Master a Musical Instrument",
            description: "Express yourself through music by learning to play an instrument you love.",
            category: .creative,
            suggestedSteps: ["Choose your instrument", "Find a teacher or course", "Practice 20 minutes daily", "Learn 5 songs you love", "Perform for friends or family", "Join a jam session or band"],
            relevantSkills: Set(["music"]),
            relevantInterests: Set(["music"]),
            ageRange: 10...70
        ),
        DreamTemplate(
            title: "Write a Short Story Collection",
            description: "Channel your creativity into compelling narratives that captivate readers.",
            category: .creative,
            suggestedSteps: ["Brainstorm story ideas", "Write one short story per month", "Join a writing workshop", "Get feedback from beta readers", "Edit and polish your collection", "Publish or submit to magazines"],
            relevantSkills: Set(["writing", "communication"]),
            relevantInterests: Set(["reading", "art"]),
            ageRange: 14...70
        ),
        DreamTemplate(
            title: "Create a Digital Art Portfolio",
            description: "Build a stunning collection of digital artwork that showcases your unique style.",
            category: .creative,
            suggestedSteps: ["Learn digital art fundamentals", "Choose your tools and software", "Create 10 portfolio pieces", "Develop a consistent style", "Build an online portfolio", "Share on art communities"],
            relevantSkills: Set(["art", "design", "photography"]),
            relevantInterests: Set(["art", "technology"]),
            ageRange: 12...55
        ),
        DreamTemplate(
            title: "Start a Photography Project",
            description: "Tell visual stories through a focused photography project that pushes your creative boundaries.",
            category: .creative,
            suggestedSteps: ["Define your project theme", "Learn composition techniques", "Shoot weekly", "Edit and curate best shots", "Create a photo series", "Display or publish your work"],
            relevantSkills: Set(["photography", "art", "design"]),
            relevantInterests: Set(["photography", "art", "nature", "travel"]),
            ageRange: 12...65
        ),
        DreamTemplate(
            title: "Plan a Dream Vacation",
            description: "Design and experience the trip of a lifetime to a place you've always wanted to visit.",
            category: .travel,
            suggestedSteps: ["Choose your dream destination", "Research best times to visit", "Create a savings plan", "Book flights and accommodation", "Plan your itinerary", "Go and make memories!"],
            relevantSkills: Set([]),
            relevantInterests: Set(["travel"]),
            ageRange: 18...70
        ),
        DreamTemplate(
            title: "Travel Solo for the First Time",
            description: "Discover independence and self-confidence through a transformative solo travel experience.",
            category: .travel,
            suggestedSteps: ["Choose a safe, beginner-friendly destination", "Plan your budget", "Book accommodation in social areas", "Research local customs", "Pack light and smart", "Embrace the adventure!"],
            relevantSkills: Set(["communication", "languages"]),
            relevantInterests: Set(["travel", "nature"]),
            ageRange: 18...50
        ),
        DreamTemplate(
            title: "Explore 10 Local Hidden Gems",
            description: "Become a tourist in your own city and discover amazing places you never knew existed.",
            category: .travel,
            suggestedSteps: ["Research local attractions and hidden spots", "Create a bucket list of 10 places", "Visit one new place per week", "Document each visit with photos", "Write reviews to help others discover them"],
            relevantSkills: Set(["photography"]),
            relevantInterests: Set(["travel", "nature", "photography"]),
            ageRange: 12...70
        ),
        DreamTemplate(
            title: "Build an Emergency Fund",
            description: "Create financial security with 3-6 months of expenses saved for unexpected situations.",
            category: .financial,
            suggestedSteps: ["Calculate monthly expenses", "Set a target savings amount", "Open a high-yield savings account", "Automate monthly transfers", "Cut unnecessary expenses", "Reach your savings goal"],
            relevantSkills: Set(["analytics", "finance"]),
            relevantInterests: Set(["business"]),
            ageRange: 18...60
        ),
        DreamTemplate(
            title: "Start Investing",
            description: "Grow your wealth over time by learning the fundamentals of investing.",
            category: .financial,
            suggestedSteps: ["Learn investing basics", "Define your risk tolerance", "Open an investment account", "Start with index funds", "Set up automatic contributions", "Review and rebalance quarterly"],
            relevantSkills: Set(["analytics", "finance"]),
            relevantInterests: Set(["business", "technology"]),
            ageRange: 18...55
        ),
        DreamTemplate(
            title: "Journal Every Day",
            description: "Develop self-awareness and clarity through a daily journaling practice.",
            category: .personalGrowth,
            suggestedSteps: ["Choose a journal format", "Write at the same time daily", "Start with gratitude entries", "Reflect on weekly progress", "Complete a 60-day streak"],
            relevantSkills: Set(["writing"]),
            relevantInterests: Set(["psychology", "health"]),
            ageRange: 12...70
        ),
        DreamTemplate(
            title: "Build a Powerful Morning Routine",
            description: "Start every day with intention and energy through a carefully crafted morning ritual.",
            category: .personalGrowth,
            suggestedSteps: ["Wake up 30 minutes earlier", "Add exercise or stretching", "Include mindfulness or meditation", "Plan your top 3 priorities", "Maintain for 30 consecutive days"],
            relevantSkills: Set(["fitness"]),
            relevantInterests: Set(["health", "psychology"]),
            ageRange: 14...70
        ),
        DreamTemplate(
            title: "Practice Daily Gratitude",
            description: "Transform your mindset by actively recognizing and appreciating the good in your life.",
            category: .personalGrowth,
            suggestedSteps: ["Write 3 things you're grateful for daily", "Share appreciation with someone weekly", "Create a gratitude jar", "Review your entries monthly", "Notice the shift in your perspective"],
            relevantSkills: Set(["communication"]),
            relevantInterests: Set(["psychology", "health"]),
            ageRange: 12...70
        ),
        DreamTemplate(
            title: "Build Your First App",
            description: "Bring your ideas to life by learning to build a mobile or web application from scratch.",
            category: .technology,
            suggestedSteps: ["Choose a platform (iOS, Android, Web)", "Learn the fundamentals", "Design your app concept", "Build a working prototype", "Test with real users", "Launch on a store or platform"],
            relevantSkills: Set(["programming", "design", "engineering"]),
            relevantInterests: Set(["technology", "science"]),
            ageRange: 14...50
        ),
        DreamTemplate(
            title: "Learn AI & Machine Learning",
            description: "Understand the technology shaping the future by diving into AI fundamentals.",
            category: .technology,
            suggestedSteps: ["Learn Python basics", "Study ML fundamentals", "Complete an AI course", "Build a simple ML model", "Apply AI to a real problem"],
            relevantSkills: Set(["programming", "analytics", "engineering"]),
            relevantInterests: Set(["technology", "science"]),
            ageRange: 16...50
        ),
        DreamTemplate(
            title: "Create a Website or Blog",
            description: "Share your knowledge and passions with the world through your own online platform.",
            category: .technology,
            suggestedSteps: ["Choose your niche and platform", "Set up hosting and domain", "Design your site layout", "Write your first 5 posts", "Build an audience", "Monetize or grow your reach"],
            relevantSkills: Set(["programming", "writing", "design", "marketing"]),
            relevantInterests: Set(["technology", "business"]),
            ageRange: 14...60
        ),
        DreamTemplate(
            title: "Volunteer Regularly",
            description: "Make a meaningful impact in your community through consistent volunteer work.",
            category: .social,
            suggestedSteps: ["Identify causes you care about", "Research local organizations", "Commit to a regular schedule", "Complete 50 volunteer hours", "Inspire others to join"],
            relevantSkills: Set(["leadership", "communication", "teaching"]),
            relevantInterests: Set(["volunteering"]),
            ageRange: 14...70
        ),
        DreamTemplate(
            title: "Build a Meaningful Community",
            description: "Create deep, lasting connections by actively building and nurturing your social circle.",
            category: .social,
            suggestedSteps: ["Identify shared interests with potential friends", "Organize a monthly meetup or gathering", "Reach out to one new person weekly", "Deepen existing friendships", "Create a group around your passion"],
            relevantSkills: Set(["communication", "leadership"]),
            relevantInterests: Set(["volunteering", "psychology"]),
            ageRange: 16...70
        ),
        DreamTemplate(
            title: "Try 12 New Experiences",
            description: "Step outside your comfort zone with one new experience every month for a year.",
            category: .adventure,
            suggestedSteps: ["Brainstorm 20 experiences you've never tried", "Pick one per month", "Document each experience", "Rate and reflect on each one", "Share your favorites with others"],
            relevantSkills: Set([]),
            relevantInterests: Set(["travel", "sports", "nature"]),
            ageRange: 14...60
        ),
        DreamTemplate(
            title: "Learn a Water Sport",
            description: "Conquer the waves by mastering surfing, kayaking, paddleboarding, or another water sport.",
            category: .adventure,
            suggestedSteps: ["Choose your water sport", "Take a beginner lesson", "Get the right gear", "Practice weekly", "Complete a challenge or trip"],
            relevantSkills: Set(["fitness"]),
            relevantInterests: Set(["sports", "nature", "travel"]),
            ageRange: 14...50
        ),
        DreamTemplate(
            title: "Start a Podcast",
            description: "Share your voice and ideas with the world through your own podcast show.",
            category: .creative,
            suggestedSteps: ["Define your podcast concept and audience", "Get recording equipment", "Record your first 3 episodes", "Launch on podcast platforms", "Build a consistent release schedule", "Reach 100 listeners"],
            relevantSkills: Set(["communication", "marketing", "music"]),
            relevantInterests: Set(["technology", "business", "movies"]),
            ageRange: 16...55
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

    private func scoreTemplate(_ template: DreamTemplate, skills: Set<String>, interests: Set<String>) -> Int {
        let skillMatch = template.relevantSkills.intersection(skills).count
        let interestMatch = template.relevantInterests.intersection(interests).count
        return skillMatch * 3 + interestMatch * 2
    }
}
