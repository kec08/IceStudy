import SwiftUI

struct MainTabView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var selectedTab: Int = 0
    @State private var homeNeedsRefresh = false

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(needsRefresh: $homeNeedsRefresh)
                .tabItem {
                    Image("MdiCup")
                        .renderingMode(.template)
                    Text("양동이")
                }
                .tag(0)

            IceTimerFlowView()
                .tabItem {
                    Image(systemName: "cube.fill")
                    Text("얼음")
                }
                .tag(1)

            ProfileView()
                .environment(authViewModel)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("마이")
                }
                .tag(2)
        }
        .tint(AppColor.primary)
        .onChange(of: selectedTab) { _, newTab in
            if newTab == 0 {
                homeNeedsRefresh = true
            }
        }
    }
}

#Preview {
    MainTabView()
        .environment(AuthViewModel())
}
