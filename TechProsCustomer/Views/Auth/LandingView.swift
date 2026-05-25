import SwiftUI

struct LandingView: View {
    @StateObject private var vm = AuthViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                // Light gradient background
                LinearGradient(
                    colors: [Color(red: 0.94, green: 0.97, blue: 1.0), Color.white],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    // Logo + brand
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    colors: [Color(red: 0.1, green: 0.5, blue: 1.0), Color(red: 0.3, green: 0.7, blue: 1.0)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 110, height: 110)
                                .shadow(color: .blue.opacity(0.3), radius: 20, y: 8)

                            Image(systemName: "house.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.white)
                        }

                        VStack(spacing: 8) {
                            Text("Tech Pros")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))

                            Text("Home Tech Help")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(Color(red: 0.1, green: 0.5, blue: 1.0))

                            Text("Get answers about your smart home devices\nright from your phone.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.top, 4)
                        }
                    }

                    Spacer()

                    // Feature pills
                    HStack(spacing: 10) {
                        FeaturePill(icon: "bubble.left.fill", text: "AI Help")
                        FeaturePill(icon: "book.fill", text: "Guides")
                        FeaturePill(icon: "camera.fill", text: "Photo Help")
                    }
                    .padding(.bottom, 36)

                    // Buttons
                    VStack(spacing: 14) {
                        NavigationLink {
                            LoginView(vm: vm)
                        } label: {
                            Text("Sign In")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 17)
                                .background(
                                    LinearGradient(
                                        colors: [Color(red: 0.1, green: 0.5, blue: 1.0), Color(red: 0.3, green: 0.7, blue: 1.0)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: .blue.opacity(0.35), radius: 10, y: 4)
                        }

                        NavigationLink {
                            SignUpView(vm: vm)
                        } label: {
                            Text("Create Account")
                                .font(.headline)
                                .foregroundColor(Color(red: 0.1, green: 0.5, blue: 1.0))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 17)
                                .background(Color.white)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(red: 0.1, green: 0.5, blue: 1.0).opacity(0.4), lineWidth: 1.5)
                                )
                        }
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 48)
                }
            }
        }
    }
}

struct FeaturePill: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(Color(red: 0.1, green: 0.5, blue: 1.0))
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }
}
