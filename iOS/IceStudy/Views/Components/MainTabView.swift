import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
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
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("마이")
                }
                .tag(2)
        }
        .tint(AppColor.primary)
    }
}

#Preview {
    MainTabView()
}
