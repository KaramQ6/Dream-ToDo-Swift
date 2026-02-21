import Foundation
import SwiftData
import SwiftUI

nonisolated struct DreamStep: Codable, Hashable, Sendable {
    var title: String
    var isCompleted: Bool

    init(title: String, isCompleted: Bool = false) {
        self.title = title
        self.isCompleted = isCompleted
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

@Model
class Dream {
    var title: String
    var dreamDescription: String
    var categoryRaw: String
    var priority: Int
    var steps: [DreamStep]
    var isCompleted: Bool
    var createdAt: Date
    var targetDate: Date?
    var aiGenerated: Bool

    var category: DreamCategory {
        DreamCategory(rawValue: categoryRaw) ?? .personalGrowth
    }

    var progress: Double {
        guard !steps.isEmpty else { return isCompleted ? 1.0 : 0.0 }
        return Double(steps.filter(\.isCompleted).count) / Double(steps.count)
    }

    init(title: String, dreamDescription: String, category: DreamCategory, priority: Int = 2, steps: [DreamStep] = [], targetDate: Date? = nil, aiGenerated: Bool = false) {
        self.title = title
        self.dreamDescription = dreamDescription
        self.categoryRaw = category.rawValue
        self.priority = priority
        self.steps = steps
        self.isCompleted = false
        self.createdAt = Date()
        self.targetDate = targetDate
        self.aiGenerated = aiGenerated
    }
}
