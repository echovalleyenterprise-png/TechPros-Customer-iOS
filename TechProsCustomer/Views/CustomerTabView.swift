import SwiftUI

struct CustomerTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            ChatTab()
                .tabItem {
                    Label("Help", systemImage: "bubble.left.and.bubble.right.fill")
                }
                .tag(0)

            GuidesTab()
                .tabItem {
                    Label("Guides", systemImage: "book.fill")
                }
                .tag(1)

            AccountTab()
                .tabItem {
                    Label("Account", systemImage: "person.circle.fill")
                }
                .tag(2)
        }
        .tint(Color(red: 0.1, green: 0.5, blue: 1.0))
    }
}

// MARK: - Chat Tab wrapper

struct ChatTab: View {
    var body: some View {
        CustomerChatView()
    }
}

// MARK: - Guides Tab wrapper

struct GuidesTab: View {
    var body: some View {
        CustomerGuidesView()
    }
}

// MARK: - Account Tab

struct AccountTab: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 14) {
                        Circle()
                            .fill(LinearGradient(
                                colors: [Color(red: 0.1, green: 0.5, blue: 1.0), Color(red: 0.3, green: 0.7, blue: 1.0)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ))
                            .frame(width: 52, height: 52)
                            .overlay(
                                Text(String(appState.displayName.prefix(1)).uppercased())
                                    .font(.title3).fontWeight(.bold).foregroundColor(.white)
                            )
                        VStack(alignment: .leading, spacing: 2) {
                            Text(appState.displayName)
                                .font(.headline)
                            Text(appState.currentUser?.email ?? "")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 6)
                }

                Section("Support") {
                    Label("How Tech Pros Works", systemImage: "questionmark.circle")
                    Label("Contact Support", systemImage: "envelope")
                    Label("Privacy Policy", systemImage: "hand.raised")
                    Label("Terms of Service", systemImage: "doc.text")
                }

                Section {
                    Button(role: .destructive) {
                        Task { await appState.signOut() }
                    } label: {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("Account")
        }
    }
}
