import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Notebook", systemImage: "book.fill", value: 0) {
                DreamsView()
            }
            Tab("Insights", systemImage: "brain.head.profile.fill", value: 1) {
                DiscoverView()
            }
            Tab("Assistant", systemImage: "sparkles", value: 2) {
                ChatView()
            }
            Tab("Profile", systemImage: "person.crop.circle.fill", value: 3) {
                ProfileView()
            }
        }
        .tint(.primary)
    }
}
