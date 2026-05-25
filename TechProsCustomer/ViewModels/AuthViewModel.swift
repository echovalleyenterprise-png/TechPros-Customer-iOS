import SwiftUI

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var fullName = ""
    @Published var confirmPassword = ""

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    // Sign Up state
    @Published var showVerifyEmail = false
    @Published var pendingEmail = ""

    // MARK: - Sign In

    func signIn() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter your email and password."
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            try await AuthService.shared.signIn(email: email.lowercased().trimmingCharacters(in: .whitespaces), password: password)
        } catch {
            errorMessage = friendlyError(error)
        }
        isLoading = false
    }

    // MARK: - Sign Up

    func signUp() async {
        let trimmedEmail = email.lowercased().trimmingCharacters(in: .whitespaces)
        let trimmedName  = fullName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { errorMessage = "Please enter your name."; return }
        guard !trimmedEmail.isEmpty else { errorMessage = "Please enter your email."; return }
        guard password.count >= 8 else { errorMessage = "Password must be at least 8 characters."; return }
        guard password == confirmPassword else { errorMessage = "Passwords don't match."; return }

        isLoading = true
        errorMessage = nil
        do {
            let result = try await AuthService.shared.signUp(fullName: trimmedName, email: trimmedEmail, password: password)
            if result.requiresEmailConfirmation {
                pendingEmail = trimmedEmail
                showVerifyEmail = true
            }
        } catch {
            errorMessage = friendlyError(error)
        }
        isLoading = false
    }

    // MARK: - Forgot Password

    func forgotPassword() async {
        let trimmed = email.lowercased().trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { errorMessage = "Please enter your email."; return }
        isLoading = true
        errorMessage = nil
        do {
            try await AuthService.shared.forgotPassword(email: trimmed)
            successMessage = "Check your email for a reset link."
        } catch {
            errorMessage = friendlyError(error)
        }
        isLoading = false
    }

    // MARK: - Resend verification

    func resendVerification() async {
        guard !pendingEmail.isEmpty else { return }
        isLoading = true
        do {
            try await AuthService.shared.resendVerification(email: pendingEmail)
            successMessage = "Verification email sent."
        } catch {
            errorMessage = friendlyError(error)
        }
        isLoading = false
    }

    // MARK: - Helpers

    private func friendlyError(_ error: Error) -> String {
        let msg = error.localizedDescription.lowercased()
        if msg.contains("invalid") || msg.contains("credentials") { return "Incorrect email or password." }
        if msg.contains("email not confirmed") || msg.contains("not confirmed") { return "Please verify your email first." }
        if msg.contains("already registered") || msg.contains("already exists") { return "An account with that email already exists." }
        return error.localizedDescription
    }
}
