import SwiftUI

struct MainTabView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var selectedTab: Int = 0

    var body: some View {
        if !authViewModel.isLoggedIn {
            LoginView()
                .environment(authViewModel)
        } else {
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
                    .environment(authViewModel)
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("마이")
                    }
                    .tag(2)
            }
            .tint(AppColor.primary)
        }
    }
}

#Preview {
    MainTabView()
        .environment(AuthViewModel())
}
