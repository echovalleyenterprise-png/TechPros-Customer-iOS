import SwiftUI

struct LoginView: View {
    @ObservedObject var vm: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focused: Field?

    enum Field { case email, password }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color(red: 0.1, green: 0.5, blue: 1.0))
                        .padding(.top, 20)
                    Text("Welcome back")
                        .font(.title2).fontWeight(.bold)
                        .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                    Text("Sign in to your Tech Pros account")
                        .font(.subheadline).foregroundColor(.secondary)
                }

                // Fields
                VStack(spacing: 14) {
                    CustomerField(
                        placeholder: "Email address",
                        text: $vm.email,
                        keyboardType: .emailAddress,
                        focused: $focused,
                        tag: .email
                    )

                    CustomerSecureField(
                        placeholder: "Password",
                        text: $vm.password,
                        focused: $focused,
                        tag: .password
                    )
                }

                // Error
                if let err = vm.errorMessage {
                    ErrorBanner(message: err)
                }

                // Sign In button
                Button {
                    Task { await vm.signIn() }
                } label: {
                    Group {
                        if vm.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Sign In").font(.headline).foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.1, green: 0.5, blue: 1.0), Color(red: 0.3, green: 0.7, blue: 1.0)],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: .blue.opacity(0.3), radius: 8, y: 4)
                }
                .disabled(vm.isLoading)

                // Forgot password
                NavigationLink {
                    ForgotPasswordView(vm: vm)
                } label: {
                    Text("Forgot password?")
                        .font(.subheadline)
                        .foregroundColor(Color(red: 0.1, green: 0.5, blue: 1.0))
                }
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 40)
        }
        .navigationTitle("Sign In")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(red: 0.97, green: 0.98, blue: 1.0).ignoresSafeArea())
    }
}
