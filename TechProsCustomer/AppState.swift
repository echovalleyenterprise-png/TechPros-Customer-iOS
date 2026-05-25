import SwiftUI
import Supabase

@MainActor
final class AppState: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = true

    private var authListenerTask: Task<Void, Never>?

    init() {
        AppState.current = self
        startAuthListener()
    }

    deinit {
        authListenerTask?.cancel()
    }

    // MARK: - Auth listener

    private func startAuthListener() {
        authListenerTask = Task {
            for await (event, session) in supabase.auth.authStateChanges {
                guard !Task.isCancelled else { break }
                await MainActor.run {
                    switch event {
                    case .initialSession, .signedIn, .tokenRefreshed:
                        self.isAuthenticated = session != nil
                        self.currentUser = session?.user
                        self.isLoading = false
                    case .signedOut:
                        self.isAuthenticated = false
                        self.currentUser = nil
                        self.isLoading = false
                    default:
                        self.isLoading = false
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    var displayName: String {
        if let user = currentUser {
            if case .string(let name) = user.userMetadata["full_name"], !name.isEmpty {
                return name
            }
            return user.email?.components(separatedBy: "@").first?.capitalized ?? "there"
        }
        return "there"
    }

    // MARK: - Sign out

    func signOut() async {
        try? await supabase.auth.signOut()
    }

    // MARK: - Access token for API calls

    var accessToken: String? {
        get async {
            return try? await supabase.auth.session.accessToken
        }
    }

    // MARK: - Shared reference for APIClient

    static weak var current: AppState?
}
