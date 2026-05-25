import SwiftUI

struct VerifyEmailView: View {
    @ObservedObject var vm: AuthViewModel

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 20) {
                Image(systemName: "envelope.badge.fill")
                    .font(.system(size: 64))
                    .foregroundColor(Color(red: 0.1, green: 0.5, blue: 1.0))

                VStack(spacing: 10) {
                    Text("Check your email")
                        .font(.title2).fontWeight(.bold)
                        .foregroundColor(Color(red: 0.1, green: 0.15, blue: 0.25))

                    Text("We sent a verification link to\n**\(vm.pendingEmail)**\n\nTap the link in the email to activate your account.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }

            Spacer()

            VStack(spacing: 14) {
                if let msg = vm.successMessage {
                    Text(msg).font(.caption).foregroundColor(.green)
                }

                Button {
                    Task { await vm.resendVerification() }
                } label: {
                    Text(vm.isLoading ? "Sending…" : "Resend verification email")
                        .font(.subheadline)
                        .foregroundColor(Color(red: 0.1, green: 0.5, blue: 1.0))
                }
                .disabled(vm.isLoading)
            }
            .padding(.bottom, 48)
        }
        .padding(.horizontal, 32)
        .navigationTitle("Verify Email")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(red: 0.97, green: 0.98, blue: 1.0).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }
}
