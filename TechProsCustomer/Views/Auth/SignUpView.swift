import SwiftUI

struct SignUpView: View {
    @ObservedObject var vm: AuthViewModel
    @FocusState private var focused: Field?

    enum Field { case name, email, password, confirm }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "person.badge.plus.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color(red: 0.1, green: 0.5, blue: 1.0))
                        .padding(.top, 20)
                    Text("Create your account")
                        .font(.title2).fontWeight(.bold)
                        .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                    Text("Get instant help with your home tech")
                        .font(.subheadline).foregroundColor(.secondary)
                }

                // Fields
                VStack(spacing: 14) {
                    CustomerField(placeholder: "Full name", text: $vm.fullName, focused: $focused, tag: .name)
                    CustomerField(placeholder: "Email address", text: $vm.email, keyboardType: .emailAddress, focused: $focused, tag: .email)
                    CustomerSecureField(placeholder: "Password (8+ characters)", text: $vm.password, focused: $focused, tag: .password)
                    CustomerSecureField(placeholder: "Confirm password", text: $vm.confirmPassword, focused: $focused, tag: .confirm)
                }

                if let err = vm.errorMessage {
                    ErrorBanner(message: err)
                }

                Button {
                    Task { await vm.signUp() }
                } label: {
                    Group {
                        if vm.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Create Account").font(.headline).foregroundColor(.white)
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

                Text("By creating an account you agree to our Terms of Service and Privacy Policy.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 40)
        }
        .navigationTitle("Create Account")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(red: 0.97, green: 0.98, blue: 1.0).ignoresSafeArea())
        .navigationDestination(isPresented: $vm.showVerifyEmail) {
            VerifyEmailView(vm: vm)
        }
    }
}
