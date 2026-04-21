import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("양동이")
                }
                .tag(0)

            TempIceView()
                .tabItem {
                    Image(systemName: "cube.fill")
                    Text("얼음")
                }
                .tag(1)

            TempProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("마이")
                }
                .tag(2)
        }
        .tint(AppColor.primary)
    }
}

// MARK: - 임시 탭 화면들
struct TempIceView: View {
    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()
            VStack(spacing: 12) {
                Image(systemName: "cube.fill")
                    .font(.system(size: 48))
                    .foregroundColor(AppColor.primary.opacity(0.3))
                Text("얼음 타이머")
                    .font(AppFont.title2())
                    .foregroundColor(AppColor.textSecondary)
                Text("추후 구현 예정")
                    .font(AppFont.callout())
                    .foregroundColor(AppColor.textTertiary)
            }
        }
    }
}

struct TempProfileView: View {
    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()
            VStack(spacing: 12) {
                Image(systemName: "person.fill")
                    .font(.system(size: 48))
                    .foregroundColor(AppColor.primary.opacity(0.3))
                Text("마이페이지")
                    .font(AppFont.title2())
                    .foregroundColor(AppColor.textSecondary)
                Text("추후 구현 예정")
                    .font(AppFont.callout())
                    .foregroundColor(AppColor.textTertiary)
            }
        }
    }
}

#Preview {
    MainTabView()
}
