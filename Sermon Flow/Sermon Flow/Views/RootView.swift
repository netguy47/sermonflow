
import SwiftUI

struct RootView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MainTimelineView()
                .tabItem {
                    Label("Timeline", systemImage: "clock.v2")
                }
                .tag(0)
            
            SermonArchitectView()
                .tabItem {
                    Label("Create", systemImage: "sparkles")
                }
                .tag(1)
        }
        .accentColor(.sermonGold)
        .onAppear {
            // Configure TabBar appearance if needed
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Color.parchment)
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

#Preview {
    RootView()
}
