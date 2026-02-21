import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var profiles: [UserProfile]

    var body: some View {
        if let profile = profiles.first, profile.onboardingCompleted {
            MainTabView()
        } else {
            OnboardingView()
        }
    }
}
