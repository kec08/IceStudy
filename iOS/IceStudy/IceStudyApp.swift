import SwiftUI

@main
struct IceStudyApp: App {
    @State private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            SplashView()
                .environment(authViewModel)
        }
    }
}
