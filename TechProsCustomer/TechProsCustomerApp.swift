import SwiftUI

@main
struct TechProsCustomerApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .preferredColorScheme(.light)
                .onOpenURL { url in
                    // Handle deep links (e.g. password reset from email)
                    Task {
                        try? await supabase.auth.session(from: url)
                    }
                }
        }
    }
}
