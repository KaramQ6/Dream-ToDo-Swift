import Foundation
import SwiftData

@Model
class UserProfile {
    var name: String
    var age: Int
    var skills: [String]
    var interests: [String]
    var onboardingCompleted: Bool
    var createdAt: Date
    var preferredTheme: String

    init(name: String = "", age: Int = 25, skills: [String] = [], interests: [String] = [], onboardingCompleted: Bool = false, preferredTheme: String = "system") {
        self.name = name
        self.age = age
        self.skills = skills
        self.interests = interests
        self.onboardingCompleted = onboardingCompleted
        self.createdAt = Date()
        self.preferredTheme = preferredTheme
    }
}
