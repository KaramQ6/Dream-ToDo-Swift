import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Dreams", systemImage: "star.fill", value: 0) {
                DreamsView()
            }
            Tab("Discover", systemImage: "sparkles", value: 1) {
                DiscoverView()
            }
            Tab("Chat", systemImage: "bubble.left.and.bubble.right.fill", value: 2) {
                ChatView()
            }
            Tab("Profile", systemImage: "person.crop.circle.fill", value: 3) {
                ProfileView()
            }
        }
        .tint(.indigo)
    }
}
