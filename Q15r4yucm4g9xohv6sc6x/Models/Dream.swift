import Foundation
import SwiftData
import SwiftUI

nonisolated enum DreamMood: String, Codable, CaseIterable, Sendable {
    case peaceful = "Peaceful"
    case joyful = "Joyful"
    case anxious = "Anxious"
    case mysterious = "Mysterious"
    case fearful = "Fearful"
    case exciting = "Exciting"
    case sad = "Sad"
    case neutral = "Neutral"
    case surreal = "Surreal"
    case nostalgic = "Nostalgic"

    var icon: String {
        switch self {
        case .peaceful: "moon.stars.fill"
        case .joyful: "sun.max.fill"
        case .anxious: "cloud.bolt.fill"
        case .mysterious: "eye.fill"
        case .fearful: "bolt.fill"
        case .exciting: "flame.fill"
        case .sad: "cloud.rain.fill"
        case .neutral: "circle.fill"
        case .surreal: "sparkles"
        case .nostalgic: "clock.fill"
        }
    }

    var color: Color {
        switch self {
        case .peaceful: .cyan
        case .joyful: .yellow
        case .anxious: .orange
        case .mysterious: .purple
        case .fearful: .red
        case .exciting: .pink
        case .sad: .blue
        case .neutral: .gray
        case .surreal: .indigo
        case .nostalgic: .brown
        }
    }
}

nonisolated enum DreamCategory: String, Codable, CaseIterable, Sendable {
    case career = "Career"
    case health = "Health"
    case education = "Education"
    case creative = "Creative"
    case travel = "Travel"
    case financial = "Financial"
    case personalGrowth = "Personal Growth"
    case technology = "Technology"
    case social = "Social"
    case adventure = "Adventure"

    var icon: String {
        switch self {
        case .career: "briefcase.fill"
        case .health: "heart.fill"
        case .education: "book.fill"
        case .creative: "paintbrush.fill"
        case .travel: "airplane"
        case .financial: "dollarsign.circle.fill"
        case .personalGrowth: "leaf.fill"
        case .technology: "laptopcomputer"
        case .social: "person.2.fill"
        case .adventure: "figure.hiking"
        }
    }

    var color: Color {
        switch self {
        case .career: .blue
        case .health: .red
        case .education: .orange
        case .creative: .purple
        case .travel: .teal
        case .financial: .green
        case .personalGrowth: .mint
        case .technology: .indigo
        case .social: .pink
        case .adventure: .brown
        }
    }
}

nonisolated struct DreamStep: Codable, Hashable, Sendable {
    var title: String
    var isCompleted: Bool

    init(title: String, isCompleted: Bool = false) {
        self.title = title
        self.isCompleted = isCompleted
    }
}

nonisolated struct DreamTag: Codable, Hashable, Sendable {
    var name: String
}

@Model
class Dream {
    var title: String
    var dreamDescription: String
    var categoryRaw: String
    var moodRaw: String
    var priority: Int
    var steps: [DreamStep]
    var tags: [DreamTag]
    var isCompleted: Bool
    var createdAt: Date
    var targetDate: Date?
    var aiGenerated: Bool
    var aiInsight: String?
    var journalNotes: String?
    var lucidityLevel: Int

    var category: DreamCategory {
        DreamCategory(rawValue: categoryRaw) ?? .personalGrowth
    }

    var mood: DreamMood {
        DreamMood(rawValue: moodRaw) ?? .neutral
    }

    var progress: Double {
        guard !steps.isEmpty else { return isCompleted ? 1.0 : 0.0 }
        return Double(steps.filter(\.isCompleted).count) / Double(steps.count)
    }

    init(
        title: String,
        dreamDescription: String,
        category: DreamCategory,
        mood: DreamMood = .neutral,
        priority: Int = 2,
        steps: [DreamStep] = [],
        tags: [DreamTag] = [],
        targetDate: Date? = nil,
        aiGenerated: Bool = false,
        aiInsight: String? = nil,
        lucidityLevel: Int = 1
    ) {
        self.title = title
        self.dreamDescription = dreamDescription
        self.categoryRaw = category.rawValue
        self.moodRaw = mood.rawValue
        self.priority = priority
        self.steps = steps
        self.tags = tags
        self.isCompleted = false
        self.createdAt = Date()
        self.targetDate = targetDate
        self.aiGenerated = aiGenerated
        self.aiInsight = aiInsight
        self.journalNotes = nil
        self.lucidityLevel = lucidityLevel
    }
}
