import SwiftUI

struct ForgotPasswordView: View {
    @ObservedObject var vm: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var emailFocus: Bool?

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                VStack(spacing: 8) {
                    Image(systemName: "lock.rotation")
                        .font(.system(size: 40))
                        .foregroundColor(Color(red: 0.1, green: 0.5, blue: 1.0))
                        .padding(.top, 20)
                    Text("Reset your password")
                        .font(.title2).fontWeight(.bold)
                        .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))
                    Text("Enter your email and we'll send you a reset link")
                        .font(.subheadline).foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                CustomerField(
                    placeholder: "Email address",
                    text: $vm.email,
                    keyboardType: .emailAddress,
                    focused: $emailFocus,
                    tag: true as Bool?
                )

                if let err = vm.errorMessage {
                    ErrorBanner(message: err)
                }

                if let success = vm.successMessage {
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                        Text(success).font(.subheadline).foregroundColor(.green)
                    }
                    .padding()
                    .background(Color.green.opacity(0.08))
                    .cornerRadius(12)
                }

                Button {
                    Task { await vm.forgotPassword() }
                } label: {
                    Group {
                        if vm.isLoading { ProgressView().tint(.white) }
                        else { Text("Send Reset Link").font(.headline).foregroundColor(.white) }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(Color(red: 0.1, green: 0.5, blue: 1.0))
                    .cornerRadius(16)
                }
                .disabled(vm.isLoading)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 40)
        }
        .navigationTitle("Forgot Password")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(red: 0.97, green: 0.98, blue: 1.0).ignoresSafeArea())
    }
}
