import SwiftUI

@main
struct OAuth2DemoApp: App {
    @State private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authViewModel)
                .task {
                    await authViewModel.checkSession()
                }
        }
    }
}
